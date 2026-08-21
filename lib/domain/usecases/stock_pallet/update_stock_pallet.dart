// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/update_stock_pallet.dart
//
// FUNGSI:
// Use Case untuk EDIT / UPDATE Stock Pallet.
//
// TUGAS:
// 1. Validasi input pallet.
// 2. Memastikan PLU ada di Master Item.
// 3. Mengambil data Master Item berdasarkan PLU.
// 4. Mempertahankan Tear dan Stack aktual dari operator.
// 5. Menghitung Qty CTN.
// 6. Menghitung Qty PCS.
// 7. Menentukan apakah Tear dan Stack sesuai Master.
// 8. Mengirim data final ke StockPalletRepository.
//
// ALUR:
//
// UI
//   ↓
// UpdateStockPallet
//   ├── ProductRepository
//   │       ↓
//   │   Master Item
//   │
//   └── StockPalletRepository
//           ↓
//        SQLite
//
// ============================================================

import '../../entities/product.dart';
import '../../entities/stock_pallet.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/stock_pallet_repository.dart';

// ============================================================
// CLASS
// ============================================================

class UpdateStockPallet {
  // ==========================================================
  // REPOSITORY STOCK PALLET
  // ==========================================================

  final StockPalletRepository stockPalletRepository;

  // ==========================================================
  // REPOSITORY MASTER ITEM
  // ==========================================================

  final ProductRepository productRepository;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const UpdateStockPallet({
    required this.stockPalletRepository,
    required this.productRepository,
  });

  // ==========================================================
  // CALL
  // ==========================================================

  Future<void> call(StockPallet pallet) async {
    // --------------------------------------------------------
    // VALIDASI LOCATION
    // --------------------------------------------------------

    final locationCode = pallet.locationCode.trim();

    if (locationCode.isEmpty) {
      throw ArgumentError('Location Code tidak boleh kosong.');
    }

    // --------------------------------------------------------
    // VALIDASI PLU
    // --------------------------------------------------------

    final plu = pallet.plu.trim();

    if (plu.isEmpty) {
      throw ArgumentError('PLU tidak boleh kosong.');
    }

    // --------------------------------------------------------
    // VALIDASI TEAR
    // --------------------------------------------------------

    if (pallet.tear <= 0) {
      throw ArgumentError('Tear harus lebih besar dari 0.');
    }

    // --------------------------------------------------------
    // VALIDASI STACK
    // --------------------------------------------------------

    if (pallet.stack <= 0) {
      throw ArgumentError('Stack harus lebih besar dari 0.');
    }

    // --------------------------------------------------------
    // CARI MASTER ITEM
    // --------------------------------------------------------
    //
    // PLU operator digunakan untuk mencari Master Item.
    // --------------------------------------------------------

    final Product? product = await productRepository.getProductByPlu(plu);

    // --------------------------------------------------------
    // MASTER TIDAK DITEMUKAN
    // --------------------------------------------------------
    //
    // Jangan melakukan update database jika PLU tidak valid.
    // --------------------------------------------------------

    if (product == null) {
      throw StateError('PLU $plu tidak ditemukan di Master Item.');
    }

    // --------------------------------------------------------
    // VALIDASI CONV2 MASTER
    // --------------------------------------------------------

    if (product.conv2 <= 0) {
      throw StateError('Conv2 Master Item untuk PLU $plu tidak valid.');
    }

    // --------------------------------------------------------
    // QTY CTN AKTUAL
    // --------------------------------------------------------
    //
    // PENTING:
    //
    // Qty CTN berasal dari jumlah fisik/lapangan.
    //
    // Tear dan Stack TIDAK digunakan untuk menghitung Qty CTN.
    // Tear dan Stack hanya digunakan untuk membandingkan
    // kondisi pallet aktual dengan Master Item.
    //
    // Contoh:
    //
    // Master:
    //   Tear  = 12
    //   Stack = 6
    //
    // Aktual:
    //   Tear  = 25
    //   Stack = 6
    //   Qty CTN = 150
    //
    // Hasil:
    //   Qty CTN = 150
    //   Mismatch = true
    //
    // --------------------------------------------------------

    final qtyCtn = pallet.qtyCtn;

    if (qtyCtn < 0) {
      throw ArgumentError('Qty CTN tidak boleh kurang dari 0.');
    }

    // --------------------------------------------------------
    // HITUNG QTY PCS
    // --------------------------------------------------------
    //
    // Qty PCS selalu mengikuti Qty CTN aktual.
    //
    // Rumus:
    //
    // Qty PCS = Qty CTN × Conv2
    // --------------------------------------------------------

    final qtyPcs = qtyCtn * product.conv2;

    // --------------------------------------------------------
    // CEK KESESUAIAN MASTER
    // --------------------------------------------------------
    //
    // Tear dan Stack aktual dibandingkan dengan Master Item.
    //
    // true:
    //   keduanya sama.
    //
    // false:
    //   salah satu atau keduanya berbeda.
    // --------------------------------------------------------

    final sesuaiMaster =
        pallet.tear == product.masterTear &&
        pallet.stack == product.masterStack;

    // --------------------------------------------------------
    // BUAT DATA PALLET FINAL
    // --------------------------------------------------------
    //
    // Data master diambil dari Product.
    //
    // Tear dan Stack tetap menggunakan nilai aktual operator.
    // --------------------------------------------------------

    final updatedPallet = StockPallet(
      locationCode: locationCode,

      // ------------------------------------------------------
      // MASTER ITEM
      // ------------------------------------------------------
      plu: product.plu,
      barcode: product.barcode,
      description: product.description,
      price: product.price,
      returHari: product.returHari,
      conv2: product.conv2,
      type: product.type,

      // ------------------------------------------------------
      // DATA AKTUAL PALLET
      // ------------------------------------------------------
      tear: pallet.tear,
      stack: pallet.stack,

      // ------------------------------------------------------
      // QUANTITY HASIL PERHITUNGAN SISTEM
      // ------------------------------------------------------
      qtyCtn: qtyCtn,
      qtyPcs: qtyPcs,

      // ------------------------------------------------------
      // TANGGAL
      // ------------------------------------------------------
      expiredDate: pallet.expiredDate,
      inputDate: pallet.inputDate,

      // ------------------------------------------------------
      // OPERATOR
      // ------------------------------------------------------
      operatorNik: pallet.operatorNik.trim(),

      // ------------------------------------------------------
      // HASIL PERBANDINGAN DENGAN MASTER
      // ------------------------------------------------------
      sesuaiMaster: sesuaiMaster,
    );

    // --------------------------------------------------------
    // UPDATE DATABASE
    // --------------------------------------------------------
    //
    // Database hanya disentuh setelah seluruh validasi berhasil.
    // --------------------------------------------------------

    await stockPalletRepository.update(updatedPallet);
  }
}

// ============================================================
// FILE:
// lib/domain/usecases/map_stock_pallet_import.dart
//
// FUNGSI:
// Mengubah satu baris data import Stock Pallet menjadi
// Domain Entity StockPallet.
//
// ATURAN QTY IMPORT:
// ------------------------------------------------------------
// Qty CTN TIDAK dihitung dari Tear × Stack.
//
// Qty CTN berasal dari:
//     qty_so
//
// Qty PCS dihitung dari:
//     qty_so × CONV2
//
// Tear Aktual dan Stack Aktual hanya digunakan untuk
// membandingkan kondisi fisik pallet dengan Master Item.
//
// Contoh:
//
// MASTER:
// Tear  = 25
// Stack = 6
//
// FISIK:
// Tear Aktual  = 12
// Stack Aktual = 6
//
// IMPORT:
// Qty SO = 150
//
// HASIL:
// Qty CTN      = 150
// Qty PCS      = 150 × CONV2
// sesuaiMaster = false
//
// Artinya:
// 🟠 MISMATCH tidak mengubah Qty CTN.
//
// ============================================================

import '../entities/product.dart';
import '../entities/stock_pallet.dart';

class MapStockPalletImport {
  const MapStockPalletImport();

  // ==========================================================
  // EXECUTE
  // ==========================================================
  //
  // Excel row
  //     ↓
  // validasi data
  //     ↓
  // Master Item
  //     ↓
  // StockPallet
  //
  // Sumber data:
  //
  // Identitas barang:
  //   Product / Master Item
  //
  // Qty:
  //   qty_so dari Excel
  //
  // Kondisi fisik:
  //   tear_aktual
  //   stack
  //
  // Kesesuaian:
  //   tear_aktual vs masterTear
  //   stack vs masterStack
  //
  // ==========================================================

  StockPallet execute({
    required Map<String, dynamic> row,
    required Product product,
    required String operatorNik,
    DateTime? inputDate,
  }) {
    // --------------------------------------------------------
    // LOCATION
    // --------------------------------------------------------

    final locationCode = _requiredString(row, 'lokasi');

    // --------------------------------------------------------
    // PLU
    // --------------------------------------------------------

    final excelPlu = _requiredString(row, 'plu');

    if (excelPlu != product.plu.trim()) {
      throw FormatException(
        'PLU Excel "$excelPlu" tidak sesuai dengan '
        'Master Item "${product.plu}".',
      );
    }

    // --------------------------------------------------------
    // QTY SO
    // --------------------------------------------------------
    //
    // PENTING:
    //
    // qty_so adalah sumber kebenaran Qty CTN ketika import.
    //
    // JANGAN menggunakan:
    //
    // tear × stack
    //
    // untuk menentukan Qty CTN.
    //
    // --------------------------------------------------------

    final qtySo = _requiredInt(row, 'qty_so');

    if (qtySo < 0) {
      throw const FormatException('Qty SO tidak boleh negatif.');
    }

    // --------------------------------------------------------
    // TEAR AKTUAL
    // --------------------------------------------------------
    //
    // Nilai kondisi fisik pallet.
    //
    // Tidak digunakan untuk menghitung Qty CTN.
    // --------------------------------------------------------

    final tear = _requiredInt(row, 'tear_aktual');

    if (tear <= 0) {
      throw const FormatException('Tear aktual harus lebih besar dari 0.');
    }

    // --------------------------------------------------------
    // STACK AKTUAL
    // --------------------------------------------------------
    //
    // Nilai kondisi fisik pallet.
    //
    // Tidak digunakan untuk menghitung Qty CTN.
    // --------------------------------------------------------

    final stack = _requiredInt(row, 'stack');

    if (stack <= 0) {
      throw const FormatException('Stack aktual harus lebih besar dari 0.');
    }

    // --------------------------------------------------------
    // QTY CTN
    // --------------------------------------------------------
    //
    // ATURAN BISNIS FINAL:
    //
    // Qty CTN = Qty SO dari data lapangan.
    //
    // Contoh:
    //
    // qty_so = 150
    //
    // Maka:
    //
    // qtyCtn = 150
    //
    // BUKAN:
    //
    // tear × stack
    //
    // BUKAN:
    //
    // masterTear × masterStack
    // --------------------------------------------------------

    final qtyCtn = qtySo;

    // --------------------------------------------------------
    // QTY PCS
    // --------------------------------------------------------
    //
    // Qty PCS mengikuti Qty CTN aktual dari Qty SO.
    //
    // Rumus:
    //
    // Qty PCS = Qty CTN × CONV2
    // --------------------------------------------------------

    final qtyPcs = qtyCtn * product.conv2;

    // --------------------------------------------------------
    // EXPIRED DATE
    // --------------------------------------------------------

    final expiredDate = _requiredDateTime(row, 'exp_date');

    // --------------------------------------------------------
    // VALIDASI TEAR / STACK TERHADAP MASTER
    // --------------------------------------------------------
    //
    // Ini HANYA menentukan apakah kondisi fisik pallet
    // sesuai dengan Master Item.
    //
    // Tidak mengubah:
    //
    // - qtyCtn
    // - qtyPcs
    //
    // Jika berbeda:
    //
    // sesuaiMaster = false
    //
    // UI dapat menampilkan:
    //
    // 🟠 MISMATCH
    // --------------------------------------------------------

    final sesuaiMaster =
        tear == product.masterTear && stack == product.masterStack;

    // --------------------------------------------------------
    // OPERATOR NIK
    // --------------------------------------------------------

    final normalizedOperatorNik = operatorNik.trim();

    if (normalizedOperatorNik.isEmpty) {
      throw const FormatException('Operator NIK wajib diisi.');
    }

    // --------------------------------------------------------
    // CREATE DOMAIN ENTITY
    // --------------------------------------------------------

    return StockPallet(
      locationCode: locationCode,
      plu: product.plu.trim(),
      barcode: product.barcode.trim(),
      description: product.description.trim(),
      price: product.price,
      returHari: product.returHari,
      conv2: product.conv2,
      type: product.type.trim(),

      // Kondisi fisik aktual.
      tear: tear,
      stack: stack,

      // Qty berasal dari Qty SO.
      qtyCtn: qtyCtn,
      qtyPcs: qtyPcs,

      expiredDate: expiredDate,
      inputDate: inputDate ?? DateTime.now(),
      operatorNik: normalizedOperatorNik,

      // Hanya status kesesuaian Master.
      sesuaiMaster: sesuaiMaster,
    );
  }

  // ==========================================================
  // REQUIRED STRING
  // ==========================================================

  String _requiredString(Map<String, dynamic> row, String key) {
    final value = row[key];

    if (value == null) {
      throw FormatException('Kolom "$key" wajib diisi.');
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      throw FormatException('Kolom "$key" tidak boleh kosong.');
    }

    return result;
  }

  // ==========================================================
  // REQUIRED INT
  // ==========================================================

  int _requiredInt(Map<String, dynamic> row, String key) {
    final value = row[key];

    if (value == null) {
      throw FormatException('Kolom "$key" wajib diisi.');
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      if (!value.isFinite) {
        throw FormatException('Kolom "$key" harus berupa angka.');
      }

      return value.toInt();
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      throw FormatException('Kolom "$key" wajib diisi.');
    }

    final parsedInt = int.tryParse(text);

    if (parsedInt != null) {
      return parsedInt;
    }

    final parsedDouble = double.tryParse(text);

    if (parsedDouble != null && parsedDouble.isFinite) {
      return parsedDouble.toInt();
    }

    throw FormatException('Kolom "$key" harus berupa angka.');
  }

  // ==========================================================
  // REQUIRED DATETIME
  // ==========================================================

  DateTime _requiredDateTime(Map<String, dynamic> row, String key) {
    final value = row[key];

    if (value == null) {
      throw FormatException('Kolom "$key" wajib diisi.');
    }

    if (value is DateTime) {
      return value;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      throw FormatException('Kolom "$key" wajib diisi.');
    }

    final parsed = DateTime.tryParse(text);

    if (parsed == null) {
      throw FormatException('Kolom "$key" harus berupa tanggal yang valid.');
    }

    return parsed;
  }
}

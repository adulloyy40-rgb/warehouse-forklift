import '../entities/product.dart';
import '../entities/stock_pallet.dart';
import '../repositories/product_repository.dart';
import '../repositories/stock_pallet_repository.dart';
import 'map_stock_pallet_import.dart';

class ImportStockPalletToDatabaseResult {
  final int successCount;
  final int failedCount;
  final List<String> errors;

  const ImportStockPalletToDatabaseResult({
    required this.successCount,
    required this.failedCount,
    required this.errors,
  });

  bool get isSuccess => failedCount == 0;
}

class ImportStockPalletToDatabase {
  final ProductRepository productRepository;
  final StockPalletRepository stockPalletRepository;
  final MapStockPalletImport mapper;

  const ImportStockPalletToDatabase({
    required this.productRepository,
    required this.stockPalletRepository,
    this.mapper = const MapStockPalletImport(),
  });

  Future<ImportStockPalletToDatabaseResult> execute({
    required List<Map<String, dynamic>> rows,
    required String operatorNik,
  }) async {
    var successCount = 0;
    var failedCount = 0;

    final errors = <String>[];

    // ==========================================================
    // 1. LOAD MASTER BARANG SEKALI SAJA
    // ==========================================================
    //
    // Sebelumnya getProductByPlu() dipanggil untuk setiap baris.
    //
    // Contoh 1.863 baris:
    //
    // 1.863 x baca Excel
    //
    // Ini sangat berat.
    //
    // Sekarang Master Barang dibaca SATU KALI.
    // ==========================================================

    final products = await productRepository.getAllProducts();

    // ==========================================================
    // 2. BUAT INDEX PLU DI MEMORY
    // ==========================================================
    //
    // PLU → Product
    //
    // Dengan Map, pencarian PLU menjadi sangat cepat.
    // Tidak perlu scan seluruh List<Product> berulang kali.
    // ==========================================================

    final productByPlu = <String, Product>{};

    for (final product in products) {
      final plu = product.plu.trim();

      if (plu.isNotEmpty) {
        productByPlu[plu] = product;
      }
    }

    // ==========================================================
    // 3. LOAD STOCK PALLET YANG SUDAH ADA SEKALI
    // ==========================================================
    //
    // Sebelumnya:
    //
    // setiap baris →
    // findByLocationCode() →
    // SQLite
    //
    // Sekarang database dibaca SATU KALI.
    // ==========================================================

    final existingPallets = await stockPalletRepository.getAll();

    final existingLocations = <String>{};

    for (final pallet in existingPallets) {
      final location = pallet.locationCode.trim();

      if (location.isNotEmpty) {
        existingLocations.add(location);
      }
    }

    // ==========================================================
    // 4. SIAPKAN DATA UNTUK BATCH INSERT
    // ==========================================================
    //
    // Semua pallet yang valid dikumpulkan terlebih dahulu.
    //
    // Database belum disentuh satu per satu.
    // ==========================================================

    final palletsToSave = <StockPallet>[];

    // Lokasi yang muncul di file import.
    //
    // Digunakan untuk mendeteksi duplicate location
    // di dalam file Excel itu sendiri.
    final importLocations = <String>{};

    // ==========================================================
    // 5. VALIDASI + MAPPING DI MEMORY
    // ==========================================================

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final rowNumber = i + 2;

      try {
        final plu = row['plu']?.toString().trim() ?? '';

        if (plu.isEmpty) {
          throw const FormatException('PLU kosong.');
        }

        // ------------------------------------------------------
        // Cari Master Barang dari Map.
        // ------------------------------------------------------

        final product = productByPlu[plu];

        if (product == null) {
          throw FormatException('PLU $plu tidak ditemukan di Master Barang.');
        }

        // ------------------------------------------------------
        // Mapping Excel → StockPallet.
        // ------------------------------------------------------

        final pallet = mapper.execute(
          row: row,
          product: product,
          operatorNik: operatorNik,
        );

        final location = pallet.locationCode.trim();

        if (location.isEmpty) {
          throw const FormatException('Location kosong.');
        }

        // ------------------------------------------------------
        // Cek lokasi yang sudah ada di database.
        //
        // Tidak perlu query SQLite.
        // Cukup cek Set di memory.
        // ------------------------------------------------------

        if (existingLocations.contains(location)) {
          throw StateError('Lokasi $location sudah memiliki pallet.');
        }

        // ------------------------------------------------------
        // Cek duplicate location di file Excel.
        // ------------------------------------------------------

        if (!importLocations.add(location)) {
          throw StateError(
            'Lokasi $location muncul lebih dari satu kali '
            'di file import.',
          );
        }

        palletsToSave.add(pallet);

        successCount++;
      } catch (e) {
        failedCount++;

        errors.add('Baris $rowNumber: ${e.toString()}');
      }
    }

    // ==========================================================
    // 6. BATCH INSERT
    // ==========================================================
    //
    // Hanya SATU operasi repository.
    //
    // Repository akan meneruskannya ke DAO batch insert.
    //
    // Ini jauh lebih ringan daripada:
    //
    // save()
    // save()
    // save()
    // save()
    // ...
    //
    // sampai 1.863 kali.
    // ==========================================================

    if (palletsToSave.isNotEmpty) {
      try {
        await stockPalletRepository.saveAll(palletsToSave);
      } catch (e) {
        // ------------------------------------------------------
        // Jika batch database gagal, data tidak boleh dianggap
        // berhasil tersimpan.
        // ------------------------------------------------------

        failedCount += successCount;
        successCount = 0;

        errors.add('Batch insert gagal: ${e.toString()}');
      }
    }

    // ==========================================================
    // 7. HASIL IMPORT
    // ==========================================================

    return ImportStockPalletToDatabaseResult(
      successCount: successCount,
      failedCount: failedCount,
      errors: List.unmodifiable(errors),
    );
  }
}

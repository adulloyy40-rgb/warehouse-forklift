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

    for (var i = 0; i < rows.length; i++) {
      final row = rows[i];
      final rowNumber = i + 2;

      try {
        final plu = row['plu']?.toString().trim() ?? '';

        if (plu.isEmpty) {
          throw const FormatException(
            'PLU kosong.',
          );
        }

        final product =
            await productRepository.getProductByPlu(plu);

        if (product == null) {
          throw FormatException(
            'PLU $plu tidak ditemukan di Master Barang.',
          );
        }

        final pallet = mapper.execute(
          row: row,
          product: product,
          operatorNik: operatorNik,
        );

        final existing =
            await stockPalletRepository.findByLocationCode(
          pallet.locationCode,
        );

        if (existing != null) {
          throw StateError(
            'Lokasi ${pallet.locationCode} sudah memiliki pallet.',
          );
        }

        await stockPalletRepository.save(pallet);

        successCount++;
      } catch (e) {
        failedCount++;

        errors.add(
          'Baris $rowNumber: ${e.toString()}',
        );
      }
    }

    return ImportStockPalletToDatabaseResult(
      successCount: successCount,
      failedCount: failedCount,
      errors: List.unmodifiable(errors),
    );
  }
}

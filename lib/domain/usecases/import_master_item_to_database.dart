import 'dart:developer' as developer;

import '../../data/database/daos/product_dao.dart';

class ImportMasterItemResult {
  final int successCount;
  final int failedCount;
  final List<String> errors;

  const ImportMasterItemResult({
    required this.successCount,
    required this.failedCount,
    required this.errors,
  });

  bool get isSuccess => failedCount == 0;
}

class ImportMasterItemToDatabase {
  final ProductDao productDao;

  const ImportMasterItemToDatabase({
    required this.productDao,
  });

  Future<ImportMasterItemResult> execute({
    required List<Map<String, dynamic>> rows,
  }) async {
    final stopwatch = Stopwatch()..start();

    final errors = <String>[];
    final validRows = <Map<String, dynamic>>[];

    final seenPlu = <String>{};
    final seenBarcode = <String>{};

    for (var i = 0; i < rows.length; i++) {
      final rowNumber = i + 1;
      final row = rows[i];

      try {
        final barcode = row['barcode']?.toString().trim() ?? '';
        final plu = row['plu']?.toString().trim() ?? '';
        final description = row['description']?.toString().trim() ?? '';

        if (barcode.isEmpty) {
          throw const FormatException('Barcode kosong.');
        }

        if (plu.isEmpty) {
          throw const FormatException('PLU kosong.');
        }

        if (description.isEmpty) {
          throw const FormatException('Description kosong.');
        }

        if (!seenBarcode.add(barcode)) {
          throw FormatException(
            'Barcode duplikat di file Excel: $barcode.',
          );
        }

        if (!seenPlu.add(plu)) {
          throw FormatException(
            'PLU duplikat di file Excel: $plu.',
          );
        }

        final price = _toDouble(row['price']);
        final returHari = _toInt(row['returHari']);
        final conv2 = _toInt(row['conv2']);
        final type = row['type']?.toString().trim() ?? '';
        final masterTear = _toInt(row['masterTear']);
        final masterStack = _toInt(row['masterStack']);

        validRows.add({
          'barcode': barcode,
          'plu': plu,
          'description': description,
          'price': price,
          'returHari': returHari,
          'conv2': conv2,
          'type': type,
          'masterTear': masterTear,
          'masterStack': masterStack,
        });
      } catch (e) {
        errors.add('Baris $rowNumber: $e');
      }
    }

    // Jangan menyentuh database jika validasi Excel gagal.
    if (errors.isNotEmpty) {
      stopwatch.stop();

      developer.log(
        'IMPORT MASTER ITEM DIBATALKAN | '
        'rows=${rows.length} | errors=${errors.length} | '
        'elapsed=${stopwatch.elapsedMilliseconds} ms',
        name: 'MasterItemImport',
      );

      return ImportMasterItemResult(
        successCount: 0,
        failedCount: errors.length,
        errors: errors,
      );
    }

    // Semua data sudah valid.
    // Sekarang baru masuk ke database.
    var successCount = 0;

    try {
      await productDao.insertProductsBatch(validRows);
      successCount = validRows.length;
    } catch (e) {
      errors.add('Gagal menyimpan Master Item ke SQLite: $e');
    }

    stopwatch.stop();

    developer.log(
      'IMPORT MASTER ITEM | '
      'success=$successCount | '
      'errors=${errors.length} | '
      'elapsed=${stopwatch.elapsedMilliseconds} ms',
      name: 'MasterItemImport',
    );

    return ImportMasterItemResult(
      successCount: successCount,
      failedCount: errors.length,
      errors: errors,
    );
  }

  int _toInt(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return 0;
    }

    return int.tryParse(text) ??
        double.tryParse(text)?.toInt() ??
        0;
  }

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return 0;
    }

    return double.tryParse(text) ?? 0;
  }
}

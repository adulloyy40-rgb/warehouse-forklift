import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/domain/validators/stock_pallet_import_validator.dart';

void main() {
  late StockPalletImportValidator validator;

  setUp(() {
    validator = const StockPalletImportValidator();
  });

  group('StockPalletImportValidator', () {
    // ========================================================
    // DATA VALID
    // ========================================================

    test('Data lengkap harus valid', () {
      final data = {
        'lokasi': '8001101',
        'plu': '123456',
        'desc': 'Contoh Barang',
        'conv2': 24,
        'qty_so': 10,
        'stack': 5,
        'tear_aktual': 2,
        'exp_date': '2026-12-31',
      };

      expect(validator.validate(data), isTrue);
    });

    // ========================================================
    // LOKASI
    // ========================================================

    test('Lokasi kosong harus invalid', () {
      final data = {
        'lokasi': '',
        'plu': '123456',
        'conv2': 24,
        'qty_so': 10,
        'stack': 5,
        'tear_aktual': 2,
        'exp_date': '2026-12-31',
      };

      expect(validator.validate(data), isFalse);
    });

    // ========================================================
    // PLU
    // ========================================================

    test('PLU kosong harus invalid', () {
      final data = {
        'lokasi': '8001101',
        'plu': '',
        'conv2': 24,
        'qty_so': 10,
        'stack': 5,
        'tear_aktual': 2,
        'exp_date': '2026-12-31',
      };

      expect(validator.validate(data), isFalse);
    });

    // ========================================================
    // CONV2
    // ========================================================

    test('CONV2 nol harus invalid', () {
      final data = {
        'lokasi': '8001101',
        'plu': '123456',
        'conv2': 0,
        'qty_so': 10,
        'stack': 5,
        'tear_aktual': 2,
        'exp_date': '2026-12-31',
      };

      expect(validator.validate(data), isFalse);
    });

    // ========================================================
    // QTY SO
    // ========================================================

    test('QTY SO negatif harus invalid', () {
      final data = {
        'lokasi': '8001101',
        'plu': '123456',
        'conv2': 24,
        'qty_so': -1,
        'stack': 5,
        'tear_aktual': 2,
        'exp_date': '2026-12-31',
      };

      expect(validator.validate(data), isFalse);
    });

    // ========================================================
    // STACK
    // ========================================================

    test('STACK nol harus invalid', () {
      final data = {
        'lokasi': '8001101',
        'plu': '123456',
        'conv2': 24,
        'qty_so': 10,
        'stack': 0,
        'tear_aktual': 2,
        'exp_date': '2026-12-31',
      };

      expect(validator.validate(data), isFalse);
    });

    // ========================================================
    // TEAR AKTUAL
    // ========================================================

    test('TEAR AKTUAL nol harus invalid', () {
      final data = {
        'lokasi': '8001101',
        'plu': '123456',
        'conv2': 24,
        'qty_so': 10,
        'stack': 5,
        'tear_aktual': 0,
        'exp_date': '2026-12-31',
      };

      expect(validator.validate(data), isFalse);
    });

    // ========================================================
    // EXP DATE
    // ========================================================

    test('EXP DATE tidak valid harus invalid', () {
      final data = {
        'lokasi': '8001101',
        'plu': '123456',
        'conv2': 24,
        'qty_so': 10,
        'stack': 5,
        'tear_aktual': 2,
        'exp_date': 'tanggal-tidak-valid',
      };

      expect(validator.validate(data), isFalse);
    });

    // ========================================================
    // EXP DATE DateTime
    // ========================================================

    test('EXP DATE berupa DateTime harus valid', () {
      final data = {
        'lokasi': '8001101',
        'plu': '123456',
        'conv2': 24,
        'qty_so': 10,
        'stack': 5,
        'tear_aktual': 2,
        'exp_date': DateTime(2026, 12, 31),
      };

      expect(validator.validate(data), isTrue);
    });
  });
}

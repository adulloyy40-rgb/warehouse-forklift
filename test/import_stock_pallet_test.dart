// ============================================================
// FILE:
// test/import_stock_pallet_test.dart
// ============================================================
//
// UNIT TEST:
// ImportStockPallet
//
// TEST:
// 1. Semua data valid.
// 2. Data invalid dipisahkan.
// 3. Counter hasil benar.
// 4. Data kosong.
// 5. isSuccess.
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/domain/usecases/import_stock_pallet.dart';
import 'package:warehouse_forklift/domain/validators/stock_pallet_import_validator.dart';

void main() {
  late ImportStockPallet useCase;

  setUp(() {
    useCase = ImportStockPallet(validator: StockPalletImportValidator());
  });

  // ==========================================================
  // DATA VALID
  // ==========================================================

  Map<String, dynamic> validRow({
    String lokasi = '8001101',
    String plu = '123456',
    String desc = 'Barang Test',
    int conv2 = 24,
    int qtySo = 10,
    int stack = 2,
    int tearAktual = 5,
    String expDate = '2026-12-31',
  }) {
    return {
      'lokasi': lokasi,
      'plu': plu,
      'desc': desc,
      'conv2': conv2,
      'qty_so': qtySo,
      'stack': stack,
      'tear_aktual': tearAktual,
      'exp_date': expDate,
    };
  }

  // ==========================================================
  // TEST 1
  // ==========================================================

  test('Semua data valid masuk ke validData', () {
    final rows = [validRow(), validRow(lokasi: '8001102')];

    final result = useCase.execute(rows);

    expect(result.total, 2);
    expect(result.validCount, 2);
    expect(result.invalidCount, 0);

    expect(result.validData.length, 2);
    expect(result.invalidData, isEmpty);

    expect(result.isSuccess, isTrue);
  });

  // ==========================================================
  // TEST 2
  // ==========================================================

  test('Data invalid dipisahkan ke invalidData', () {
    final rows = [validRow(), validRow(lokasi: '')];

    final result = useCase.execute(rows);

    expect(result.total, 2);
    expect(result.validCount, 1);
    expect(result.invalidCount, 1);

    expect(result.validData.length, 1);
    expect(result.invalidData.length, 1);

    expect(result.isSuccess, isFalse);
  });

  // ==========================================================
  // TEST 3
  // ==========================================================

  test('Counter hasil harus sesuai jumlah data', () {
    final rows = [
      validRow(lokasi: '8001101'),
      validRow(lokasi: '8001102'),
      validRow(lokasi: ''),
      validRow(lokasi: '8001103'),
    ];

    final result = useCase.execute(rows);

    expect(result.total, 4);
    expect(result.validCount, 3);
    expect(result.invalidCount, 1);
  });

  // ==========================================================
  // TEST 4
  // ==========================================================

  test('Data kosong menghasilkan result kosong', () {
    final result = useCase.execute([]);

    expect(result.total, 0);
    expect(result.validCount, 0);
    expect(result.invalidCount, 0);

    expect(result.validData, isEmpty);
    expect(result.invalidData, isEmpty);

    expect(result.isSuccess, isTrue);
  });

  // ==========================================================
  // TEST 5
  // ==========================================================

  test('isSuccess false jika terdapat data invalid', () {
    final rows = [validRow(), validRow(lokasi: '')];

    final result = useCase.execute(rows);

    expect(result.isSuccess, isFalse);
  });
}

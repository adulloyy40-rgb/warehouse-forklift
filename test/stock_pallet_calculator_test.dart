// ============================================================
// FILE:
// test/stock_pallet_calculator_test.dart
// ============================================================
//
// FUNGSI:
// Menguji StockPalletCalculator.
//
// Test memastikan:
//
// 1. Qty CTN dihitung dengan benar.
// 2. Qty PCS dihitung dengan benar.
// 3. Hasil perhitungan dapat digunakan oleh aplikasi.
//
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/domain/services/stock_pallet_calculator.dart';


void main() {
  // ==========================================================
  // TEST 1
  //
  // Tear = 4
  // Stack = 5
  //
  // Qty CTN = 4 × 5
  //         = 20
  // ==========================================================

  test(
    'Qty CTN harus dihitung dari Tear × Stack',
    () {
      final result = StockPalletCalculator.calculate(
        tear: 4,
        stack: 5,
        conv2: 12,
      );

      expect(result.qtyCtn, 20);
    },
  );


  // ==========================================================
  // TEST 2
  //
  // Qty CTN = 20
  // CONV2 = 12
  //
  // Qty PCS = 20 × 12
  //         = 240
  // ==========================================================

  test(
    'Qty PCS harus dihitung dari Qty CTN × CONV2',
    () {
      final result = StockPalletCalculator.calculate(
        tear: 4,
        stack: 5,
        conv2: 12,
      );

      expect(result.qtyPcs, 240);
    },
  );


  // ==========================================================
  // TEST 3
  //
  // Menguji contoh berbeda.
  //
  // Tear = 3
  // Stack = 4
  // CONV2 = 24
  //
  // Qty CTN = 3 × 4
  //         = 12
  //
  // Qty PCS = 12 × 24
  //         = 288
  // ==========================================================

  test(
    'Perhitungan pallet kedua harus menghasilkan 12 CTN dan 288 PCS',
    () {
      final result = StockPalletCalculator.calculate(
        tear: 3,
        stack: 4,
        conv2: 24,
      );

      expect(result.qtyCtn, 12);
      expect(result.qtyPcs, 288);
    },
  );


  // ==========================================================
  // TEST 4
  //
  // Jika Tear = 0,
  // maka Qty CTN dan Qty PCS harus 0.
  // ==========================================================

  test(
    'Jika Tear 0 maka Qty CTN dan Qty PCS harus 0',
    () {
      final result = StockPalletCalculator.calculate(
        tear: 0,
        stack: 5,
        conv2: 12,
      );

      expect(result.qtyCtn, 0);
      expect(result.qtyPcs, 0);
    },
  );


  // ==========================================================
  // TEST 5
  //
  // Jika Stack = 0,
  // maka Qty CTN dan Qty PCS harus 0.
  // ==========================================================

  test(
    'Jika Stack 0 maka Qty CTN dan Qty PCS harus 0',
    () {
      final result = StockPalletCalculator.calculate(
        tear: 5,
        stack: 0,
        conv2: 12,
      );

      expect(result.qtyCtn, 0);
      expect(result.qtyPcs, 0);
    },
  );


  // ==========================================================
  // TEST 6
  //
  // Jika CONV2 = 0,
  // Qty CTN tetap dihitung,
  // tetapi Qty PCS menjadi 0.
  // ==========================================================

  test(
    'Jika CONV2 0 maka Qty PCS harus 0',
    () {
      final result = StockPalletCalculator.calculate(
        tear: 4,
        stack: 5,
        conv2: 0,
      );

      expect(result.qtyCtn, 20);
      expect(result.qtyPcs, 0);
    },
  );
}

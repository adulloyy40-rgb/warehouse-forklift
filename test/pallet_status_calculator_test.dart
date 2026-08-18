// ============================================================
// FILE:
// test/pallet_status_calculator_test.dart
//
// FUNGSI:
// Unit test untuk PalletStatusCalculator.
//
// BUSINESS RULE YANG DIUJI:
//
// Expired Date : 15 Maret 2027
// Retur Hari   : 60
//
// 13 Januari 2027 → NORMAL
// 14 Januari 2027 → NEAR RETURN
// 14 Maret 2027   → NEAR RETURN
// 15 Maret 2027   → EXPIRED
// Setelahnya      → EXPIRED
//
// Selain itu diuji:
// - Tear mismatch
// - Stack mismatch
// - Kombinasi expiry + mismatch
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/domain/entities/stock_pallet.dart';
import 'package:warehouse_forklift/domain/services/pallet_status_calculator.dart';

void main() {
  const calculator = PalletStatusCalculator();

  // ==========================================================
  // TEST DATA
  // ==========================================================

  StockPallet createPallet({
    required DateTime expiredDate,
    int returHari = 60,
    int tear = 10,
    int stack = 5,
    bool sesuaiMaster = true,
  }) {
    return StockPallet(
      locationCode: '8001101',
      plu: '12345',
      barcode: '8999999999999',
      description: 'TEST BARANG',
      price: 10000,
      returHari: returHari,
      conv2: 24,
      type: 'TEST',
      tear: tear,
      stack: stack,
      qtyCtn: tear * stack,
      qtyPcs: tear * stack * 24,
      expiredDate: expiredDate,
      inputDate: DateTime(2026, 11, 1),
      operatorNik: 'TEST001',
      sesuaiMaster: sesuaiMaster,
    );
  }

  // ==========================================================
  // EXPIRY STATUS
  // ==========================================================

  group('PalletStatusCalculator - Expiry Status', () {
    final expiredDate = DateTime(2027, 3, 15);

    test('tanggal sebelum periode retur harus NORMAL', () {
      final pallet = createPallet(expiredDate: expiredDate);

      final result = calculator.calculate(pallet, now: DateTime(2027, 1, 13));

      expect(result.expiryStatus, PalletExpiryStatus.normal);
    });

    test('tanggal mulai periode retur harus NEAR RETURN', () {
      final pallet = createPallet(expiredDate: expiredDate);

      final result = calculator.calculate(pallet, now: DateTime(2027, 1, 14));

      expect(result.expiryStatus, PalletExpiryStatus.nearReturn);
    });

    test('tanggal sebelum expired harus NEAR RETURN', () {
      final pallet = createPallet(expiredDate: expiredDate);

      final result = calculator.calculate(pallet, now: DateTime(2027, 3, 14));

      expect(result.expiryStatus, PalletExpiryStatus.nearReturn);
    });

    test('tanggal expired harus EXPIRED', () {
      final pallet = createPallet(expiredDate: expiredDate);

      final result = calculator.calculate(pallet, now: DateTime(2027, 3, 15));

      expect(result.expiryStatus, PalletExpiryStatus.expired);
    });

    test('setelah tanggal expired harus EXPIRED', () {
      final pallet = createPallet(expiredDate: expiredDate);

      final result = calculator.calculate(pallet, now: DateTime(2027, 4, 1));

      expect(result.expiryStatus, PalletExpiryStatus.expired);
    });
  });

  // ==========================================================
  // TEAR / STACK
  // ==========================================================

  group('PalletStatusCalculator - Tear / Stack', () {
    final expiredDate = DateTime(2027, 3, 15);

    test('tear sama dengan master tidak mismatch', () {
      final pallet = createPallet(expiredDate: expiredDate, tear: 10, stack: 5);

      final result = calculator.calculate(
        pallet,
        now: DateTime(2026, 11, 1),
        masterTear: 10,
        masterStack: 5,
      );

      expect(result.tearMismatch, false);
      expect(result.stackMismatch, false);
    });

    test('tear berbeda dari master harus TEAR MISMATCH', () {
      final pallet = createPallet(expiredDate: expiredDate, tear: 8, stack: 5);

      final result = calculator.calculate(
        pallet,
        now: DateTime(2026, 11, 1),
        masterTear: 10,
        masterStack: 5,
      );

      expect(result.tearMismatch, true);
      expect(result.stackMismatch, false);
    });

    test('stack berbeda dari master harus STACK MISMATCH', () {
      final pallet = createPallet(expiredDate: expiredDate, tear: 10, stack: 4);

      final result = calculator.calculate(
        pallet,
        now: DateTime(2026, 11, 1),
        masterTear: 10,
        masterStack: 5,
      );

      expect(result.tearMismatch, false);
      expect(result.stackMismatch, true);
    });

    test('tear dan stack berbeda harus keduanya mismatch', () {
      final pallet = createPallet(expiredDate: expiredDate, tear: 8, stack: 4);

      final result = calculator.calculate(
        pallet,
        now: DateTime(2026, 11, 1),
        masterTear: 10,
        masterStack: 5,
      );

      expect(result.tearMismatch, true);
      expect(result.stackMismatch, true);
      expect(result.hasTearOrStackMismatch, true);
    });
  });

  // ==========================================================
  // COMBINATION STATUS
  // ==========================================================

  group('PalletStatusCalculator - Combination', () {
    test('EXPIRED dapat bersamaan dengan TEAR/STACK MISMATCH', () {
      final pallet = createPallet(
        expiredDate: DateTime(2027, 3, 15),
        tear: 8,
        stack: 4,
      );

      final result = calculator.calculate(
        pallet,
        now: DateTime(2027, 4, 1),
        masterTear: 10,
        masterStack: 5,
      );

      expect(result.expiryStatus, PalletExpiryStatus.expired);

      expect(result.tearMismatch, true);
      expect(result.stackMismatch, true);
    });

    test('NEAR RETURN dapat bersamaan dengan mismatch', () {
      final pallet = createPallet(
        expiredDate: DateTime(2027, 3, 15),
        tear: 8,
        stack: 5,
      );

      final result = calculator.calculate(
        pallet,
        now: DateTime(2027, 2, 1),
        masterTear: 10,
        masterStack: 5,
      );

      expect(result.expiryStatus, PalletExpiryStatus.nearReturn);

      expect(result.tearMismatch, true);
      expect(result.stackMismatch, false);
    });
  });

  // ==========================================================
  // DATE TIME SAFETY
  // ==========================================================

  group('PalletStatusCalculator - Date Only', () {
    test('jam tidak boleh mengubah status tanggal expired', () {
      final pallet = createPallet(expiredDate: DateTime(2027, 3, 15, 23, 59));

      final result = calculator.calculate(
        pallet,
        now: DateTime(2027, 3, 15, 0, 1),
      );

      expect(result.expiryStatus, PalletExpiryStatus.expired);
    });
  });
}

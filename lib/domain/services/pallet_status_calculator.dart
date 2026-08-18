// ============================================================
// FILE:
// lib/domain/services/pallet_status_calculator.dart
//
// FUNGSI:
// Sumber kebenaran business rule untuk menentukan kondisi pallet.
//
// STATUS EXPIRED:
// - NORMAL
// - NEAR RETURN
// - EXPIRED
//
// VALIDASI FISIK:
// - TEAR MISMATCH
// - STACK MISMATCH
//
// CATATAN:
// Service ini tidak mengetahui Flutter UI.
// Service ini tidak mengetahui database.
// Service ini hanya berisi business logic.
// ============================================================

import '../../domain/entities/stock_pallet.dart';

// ============================================================
// ENUM: PALLET EXPIRY STATUS
// ============================================================

enum PalletExpiryStatus {
  normal,
  nearReturn,
  expired,
}

// ============================================================
// RESULT
// ============================================================
//
// Hasil kalkulasi kondisi satu pallet.
//
// Status expired dan mismatch sengaja dipisahkan karena
// satu pallet dapat memiliki beberapa kondisi sekaligus.
//
// Contoh:
//
// EXPIRED + TEAR MISMATCH
//
// atau:
//
// NEAR RETURN + STACK MISMATCH
// ============================================================

class PalletStatusResult {
  const PalletStatusResult({
    required this.expiryStatus,
    required this.tearMismatch,
    required this.stackMismatch,
  });

  final PalletExpiryStatus expiryStatus;

  final bool tearMismatch;

  final bool stackMismatch;

  // ==========================================================
  // HELPER
  // ==========================================================

  bool get hasTearOrStackMismatch {
    return tearMismatch || stackMismatch;
  }

  bool get isNormal {
    return expiryStatus == PalletExpiryStatus.normal &&
        !hasTearOrStackMismatch;
  }
}

// ============================================================
// SERVICE: PALLET STATUS CALCULATOR
// ============================================================

class PalletStatusCalculator {
  const PalletStatusCalculator();

  // ==========================================================
  // CALCULATE
  // ==========================================================
  //
  // Aturan expired:
  //
  // nearReturnStart = expiredDate - returHari
  //
  // Jika hari ini:
  //
  // < nearReturnStart
  // → NORMAL
  //
  // >= nearReturnStart dan < expiredDate
  // → NEAR RETURN
  //
  // >= expiredDate
  // → EXPIRED
  //
  // Contoh:
  //
  // Expired Date = 15-03-2027
  // Retur Hari   = 60
  //
  // Mulai Near Return = 14-01-2027
  //
  // 13-01 → NORMAL
  // 14-01 → NEAR RETURN
  // 14-03 → NEAR RETURN
  // 15-03 → EXPIRED
  // ==========================================================

  PalletStatusResult calculate(
    StockPallet pallet, {
    DateTime? now,
    int? masterTear,
    int? masterStack,
  }) {
    final currentDate = _dateOnly(now ?? DateTime.now());

    final expiredDate = _dateOnly(pallet.expiredDate);

    final nearReturnStart = expiredDate.subtract(
      Duration(days: pallet.returHari),
    );

    late final PalletExpiryStatus expiryStatus;

    if (!currentDate.isBefore(expiredDate)) {
      expiryStatus = PalletExpiryStatus.expired;
    } else if (!currentDate.isBefore(nearReturnStart)) {
      expiryStatus = PalletExpiryStatus.nearReturn;
    } else {
      expiryStatus = PalletExpiryStatus.normal;
    }

    // ========================================================
    // TEAR / STACK
    // ========================================================
    //
    // Jika master value diberikan, lakukan perbandingan langsung.
    //
    // Jika tidak diberikan, gunakan informasi sesuaiMaster
    // sebagai fallback kompatibilitas dengan model lama.
    // ========================================================

    final tearMismatch = masterTear != null
        ? pallet.tear != masterTear
        : !pallet.sesuaiMaster;

    final stackMismatch = masterStack != null
        ? pallet.stack != masterStack
        : !pallet.sesuaiMaster;

    return PalletStatusResult(
      expiryStatus: expiryStatus,
      tearMismatch: tearMismatch,
      stackMismatch: stackMismatch,
    );
  }

  // ==========================================================
  // DATE ONLY
  // ==========================================================
  //
  // Jam tidak ikut dihitung.
  //
  // Ini penting agar:
  //
  // 15-03-2027 00:01
  // dan
  // 15-03-2027 23:59
  //
  // tetap dianggap tanggal yang sama.
  // ==========================================================

  DateTime _dateOnly(DateTime value) {
    return DateTime(
      value.year,
      value.month,
      value.day,
    );
  }
}

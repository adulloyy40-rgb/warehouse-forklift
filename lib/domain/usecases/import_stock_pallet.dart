// ============================================================
// FILE:
// lib/domain/usecases/import_stock_pallet.dart
// ============================================================
//
// FUNGSI:
// Use case untuk memvalidasi data Stock Pallet hasil import.
//
// ALUR:
//
// Excel
//   ↓
// StockPalletExcelDataSource
//   ↓
// List<Map<String, dynamic>>
//   ↓
// ImportStockPallet
//   ↓
// StockPalletImportValidator
//   ↓
// Data valid / invalid
//
// CATATAN:
//
// Use case ini TIDAK:
// - membaca file Excel
// - mengakses Drift
// - mengakses SQLite
// - mengakses DAO
// - mengakses Flutter UI
//
// Tujuannya agar business logic tetap berada di Domain.
// ============================================================

import '../validators/stock_pallet_import_validator.dart';

// ============================================================
// RESULT
// ============================================================
//
// Menyimpan hasil proses import.
//
// validData:
// Data yang lolos validasi.
//
// invalidData:
// Data yang tidak lolos validasi.
//
// total:
// Jumlah seluruh baris yang diproses.
// ============================================================

class ImportStockPalletResult {
  final List<Map<String, dynamic>> validData;

  final List<Map<String, dynamic>> invalidData;

  const ImportStockPalletResult({
    required this.validData,
    required this.invalidData,
  });

  int get total => validData.length + invalidData.length;

  int get validCount => validData.length;

  int get invalidCount => invalidData.length;

  bool get isSuccess => invalidData.isEmpty;
}

// ============================================================
// USE CASE:
// ImportStockPallet
// ============================================================

class ImportStockPallet {
  final StockPalletImportValidator validator;

  const ImportStockPallet({required this.validator});

  // ==========================================================
  // EXECUTE
  // ==========================================================
  //
  // Memproses data hasil parser.
  //
  // Setiap baris:
  //
  // VALID
  //   → validData
  //
  // INVALID
  //   → invalidData
  //
  // Tidak ada data yang diubah.
  // ==========================================================

  ImportStockPalletResult execute(List<Map<String, dynamic>> rows) {
    final validData = <Map<String, dynamic>>[];

    final invalidData = <Map<String, dynamic>>[];

    for (final row in rows) {
      if (validator.validate(row)) {
        validData.add(row);
      } else {
        invalidData.add(row);
      }
    }

    return ImportStockPalletResult(
      validData: List.unmodifiable(validData),
      invalidData: List.unmodifiable(invalidData),
    );
  }
}

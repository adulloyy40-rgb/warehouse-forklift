// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/delete_stock_pallet.dart
//
// FUNGSI:
// Use Case untuk mengosongkan / menghapus pallet dari lokasi.
//
// ALUR:
//
// UI
//   ↓
// DeleteStockPallet
//   ↓
// StockPalletRepository
//   ↓
// SQLite
//
// CATATAN:
// - Use case tidak mengetahui SQLite.
// - Use case tidak mengakses DAO secara langsung.
// - Penghapusan dilakukan berdasarkan Location Code.
// ============================================================

import '../../repositories/stock_pallet_repository.dart';

// ============================================================
// CLASS
// ============================================================

class DeleteStockPallet {
  // ==========================================================
  // REPOSITORY
  // ==========================================================

  final StockPalletRepository stockPalletRepository;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const DeleteStockPallet({
    required this.stockPalletRepository,
  });

  // ==========================================================
  // CALL
  // ==========================================================

  Future<void> call(String locationCode) async {
    // --------------------------------------------------------
    // NORMALISASI LOCATION CODE
    // --------------------------------------------------------

    final normalizedLocationCode = locationCode.trim();

    // --------------------------------------------------------
    // VALIDASI LOCATION CODE
    // --------------------------------------------------------

    if (normalizedLocationCode.isEmpty) {
      throw ArgumentError(
        'Location Code tidak boleh kosong.',
      );
    }

    // --------------------------------------------------------
    // HAPUS PALLET
    // --------------------------------------------------------
    //
    // Repository yang bertanggung jawab meneruskan proses
    // sampai DAO/database.
    // --------------------------------------------------------

    await stockPalletRepository.deleteByLocationCode(
      normalizedLocationCode,
    );
  }
}

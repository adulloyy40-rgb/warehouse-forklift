// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/delete_stock_pallet.dart
// ============================================================
//
// FUNGSI:
// Menghapus StockPallet berdasarkan Location Code.
//
// Contoh:
//
// deleteStockPallet('8001101');
//
// Maka pallet aktif pada Location Code 8001101
// akan dihapus dari repository.
// ============================================================

import '../../repositories/stock_pallet_repository.dart';


// ============================================================
// CLASS:
// DeleteStockPallet
// ============================================================

class DeleteStockPallet {
  // ==========================================================
  // Repository
  // ==========================================================

  final StockPalletRepository repository;


  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const DeleteStockPallet({
    required this.repository,
  });


  // ==========================================================
  // CALL
  // ==========================================================
  //
  // FUNGSI:
  // Menghapus pallet berdasarkan Location Code.
  // ==========================================================

  Future<void> call(
    String locationCode,
  ) async {
    await repository.deleteByLocationCode(
      locationCode,
    );
  }
}

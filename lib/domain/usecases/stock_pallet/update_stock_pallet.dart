// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/update_stock_pallet.dart
// ============================================================
//
// FUNGSI:
// Memperbarui data StockPallet yang sudah tersimpan.
//
// Contoh perubahan:
// - Tear Aktual
// - Stack Aktual
// - Qty CTN
// - Qty PCS
// - Expired Date
// - Operator NIK
// - Sesuai Master
// ============================================================

import '../../entities/stock_pallet.dart';
import '../../repositories/stock_pallet_repository.dart';


// ============================================================
// CLASS:
// UpdateStockPallet
// ============================================================

class UpdateStockPallet {
  // ==========================================================
  // Repository
  // ==========================================================

  final StockPalletRepository repository;


  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const UpdateStockPallet({
    required this.repository,
  });


  // ==========================================================
  // CALL
  // ==========================================================
  //
  // FUNGSI:
  // Memperbarui StockPallet.
  //
  // Jika Location Code belum tersimpan,
  // repository akan menghasilkan StateError.
  // ==========================================================

  Future<void> call(
    StockPallet pallet,
  ) async {
    await repository.update(pallet);
  }
}

// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/get_all_stock_pallets.dart
// ============================================================
//
// FUNGSI:
// Mengambil seluruh data StockPallet.
//
// Digunakan nantinya untuk:
// - halaman daftar stok pallet
// - dashboard
// - monitoring storage
// - laporan
// - export Excel
// ============================================================

import '../../entities/stock_pallet.dart';
import '../../repositories/stock_pallet_repository.dart';


// ============================================================
// CLASS:
// GetAllStockPallets
// ============================================================

class GetAllStockPallets {
  // ==========================================================
  // Repository
  // ==========================================================

  final StockPalletRepository repository;


  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const GetAllStockPallets({
    required this.repository,
  });


  // ==========================================================
  // CALL
  // ==========================================================
  //
  // FUNGSI:
  // Mengambil seluruh pallet.
  // ==========================================================

  Future<List<StockPallet>> call() async {
    return await repository.getAll();
  }
}

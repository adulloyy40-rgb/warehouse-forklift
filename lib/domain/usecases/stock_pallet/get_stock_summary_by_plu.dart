// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/get_stock_summary_by_plu.dart
//
// FUNGSI:
// Mengambil rekap stok pallet berdasarkan PLU.
//
// Data yang direkap:
// - Total pallet
// - Total CTN
// - Total PCS
// - Total nilai stok
//
// ALUR:
//
// UI
//   ↓
// GetStockSummaryByPlu
//   ↓
// StockPalletRepository
//   ↓
// StockPalletRepositoryImpl
//   ↓
// StockPalletDao
//   ↓
// SQLite / Drift
// ============================================================

import '../../entities/stock_pallet_summary.dart';
import '../../repositories/stock_pallet_repository.dart';

class GetStockSummaryByPlu {
  final StockPalletRepository repository;

  const GetStockSummaryByPlu({required this.repository});

  Future<List<StockPalletSummary>> call() async {
    return await repository.getStockSummaryByPlu();
  }
}

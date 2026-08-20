// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/get_stock_summary_for_plu.dart
//
// FUNGSI:
// Mengambil rekap stok untuk satu PLU.
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
// GetStockSummaryForPlu
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

class GetStockSummaryForPlu {
  final StockPalletRepository repository;

  const GetStockSummaryForPlu({required this.repository});

  Future<StockPalletSummary?> call(String plu) async {
    final normalizedPlu = plu.trim();

    if (normalizedPlu.isEmpty) {
      return null;
    }

    return repository.getStockSummaryForPlu(normalizedPlu);
  }
}

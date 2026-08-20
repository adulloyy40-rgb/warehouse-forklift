// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/get_grand_total_stock_value.dart
//
// FUNGSI:
// Mengambil total nilai seluruh stok pallet aktif.
//
// Rumus:
//
// Grand Total
// = Σ (Qty PCS × Harga)
//
// Nilai ini mencakup seluruh PLU dan seluruh lokasi
// yang memiliki pallet aktif.
//
// ALUR:
//
// UI
//   ↓
// GetGrandTotalStockValue
//   ↓
// StockPalletRepository
//   ↓
// StockPalletRepositoryImpl
//   ↓
// StockPalletDao
//   ↓
// SQLite / Drift
// ============================================================

import '../../repositories/stock_pallet_repository.dart';

class GetGrandTotalStockValue {
  final StockPalletRepository repository;

  const GetGrandTotalStockValue({required this.repository});

  Future<double> call() async {
    return await repository.getGrandTotalStockValue();
  }
}

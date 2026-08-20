// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/search_stock_pallets.dart
// ============================================================
//
// FUNGSI:
// Mencari seluruh StockPallet berdasarkan:
// - PLU
// - Barcode
// - Description
//
// BERBEDA DENGAN:
// FindStockPalletByLocation
//
// FindStockPalletByLocation:
//   Location Code → satu pallet
//
// SearchStockPallets:
//   PLU / Barcode / Description → banyak pallet
//
// Contoh:
//
// Operator mencari:
// "AQUA"
//
// Hasil:
//
// 8001101 → AQUA
// 8001105 → AQUA
// 8102302 → AQUA
//
// Use Case tidak mengetahui:
// - Drift
// - SQLite
// - DAO
// - Flutter UI
//
// ============================================================

import '../../entities/stock_pallet.dart';
import '../../repositories/stock_pallet_repository.dart';

// ============================================================
// CLASS:
// SearchStockPallets
// ============================================================

class SearchStockPallets {
  // ==========================================================
  // REPOSITORY
  // ==========================================================

  final StockPalletRepository repository;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const SearchStockPallets({
    required this.repository,
  });

  // ==========================================================
  // CALL
  // ==========================================================
  //
  // Parameter:
  // query
  //
  // Return:
  // Semua pallet yang cocok.
  //
  // Jika query kosong:
  // repository akan mengembalikan seluruh pallet.
  // ==========================================================

  Future<List<StockPallet>> call(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return repository.getAll();
    }

    return repository.searchPallets(normalizedQuery);
  }
}

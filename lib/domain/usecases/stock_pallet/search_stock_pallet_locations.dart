// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/search_stock_pallet_locations.dart
// ============================================================
//
// FUNGSI:
// Mencari seluruh StockPallet berdasarkan:
// - PLU
// - Barcode
// - Description / nama barang
//
// Tujuan utama:
// Operator dapat mengetahui item tertentu berada di lokasi
// storage mana saja.
//
// ALUR:
//
// UI
//   ↓
// SearchStockPalletLocations
//   ↓
// StockPalletRepository
//   ↓
// StockPalletRepositoryImpl
//   ↓
// StockPalletDao
//   ↓
// SQLite / Drift
// ============================================================

import '../../entities/stock_pallet.dart';
import '../../repositories/stock_pallet_repository.dart';

// ============================================================
// CLASS:
// SearchStockPalletLocations
// ============================================================

class SearchStockPalletLocations {
  // ==========================================================
  // Repository
  // ==========================================================

  final StockPalletRepository repository;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const SearchStockPalletLocations({
    required this.repository,
  });

  // ==========================================================
  // CALL
  // ==========================================================
  //
  // Parameter:
  // query
  //
  // Query dapat berupa:
  // - PLU
  // - Barcode
  // - Nama / Description
  //
  // Return:
  // - List StockPallet jika ditemukan.
  // - List kosong jika query kosong atau tidak ditemukan.
  // ==========================================================

  Future<List<StockPallet>> call(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.isEmpty) {
      return <StockPallet>[];
    }

    return repository.searchPallets(normalizedQuery);
  }
}

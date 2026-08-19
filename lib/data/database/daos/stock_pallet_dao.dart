// ============================================================
// FILE:
// lib/data/database/daos/stock_pallet_dao.dart
//
// FUNGSI:
// DAO (Data Access Object) untuk tabel StockPallets.
//
// DAO menjadi pintu resmi untuk membaca dan mengubah database.
//
// Alur:
//
// Presentation
//     ↓
// UseCase
//     ↓
// Repository
//     ↓
// StockPalletDao
//     ↓
// SQLite / Drift
//
// ATURAN BISNIS:
// 1 lokasi hanya boleh memiliki 1 pallet aktif.
// ============================================================

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/stock_pallets_table.dart';

part 'stock_pallet_dao.g.dart';

// ============================================================
// CLASS: StockPalletDao
// ============================================================

@DriftAccessor(tables: [StockPallets])
class StockPalletDao extends DatabaseAccessor<AppDatabase>
    with _$StockPalletDaoMixin {
  // ----------------------------------------------------------
  // CONSTRUCTOR
  // ----------------------------------------------------------

  StockPalletDao(super.db);

  // ==========================================================
  // FIND PALLET BY LOCATION
  // ==========================================================

  Future<StockPallet?> findByLocation(String locationCode) {
    final normalizedLocation = locationCode.trim();

    return (select(stockPallets)
          ..where((tbl) => tbl.locationCode.equals(normalizedLocation)))
        .getSingleOrNull();
  }

  // ==========================================================
  // GET ALL PALLETS
  // ==========================================================

  Future<List<StockPallet>> getAllPallets() {
    return select(stockPallets).get();
  }

  // ==========================================================
  // INSERT PALLET
  // ==========================================================

  Future<int> insertPallet(StockPalletsCompanion pallet) {
    return into(stockPallets).insert(pallet);
  }

  // ==========================================================
  // INSERT BANYAK PALLET
  // ==========================================================
  //
  // Digunakan khusus untuk proses import Excel.
  //
  // Semua pallet dikirim ke SQLite dalam satu batch,
  // sehingga tidak perlu melakukan INSERT satu per satu.
  //
  // ==========================================================

  Future<void> insertPallets(List<StockPalletsCompanion> pallets) async {
    if (pallets.isEmpty) {
      return;
    }

    await batch((batch) {
      batch.insertAll(stockPallets, pallets);
    });
  }

  // ==========================================================
  // UPDATE PALLET
  // ==========================================================

  Future<bool> updatePallet(StockPalletsCompanion pallet) async {
    final count = await update(stockPallets).write(pallet);
    return count > 0;
  }

  // ==========================================================
  // DELETE PALLET BY ID
  // ==========================================================

  Future<int> deletePalletById(int id) {
    return (delete(stockPallets)..where((tbl) => tbl.id.equals(id))).go();
  }
}

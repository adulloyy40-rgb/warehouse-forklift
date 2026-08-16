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
//
// Dengan @DriftAccessor, Drift akan membuat implementasi
// DAO secara otomatis di file generated .g.dart.
//
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
  //
  // Contoh:
  //
  // Location: 8001101
  //
  // Jika ada pallet:
  //
  // 8001101 → Pallet A
  //
  // maka data pallet dikembalikan.
  //
  // Jika belum ada:
  //
  // return null
  //
  // ==========================================================

  Future<StockPallet?> findByLocation(String locationCode) {
    return (select(stockPallets)
          ..where((tbl) => tbl.locationCode.equals(locationCode.trim())))
        .getSingleOrNull();
  }

  // ==========================================================
  // GET ALL PALLETS
  // ==========================================================
  //
  // Mengambil seluruh pallet yang tersimpan di database.
  // ==========================================================

  Future<List<StockPallet>> getAllPallets() {
    return select(stockPallets).get();
  }

  // ==========================================================
  // INSERT PALLET
  // ==========================================================
  //
  // Digunakan ketika operator melakukan PUT AWAY pertama kali.
  //
  // Location harus belum memiliki pallet.
  //
  // ==========================================================

  Future<int> insertPallet(StockPalletsCompanion pallet) {
    return into(stockPallets).insert(pallet);
  }

  // ==========================================================
  // UPDATE PALLET
  // ==========================================================
  //
  // Digunakan ketika operator memilih:
  //
  // [ EDIT PALLET ]
  //
  // Data pallet lama diperbarui.
  // ==========================================================

  Future<bool> updatePallet(StockPalletsCompanion pallet) {
    return update(stockPallets).write(pallet).then((count) {
      return count > 0;
    });
  }

  // ==========================================================
  // DELETE PALLET
  // ==========================================================
  //
  // Disediakan untuk kebutuhan administrasi/data correction.
  // UI belum menggunakan fungsi ini.
  //
  // ==========================================================

  Future<int> deletePalletById(int id) {
    return (delete(stockPallets)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }
}

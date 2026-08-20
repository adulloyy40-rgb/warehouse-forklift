// ============================================================
// FILE:
// lib/data/database/app_database.dart
//
// FUNGSI:
// Database utama aplikasi Warehouse Forklift.
// ============================================================

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/stock_pallets_table.dart';
import 'tables/storage_locations.dart';
import 'tables/products.dart';

import 'daos/stock_pallet_dao.dart';
import 'daos/storage_location_dao.dart';
import 'daos/product_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [StockPallets, StorageLocations, Products],
  daos: [StockPalletDao, StorageLocationDao, ProductDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },

    onUpgrade: (Migrator m, int from, int to) async {
      // --------------------------------------------------------
      // VERSION 2
      // --------------------------------------------------------
      if (from < 2) {
        await m.addColumn(
          stockPallets,
          stockPallets.operatorNik,
        );

        await m.addColumn(
          stockPallets,
          stockPallets.sesuaiMaster,
        );
      }

      // --------------------------------------------------------
      // VERSION 3
      // --------------------------------------------------------
      if (from < 3) {
        await m.createTable(products);
      }

      // --------------------------------------------------------
      // VERSION 4
      //
      // Menambahkan quantity hasil perhitungan sistem:
      //
      // Qty CTN = Tear × Stack
      // Qty PCS = Qty CTN × Conv2
      //
      // Data pallet lama tidak dihapus.
      // --------------------------------------------------------
      if (from < 4) {
        await m.addColumn(
          stockPallets,
          stockPallets.qtyCtn,
        );

        await m.addColumn(
          stockPallets,
          stockPallets.qtyPcs,
        );

        await customStatement('''
          UPDATE stock_pallets
          SET
            qty_ctn = tear * stack,
            qty_pcs = tear * stack * conv2
        ''');
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'warehouse_forklift_database');
}

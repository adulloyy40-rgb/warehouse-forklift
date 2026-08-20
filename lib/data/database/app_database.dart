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
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.addColumn(stockPallets, stockPallets.operatorNik);

        await m.addColumn(stockPallets, stockPallets.sesuaiMaster);
      }

      if (from < 3) {
        await m.createTable(products);
      }
    },
  );
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'warehouse_forklift_database');
}

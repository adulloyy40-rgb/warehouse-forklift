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

import 'daos/stock_pallet_dao.dart';
import 'daos/storage_location_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    StockPallets,
    StorageLocations,
  ],
  daos: [
    StockPalletDao,
    StorageLocationDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase({
    QueryExecutor? executor,
  }) : super(
          executor ?? _openConnection(),
        );

  @override
  int get schemaVersion => 1;
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'warehouse_forklift_database',
  );
}

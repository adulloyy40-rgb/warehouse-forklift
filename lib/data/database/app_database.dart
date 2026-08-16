// ============================================================
// FILE:
// lib/data/database/app_database.dart
//
// FUNGSI:
// Database utama aplikasi Warehouse Forklift.
//
// DATABASE:
// - Production Android:
//   menggunakan driftDatabase()
// - Unit Test:
//   dapat menggunakan NativeDatabase.memory()
//
// CATATAN:
// Database test tidak membutuhkan path_provider.
// ============================================================

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/stock_pallets_table.dart';
import 'daos/stock_pallet_dao.dart';

part 'app_database.g.dart';

// ============================================================
// DATABASE
// ============================================================

@DriftDatabase(
  tables: [
    StockPallets,
  ],
  daos: [
    StockPalletDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================
  //
  // Jika executor diberikan:
  //   digunakan untuk unit test.
  //
  // Jika executor null:
  //   digunakan database production Android.
  // ==========================================================

  AppDatabase({
    QueryExecutor? executor,
  }) : super(
          executor ?? _openConnection(),
        );

  // ==========================================================
  // DATABASE VERSION
  // ==========================================================

  @override
  int get schemaVersion => 1;
}

// ============================================================
// PRODUCTION DATABASE CONNECTION
// ============================================================
//
// Digunakan ketika aplikasi Android benar-benar berjalan.
//
// driftDatabase() membutuhkan path_provider.
// Karena itu jangan digunakan langsung untuk unit test VM.
// ============================================================

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'warehouse_forklift_database',
  );
}

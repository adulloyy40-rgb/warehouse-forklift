// ============================================================
// FILE:
// lib/presentation/app/app_dependencies.dart
// ============================================================
//
// FUNGSI:
// Menyediakan dependency/repository yang digunakan oleh
// aplikasi Warehouse Forklift.
//
// Dependency Injection sederhana tanpa package tambahan.
//
// Repository dibuat satu kali dan dapat digunakan bersama oleh:
//
// - Dashboard
// - Storage
// - Putaway
// - Picking
// - Stock
//
// ============================================================

import '../../data/repositories/stock_pallet_repository_impl.dart';
import '../../data/repositories/storage_location_repository_impl.dart';

import '../../domain/repositories/stock_pallet_repository.dart';
import '../../domain/repositories/storage_location_repository.dart';

// ============================================================
// CLASS:
// AppDependencies
// ============================================================
//
// Tempat seluruh dependency utama aplikasi.
//
// ============================================================

class AppDependencies {
  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const AppDependencies({
    required this.storageLocationRepository,
    required this.stockPalletRepository,
  });

  // ==========================================================
  // STORAGE LOCATION REPOSITORY
  // ==========================================================
  //
  // Repository untuk Master Storage Location.
  //
  // Menyediakan:
  //
  // - Rack
  // - Bay
  // - Shelving
  // - Position
  // - Location Code
  //
  // Layout saat ini:
  //
  // 1.860 lokasi
  // ==========================================================

  final StorageLocationRepository storageLocationRepository;

  // ==========================================================
  // STOCK PALLET REPOSITORY
  // ==========================================================
  //
  // Repository untuk data pallet.
  //
  // Menyediakan:
  //
  // - Save pallet
  // - Get all pallet
  // - Find pallet berdasarkan lokasi
  // - Update pallet
  // - Delete pallet
  //
  // ==========================================================

  final StockPalletRepository stockPalletRepository;

  // ==========================================================
  // CREATE DEFAULT DEPENDENCIES
  // ==========================================================
  //
  // Membuat dependency standar aplikasi.
  //
  // Implementation DATA layer disimpan menggunakan tipe
  // interface DOMAIN layer.
  //
  // Ini menjaga prinsip Clean Architecture.
  // ==========================================================

  factory AppDependencies.create() {
    return AppDependencies(
      storageLocationRepository: const StorageLocationRepositoryImpl(),

      stockPalletRepository: StockPalletRepositoryImpl(),
    );
  }
}

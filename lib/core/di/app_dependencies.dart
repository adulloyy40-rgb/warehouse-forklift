// ============================================================
// FILE:
// lib/core/di/app_dependencies.dart
//
// FUNGSI:
// Dependency Injection utama aplikasi Warehouse Forklift.
//
// Semua dependency penting aplikasi dibuat di sini.
//
// Prinsip:
// SATU AppDatabase
//        ↓
// SATU StockPalletRepository
//        ↓
// Dipakai bersama oleh seluruh aplikasi.
// ============================================================

import '../../data/database/app_database.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/stock_pallet_repository_impl.dart';
import '../../data/repositories/storage_location_repository_impl.dart';

import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/stock_pallet_repository.dart';
import '../../domain/repositories/storage_location_repository.dart';

import '../../domain/usecases/product/get_product_by_plu.dart';

// ============================================================
// CLASS:
// AppDependencies
// ============================================================

class AppDependencies {
  // ----------------------------------------------------------
  // PRIVATE CONSTRUCTOR
  // ----------------------------------------------------------

  AppDependencies._();

  // ----------------------------------------------------------
  // SINGLETON
  // ----------------------------------------------------------

  static final AppDependencies instance = AppDependencies._();

  // ==========================================================
  // DATABASE
  // ==========================================================
  //
  // SATU instance database digunakan oleh aplikasi.
  //
  // Jangan membuat AppDatabase() berulang-ulang di setiap Page.
  // ==========================================================

  final AppDatabase database = AppDatabase();

  // ==========================================================
  // STOCK PALLET REPOSITORY
  // ==========================================================
  //
  // Repository menerima database yang sama.
  // ==========================================================

  late final StockPalletRepository stockPalletRepository =
      StockPalletRepositoryImpl(database);

  // ==========================================================
  // STORAGE LOCATION REPOSITORY
  // ==========================================================

  final StorageLocationRepository storageLocationRepository =
      const StorageLocationRepositoryImpl();

  // ==========================================================
  // PRODUCT REPOSITORY
  // ==========================================================

  final ProductRepository productRepository =
      ProductRepositoryImpl(
    excelFilePath: 'test/fixtures/master_barang.xlsx',
  );

  // ==========================================================
  // GET PRODUCT BY PLU
  // ==========================================================
  //
  // UseCase menggunakan ProductRepository yang sama.
  // ==========================================================

  GetProductByPlu get getProductByPlu {
    return GetProductByPlu(
      repository: productRepository,
    );
  }

  // ==========================================================
  // CLOSE DATABASE
  // ==========================================================
  //
  // Dipanggil ketika aplikasi benar-benar ditutup.
  // ==========================================================

  Future<void> dispose() async {
    await database.close();
  }
}

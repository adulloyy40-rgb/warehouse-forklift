// ============================================================
// FILE:
// lib/core/di/app_dependencies.dart
//
// FUNGSI:
// Dependency Injection utama aplikasi Warehouse Forklift.
//
// Prinsip:
//
// SATU AppDatabase
//        |
//        +-- StockPalletRepository
//        |       |
//        |       +-- StockPalletRepositoryImpl
//        |
//        +-- ProductRepository
//        |       |
//        |       +-- ProductRepositoryImpl
//        |
//        +-- StorageLocationRepository
//
// USE CASE:
//
// Product:
//   GetProductByPlu
//
// Stock Pallet:
//   PutAwayStockPallet
//   UpdateStockPallet
//
// ============================================================

import '../../data/database/app_database.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/stock_pallet_repository_impl.dart';
import '../../data/repositories/storage_location_repository_impl.dart';

import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/stock_pallet_repository.dart';
import '../../domain/repositories/storage_location_repository.dart';

import '../../domain/usecases/product/get_product_by_plu.dart';
import '../../domain/usecases/stock_pallet/put_away_stock_pallet.dart';
import '../../domain/usecases/stock_pallet/update_stock_pallet.dart';
import '../../domain/usecases/stock_pallet/delete_stock_pallet.dart';

// ============================================================
// CLASS
// ============================================================

class AppDependencies {
  // ==========================================================
  // PRIVATE CONSTRUCTOR
  // ==========================================================

  AppDependencies._();

  // ==========================================================
  // SINGLETON
  // ==========================================================

  static final AppDependencies instance = AppDependencies._();

  // ==========================================================
  // DATABASE
  // ==========================================================
  //
  // Hanya satu database digunakan seluruh aplikasi.
  // ==========================================================

  final AppDatabase database = AppDatabase();

  // ==========================================================
  // STOCK PALLET REPOSITORY
  // ==========================================================
  //
  // Repository Stock Pallet menggunakan database yang sama.
  // ==========================================================

  late final StockPalletRepository stockPalletRepository =
      StockPalletRepositoryImpl(
    database,
  );

  // ==========================================================
  // STORAGE LOCATION REPOSITORY
  // ==========================================================
  //
  // Repository untuk master lokasi storage.
  // ==========================================================

  final StorageLocationRepository storageLocationRepository =
      const StorageLocationRepositoryImpl();

  // ==========================================================
  // PRODUCT REPOSITORY
  // ==========================================================
  //
  // Repository Master Barang.
  //
  // Untuk sekarang Master Barang dibaca dari:
  //
  // test/fixtures/master_barang.xlsx
  //
  // ==========================================================

  final ProductRepository productRepository =
      ProductRepositoryImpl(
    excelFilePath: 'test/fixtures/master_barang.xlsx',
  );

  // ==========================================================
  // GET PRODUCT BY PLU
  // ==========================================================
  //
  // Digunakan untuk mencari Master Barang berdasarkan PLU.
  //
  // ALUR:
  //
  // UI
  //  ↓
  // GetProductByPlu
  //  ↓
  // ProductRepository
  //  ↓
  // Master Barang
  //
  // ==========================================================

  GetProductByPlu get getProductByPlu {
    return GetProductByPlu(
      repository: productRepository,
    );
  }

  // ==========================================================
  // PUT AWAY STOCK PALLET
  // ==========================================================
  //
  // Digunakan untuk memasukkan pallet baru ke lokasi kosong.
  //
  // ALUR:
  //
  // UI
  //  ↓
  // PutAwayStockPallet
  //  ↓
  // StockPalletRepository
  //  ↓
  // StockPalletRepositoryImpl
  //  ↓
  // StockPalletDao
  //  ↓
  // SQLite
  //
  // ==========================================================

  PutAwayStockPallet get putAwayStockPallet {
    return PutAwayStockPallet(
      repository: stockPalletRepository,
    );
  }

  // ==========================================================
  // UPDATE STOCK PALLET
  // ==========================================================
  //
  // Digunakan untuk EDIT pallet yang sudah tersimpan.
  //
  // Use Case membutuhkan DUA repository:
  //
  // 1. ProductRepository
  //    Untuk mencari Master Barang berdasarkan PLU.
  //
  // 2. StockPalletRepository
  //    Untuk menyimpan perubahan pallet.
  //
  // ==========================================================

  UpdateStockPallet get updateStockPallet {
    return UpdateStockPallet(
      productRepository: productRepository,
      stockPalletRepository: stockPalletRepository,
    );
  }

  // ==========================================================
  // DELETE STOCK PALLET
  // ==========================================================
  //
  // Digunakan untuk mengosongkan pallet dari lokasi storage.
  //
  // Use Case menggunakan StockPalletRepository yang sama
  // dengan PUT AWAY dan EDIT PALLET.
  //
  // ==========================================================

  DeleteStockPallet get deleteStockPallet {
    return DeleteStockPallet(
      stockPalletRepository: stockPalletRepository,
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================
  //
  // Menutup database dari instance yang sama.
  // ==========================================================

  Future<void> dispose() async {
    await database.close();
  }
}

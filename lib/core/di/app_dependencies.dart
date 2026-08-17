// ============================================================
// FILE:
// lib/core/di/app_dependencies.dart
//
// FUNGSI:
// Dependency Injection utama aplikasi Warehouse Forklift.
//
// Semua dependency penting aplikasi dibuat di sini.
//
// PRINSIP:
// SATU AppDatabase
//        ↓
// SATU StockPalletRepository
//        ↓
// Dipakai bersama oleh seluruh aplikasi.
//
// Use Case:
// - GetProductByPlu
// - PutAwayStockPallet
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

// ============================================================
// CLASS:
// AppDependencies
// ============================================================
//
// Dependency Injection utama aplikasi.
//
// Semua dependency yang bersifat shared dibuat dari sini.
//
// Tujuannya:
// - Tidak membuat database berkali-kali.
// - Tidak membuat repository berkali-kali.
// - Use Case menggunakan repository yang sama.
// - Memudahkan pengembangan aplikasi.
// ============================================================

class AppDependencies {
  // ==========================================================
  // PRIVATE CONSTRUCTOR
  // ==========================================================
  //
  // Constructor private agar class digunakan sebagai Singleton.
  // ==========================================================

  AppDependencies._();

  // ==========================================================
  // SINGLETON
  // ==========================================================
  //
  // Satu instance AppDependencies untuk seluruh aplikasi.
  // ==========================================================

  static final AppDependencies instance = AppDependencies._();

  // ==========================================================
  // DATABASE
  // ==========================================================
  //
  // SATU instance database digunakan oleh seluruh aplikasi.
  //
  // Jangan membuat:
  //
  // AppDatabase()
  //
  // secara langsung pada setiap Page.
  // ==========================================================

  final AppDatabase database = AppDatabase();

  // ==========================================================
  // STOCK PALLET REPOSITORY
  // ==========================================================
  //
  // Repository menerima database yang sama.
  //
  // Semua proses StockPallet menggunakan repository ini.
  // ==========================================================

  late final StockPalletRepository stockPalletRepository =
      StockPalletRepositoryImpl(
    database,
  );

  // ==========================================================
  // STORAGE LOCATION REPOSITORY
  // ==========================================================
  //
  // Repository untuk data lokasi storage.
  // ==========================================================

  final StorageLocationRepository storageLocationRepository =
      const StorageLocationRepositoryImpl();

  // ==========================================================
  // PRODUCT REPOSITORY
  // ==========================================================
  //
  // Repository untuk Master Barang.
  //
  // Saat ini sumber data menggunakan file Excel fixture.
  // ==========================================================

  final ProductRepository productRepository =
      ProductRepositoryImpl(
    excelFilePath: 'test/fixtures/master_barang.xlsx',
  );

  // ==========================================================
  // GET PRODUCT BY PLU
  // ==========================================================
  //
  // Use Case:
  //
  // PLU
  //  ↓
  // GetProductByPlu
  //  ↓
  // ProductRepository
  //  ↓
  // Master Barang
  //
  // Digunakan oleh form PUT AWAY.
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
  // Use Case utama untuk proses PUT AWAY.
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
  // DAO
  //  ↓
  // SQLite
  //
  // PutAwayStockPallet juga memastikan Location Code
  // belum digunakan sebelum pallet disimpan.
  //
  // Repository yang digunakan adalah instance yang sama
  // dengan seluruh aplikasi.
  // ==========================================================

  PutAwayStockPallet get putAwayStockPallet {
    return PutAwayStockPallet(
      repository: stockPalletRepository,
    );
  }

  // ==========================================================
  // CLOSE DATABASE
  // ==========================================================
  //
  // Dipanggil ketika aplikasi benar-benar ditutup.
  //
  // Database ditutup hanya dari instance yang sama.
  // ==========================================================

  Future<void> dispose() async {
    await database.close();
  }
}

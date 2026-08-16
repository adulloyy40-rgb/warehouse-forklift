// ============================================================
// FILE:
// lib/core/di/app_dependencies.dart
// ============================================================
//
// FUNGSI:
// Dependency Injection / Dependency Container aplikasi.
//
// Tujuan utama:
// Memastikan repository yang digunakan oleh seluruh halaman
// menggunakan INSTANCE YANG SAMA.
//
// Contoh:
//
// StoragePage
//      ↓
// AppDependencies.stockPalletRepository
//      ↓
// StockPalletRepositoryImpl
//      ↑
// StorageDetailPage
//
// Dengan demikian ketika PUT AWAY menyimpan pallet,
// StoragePage dapat melihat perubahan status location.
// ============================================================

import '../../data/repositories/stock_pallet_repository_impl.dart';
import '../../data/repositories/storage_location_repository_impl.dart';
import '../../domain/repositories/stock_pallet_repository.dart';
import '../../domain/repositories/storage_location_repository.dart';

import '../../data/repositories/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/product/get_product_by_plu.dart';

// ============================================================
// CLASS:
// AppDependencies
// ============================================================
//
// Container dependency aplikasi.
//
// Semua dependency utama aplikasi ditempatkan di sini.
// ============================================================

class AppDependencies {
  // ==========================================================
  // PRIVATE CONSTRUCTOR
  // ==========================================================
  //
  // Class ini tidak dibuat menggunakan AppDependencies().
  //
  // Kita menggunakan singleton.
  // ==========================================================

  AppDependencies._();

  // ==========================================================
  // SINGLETON INSTANCE
  // ==========================================================

  static final AppDependencies instance = AppDependencies._();

  // ==========================================================
  // STOCK PALLET REPOSITORY
  // ==========================================================
  //
  // SANGAT PENTING:
  //
  // Jangan membuat:
  //
  // StockPalletRepositoryImpl()
  //
  // berulang-ulang di setiap Page.
  //
  // Kita hanya membuat SATU instance.
  // ==========================================================

  final StockPalletRepository stockPalletRepository =
      StockPalletRepositoryImpl();

  // ==========================================================
  // STORAGE LOCATION REPOSITORY
  // ==========================================================
  //
  // Repository master lokasi storage.
  // ==========================================================

  final StorageLocationRepository storageLocationRepository =
      const StorageLocationRepositoryImpl();

  // ==========================================================
  // PRODUCT REPOSITORY
  // ==========================================================
  //
  // Repository Master Barang.
  //
  // Digunakan oleh PUT AWAY untuk mencari barang berdasarkan
  // PLU.
  //
  // Instance dibuat satu kali agar seluruh aplikasi memakai
  // repository yang sama.
  // ==========================================================

  final ProductRepository productRepository = ProductRepositoryImpl(
    excelFilePath: 'test/fixtures/master_barang.xlsx',
  );

  // ==========================================================
  // GET PRODUCT BY PLU
  // ==========================================================
  //
  // Use Case untuk mencari Master Barang berdasarkan PLU.
  //
  // Getter ini menggunakan productRepository milik
  // AppDependencies yang sama.
  // ==========================================================

  GetProductByPlu get getProductByPlu {
    return GetProductByPlu(repository: productRepository);
  }
}

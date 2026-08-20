// ============================================================
// FILE:
// lib/core/di/app_dependencies.dart
//
// FUNGSI:
// Dependency Injection utama aplikasi Warehouse Forklift.
//
// SATU AppDatabase
//        |
//        +-- ProductRepository
//        |       |
//        |       +-- ProductRepositoryImpl
//        |
//        +-- StockPalletRepository
//        |
//        +-- StorageLocationRepository
//
// ============================================================

import '../../data/database/app_database.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/repositories/stock_pallet_repository_impl.dart';
import '../../data/repositories/storage_location_repository_impl.dart';

import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/stock_pallet_repository.dart';
import '../../domain/repositories/storage_location_repository.dart';

import '../../domain/usecases/product/create_product.dart';
import '../../domain/usecases/product/delete_product.dart';
import '../../domain/usecases/product/get_product_by_id.dart';
import '../../domain/usecases/product/get_product_by_plu.dart';
import '../../domain/usecases/product/update_product.dart';

import '../../domain/usecases/import_master_item_to_database.dart';
import '../../domain/usecases/stock_pallet/get_grand_total_stock_value.dart';
import '../../domain/usecases/stock_pallet/get_stock_summary_by_plu.dart';
import '../../domain/usecases/stock_pallet/get_stock_summary_for_plu.dart';
import '../../domain/usecases/stock_pallet/delete_stock_pallet.dart';
import '../../domain/usecases/stock_pallet/put_away_stock_pallet.dart';
import '../../domain/usecases/stock_pallet/update_stock_pallet.dart';

// ============================================================
// CLASS
// ============================================================

class AppDependencies {
  AppDependencies._();

  static final AppDependencies instance = AppDependencies._();

  // ==========================================================
  // DATABASE
  // ==========================================================

  final AppDatabase database = AppDatabase();

  // ==========================================================
  // PRODUCT REPOSITORY
  // ==========================================================

  late final ProductRepository productRepository = ProductRepositoryImpl(
    database.productDao,
  );

  // ==========================================================
  // STOCK PALLET REPOSITORY
  // ==========================================================

  late final StockPalletRepository stockPalletRepository =
      StockPalletRepositoryImpl(database);

  // ==========================================================
  // STORAGE LOCATION REPOSITORY
  // ==========================================================

  late final StorageLocationRepository storageLocationRepository =
      StorageLocationRepositoryImpl(database.storageLocationDao);

  // ==========================================================
  // MASTER ITEM
  // ==========================================================

  GetProductByPlu get getProductByPlu {
    return GetProductByPlu(repository: productRepository);
  }

  GetProductById get getProductById {
    return GetProductById(repository: productRepository);
  }

  CreateProduct get createProduct {
    return CreateProduct(repository: productRepository);
  }

  UpdateProduct get updateProduct {
    return UpdateProduct(repository: productRepository);
  }

  DeleteProduct get deleteProduct {
    return DeleteProduct(repository: productRepository);
  }

  // ==========================================================
  // IMPORT MASTER ITEM
  // ==========================================================

  ImportMasterItemToDatabase get importMasterItemToDatabase {
    return ImportMasterItemToDatabase(productDao: database.productDao);
  }

  // ==========================================================
  // STOCK PALLET
  // ==========================================================

  PutAwayStockPallet get putAwayStockPallet {
    return PutAwayStockPallet(repository: stockPalletRepository);
  }

  UpdateStockPallet get updateStockPallet {
    return UpdateStockPallet(
      productRepository: productRepository,
      stockPalletRepository: stockPalletRepository,
    );
  }

  DeleteStockPallet get deleteStockPallet {
    return DeleteStockPallet(stockPalletRepository: stockPalletRepository);
  }

  // ==========================================================
  // STOCK SUMMARY
  // ==========================================================

  GetStockSummaryByPlu get getStockSummaryByPlu {
    return GetStockSummaryByPlu(repository: stockPalletRepository);
  }

  GetStockSummaryForPlu get getStockSummaryForPlu {
    return GetStockSummaryForPlu(repository: stockPalletRepository);
  }

  GetGrandTotalStockValue get getGrandTotalStockValue {
    return GetGrandTotalStockValue(repository: stockPalletRepository);
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  Future<void> dispose() async {
    await database.close();
  }
}

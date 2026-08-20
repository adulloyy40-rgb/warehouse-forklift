// ============================================================
// FILE:
// lib/domain/repositories/product_repository.dart
// ============================================================
//
// FUNGSI:
// Interface/kontrak Repository untuk Master Item.
//
// Repository berada di antara:
// Presentation / UI
//        ↓
// Repository
//        ↓
// DataSource / Database / Excel
//
// Keuntungan:
// UI tidak perlu mengetahui sumber data sebenarnya.
//
// Hari ini sumber data kita:
// ExcelDataSource
//
// Nanti bisa berkembang menjadi:
// Local Database
// Import Storage
// Sync Database
// ============================================================

import '../entities/product.dart';

// ============================================================
// ABSTRACT CLASS: ProductRepository
// ============================================================
//
// Ini adalah KONTRAK.
//
// Implementasi sebenarnya akan dibuat pada Data Layer.
//
// Contoh:
//
// ProductRepositoryImpl
//        ↓
// ExcelDataSource
//
// atau nantinya:
//
// ProductRepositoryImpl
//        ↓
// Local Database
// ============================================================

abstract class ProductRepository {
  // ==========================================================
  // getAllProducts()
  // ==========================================================
  //
  // Fungsi:
  // Mengambil seluruh Master Item.
  //
  // Return:
  // List<Product>
  //
  // Contoh:
  //
  // 100 data Excel
  //        ↓
  // List<Product>
  // ==========================================================

  Future<List<Product>> getAllProducts();

  // ==========================================================
  // getProductByPlu()
  // ==========================================================
  //
  // Fungsi:
  // Mencari satu barang berdasarkan PLU.
  //
  // Contoh:
  //
  // PLU 5867
  //        ↓
  // AQUA AIR MNRL PET 1500ML
  //
  // Jika tidak ditemukan:
  // return null
  // ==========================================================

  Future<Product?> getProductByPlu(String plu);

  // ==========================================================
  // GET PRODUCT BY BARCODE
  // ==========================================================
  //
  // Fungsi:
  // Mencari satu barang berdasarkan barcode.
  //
  // Digunakan oleh fitur Scan Barcode.
  //
  // Jika barcode ditemukan:
  //   return Product
  //
  // Jika tidak ditemukan:
  //   return null
  // ==========================================================

  Future<Product?> getProductByBarcode(String barcode);

  // ==========================================================
  // searchProducts()
  // ==========================================================
  //
  // Fungsi:
  // Mencari barang berdasarkan:
  //
  // - PLU
  // - Barcode
  // - Description
  //
  // Ini akan menjadi dasar fitur Search Item yang sudah
  // kita rencanakan.
  // ==========================================================

  Future<List<Product>> searchProducts(String query);
}

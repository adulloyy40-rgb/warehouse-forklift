// ============================================================
// FILE:
// lib/domain/repositories/product_repository.dart
// ============================================================
//
// FUNGSI:
// Interface/kontrak Repository untuk Master Barang.
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
  // Mengambil seluruh Master Barang.
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

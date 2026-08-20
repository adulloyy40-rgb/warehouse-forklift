// ============================================================
// FILE:
// lib/domain/usecases/product/get_product_by_id.dart
//
// FUNGSI:
// Use Case untuk mengambil satu Master Item berdasarkan
// ID internal SQLite.
//
// ALUR:
//
// MasterItemDetailPage
//        ↓
// GetProductById
//        ↓
// ProductRepository
//        ↓
// ProductRepositoryImpl
//        ↓
// ProductDao.findById()
//        ↓
// SQLite / Drift
//
// ============================================================

import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

// ============================================================
// CLASS: GetProductById
// ============================================================

class GetProductById {
  // ==========================================================
  // REPOSITORY
  // ==========================================================

  final ProductRepository repository;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const GetProductById({required this.repository});

  // ==========================================================
  // CALL
  // ==========================================================
  //
  // Mengambil satu Master Item berdasarkan ID SQLite.
  //
  // ID harus lebih besar dari 0.
  //
  // Jika ID tidak valid atau data tidak ditemukan:
  // return null.
  // ==========================================================

  Future<Product?> call(int id) async {
    if (id <= 0) {
      return null;
    }

    return repository.getProductById(id);
  }
}

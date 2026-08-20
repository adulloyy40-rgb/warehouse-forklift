// ============================================================
// FILE:
// lib/domain/usecases/product/get_product_by_plu.dart
//
// FUNGSI:
// Mencari Master Item berdasarkan PLU.
//
// ALUR:
//
// UI
//   ↓
// GetProductByPlu
//   ↓
// ProductRepository
//   ↓
// ProductRepositoryImpl
//   ↓
// SQLite / Drift
// ============================================================

import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetProductByPlu {
  final ProductRepository repository;

  const GetProductByPlu({required this.repository});

  Future<Product?> call(String plu) async {
    final normalizedPlu = plu.trim();

    if (normalizedPlu.isEmpty) {
      return null;
    }

    return repository.getProductByPlu(normalizedPlu);
  }
}

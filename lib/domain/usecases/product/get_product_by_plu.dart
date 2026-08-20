// ============================================================
// FILE:
// lib/domain/usecases/product/get_product_by_plu.dart
// ============================================================
//
// FUNGSI:
// Use Case untuk mencari Master Item berdasarkan PLU.
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
// ExcelDataSource
//
// ============================================================

import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

// ============================================================
// CLASS:
// GetProductByPlu
// ============================================================

class GetProductByPlu {
  // ==========================================================
  // REPOSITORY
  // ==========================================================

  final ProductRepository repository;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const GetProductByPlu({required this.repository});

  // ==========================================================
  // CALL
  // ==========================================================
  //
  // Mencari satu produk berdasarkan PLU.
  // ==========================================================

  Future<Product?> call(String plu) async {
    final normalizedPlu = plu.trim();

    // --------------------------------------------------------
    // PLU kosong tidak boleh diproses.
    // --------------------------------------------------------

    if (normalizedPlu.isEmpty) {
      return null;
    }

    // --------------------------------------------------------
    // Delegasikan pencarian kepada repository.
    // --------------------------------------------------------

    return repository.getProductByPlu(normalizedPlu);
  }
}

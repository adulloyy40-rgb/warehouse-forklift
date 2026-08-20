// ============================================================
// FILE:
// lib/domain/usecases/product/delete_product.dart
//
// FUNGSI:
// Menghapus Master Item berdasarkan ID.
// ============================================================

import '../../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository repository;

  const DeleteProduct({required this.repository});

  Future<bool> call(int id) async {
    if (id <= 0) {
      return false;
    }

    return repository.deleteProduct(id);
  }
}

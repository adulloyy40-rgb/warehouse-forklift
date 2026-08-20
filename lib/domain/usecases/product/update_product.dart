// ============================================================
// FILE:
// lib/domain/usecases/product/update_product.dart
//
// FUNGSI:
// Mengubah Master Item yang sudah tersimpan.
// ============================================================

import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository repository;

  const UpdateProduct({required this.repository});

  Future<Product> call(Product product) async {
    final id = product.id;

    if (id == null || id <= 0) {
      throw ArgumentError('ID Master Item wajib tersedia untuk proses edit.');
    }

    return repository.updateProduct(product);
  }
}

// ============================================================
// FILE:
// lib/domain/usecases/product/create_product.dart
//
// FUNGSI:
// Menambahkan Master Item baru ke database.
// ============================================================

import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class CreateProduct {
  final ProductRepository repository;

  const CreateProduct({required this.repository});

  Future<Product> call(Product product) async {
    return repository.createProduct(product);
  }
}

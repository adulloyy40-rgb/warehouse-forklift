// ============================================================
// FILE:
// lib/domain/usecases/product/get_all_products.dart
//
// FUNGSI:
// Mengambil seluruh Master Item melalui ProductRepository.
//
// ALUR:
//
// Presentation
//     ↓
// GetAllProducts
//     ↓
// ProductRepository
//     ↓
// Data Layer
// ============================================================

import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;

  const GetAllProducts({required this.repository});

  Future<List<Product>> call() async {
    return repository.getAllProducts();
  }
}

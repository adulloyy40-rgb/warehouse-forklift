import 'package:drift/drift.dart';

import '../database/app_database.dart' hide Product;
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../database/daos/product_dao.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDao _dao;

  ProductRepositoryImpl(this._dao);

  // ==========================================================
  // GET ALL PRODUCTS
  // ==========================================================
  //
  // Sumber data operasional:
  // SQLite / Drift
  //
  // Excel TIDAK dibaca di sini.
  // Excel hanya digunakan oleh proses import Master Item.
  // ==========================================================

  @override
  Future<List<Product>> getAllProducts() async {
    final rows = await _dao.getAllProducts();

    return rows.map(_mapToProduct).toList();
  }

  // ==========================================================
  // GET PRODUCT BY ID
  // ==========================================================

  @override
  Future<Product?> getProductById(int id) async {
    if (id <= 0) {
      return null;
    }

    final row = await _dao.findById(id);

    if (row == null) {
      return null;
    }

    return _mapToProduct(row);
  }

  // ==========================================================
  // CREATE PRODUCT
  // ==========================================================

  @override
  Future<Product> createProduct(Product product) async {
    final normalized = _normalizeProduct(product);

    final id = await _dao.insertProduct(
      ProductsCompanion.insert(
        barcode: normalized.barcode,
        plu: normalized.plu,
        description: normalized.description,
        price: Value(normalized.price),
        returHari: Value(normalized.returHari),
        conv2: Value(normalized.conv2),
        type: Value(normalized.type),
        masterTear: Value(normalized.masterTear),
        masterStack: Value(normalized.masterStack),
      ),
    );

    final created = await _dao.findById(id);

    if (created == null) {
      throw StateError(
        'Master Item berhasil disimpan tetapi tidak dapat dibaca kembali.',
      );
    }

    return _mapToProduct(created);
  }

  // ==========================================================
  // UPDATE PRODUCT
  // ==========================================================

  @override
  Future<Product> updateProduct(Product product) async {
    final id = product.id;

    if (id == null || id <= 0) {
      throw ArgumentError('ID Master Item wajib tersedia untuk proses edit.');
    }

    final normalized = _normalizeProduct(product);

    final updated = await _dao.updateProductById(
      id,
      ProductsCompanion(
        barcode: Value(normalized.barcode),
        plu: Value(normalized.plu),
        description: Value(normalized.description),
        price: Value(normalized.price),
        returHari: Value(normalized.returHari),
        conv2: Value(normalized.conv2),
        type: Value(normalized.type),
        masterTear: Value(normalized.masterTear),
        masterStack: Value(normalized.masterStack),
      ),
    );

    if (!updated) {
      throw StateError('Master Item dengan ID $id tidak ditemukan.');
    }

    final result = await _dao.findById(id);

    if (result == null) {
      throw StateError(
        'Master Item berhasil diubah tetapi tidak dapat dibaca kembali.',
      );
    }

    return _mapToProduct(result);
  }

  // ==========================================================
  // DELETE PRODUCT
  // ==========================================================

  @override
  Future<bool> deleteProduct(int id) async {
    if (id <= 0) {
      return false;
    }

    final count = await _dao.deleteProductById(id);

    return count > 0;
  }

  // ==========================================================
  // GET PRODUCT BY PLU
  // ==========================================================

  @override
  Future<Product?> getProductByPlu(String plu) async {
    final normalizedPlu = plu.trim();

    if (normalizedPlu.isEmpty) {
      return null;
    }

    final row = await _dao.findByPlu(normalizedPlu);

    if (row == null) {
      return null;
    }

    return _mapToProduct(row);
  }

  // ==========================================================
  // GET PRODUCT BY BARCODE
  // ==========================================================

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();

    if (normalizedBarcode.isEmpty) {
      return null;
    }

    final row = await _dao.findByBarcode(normalizedBarcode);

    if (row == null) {
      return null;
    }

    return _mapToProduct(row);
  }

  // ==========================================================
  // SEARCH PRODUCTS
  // ==========================================================

  @override
  Future<List<Product>> searchProducts(String query) async {
    final normalizedQuery = query.trim();

    final rows = await _dao.searchProducts(normalizedQuery);

    return rows.map(_mapToProduct).toList();
  }

  // ==========================================================
  // MAP DATABASE ROW → DOMAIN ENTITY
  // ==========================================================

  Product _normalizeProduct(Product product) {
    return Product(
      id: product.id,
      barcode: product.barcode.trim(),
      plu: product.plu.trim(),
      description: product.description.trim(),
      price: product.price,
      returHari: product.returHari,
      conv2: product.conv2,
      type: product.type.trim(),
      masterTear: product.masterTear,
      masterStack: product.masterStack,
    );
  }

  Product _mapToProduct(dynamic row) {
    return Product(
      id: row.id,
      barcode: row.barcode,
      plu: row.plu,
      description: row.description,
      price: row.price,
      returHari: row.returHari,
      conv2: row.conv2,
      type: row.type,
      masterTear: row.masterTear,
      masterStack: row.masterStack,
    );
  }
}

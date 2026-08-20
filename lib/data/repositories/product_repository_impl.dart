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

  Product _mapToProduct(dynamic row) {
    return Product(
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

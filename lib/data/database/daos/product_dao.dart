import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/products.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  Future<List<Product>> getAllProducts() {
    return select(products).get();
  }

  Future<Product?> findByBarcode(String barcode) {
    final normalized = barcode.trim();

    return (select(
      products,
    )..where((tbl) => tbl.barcode.equals(normalized))).getSingleOrNull();
  }

  Future<Product?> findByPlu(String plu) {
    final normalized = plu.trim();

    return (select(
      products,
    )..where((tbl) => tbl.plu.equals(normalized))).getSingleOrNull();
  }

  Future<List<Product>> searchProducts(String query) {
    final normalized = query.trim();

    if (normalized.isEmpty) {
      return getAllProducts();
    }

    final pattern = '%$normalized%';

    return (select(products)
          ..where(
            (tbl) =>
                tbl.plu.like(pattern) |
                tbl.barcode.like(pattern) |
                tbl.description.like(pattern),
          )
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.description)]))
        .get();
  }

  Future<int> insertProduct(ProductsCompanion product) {
    return into(products).insert(product);
  }

  Future<void> insertProductsBatch(
    List<Map<String, dynamic>> productList,
  ) async {
    final companions = productList.map((row) {
      return ProductsCompanion.insert(
        barcode: row['barcode'] as String,
        plu: row['plu'] as String,
        description: row['description'] as String,
        price: Value(row['price'] as double),
        returHari: Value(row['returHari'] as int),
        conv2: Value(row['conv2'] as int),
        type: Value(row['type'] as String),
        masterTear: Value(row['masterTear'] as int),
        masterStack: Value(row['masterStack'] as int),
      );
    }).toList();

    await batch((batch) {
      batch.insertAll(products, companions);
    });
  }

  Future<bool> updateProductById(int id, ProductsCompanion product) async {
    final count = await (update(
      products,
    )..where((tbl) => tbl.id.equals(id))).write(product);

    return count > 0;
  }

  Future<int> deleteProductById(int id) {
    return (delete(products)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<Product?> findById(int id) {
    return (select(
      products,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }
}

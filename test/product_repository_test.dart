import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart' as drift_native;

import 'package:warehouse_forklift/data/database/app_database.dart';
import 'package:warehouse_forklift/data/database/daos/product_dao.dart';
import 'package:warehouse_forklift/data/repositories/product_repository_impl.dart';

void main() {
  late AppDatabase database;
  late ProductDao productDao;
  late ProductRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(executor: drift_native.NativeDatabase.memory());

    productDao = database.productDao;

    repository = ProductRepositoryImpl(productDao);

    await productDao.insertProduct(
      ProductsCompanion.insert(
        barcode: '899999999001',
        plu: '5867',
        description: 'AQUA AIR MNRL PET 1500ML',
        price: const drift.Value(4216.94),
        returHari: const drift.Value(60),
        conv2: const drift.Value(12),
        type: const drift.Value('CTN'),
        masterTear: const drift.Value(10),
        masterStack: const drift.Value(20),
      ),
    );

    await productDao.insertProduct(
      ProductsCompanion.insert(
        barcode: '899999999002',
        plu: '7000',
        description: 'TEST PRODUCT',
        price: const drift.Value(10000),
        returHari: const drift.Value(30),
        conv2: const drift.Value(24),
        type: const drift.Value('PCS'),
        masterTear: const drift.Value(5),
        masterStack: const drift.Value(10),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'Repository harus dapat membaca semua Master Item dari SQLite',
    () async {
      final products = await repository.getAllProducts();

      expect(products, hasLength(2));
    },
  );

  test('Repository harus dapat mencari PLU 5867', () async {
    final product = await repository.getProductByPlu('5867');

    expect(product, isNotNull);
    expect(product!.plu, '5867');
  });

  test('PLU 5867 harus memiliki description yang benar', () async {
    final product = await repository.getProductByPlu('5867');

    expect(product, isNotNull);
    expect(product!.description, 'AQUA AIR MNRL PET 1500ML');
  });

  test('Repository harus dapat mencari berdasarkan barcode', () async {
    final product = await repository.getProductByBarcode('899999999001');

    expect(product, isNotNull);
    expect(product!.plu, '5867');
  });

  test('Master Tear harus terbaca dari SQLite', () async {
    final product = await repository.getProductByPlu('5867');

    expect(product, isNotNull);
    expect(product!.masterTear, 10);
  });

  test('Master Stack harus terbaca dari SQLite', () async {
    final product = await repository.getProductByPlu('5867');

    expect(product, isNotNull);
    expect(product!.masterStack, 20);
  });

  test('CONV2 harus terbaca dari SQLite', () async {
    final product = await repository.getProductByPlu('5867');

    expect(product, isNotNull);
    expect(product!.conv2, 12);
  });

  test('Search PLU harus bekerja', () async {
    final products = await repository.searchProducts('5867');

    expect(products, isNotEmpty);
    expect(products.first.plu, '5867');
  });

  test('Search description harus bekerja', () async {
    final products = await repository.searchProducts('AQUA');

    expect(products, isNotEmpty);
    expect(products.first.description, 'AQUA AIR MNRL PET 1500ML');
  });

  test('Search barcode harus bekerja', () async {
    final products = await repository.searchProducts('899999999001');

    expect(products, isNotEmpty);
    expect(products.first.plu, '5867');
  });
}

import 'package:drift/native.dart' as drift_native;
import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/data/database/app_database.dart';
import 'package:warehouse_forklift/data/datasources/excel_data_source.dart';
import 'package:warehouse_forklift/domain/usecases/import_master_item_to_database.dart';

void main() {
  late AppDatabase database;
  late ExcelDataSource dataSource;
  late ImportMasterItemToDatabase importer;

  const excelPath = 'test/fixtures/master_barang.xlsx';

  setUp(() {
    database = AppDatabase(
      executor: drift_native.NativeDatabase.memory(),
    );

    dataSource = ExcelDataSource();

    importer = ImportMasterItemToDatabase(
      productDao: database.productDao,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'Import Master Item dari Excel ke SQLite harus berhasil 100 item',
    () async {
      final rows = await dataSource.readMasterProduct(excelPath);

      expect(rows, hasLength(100));

      final result = await importer.execute(rows: rows);

      expect(result.isSuccess, isTrue);
      expect(result.successCount, 100);
      expect(result.failedCount, 0);
      expect(result.errors, isEmpty);

      final products = await database.productDao.getAllProducts();

      expect(products, hasLength(100));
    },
  );

  test(
    'Data Master Item hasil import harus memiliki field utama',
    () async {
      final rows = await dataSource.readMasterProduct(excelPath);

      final result = await importer.execute(rows: rows);

      expect(result.isSuccess, isTrue);

      final products = await database.productDao.getAllProducts();

      expect(products, isNotEmpty);

      final product = products.first;

      expect(product.barcode, isNotEmpty);
      expect(product.plu, isNotEmpty);
      expect(product.description, isNotEmpty);
    },
  );

  test(
    'Data Master Item hasil import harus dapat dicari berdasarkan PLU',
    () async {
      final rows = await dataSource.readMasterProduct(excelPath);

      await importer.execute(rows: rows);

      final products = await database.productDao.getAllProducts();

      final firstProduct = products.first;

      final result = await database.productDao.findByPlu(
        firstProduct.plu,
      );

      expect(result, isNotNull);
      expect(result!.plu, firstProduct.plu);
      expect(result.barcode, firstProduct.barcode);
    },
  );
}

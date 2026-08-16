// ============================================================
// FILE:
// test/stock_pallet_repository_test.dart
//
// FUNGSI:
// Integration/unit test untuk:
// StockPalletRepositoryImpl
//
// YANG DIUJI:
// 1. Save pallet.
// 2. Menolak location duplikat.
// 3. Get all pallet.
// 4. Find pallet berdasarkan location.
// 5. Find location yang tidak ada.
// 6. Update pallet.
// 7. Menolak update pallet yang belum tersimpan.
// 8. Delete pallet.
// 9. Memastikan pallet benar-benar terhapus.
//
// CATATAN PENTING:
// Test menggunakan:
// NativeDatabase.memory()
//
// Dengan demikian:
// - Tidak membutuhkan path_provider.
// - Tidak membutuhkan Android.
// - Tidak membuat database permanen.
// - Setiap test mendapatkan database baru.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:warehouse_forklift/data/database/app_database.dart';
import 'package:warehouse_forklift/data/repositories/stock_pallet_repository_impl.dart';
import 'package:warehouse_forklift/domain/entities/stock_pallet.dart' as domain;

// ============================================================
// MAIN TEST
// ============================================================

void main() {
  // ==========================================================
  // INITIALIZE FLUTTER TEST BINDING
  // ==========================================================
  //
  // Ini diperlukan karena project kita menggunakan Flutter.
  //
  // Tetapi database test tetap menggunakan:
  // NativeDatabase.memory()
  //
  // sehingga tidak membutuhkan path_provider.
  // ==========================================================

  TestWidgetsFlutterBinding.ensureInitialized();

  // ==========================================================
  // HELPER:
  // CREATE REPOSITORY
  // ==========================================================
  //
  // Setiap test mendapatkan database memory baru.
  //
  // Alur:
  //
  // NativeDatabase.memory()
  //        ↓
  // AppDatabase
  //        ↓
  // StockPalletRepositoryImpl
  // ==========================================================

  Future<(AppDatabase, StockPalletRepositoryImpl)> createRepository() async {
    final database = AppDatabase(executor: NativeDatabase.memory());

    final repository = StockPalletRepositoryImpl(database);

    return (database, repository);
  }

  // ==========================================================
  // HELPER:
  // CREATE PALLET
  // ==========================================================
  //
  // Digunakan oleh semua test supaya data test konsisten.
  // ==========================================================

  domain.StockPallet createPallet({
    String locationCode = '8001101',
    String plu = '100001',
    String barcode = '8991234567890',
    String description = 'Produk Test',
    double price = 15000,
    int returHari = 7,
    int conv2 = 12,
    String type = 'REGULER',
    int tear = 4,
    int stack = 5,
    int qtyCtn = 20,
    int qtyPcs = 240,
    DateTime? expiredDate,
    DateTime? inputDate,
    String operatorNik = '123456789',
    bool sesuaiMaster = true,
  }) {
    return domain.StockPallet(
      locationCode: locationCode,
      plu: plu,
      barcode: barcode,
      description: description,
      price: price,
      returHari: returHari,
      conv2: conv2,
      type: type,
      tear: tear,
      stack: stack,
      qtyCtn: qtyCtn,
      qtyPcs: qtyPcs,
      expiredDate: expiredDate ?? DateTime(2027, 12, 31),
      inputDate: inputDate ?? DateTime(2026, 8, 14, 10, 0),
      operatorNik: operatorNik,
      sesuaiMaster: sesuaiMaster,
    );
  }

  // ==========================================================
  // TEST 1
  // SAVE
  // ==========================================================

  test('save harus menyimpan StockPallet', () async {
    final (database, repository) = await createRepository();

    try {
      final pallet = createPallet();

      await repository.save(pallet);

      final result = await repository.getAll();

      // Harus ada satu pallet.
      expect(result.length, 1);

      // Location.
      expect(result.first.locationCode, '8001101');

      // PLU.
      expect(result.first.plu, '100001');

      // Barcode.
      expect(result.first.barcode, '8991234567890');

      // Harga.
      expect(result.first.price, 15000);

      // Retur hari.
      expect(result.first.returHari, 7);

      // Type.
      expect(result.first.type, 'REGULER');

      // CONV2.
      expect(result.first.conv2, 12);

      // Tear.
      expect(result.first.tear, 4);

      // Stack.
      expect(result.first.stack, 5);

      // Qty CTN.
      expect(result.first.qtyCtn, 20);

      // Qty PCS.
      expect(result.first.qtyPcs, 240);
    } finally {
      await database.close();
    }
  });

  // ==========================================================
  // TEST 2
  // DUPLICATE LOCATION
  // ==========================================================

  test('save harus menolak Location Code duplikat', () async {
    final (database, repository) = await createRepository();

    try {
      final pallet1 = createPallet(locationCode: '8001101');

      final pallet2 = createPallet(locationCode: '8001101', plu: '100002');

      // Simpan pallet pertama.
      await repository.save(pallet1);

      // Pallet kedua menggunakan location
      // yang sama.
      //
      // Repository harus menolak.
      await expectLater(repository.save(pallet2), throwsA(isA<StateError>()));
    } finally {
      await database.close();
    }
  });

  // ==========================================================
  // TEST 3
  // GET ALL
  // ==========================================================

  test('getAll harus mengambil seluruh pallet', () async {
    final (database, repository) = await createRepository();

    try {
      await repository.save(createPallet(locationCode: '8001101'));

      await repository.save(
        createPallet(locationCode: '8001102', plu: '100002'),
      );

      final result = await repository.getAll();

      expect(result.length, 2);

      final locations = result.map((e) => e.locationCode).toList();

      expect(locations, containsAll(['8001101', '8001102']));
    } finally {
      await database.close();
    }
  });

  // ==========================================================
  // TEST 4
  // FIND BY LOCATION
  // ==========================================================

  test('findByLocationCode harus menemukan pallet', () async {
    final (database, repository) = await createRepository();

    try {
      await repository.save(createPallet(locationCode: '8001105'));

      final result = await repository.findByLocationCode('8001105');

      expect(result, isNotNull);

      expect(result!.locationCode, '8001105');

      expect(result.plu, '100001');
    } finally {
      await database.close();
    }
  });

  // ==========================================================
  // TEST 5
  // FIND LOCATION TIDAK ADA
  // ==========================================================

  test('findByLocationCode harus null jika location tidak ditemukan', () async {
    final (database, repository) = await createRepository();

    try {
      final result = await repository.findByLocationCode('9999999');

      expect(result, isNull);
    } finally {
      await database.close();
    }
  });

  // ==========================================================
  // TEST 6
  // UPDATE
  // ==========================================================

  test('update harus mengubah data pallet', () async {
    final (database, repository) = await createRepository();

    try {
      final original = createPallet(
        locationCode: '8001110',
        plu: '100001',
        tear: 4,
        stack: 5,
      );

      await repository.save(original);

      final updatedPallet = createPallet(
        locationCode: '8001110',
        plu: '100999',
        barcode: '8999999999999',
        description: 'Produk Updated',
        price: 25000,
        returHari: 14,
        conv2: 24,
        type: 'PROMO',
        tear: 6,
        stack: 7,
        qtyCtn: 42,
        qtyPcs: 1008,
      );

      await repository.update(updatedPallet);

      final result = await repository.findByLocationCode('8001110');

      expect(result, isNotNull);

      expect(result!.plu, '100999');

      expect(result.barcode, '8999999999999');

      expect(result.description, 'Produk Updated');

      expect(result.price, 25000);

      expect(result.returHari, 14);

      expect(result.conv2, 24);

      expect(result.type, 'PROMO');

      expect(result.tear, 6);

      expect(result.stack, 7);

      expect(result.qtyCtn, 42);

      expect(result.qtyPcs, 1008);
    } finally {
      await database.close();
    }
  });

  // ==========================================================
  // TEST 7
  // UPDATE DATA TIDAK ADA
  // ==========================================================

  test('update harus menolak pallet yang belum tersimpan', () async {
    final (database, repository) = await createRepository();

    try {
      final pallet = createPallet(locationCode: '8888888');

      await expectLater(repository.update(pallet), throwsA(isA<StateError>()));
    } finally {
      await database.close();
    }
  });

  // ==========================================================
  // TEST 8
  // DELETE
  // ==========================================================

  test('delete harus menghapus pallet', () async {
    final (database, repository) = await createRepository();

    try {
      final pallet = createPallet(locationCode: '8010001');

      await repository.save(pallet);

      await repository.deleteByLocationCode(pallet.locationCode);
      final result = await repository.findByLocationCode(pallet.locationCode);

      expect(result, isNull);
    } finally {
      await database.close();
    }
  });
}

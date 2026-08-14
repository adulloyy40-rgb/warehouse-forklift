// ============================================================
// FILE:
// test/stock_pallet_repository_test.dart
// ============================================================
//
// FUNGSI:
// Menguji StockPalletRepositoryImpl.
//
// Yang diuji:
// - Menyimpan StockPallet.
// - Menolak Location Code duplikat.
// - Mengambil seluruh pallet.
// - Mencari pallet berdasarkan Location Code.
// - Update pallet.
// - Menolak update pallet yang belum tersimpan.
// - Menghapus pallet.
// - Memastikan pallet benar-benar terhapus.
//
// CATATAN:
// Repository menggunakan StateError untuk kondisi bisnis
// seperti data duplikat atau data tidak ditemukan.
//
// Karena itu test menggunakan:
//
// throwsA(isA<StateError>())
//
// bukan:
//
// throwsA(isA<Exception>())
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/data/repositories/stock_pallet_repository_impl.dart';
import 'package:warehouse_forklift/domain/entities/stock_pallet.dart';

void main() {
  // ==========================================================
  // HELPER:
  // Membuat StockPallet untuk kebutuhan testing.
  // ==========================================================

  StockPallet createPallet({
    String locationCode = '8001101',
    String plu = '100001',
    String description = 'Produk Test',
    int tear = 4,
    int stack = 5,
    int qtyCtn = 20,
    int qtyPcs = 240,
    int conv2 = 12,
    DateTime? expiredDate,
    DateTime? inputDate,
    String operatorNik = '123456789',
    bool sesuaiMaster = true,
  }) {
    return StockPallet(
      locationCode: locationCode,
      plu: plu,
      description: description,
      tear: tear,
      stack: stack,
      qtyCtn: qtyCtn,
      qtyPcs: qtyPcs,
      conv2: conv2,
      expiredDate:
          expiredDate ?? DateTime(2027, 12, 31),
      inputDate:
          inputDate ?? DateTime(2026, 8, 14, 10, 0),
      operatorNik: operatorNik,
      sesuaiMaster: sesuaiMaster,
    );
  }

  // ==========================================================
  // TEST 1
  //
  // FUNGSI:
  // Memastikan repository dapat menyimpan pallet.
  // ==========================================================

  test(
    'save harus menyimpan StockPallet',
    () async {
      // Membuat repository baru.
      final repository = StockPalletRepositoryImpl();

      // Membuat pallet.
      final pallet = createPallet();

      // Menyimpan pallet.
      await repository.save(pallet);

      // Mengambil semua data.
      final result = await repository.getAll();

      // Harus terdapat satu pallet.
      expect(result.length, 1);

      // Location Code harus sesuai.
      expect(
        result.first.locationCode,
        '8001101',
      );

      // PLU harus sesuai.
      expect(
        result.first.plu,
        '100001',
      );
    },
  );

  // ==========================================================
  // TEST 2
  //
  // FUNGSI:
  // Memastikan pallet kedua dengan Location Code yang sama
  // ditolak.
  // ==========================================================

  test(
    'save harus menolak Location Code duplikat',
    () async {
      // Repository baru.
      final repository = StockPalletRepositoryImpl();

      // Pallet pertama.
      final pallet1 = createPallet(
        locationCode: '8001101',
        plu: '100001',
      );

      // Pallet kedua menggunakan lokasi yang sama.
      final pallet2 = createPallet(
        locationCode: '8001101',
        plu: '100002',
      );

      // Simpan pallet pertama.
      await repository.save(pallet1);

      // Pallet kedua harus ditolak.
      //
      // Repository menggunakan StateError
      // untuk Location Code yang sudah digunakan.
      await expectLater(
        repository.save(pallet2),
        throwsA(isA<StateError>()),
      );
    },
  );

  // ==========================================================
  // TEST 3
  //
  // FUNGSI:
  // Memastikan getAll() mengembalikan seluruh pallet.
  // ==========================================================

  test(
    'getAll harus mengembalikan seluruh StockPallet',
    () async {
      // Repository baru.
      final repository = StockPalletRepositoryImpl();

      // Membuat dua pallet berbeda.
      final pallet1 = createPallet(
        locationCode: '8001101',
        plu: '100001',
      );

      final pallet2 = createPallet(
        locationCode: '8001201',
        plu: '100002',
      );

      // Menyimpan keduanya.
      await repository.save(pallet1);
      await repository.save(pallet2);

      // Mengambil seluruh pallet.
      final result = await repository.getAll();

      // Harus ada dua pallet.
      expect(result.length, 2);

      // Pastikan lokasi pertama ada.
      expect(
        result.any(
          (pallet) =>
              pallet.locationCode == '8001101',
        ),
        true,
      );

      // Pastikan lokasi kedua ada.
      expect(
        result.any(
          (pallet) =>
              pallet.locationCode == '8001201',
        ),
        true,
      );
    },
  );

  // ==========================================================
  // TEST 4
  //
  // FUNGSI:
  // Memastikan findByLocationCode()
  // dapat menemukan pallet.
  // ==========================================================

  test(
    'findByLocationCode harus menemukan pallet',
    () async {
      // Repository baru.
      final repository = StockPalletRepositoryImpl();

      // Membuat pallet.
      final pallet = createPallet(
        locationCode: '8001101',
      );

      // Simpan pallet.
      await repository.save(pallet);

      // Cari berdasarkan Location Code.
      final result =
          await repository.findByLocationCode(
        '8001101',
      );

      // Data harus ditemukan.
      expect(result, isNotNull);

      // Pastikan Location Code benar.
      expect(
        result!.locationCode,
        '8001101',
      );
    },
  );

  // ==========================================================
  // TEST 5
  //
  // FUNGSI:
  // Memastikan findByLocationCode()
  // mengembalikan null jika lokasi tidak ditemukan.
  // ==========================================================

  test(
    'findByLocationCode harus null jika lokasi tidak ditemukan',
    () async {
      // Repository baru.
      final repository = StockPalletRepositoryImpl();

      // Cari lokasi yang belum ada.
      final result =
          await repository.findByLocationCode(
        '9999999',
      );

      // Harus null.
      expect(result, isNull);
    },
  );

  // ==========================================================
  // TEST 6
  //
  // FUNGSI:
  // Memastikan update() dapat memperbarui pallet.
  // ==========================================================

  test(
    'update harus memperbarui StockPallet',
    () async {
      // Repository baru.
      final repository = StockPalletRepositoryImpl();

      // Pallet awal.
      final pallet = createPallet(
        locationCode: '8001101',
        tear: 4,
        stack: 5,
        qtyCtn: 20,
        qtyPcs: 240,
      );

      // Simpan pallet awal.
      await repository.save(pallet);

      // Membuat data yang sudah diperbarui.
      final updatedPallet = createPallet(
        locationCode: '8001101',
        tear: 6,
        stack: 5,
        qtyCtn: 30,
        qtyPcs: 360,
        sesuaiMaster: false,
      );

      // Update pallet.
      await repository.update(updatedPallet);

      // Ambil kembali data.
      final result =
          await repository.findByLocationCode(
        '8001101',
      );

      // Data harus ditemukan.
      expect(result, isNotNull);

      // Pastikan nilai sudah berubah.
      expect(result!.tear, 6);
      expect(result.stack, 5);
      expect(result.qtyCtn, 30);
      expect(result.qtyPcs, 360);

      // Status master juga berubah.
      expect(
        result.sesuaiMaster,
        false,
      );
    },
  );

  // ==========================================================
  // TEST 7
  //
  // FUNGSI:
  // Memastikan update() menolak pallet yang belum tersimpan.
  //
  // Repository menggunakan StateError.
  // ==========================================================

  test(
    'update harus menolak pallet yang belum tersimpan',
    () async {
      // Repository baru.
      final repository = StockPalletRepositoryImpl();

      // Pallet belum pernah disimpan.
      final pallet = createPallet(
        locationCode: '8001101',
      );

      // Update harus gagal.
      await expectLater(
        repository.update(pallet),
        throwsA(isA<StateError>()),
      );
    },
  );

  // ==========================================================
  // TEST 8
  //
  // FUNGSI:
  // Memastikan deleteByLocationCode()
  // menghapus pallet.
  // ==========================================================

  test(
    'deleteByLocationCode harus menghapus pallet',
    () async {
      // Repository baru.
      final repository = StockPalletRepositoryImpl();

      // Membuat pallet.
      final pallet = createPallet(
        locationCode: '8001101',
      );

      // Simpan pallet.
      await repository.save(pallet);

      // Pastikan data ada.
      expect(
        await repository.findByLocationCode(
          '8001101',
        ),
        isNotNull,
      );

      // Hapus pallet.
      await repository.deleteByLocationCode(
        '8001101',
      );

      // Pastikan data sudah tidak ada.
      expect(
        await repository.findByLocationCode(
          '8001101',
        ),
        isNull,
      );
    },
  );

  // ==========================================================
  // TEST 9
  //
  // FUNGSI:
  // Memastikan delete lokasi yang tidak ada
  // menghasilkan StateError.
  // ==========================================================

  test(
  'deleteByLocationCode aman untuk lokasi yang tidak ditemukan',
  () async {
    // Membuat repository baru.
    final repository =
        StockPalletRepositoryImpl();

    // Memastikan lokasi memang belum ada.
    final beforeDelete =
        await repository.findByLocationCode(
      '9999999',
    );

    expect(
      beforeDelete,
      isNull,
    );

    // Memanggil delete pada lokasi yang belum ada.
    //
    // Tidak boleh menyebabkan test gagal.
    await repository.deleteByLocationCode(
      '9999999',
    );

    // Pastikan lokasi tetap tidak ada.
    final afterDelete =
        await repository.findByLocationCode(
      '9999999',
    );

    expect(
      afterDelete,
      isNull,
    );
  },
);
  // ==========================================================
  // TEST 10
  //
  // FUNGSI:
  // Memastikan dua pallet dengan Location Code berbeda
  // dapat disimpan bersamaan.
  // ==========================================================
test(
    'dua pallet dengan lokasi berbeda harus dapat disimpan',
    () async {
      // Repository baru.
      final repository = StockPalletRepositoryImpl();

      // Pallet pertama.
      final pallet1 = createPallet(
        locationCode: '8001101',
        plu: '100001',
      );

      // Pallet kedua.
      final pallet2 = createPallet(
        locationCode: '8001201',
        plu: '100002',
      );

      // Simpan keduanya.
      await repository.save(pallet1);
      await repository.save(pallet2);

      // Ambil semua data.
      final result = await repository.getAll();

      // Harus terdapat dua pallet.
      expect(result.length, 2);
    },
  );
}


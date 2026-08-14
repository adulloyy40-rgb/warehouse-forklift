// ============================================================
// FILE:
// test/product_repository_test.dart
// ============================================================
//
// FUNGSI:
// Menguji ProductRepositoryImpl.
//
// Yang diuji:
//
// 1. Semua Master Barang dapat dibaca.
// 2. PLU 5867 dapat ditemukan.
// 3. Description AQUA dapat ditemukan.
// 4. Barcode dapat digunakan untuk search.
// 5. Master Tear terbaca.
// 6. Master Stack terbaca.
// 7. CONV2 terbaca.
// 8. Search PLU bekerja.
// 9. Search Description bekerja.
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/data/repositories/product_repository_impl.dart';


// ============================================================
// main()
// ============================================================
//
// Entry point seluruh pengujian Repository.
// ============================================================

void main() {
  // ==========================================================
  // Lokasi file Excel untuk TEST.
  // ==========================================================
  //
  // File ini sudah kita siapkan sebelumnya:
  //
  // test/fixtures/master_barang.xlsx
  // ==========================================================

  const excelPath =
      'test/fixtures/master_barang.xlsx';


  // ==========================================================
  // Membuat Repository yang akan digunakan oleh semua test.
  // ==========================================================

  late ProductRepositoryImpl repository;


  // ==========================================================
  // setUp()
  // ==========================================================
  //
  // Dijalankan sebelum setiap test.
  //
  // Tujuannya memastikan setiap test mendapatkan Repository
  // dengan konfigurasi yang sama.
  // ==========================================================

  setUp(() {
    repository = ProductRepositoryImpl(
      excelFilePath: excelPath,
    );
  });


  // ==========================================================
  // TEST 1
  // ==========================================================
  //
  // Memastikan Master Barang berhasil dibaca.
  // ==========================================================

  test(
    'Repository harus dapat membaca Master Barang',
    () async {
      // Mengambil seluruh produk.
      final products =
          await repository.getAllProducts();

      // Data tidak boleh kosong.
      expect(products, isNotEmpty);

      // Dataset kita berisi 100 Master Barang.
      expect(products.length, 100);
    },
  );


  // ==========================================================
  // TEST 2
  // ==========================================================
  //
  // Memastikan PLU 5867 dapat ditemukan.
  // ==========================================================

  test(
    'Repository harus dapat mencari PLU 5867',
    () async {
      // Mencari produk berdasarkan PLU.
      final product =
          await repository.getProductByPlu('5867');

      // Produk harus ditemukan.
      expect(product, isNotNull);

      // PLU harus benar.
      expect(product!.plu, '5867');
    },
  );


  // ==========================================================
  // TEST 3
  // ==========================================================
  //
  // Memastikan Description barang PLU 5867 benar.
  // ==========================================================

  test(
    'PLU 5867 harus memiliki description yang benar',
    () async {
      final product =
          await repository.getProductByPlu('5867');

      // Produk harus ditemukan.
      expect(product, isNotNull);

      // Description harus sesuai Master Barang.
      expect(
        product!.description,
        'AQUA AIR MNRL PET 1500ML',
      );
    },
  );


  // ==========================================================
  // TEST 4
  // ==========================================================
  //
  // Memastikan CONV2 terbaca.
  // ==========================================================

  test(
    'PLU 5867 harus memiliki CONV2 yang benar',
    () async {
      final product =
          await repository.getProductByPlu('5867');

      expect(product, isNotNull);

      // CONV2 Master Barang harus 12.
      expect(product!.conv2, 12);
    },
  );


  // ==========================================================
  // TEST 5
  // ==========================================================
  //
  // Memastikan Master Tear terbaca.
  // ==========================================================

  test(
    'PLU 5867 harus memiliki Master Tear yang benar',
    () async {
      final product =
          await repository.getProductByPlu('5867');

      expect(product, isNotNull);

      // Master Tear harus 8.
      expect(product!.masterTear, 8);
    },
  );


  // ==========================================================
  // TEST 6
  // ==========================================================
  //
  // Memastikan Master Stack terbaca.
  // ==========================================================

  test(
    'PLU 5867 harus memiliki Master Stack yang benar',
    () async {
      final product =
          await repository.getProductByPlu('5867');

      expect(product, isNotNull);

      // Master Stack harus 4.
      expect(product!.masterStack, 4);
    },
  );


  // ==========================================================
  // TEST 7
  // ==========================================================
  //
  // Search berdasarkan PLU.
  // ==========================================================

  test(
    'Search PLU 5867 harus berhasil',
    () async {
      final results =
          await repository.searchProducts('5867');

      // Hasil tidak boleh kosong.
      expect(results, isNotEmpty);

      // Salah satu hasil harus memiliki PLU 5867.
      expect(
        results.any(
          (product) => product.plu == '5867',
        ),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 8
  // ==========================================================
  //
  // Search berdasarkan Description.
  // ==========================================================

  test(
    'Search description AQUA harus berhasil',
    () async {
      final results =
          await repository.searchProducts('AQUA');

      // Hasil harus ditemukan.
      expect(results, isNotEmpty);

      // Harus ada produk yang description-nya mengandung AQUA.
      expect(
        results.any(
          (product) =>
              product.description
                  .toUpperCase()
                  .contains('AQUA'),
        ),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 9
  // ==========================================================
  //
  // Search tidak case-sensitive.
  //
  // "aqua" harus tetap menemukan "AQUA".
  // ==========================================================

  test(
    'Search harus tidak case-sensitive',
    () async {
      final results =
          await repository.searchProducts('aqua');

      // Harus tetap menemukan barang.
      expect(results, isNotEmpty);
    },
  );


  // ==========================================================
  // TEST 10
  // ==========================================================
  //
  // Search kosong harus mengembalikan seluruh produk.
  // ==========================================================

  test(
    'Search kosong harus mengembalikan semua produk',
    () async {
      final results =
          await repository.searchProducts('');

      // Jumlah harus sama dengan seluruh Master Barang.
      expect(results.length, 100);
    },
  );


  // ==========================================================
  // TEST 11
  // ==========================================================
  //
  // PLU yang tidak ada harus menghasilkan null.
  // ==========================================================

  test(
    'PLU yang tidak ditemukan harus menghasilkan null',
    () async {
      final product =
          await repository.getProductByPlu('999999');

      // Tidak boleh ada produk.
      expect(product, isNull);
    },
  );
}

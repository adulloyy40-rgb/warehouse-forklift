// ============================================================
// FILE:
// test/excel_data_source_test.dart
// ============================================================
//
// FUNGSI:
// Menguji pembacaan Master Item dari Excel.
//
// Excel asli:
// BARCODE
// PLU
// PRICE
// DESC
// RETUR HARI
// C2
// TYPE
// STACK
// TEAR
//
// Setelah dibaca oleh ExcelDataSource, data dipetakan menjadi:
//
// barcode
// plu
// price
// description
// returHari
// conv2
// type
// masterStack
// masterTear
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/data/datasources/excel_data_source.dart';

void main() {
  // ==========================================================
  // LOKASI FILE EXCEL MASTER ITEM
  // ==========================================================

  const excelPath = 'test/fixtures/master_barang.xlsx';


  // ==========================================================
  // TEST 1
  // ==========================================================
  //
  // Memastikan file Excel dapat dibaca.
  // ==========================================================

  test(
    'Excel Master Item harus dapat dibaca',
    () async {
      // Membuat ExcelDataSource.
      final dataSource = ExcelDataSource();

      // Membaca file Excel.
      final rows = await dataSource.readMasterProduct(
        excelPath,
      );

      // Memastikan data tidak kosong.
      expect(rows, isNotEmpty);
    },
  );


  // ==========================================================
  // TEST 2
  // ==========================================================
  //
  // Memastikan jumlah Master Item adalah 100.
  // ==========================================================

  test(
    'Master Item harus memiliki 100 item',
    () async {
      // Membuat ExcelDataSource.
      final dataSource = ExcelDataSource();

      // Membaca Master Item.
      final rows = await dataSource.readMasterProduct(
        excelPath,
      );

      // Memastikan jumlah barang tepat 100.
      expect(rows.length, 100);
    },
  );


  // ==========================================================
  // TEST 3
  // ==========================================================
  //
  // Memastikan field hasil mapping datasource tersedia.
  // ==========================================================

  test(
    'Data Master harus memiliki field aplikasi yang benar',
    () async {
      // Membuat ExcelDataSource.
      final dataSource = ExcelDataSource();

      // Membaca Master Item.
      final rows = await dataSource.readMasterProduct(
        excelPath,
      );

      // Mengambil barang pertama.
      final firstRow = rows.first;

      // ------------------------------------------------------
      // Field barcode.
      // ------------------------------------------------------

      expect(
        firstRow.containsKey('barcode'),
        isTrue,
      );

      // ------------------------------------------------------
      // Field PLU.
      // ------------------------------------------------------

      expect(
        firstRow.containsKey('plu'),
        isTrue,
      );

      // ------------------------------------------------------
      // Field description.
      // ------------------------------------------------------

      expect(
        firstRow.containsKey('description'),
        isTrue,
      );

      // ------------------------------------------------------
      // Field price.
      // ------------------------------------------------------

      expect(
        firstRow.containsKey('price'),
        isTrue,
      );

      // ------------------------------------------------------
      // Field retur hari.
      // ------------------------------------------------------

      expect(
        firstRow.containsKey('returHari'),
        isTrue,
      );

      // ------------------------------------------------------
      // Field conv2.
      //
      // Berasal dari Excel C2.
      // ------------------------------------------------------

      expect(
        firstRow.containsKey('conv2'),
        isTrue,
      );

      // ------------------------------------------------------
      // Field type.
      // ------------------------------------------------------

      expect(
        firstRow.containsKey('type'),
        isTrue,
      );

      // ------------------------------------------------------
      // Field master stack.
      //
      // Berasal dari Excel STACK.
      // ------------------------------------------------------

      expect(
        firstRow.containsKey('masterStack'),
        isTrue,
      );

      // ------------------------------------------------------
      // Field master tear.
      //
      // Berasal dari Excel TEAR.
      // ------------------------------------------------------

      expect(
        firstRow.containsKey('masterTear'),
        isTrue,
      );
    },
  );


  // ==========================================================
  // TEST 4
  // ==========================================================
  //
  // Memastikan PLU 5867 dapat ditemukan.
  //
  // Data Excel:
  //
  // PLU  = 5867
  // DESC = AQUA AIR MNRL PET 1500ML
  // ==========================================================

  test(
    'PLU 5867 harus dapat ditemukan',
    () async {
      // Membuat ExcelDataSource.
      final dataSource = ExcelDataSource();

      // Membaca Master Item.
      final rows = await dataSource.readMasterProduct(
        excelPath,
      );

      // Mencari PLU 5867.
      final matches = rows.where(
        (row) =>
            row['plu']?.toString().trim() == '5867',
      );

      // Memastikan PLU ditemukan.
      expect(
        matches,
        isNotEmpty,
      );

      // Mengambil data PLU 5867.
      final product = matches.first;

      // Memastikan deskripsi benar.
      expect(
        product['description']?.toString().trim(),
        'AQUA AIR MNRL PET 1500ML',
      );
    },
  );


  // ==========================================================
  // TEST 5
  // ==========================================================
  //
  // Memastikan mapping:
  //
  // Excel C2    → conv2
  // Excel STACK → masterStack
  // Excel TEAR  → masterTear
  //
  // Untuk PLU 5867 kita harapkan:
  //
  // C2    = 12
  // STACK = 4
  // TEAR  = 8
  // ==========================================================

  test(
    'PLU 5867 harus memiliki mapping C2, STACK, dan TEAR yang benar',
    () async {
      // Membuat ExcelDataSource.
      final dataSource = ExcelDataSource();

      // Membaca Master Item.
      final rows = await dataSource.readMasterProduct(
        excelPath,
      );

      // Mencari PLU 5867.
      final matches = rows.where(
        (row) =>
            row['plu']?.toString().trim() == '5867',
      );

      // Memastikan barang ditemukan.
      expect(
        matches,
        isNotEmpty,
      );

      // Mengambil data barang.
      final product = matches.first;

      // ------------------------------------------------------
      // C2 Excel → conv2 aplikasi.
      // ------------------------------------------------------

      expect(
        product['conv2'],
        12,
      );

      // ------------------------------------------------------
      // STACK Excel → masterStack aplikasi.
      // ------------------------------------------------------

      expect(
        product['masterStack'],
        4,
      );

      // ------------------------------------------------------
      // TEAR Excel → masterTear aplikasi.
      // ------------------------------------------------------

      expect(
        product['masterTear'],
        8,
      );
    },
  );


  // ==========================================================
  // TEST 6
  // ==========================================================
  //
  // Memastikan data PLU 5867 lengkap.
  // ==========================================================

  test(
    'Data PLU 5867 harus lengkap',
    () async {
      // Membuat ExcelDataSource.
      final dataSource = ExcelDataSource();

      // Membaca Master Item.
      final rows = await dataSource.readMasterProduct(
        excelPath,
      );

      // Mencari PLU 5867.
      final product = rows.firstWhere(
        (row) =>
            row['plu']?.toString().trim() == '5867',
      );

      // Memastikan barcode tersedia.
      expect(
        product['barcode'],
        isNotEmpty,
      );

      // Memastikan PLU benar.
      expect(
        product['plu'],
        '5867',
      );

      // Memastikan deskripsi benar.
      expect(
        product['description'],
        'AQUA AIR MNRL PET 1500ML',
      );

      // Memastikan harga lebih besar dari nol.
      expect(
        product['price'],
        greaterThan(0),
      );

      // Memastikan retur hari tersedia.
      expect(
        product['returHari'],
        30,
      );

      // Memastikan CONV2 tersedia.
      expect(
        product['conv2'],
        12,
      );

      // Memastikan TYPE tersedia.
      expect(
        product['type'],
        'F',
      );

      // Memastikan Master Stack benar.
      expect(
        product['masterStack'],
        4,
      );

      // Memastikan Master Tear benar.
      expect(
        product['masterTear'],
        8,
      );
    },
  );
}

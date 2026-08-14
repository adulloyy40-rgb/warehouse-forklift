// ============================================================
// FILE:
// test/storage_excel_data_source_test.dart
// ============================================================
//
// FUNGSI:
// Unit test untuk:
//
// StorageExcelDataSource
//
// TEST YANG DILAKUKAN:
//
// 1. DataSource dapat dibuat.
// 2. File Excel .xlsx kosong secara struktur dapat dibaca.
// 3. Excel tanpa data menghasilkan list kosong.
// 4. readValidLocations() tidak menghasilkan lokasi jika
//    Excel tidak mempunyai data.
// 5. LocationValidator terpasang dengan benar.
//
// PENTING:
// Kita TIDAK menggunakan Uint8List kosong sebagai Excel.
//
// Karena package excel membutuhkan file .xlsx yang valid.
//
// Untuk membuat workbook test, kita menggunakan package excel
// langsung di dalam test.
// ============================================================

import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/data/datasources/storage_excel_data_source.dart';
import 'package:warehouse_forklift/domain/validators/location_validator.dart';


// ============================================================
// MAIN
// ============================================================

void main() {

  // ==========================================================
  // DATASOURCE
  // ==========================================================
  //
  // DataSource akan dibuat ulang sebelum setiap test.
  // ==========================================================

  late StorageExcelDataSource dataSource;


  // ==========================================================
  // SETUP
  // ==========================================================
  //
  // setUp() dijalankan sebelum setiap test.
  // ==========================================================

  setUp(() {

    dataSource = StorageExcelDataSource(
      locationValidator: LocationValidator(),
    );
  });


  // ==========================================================
  // HELPER:
  // _createEmptyExcel()
  // ==========================================================
  //
  // Membuat file Excel .xlsx VALID tetapi tidak mempunyai
  // baris data.
  //
  // Ini jauh lebih benar daripada:
  //
  // Uint8List.fromList(<int>[])
  //
  // karena bytes kosong bukan file Excel.
  // ==========================================================

  Uint8List createEmptyExcel() {

    // Membuat workbook baru.

    final excel = Excel.createExcel();


    // Mengambil sheet pertama.

    final sheetName = excel.getDefaultSheet();

    if (sheetName == null) {
      throw StateError(
        'Default Excel sheet tidak tersedia.',
      );
    }


    // --------------------------------------------------------
    // Tambahkan header saja.
    //
    // Dengan adanya header, Excel benar-benar mempunyai
    // struktur tabel tetapi belum mempunyai data.
    // --------------------------------------------------------

    final sheet = excel[sheetName];

    sheet.appendRow([
      TextCellValue('RACK'),
      TextCellValue('BAY'),
      TextCellValue('SHELVING'),
      TextCellValue('POSITION'),
    ]);


    // --------------------------------------------------------
    // Encode workbook menjadi .xlsx.
    // --------------------------------------------------------

    final bytes = excel.encode();

    if (bytes == null || bytes.isEmpty) {
      throw StateError(
        'Gagal membuat bytes Excel test.',
      );
    }


    return Uint8List.fromList(bytes);
  }


  // ==========================================================
  // GROUP
  // ==========================================================

  group(
    'StorageExcelDataSource',
    () {


      // ======================================================
      // TEST 1
      // ======================================================

      test(
        'DataSource harus dapat dibuat',
        () {

          expect(
            dataSource,
            isA<StorageExcelDataSource>(),
          );
        },
      );


      // ======================================================
      // TEST 2
      // ======================================================
      //
      // Excel valid tetapi hanya mempunyai header.
      //
      // Tidak boleh ada data yang terbaca.
      // ======================================================

      test(
        'Excel hanya header menghasilkan data kosong',
        () {

          final bytes = createEmptyExcel();


          final result = dataSource.read(
            bytes,
          );


          expect(
            result,
            isEmpty,
          );
        },
      );


      // ======================================================
      // TEST 3
      // ======================================================
      //
      // readValidLocations() juga harus menghasilkan
      // list kosong jika Excel hanya berisi header.
      // ======================================================

      test(
        'Excel hanya header menghasilkan lokasi valid kosong',
        () {

          final bytes = createEmptyExcel();


          final result =
              dataSource.readValidLocations(
            bytes,
          );


          expect(
            result,
            isEmpty,
          );
        },
      );


      // ======================================================
      // TEST 4
      // ======================================================
      //
      // Pastikan LocationValidator terpasang.
      // ======================================================

      test(
        'DataSource memiliki validator lokasi',
        () {

          expect(
            dataSource.locationValidator,
            isA<LocationValidator>(),
          );
        },
      );
    },
  );
}

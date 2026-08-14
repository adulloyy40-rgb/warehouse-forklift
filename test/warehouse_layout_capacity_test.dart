// ============================================================
// FILE:
// test/warehouse_layout_capacity_test.dart
// ============================================================
//
// FUNGSI:
// Memastikan seluruh layout Rack gudang menghasilkan tepat
// 1.860 lokasi pallet.
//
// Layout yang digunakan:
//
// Rack 80:
// 7 Bay × 6 Shelving × 3 Position = 126 lokasi
//
// Rack 81–90:
// 10 Rack × 7 Bay × 5 Shelving × 3 Position
// = 1.050 lokasi
//
// Rack 91–94:
// 4 Rack × 7 Bay × 6 Shelving × 3 Position
// = 504 lokasi
//
// Rack 95–96:
// 2 Rack × 5 Bay × 6 Shelving × 3 Position
// = 180 lokasi
//
// TOTAL:
// 126 + 1.050 + 504 + 180
// = 1.860 lokasi
//
// TEST INI TIDAK:
// - membaca Excel
// - menggunakan database
// - mengubah data
//
// Test hanya memastikan generator lokasi sesuai layout.
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/core/utils/location_code_generator.dart';

void main() {
  // ==========================================================
  // TEST 1
  //
  // Memastikan Rack 80 mempunyai 126 lokasi.
  // ==========================================================

  test('Rack 80 harus memiliki 126 lokasi', () {
    final List<String> locations =
        LocationCodeGenerator.generateRackLocations(80);

    expect(locations.length, 126);
  });


  // ==========================================================
  // TEST 2
  //
  // Memastikan setiap Rack 81–90 mempunyai 105 lokasi.
  //
  // 7 Bay × 5 Shelving × 3 Position
  // = 105 lokasi.
  // ==========================================================

  test('Rack 81-90 masing-masing harus memiliki 105 lokasi', () {
    for (int rack = 81; rack <= 90; rack++) {
      final List<String> locations =
          LocationCodeGenerator.generateRackLocations(rack);

      expect(
        locations.length,
        105,
        reason: 'Rack $rack harus memiliki 105 lokasi.',
      );
    }
  });


  // ==========================================================
  // TEST 3
  //
  // Memastikan setiap Rack 91–94 mempunyai 126 lokasi.
  //
  // 7 Bay × 6 Shelving × 3 Position
  // = 126 lokasi.
  // ==========================================================

  test('Rack 91-94 masing-masing harus memiliki 126 lokasi', () {
    for (int rack = 91; rack <= 94; rack++) {
      final List<String> locations =
          LocationCodeGenerator.generateRackLocations(rack);

      expect(
        locations.length,
        126,
        reason: 'Rack $rack harus memiliki 126 lokasi.',
      );
    }
  });


  // ==========================================================
  // TEST 4
  //
  // Memastikan Rack 95–96 mempunyai 90 lokasi.
  //
  // 5 Bay × 6 Shelving × 3 Position
  // = 90 lokasi.
  // ==========================================================

  test('Rack 95-96 masing-masing harus memiliki 90 lokasi', () {
    for (int rack = 95; rack <= 96; rack++) {
      final List<String> locations =
          LocationCodeGenerator.generateRackLocations(rack);

      expect(
        locations.length,
        90,
        reason: 'Rack $rack harus memiliki 90 lokasi.',
      );
    }
  });


  // ==========================================================
  // TEST 5
  //
  // Memastikan total seluruh layout adalah 1.860 lokasi.
  //
  // Rack 80       = 126
  // Rack 81–90    = 1.050
  // Rack 91–94    = 504
  // Rack 95–96    = 180
  //
  // TOTAL         = 1.860
  // ==========================================================

  test('Seluruh layout harus memiliki total 1860 lokasi', () {
    final List<String> allLocations = <String>[];

    // --------------------------------------------------------
    // Rack 80
    // --------------------------------------------------------

    allLocations.addAll(
      LocationCodeGenerator.generateRackLocations(80),
    );


    // --------------------------------------------------------
    // Rack 81–90
    // --------------------------------------------------------

    for (int rack = 81; rack <= 90; rack++) {
      allLocations.addAll(
        LocationCodeGenerator.generateRackLocations(rack),
      );
    }


    // --------------------------------------------------------
    // Rack 91–94
    // --------------------------------------------------------

    for (int rack = 91; rack <= 94; rack++) {
      allLocations.addAll(
        LocationCodeGenerator.generateRackLocations(rack),
      );
    }


    // --------------------------------------------------------
    // Rack 95–96
    // --------------------------------------------------------

    for (int rack = 95; rack <= 96; rack++) {
      allLocations.addAll(
        LocationCodeGenerator.generateRackLocations(rack),
      );
    }


    // --------------------------------------------------------
    // Validasi total.
    // --------------------------------------------------------

    expect(
      allLocations.length,
      1860,
    );
  });


  // ==========================================================
  // TEST 6
  //
  // Memastikan tidak ada kode lokasi yang duplikat.
  //
  // Ini sangat penting karena kode lokasi nantinya menjadi
  // identitas unik posisi pallet.
  // ==========================================================

  test('Seluruh kode lokasi harus unik', () {
    final Set<String> uniqueLocations = <String>{};


    // Rack 80.
    uniqueLocations.addAll(
      LocationCodeGenerator.generateRackLocations(80),
    );


    // Rack 81–90.
    for (int rack = 81; rack <= 90; rack++) {
      uniqueLocations.addAll(
        LocationCodeGenerator.generateRackLocations(rack),
      );
    }


    // Rack 91–94.
    for (int rack = 91; rack <= 94; rack++) {
      uniqueLocations.addAll(
        LocationCodeGenerator.generateRackLocations(rack),
      );
    }


    // Rack 95–96.
    for (int rack = 95; rack <= 96; rack++) {
      uniqueLocations.addAll(
        LocationCodeGenerator.generateRackLocations(rack),
      );
    }


    // Jika jumlah Set sama dengan 1.860,
    // berarti tidak ada kode lokasi yang duplikat.
    expect(
      uniqueLocations.length,
      1860,
    );
  });
}

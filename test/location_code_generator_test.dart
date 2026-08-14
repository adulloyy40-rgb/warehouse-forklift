// File:
// test/location_code_generator_test.dart

// Mengimpor library testing bawaan Flutter.
import 'package:flutter_test/flutter_test.dart';

// Mengimpor generator kode lokasi yang akan kita uji.
import 'package:warehouse_forklift/core/utils/location_code_generator.dart';

void main() {
  // ------------------------------------------------------------
  // TEST 1
  // Memastikan Rack 80 Bay 01 Shelving 01 Posisi 01
  // menghasilkan kode lokasi 8001101.
  // ------------------------------------------------------------
  test('Rack 80 Bay 01 Pos 01 harus menghasilkan 8001101', () {
    // Membuat kode lokasi berdasarkan parameter.
    final String code = LocationCodeGenerator.generateCode(
      rack: 80,
      bay: 1,
      shelving: 1,
      position: 1,
    );

    // Memastikan hasil generator sama dengan kode yang kita inginkan.
    expect(code, '8001101');
  });

  // ------------------------------------------------------------
  // TEST 2
  // Memastikan Posisi 02 menghasilkan 8001102.
  // ------------------------------------------------------------
  test('Rack 80 Bay 01 Pos 02 harus menghasilkan 8001102', () {
    // Membuat kode posisi pallet kedua.
    final String code = LocationCodeGenerator.generateCode(
      rack: 80,
      bay: 1,
      shelving: 1,
      position: 2,
    );

    // Memastikan hasilnya benar.
    expect(code, '8001102');
  });

  // ------------------------------------------------------------
  // TEST 3
  // Memastikan Posisi 03 menghasilkan 8001103.
  // ------------------------------------------------------------
  test('Rack 80 Bay 01 Pos 03 harus menghasilkan 8001103', () {
    // Membuat kode posisi pallet ketiga.
    final String code = LocationCodeGenerator.generateCode(
      rack: 80,
      bay: 1,
      shelving: 1,
      position: 3,
    );

    // Memastikan hasilnya benar.
    expect(code, '8001103');
  });

  // ------------------------------------------------------------
  // TEST 4
  // Memastikan Rack 80 Bay 02 dimulai dari 8002101.
  // ------------------------------------------------------------
  test('Rack 80 Bay 02 harus dimulai dari 8002101', () {
    // Membuat kode lokasi Bay 02 posisi pertama.
    final String code = LocationCodeGenerator.generateCode(
      rack: 80,
      bay: 2,
      shelving: 1,
      position: 1,
    );

    // Memastikan kode lokasi benar.
    expect(code, '8002101');
  });

  // ------------------------------------------------------------
  // TEST 5
  // Memastikan Rack 81 dimulai dari 8101201.
  // ------------------------------------------------------------
  test('Rack 81 harus dimulai dari 8101201', () {
    // Menghasilkan seluruh lokasi Rack 81.
    final List<String> locations =
        LocationCodeGenerator.generateRackLocations(81);

    // Memastikan lokasi pertama adalah 8101201.
    expect(locations.first, '8101201');
  });

  // ------------------------------------------------------------
  // TEST 6
  // Rack 81 tidak boleh memiliki shelving 01.
  // ------------------------------------------------------------
  test('Rack 81 tidak boleh memiliki 8101101', () {
    // Menghasilkan seluruh lokasi Rack 81.
    final List<String> locations =
        LocationCodeGenerator.generateRackLocations(81);

    // Memastikan kode 8101101 tidak terdapat dalam list.
    expect(locations.contains('8101101'), false);
  });

  // ------------------------------------------------------------
  // TEST 7
  // Memastikan Rack 81 menggunakan 15 pallet per Bay.
  //
  // Shelving 02-06 = 5 shelving.
  // Setiap shelving mempunyai 3 posisi.
  //
  // 5 × 3 = 15 pallet.
  // ------------------------------------------------------------
  test('Rack 81 harus memiliki 15 pallet per Bay', () {
    // Menghasilkan lokasi Rack 81.
    final List<String> locations =
        LocationCodeGenerator.generateRackLocations(81);

    // Rack 81 sementara memiliki 5 Bay.
    // 7 Bay × 15 pallet = 105 lokasi.
    expect(locations.length, 105);
  });

  // ------------------------------------------------------------
  // TEST 8
  // Memastikan Rack 80 memiliki 126 lokasi.
  //
  // 7 Bay × 6 shelving × 3 posisi = 126.
  // ------------------------------------------------------------
  test('Rack 80 harus memiliki 126 lokasi', () {
    // Menghasilkan seluruh lokasi Rack 80.
    final List<String> locations =
        LocationCodeGenerator.generateRackLocations(80);

    // Memastikan jumlah lokasi benar.
    expect(locations.length, 126);
  });

  // ------------------------------------------------------------
  // TEST 9
  // Memastikan Rack 95 hanya mempunyai 5 Bay.
  //
  // 5 Bay × 6 shelving × 3 posisi = 90 lokasi.
  // ------------------------------------------------------------
  test('Rack 95 harus memiliki 90 lokasi', () {
    // Menghasilkan seluruh lokasi Rack 95.
    final List<String> locations =
        LocationCodeGenerator.generateRackLocations(95);

    // Memastikan jumlah lokasi benar.
    expect(locations.length, 90);
  });

  // ------------------------------------------------------------
  // TEST 10
  // Memastikan Rack 96 juga mempunyai 90 lokasi.
  // ------------------------------------------------------------
  test('Rack 96 harus memiliki 90 lokasi', () {
    // Menghasilkan seluruh lokasi Rack 96.
    final List<String> locations =
        LocationCodeGenerator.generateRackLocations(96);

    // Memastikan jumlah lokasi benar.
    expect(locations.length, 90);
  });
}

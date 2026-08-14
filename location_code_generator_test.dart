// File:
// test/location_code_generator_test.dart

// Mengimpor fitur testing bawaan Dart.
import 'package:flutter_test/flutter_test.dart';

// Mengimpor generator kode lokasi yang ingin kita tes.
import 'package:warehouse_forklift/core/utils/location_code_generator.dart';

void main() {
  // Test untuk memastikan Rack 80 Bay 01
  // menghasilkan kode awal yang benar.
  test('Rack 80 Bay 01 dimulai dari 8001101', () {
    // Membuat kode lokasi pertama.
    final String code = LocationCodeGenerator.generateCode(
      rack: 80,
      bay: 1,
      shelving: 1,
      position: 1,
    );

    // Memastikan hasil sesuai aturan lapangan.
    expect(code, '8001101');
  });

  // Test untuk memastikan posisi kedua.
  test('Rack 80 Bay 01 Pos 02 menghasilkan 8001102', () {
    // Membuat kode posisi kedua.
    final String code = LocationCodeGenerator.generateCode(
      rack: 80,
      bay: 1,
      shelving: 1,
      position: 2,
    );

    // Memastikan kode benar.
    expect(code, '8001102');
  });

  // Test untuk memastikan Rack 81 dimulai dari shelving 02.
  test('Rack 81 dimulai dari 8101201', () {
    // Mengambil seluruh lokasi Rack 81.
    final locations = LocationCodeGenerator.generateRackLocations(81);

    // Lokasi pertama harus 8101201.
    expect(locations.first, '8101201');
  });

  // Test untuk memastikan Rack 81 tidak memiliki 8101101.
  test('Rack 81 tidak menggunakan shelving 01', () {
    // Mengambil seluruh lokasi Rack 81.
    final locations = LocationCodeGenerator.generateRackLocations(81);

    // Memastikan kode shelving 01 tidak ada.
    expect(locations.contains('8101101'), false);
  });
}

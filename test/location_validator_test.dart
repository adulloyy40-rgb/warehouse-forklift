// ============================================================
// FILE:
// test/location_validator_test.dart
//
// FUNGSI:
// Menguji aturan validasi lokasi storage.
//
// Test ini memastikan:
// 1. Rack 80 valid.
// 2. Rack 91-94 valid.
// 3. Rack 95-96 hanya memiliki Bay 01-05.
// 4. Rack 81-90 memiliki 7 Bay.
// 5. Rack 81-90 menggunakan Shelving 02-06.
// 6. Rack 81-90 memiliki Position 01-03.
// 7. Rack di luar 80-96 ditolak.
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/domain/entities/storage_location.dart';
import 'package:warehouse_forklift/domain/validators/location_validator.dart';


// ============================================================
// main()
//
// Entry point seluruh pengujian LocationValidator.
// ============================================================

void main() {
  // Membuat object validator yang akan digunakan oleh test.
  final validator = LocationValidator();


  // ==========================================================
  // TEST 1
  // Rack 80 memiliki 7 Bay.
  // ==========================================================

  test(
    'Rack 80 harus memiliki 7 Bay',
    () {
      expect(
        validator.getBayCount(80),
        7,
      );
    },
  );


  // ==========================================================
  // TEST 2
  // Rack 91-94 masing-masing memiliki 7 Bay.
  // ==========================================================

  test(
    'Rack 91 sampai 94 harus memiliki 7 Bay',
    () {
      for (int rack = 91; rack <= 94; rack++) {
        expect(
          validator.getBayCount(rack),
          7,
        );
      }
    },
  );


  // ==========================================================
  // TEST 3
  // Rack 95 dan 96 masing-masing hanya memiliki 5 Bay.
  // ==========================================================

  test(
    'Rack 95 dan 96 harus memiliki 5 Bay',
    () {
      expect(
        validator.getBayCount(95),
        5,
      );

      expect(
        validator.getBayCount(96),
        5,
      );
    },
  );


  // ==========================================================
  // TEST 4
  // Rack 81-90 masing-masing memiliki 7 Bay.
  // ==========================================================

  test(
    'Rack 81 sampai 90 harus memiliki 7 Bay',
    () {
      for (int rack = 81; rack <= 90; rack++) {
        expect(
          validator.getBayCount(rack),
          7,
        );
      }
    },
  );


  // ==========================================================
  // TEST 5
  // Rack 80 Bay 07 valid.
  // ==========================================================

  test(
    'Rack 80 Bay 07 harus valid',
    () {
      expect(
        validator.isBayValid(
          rack: 80,
          bay: 7,
        ),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 6
  // Rack 80 Bay 08 tidak valid.
  // ==========================================================

  test(
    'Rack 80 Bay 08 harus tidak valid',
    () {
      expect(
        validator.isBayValid(
          rack: 80,
          bay: 8,
        ),
        false,
      );
    },
  );


  // ==========================================================
  // TEST 7
  // Rack 95 Bay 05 valid.
  // ==========================================================

  test(
    'Rack 95 Bay 05 harus valid',
    () {
      expect(
        validator.isBayValid(
          rack: 95,
          bay: 5,
        ),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 8
  // Rack 95 Bay 06 tidak valid.
  // ==========================================================

  test(
    'Rack 95 Bay 06 harus tidak valid',
    () {
      expect(
        validator.isBayValid(
          rack: 95,
          bay: 6,
        ),
        false,
      );
    },
  );


  // ==========================================================
  // TEST 9
  // Rack 81 Shelving 02 valid.
  // ==========================================================

  test(
    'Rack 81 Shelving 02 harus valid',
    () {
      expect(
        validator.isShelvingValid(
          rack: 81,
          shelving: 2,
        ),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 10
  // Rack 81 Shelving 06 valid.
  // ==========================================================

  test(
    'Rack 81 Shelving 06 harus valid',
    () {
      expect(
        validator.isShelvingValid(
          rack: 81,
          shelving: 6,
        ),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 11
  // Rack 81 Shelving 01 tidak valid.
  // ==========================================================

  test(
    'Rack 81 Shelving 01 harus tidak valid',
    () {
      expect(
        validator.isShelvingValid(
          rack: 81,
          shelving: 1,
        ),
        false,
      );
    },
  );


  // ==========================================================
  // TEST 12
  // Rack 81 Shelving 07 tidak valid.
  // ==========================================================

  test(
    'Rack 81 Shelving 07 harus tidak valid',
    () {
      expect(
        validator.isShelvingValid(
          rack: 81,
          shelving: 7,
        ),
        false,
      );
    },
  );


  // ==========================================================
  // TEST 13
  // Rack 81 Position 01 valid.
  // ==========================================================

  test(
    'Rack 81 Position 01 harus valid',
    () {
      expect(
        validator.isPositionValid(
          rack: 81,
          position: 1,
        ),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 14
  // Rack 81 Position 03 valid.
  // ==========================================================

  test(
    'Rack 81 Position 03 harus valid',
    () {
      expect(
        validator.isPositionValid(
          rack: 81,
          position: 3,
        ),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 15
  // Rack 81 Position 04 tidak valid.
  // ==========================================================

  test(
    'Rack 81 Position 04 harus tidak valid',
    () {
      expect(
        validator.isPositionValid(
          rack: 81,
          position: 4,
        ),
        false,
      );
    },
  );


  // ==========================================================
  // TEST 16
  // Rack 79 tidak boleh digunakan.
  // ==========================================================

  test(
    'Rack 79 harus tidak valid',
    () {
      expect(
        validator.isRackValid(79),
        false,
      );
    },
  );


  // ==========================================================
  // TEST 17
  // Rack 97 tidak boleh digunakan.
  // ==========================================================

  test(
    'Rack 97 harus tidak valid',
    () {
      expect(
        validator.isRackValid(97),
        false,
      );
    },
  );


  // ==========================================================
  // TEST 18
  // StorageLocation lengkap yang valid harus diterima.
  //
  // Contoh:
  // Rack 81
  // Bay 01
  // Shelving 02
  // Position 01
  // ==========================================================

  test(
    'StorageLocation Rack 81 lengkap harus valid',
    () {
      const location = StorageLocation(
        rack: 81,
        bay: 1,
        shelving: 2,
        
        position: 1,
        code: '8101201',
      );

      expect(
        validator.validate(location),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 19
  // StorageLocation dengan Shelving salah harus ditolak.
  // ==========================================================

  test(
    'StorageLocation dengan Shelving 01 harus ditolak',
    () {
      const location = StorageLocation(
        rack: 81,
        bay: 1,
        shelving: 1,
        
        position: 1,
        code: '8101101',
      );

      expect(
        validator.validate(location),
        false,
      );
    },
  );


  // ==========================================================
  // TEST 20
  // StorageLocation Rack 96 Bay 05 valid.
  // ==========================================================

  test(
    'StorageLocation Rack 96 Bay 05 harus valid',
    () {
      const location = StorageLocation(
        rack: 96,
        bay: 5,
        code: '9605',
      );

      expect(
        validator.validate(location),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 21
  // StorageLocation Rack 96 Bay 06 tidak valid.
  // ==========================================================

  test(
    'StorageLocation Rack 96 Bay 06 harus ditolak',
    () {
      const location = StorageLocation(
        rack: 96,
        bay: 6,
        code: '9606',
      );

      expect(
        validator.validate(location),
        false,
      );
    },
  );
}

// ============================================================
// FILE:
// test/rack_configuration_test.dart
//
// FUNGSI:
// Menguji seluruh konfigurasi Rack gudang.
//
// Aturan yang diuji:
//
// Rack 80
//   Bay 01–07
//
// Rack 81–90
//   Bay 01–07
//   Shelving 02–06
//   Position 01–03
//
// Rack 91–94
//   Bay 01–07
//
// Rack 95–96
//   Bay 01–05
//
// Rack di luar 80–96
//   Tidak memiliki konfigurasi.
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/domain/config/rack_configuration.dart';


// ============================================================
// main()
//
// Titik awal seluruh pengujian.
// ============================================================

void main() {
  // ==========================================================
  // TEST 1
  //
  // Rack 80 harus memiliki konfigurasi.
  // ==========================================================

  test(
    'Rack 80 harus memiliki konfigurasi',
    () {
      final config = RackConfigurations.get(80);

      expect(config, isNotNull);
      expect(config!.rack, 80);
    },
  );


  // ==========================================================
  // TEST 2
  //
  // Rack 80 harus memiliki 7 Bay.
  // ==========================================================

  test(
    'Rack 80 harus memiliki 7 Bay',
    () {
      final config = RackConfigurations.get(80);

      expect(config, isNotNull);
      expect(config!.bayCount, 7);
    },
  );


  // ==========================================================
  // TEST 3
  //
  // Rack 80:
  // Bay 01 valid.
  // ==========================================================

  test(
    'Rack 80 Bay 01 harus valid',
    () {
      final config = RackConfigurations.get(80);

      expect(config, isNotNull);
      expect(config!.isBayValid(1), true);
    },
  );


  // ==========================================================
  // TEST 4
  //
  // Rack 80:
  // Bay 07 valid.
  // ==========================================================

  test(
    'Rack 80 Bay 07 harus valid',
    () {
      final config = RackConfigurations.get(80);

      expect(config, isNotNull);
      expect(config!.isBayValid(7), true);
    },
  );


  // ==========================================================
  // TEST 5
  //
  // Rack 80:
  // Bay 08 tidak valid.
  // ==========================================================

  test(
    'Rack 80 Bay 08 harus tidak valid',
    () {
      final config = RackConfigurations.get(80);

      expect(config, isNotNull);
      expect(config!.isBayValid(8), false);
    },
  );


  // ==========================================================
  // TEST 6
  //
  // Rack 81–90 semuanya harus memiliki konfigurasi.
  // ==========================================================

  test(
    'Rack 81 sampai 90 harus memiliki konfigurasi',
    () {
      for (int rack = 81; rack <= 90; rack++) {
        final config = RackConfigurations.get(rack);

        expect(config, isNotNull);
        expect(config!.rack, rack);
      }
    },
  );


  // ==========================================================
  // TEST 7
  //
  // Rack 81–90 masing-masing memiliki 7 Bay.
  // ==========================================================

  test(
    'Rack 81 sampai 90 harus memiliki 7 Bay',
    () {
      for (int rack = 81; rack <= 90; rack++) {
        final config = RackConfigurations.get(rack);

        expect(config, isNotNull);
        expect(config!.bayCount, 7);
      }
    },
  );


  // ==========================================================
  // TEST 8
  //
  // Rack 81–90 menggunakan Shelving 02–06.
  // ==========================================================

  test(
    'Rack 81 sampai 90 harus menggunakan Shelving 02 sampai 06',
    () {
      for (int rack = 81; rack <= 90; rack++) {
        final config = RackConfigurations.get(rack);

        expect(config, isNotNull);

        expect(config!.minShelving, 2);
        expect(config.maxShelving, 6);
      }
    },
  );


  // ==========================================================
  // TEST 9
  //
  // Rack 81–90 memiliki 3 posisi per Shelving.
  // ==========================================================

  test(
    'Rack 81 sampai 90 harus memiliki 3 Position',
    () {
      for (int rack = 81; rack <= 90; rack++) {
        final config = RackConfigurations.get(rack);

        expect(config, isNotNull);
        expect(config!.positionCount, 3);
      }
    },
  );


  // ==========================================================
  // TEST 10
  //
  // Rack 81 harus memiliki Shelving.
  // ==========================================================

  test(
    'Rack 81 harus memiliki Shelving',
    () {
      final config = RackConfigurations.get(81);

      expect(config, isNotNull);
      expect(config!.hasShelving, true);
    },
  );


  // ==========================================================
  // TEST 11
  //
  // Rack 81 Shelving 02 valid.
  // ==========================================================

  test(
    'Rack 81 Shelving 02 harus valid',
    () {
      final config = RackConfigurations.get(81);

      expect(config, isNotNull);
      expect(config!.isShelvingValid(2), true);
    },
  );


  // ==========================================================
  // TEST 12
  //
  // Rack 81 Shelving 06 valid.
  // ==========================================================

  test(
    'Rack 81 Shelving 06 harus valid',
    () {
      final config = RackConfigurations.get(81);

      expect(config, isNotNull);
      expect(config!.isShelvingValid(6), true);
    },
  );


  // ==========================================================
  // TEST 13
  //
  // Rack 81 Shelving 01 tidak valid.
  // ==========================================================

  test(
    'Rack 81 Shelving 01 harus tidak valid',
    () {
      final config = RackConfigurations.get(81);

      expect(config, isNotNull);
      expect(config!.isShelvingValid(1), false);
    },
  );


  // ==========================================================
  // TEST 14
  //
  // Rack 81 Shelving 07 tidak valid.
  // ==========================================================

  test(
    'Rack 81 Shelving 07 harus tidak valid',
    () {
      final config = RackConfigurations.get(81);

      expect(config, isNotNull);
      expect(config!.isShelvingValid(7), false);
    },
  );


  // ==========================================================
  // TEST 15
  //
  // Rack 81 Position 01 valid.
  // ==========================================================

  test(
    'Rack 81 Position 01 harus valid',
    () {
      final config = RackConfigurations.get(81);

      expect(config, isNotNull);
      expect(config!.isPositionValid(1), true);
    },
  );


  // ==========================================================
  // TEST 16
  //
  // Rack 81 Position 03 valid.
  // ==========================================================

  test(
    'Rack 81 Position 03 harus valid',
    () {
      final config = RackConfigurations.get(81);

      expect(config, isNotNull);
      expect(config!.isPositionValid(3), true);
    },
  );


  // ==========================================================
  // TEST 17
  //
  // Rack 81 Position 04 tidak valid.
  // ==========================================================

  test(
    'Rack 81 Position 04 harus tidak valid',
    () {
      final config = RackConfigurations.get(81);

      expect(config, isNotNull);
      expect(config!.isPositionValid(4), false);
    },
  );


  // ==========================================================
  // TEST 18
  //
  // Rack 91–94 harus memiliki 7 Bay.
  // ==========================================================

  test(
    'Rack 91 sampai 94 harus memiliki 7 Bay',
    () {
      for (int rack = 91; rack <= 94; rack++) {
        final config = RackConfigurations.get(rack);

        expect(config, isNotNull);
        expect(config!.bayCount, 7);
      }
    },
  );


  // ==========================================================
  // TEST 19
  //
  // Rack 95–96 harus memiliki 5 Bay.
  // ==========================================================

  test(
    'Rack 95 sampai 96 harus memiliki 5 Bay',
    () {
      for (int rack = 95; rack <= 96; rack++) {
        final config = RackConfigurations.get(rack);

        expect(config, isNotNull);
        expect(config!.bayCount, 5);
      }
    },
  );


  // ==========================================================
  // TEST 20
  //
  // Rack 95 Bay 05 valid.
  // ==========================================================

  test(
    'Rack 95 Bay 05 harus valid',
    () {
      final config = RackConfigurations.get(95);

      expect(config, isNotNull);
      expect(config!.isBayValid(5), true);
    },
  );


  // ==========================================================
  // TEST 21
  //
  // Rack 95 Bay 06 tidak valid.
  // ==========================================================

  test(
    'Rack 95 Bay 06 harus tidak valid',
    () {
      final config = RackConfigurations.get(95);

      expect(config, isNotNull);
      expect(config!.isBayValid(6), false);
    },
  );


  // ==========================================================
  // TEST 22
  //
  // Rack 96 Bay 05 valid.
  // ==========================================================

  test(
    'Rack 96 Bay 05 harus valid',
    () {
      final config = RackConfigurations.get(96);

      expect(config, isNotNull);
      expect(config!.isBayValid(5), true);
    },
  );


  // ==========================================================
  // TEST 23
  //
  // Rack 96 Bay 06 tidak valid.
  // ==========================================================

  test(
    'Rack 96 Bay 06 harus tidak valid',
    () {
      final config = RackConfigurations.get(96);

      expect(config, isNotNull);
      expect(config!.isBayValid(6), false);
    },
  );


  // ==========================================================
  // TEST 24
  //
  // Rack 79 tidak boleh mempunyai konfigurasi.
  // ==========================================================

  test(
    'Rack 79 harus tidak memiliki konfigurasi',
    () {
      expect(
        RackConfigurations.get(79),
        isNull,
      );
    },
  );


  // ==========================================================
  // TEST 25
  //
  // Rack 97 tidak boleh mempunyai konfigurasi.
  // ==========================================================

  test(
    'Rack 97 harus tidak memiliki konfigurasi',
    () {
      expect(
        RackConfigurations.get(97),
        isNull,
      );
    },
  );


  // ==========================================================
  // TEST 26
  //
  // containsRack() harus mengenali Rack 80.
  // ==========================================================

  test(
    'containsRack harus mengenali Rack 80',
    () {
      expect(
        RackConfigurations.containsRack(80),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 27
  //
  // containsRack() harus mengenali Rack 96.
  // ==========================================================

  test(
    'containsRack harus mengenali Rack 96',
    () {
      expect(
        RackConfigurations.containsRack(96),
        true,
      );
    },
  );


  // ==========================================================
  // TEST 28
  //
  // containsRack() harus menolak Rack 79.
  // ==========================================================

  test(
    'containsRack harus menolak Rack 79',
    () {
      expect(
        RackConfigurations.containsRack(79),
        false,
      );
    },
  );


  // ==========================================================
  // TEST 29
  //
  // containsRack() harus menolak Rack 97.
  // ==========================================================

  test(
    'containsRack harus menolak Rack 97',
    () {
      expect(
        RackConfigurations.containsRack(97),
        false,
      );
    },
  );
}

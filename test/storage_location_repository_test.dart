// ============================================================
// FILE:
// test/storage_location_repository_test.dart
// ============================================================
//
// FUNGSI:
// Menguji StorageLocationRepositoryImpl.
//
// Test memastikan:
// 1. Total lokasi = 1.860.
// 2. Lokasi 8001101 tersedia.
// 3. Detail lokasi 8001101 benar.
// 4. Lokasi yang tidak ada menghasilkan null.
// 5. Seluruh kode lokasi unik.
// 6. Available awal = 1.860.
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:warehouse_forklift/data/database/app_database.dart';
import 'package:warehouse_forklift/data/repositories/storage_location_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late StorageLocationRepositoryImpl repository;

  setUp(() async {
    database = AppDatabase(
      executor: NativeDatabase.memory(),
    );

    repository = StorageLocationRepositoryImpl(
      database.storageLocationDao,
    );

    await repository.initializeMasterLocations();
  });

  tearDown(() async {
    await database.close();
  });


  // ==========================================================
  // TEST 1
  // ==========================================================
  //
  // Total seluruh Master Location harus 1.860.
  // ==========================================================

  test(
    'Total lokasi gudang harus 1.860',
    () async {

      final locations =
          await repository.getAllLocations();


      expect(
        locations.length,
        1860,
      );
    },
  );


  // ==========================================================
  // TEST 2
  // ==========================================================
  //
  // Kode 8001101 harus tersedia.
  // ==========================================================

  test(
    'Lokasi 8001101 harus tersedia',
    () async {

      final location =
          await repository.findByCode(
        '8001101',
      );


      expect(
        location,
        isNotNull,
      );


      expect(
        location!.code,
        '8001101',
      );
    },
  );


  // ==========================================================
  // TEST 3
  // ==========================================================
  //
  // Memastikan struktur lokasi 8001101 benar.
  //
  // 8001101:
  //
  // Rack     = 80
  // Bay      = 01
  // Shelving = 1
  // Position = 01
  // ==========================================================

  test(
    'Detail lokasi 8001101 harus benar',
    () async {

      final location =
          await repository.findByCode(
        '8001101',
      );


      expect(
        location,
        isNotNull,
      );


      expect(
        location!.rack,
        80,
      );


      expect(
        location.bay,
        1,
      );


      expect(
        location.shelving,
        1,
      );


      expect(
        location.position,
        1,
      );
    },
  );


  // ==========================================================
  // TEST 4
  // ==========================================================
  //
  // Kode lokasi yang tidak tersedia harus menghasilkan null.
  // ==========================================================

  test(
    'Lokasi yang tidak tersedia harus menghasilkan null',
    () async {

      final location =
          await repository.findByCode(
        '9999999',
      );


      expect(
        location,
        isNull,
      );
    },
  );


  // ==========================================================
  // TEST 5
  // ==========================================================
  //
  // Memastikan tidak ada kode lokasi yang duplikat.
  // ==========================================================

  test(
    'Seluruh kode lokasi harus unik',
    () async {

      final locations =
          await repository.getAllLocations();


      final Set<String> uniqueCodes =
          locations
              .map(
                (location) => location.code,
              )
              .toSet();


      expect(
        uniqueCodes.length,
        1860,
      );


      expect(
        uniqueCodes.length,
        locations.length,
      );
    },
  );


  // ==========================================================
  // TEST 6
  // ==========================================================
  //
  // Pada kondisi awal belum ada pallet.
  //
  // Maka:
  //
  // Total     = 1.860
  // Available = 1.860
  // ==========================================================

  test(
    'Available Location awal harus 1.860',
    () async {

      final available =
          await repository.getAvailableLocation();


      expect(
        available,
        1860,
      );
    },
  );


  // ==========================================================
  // TEST 7
  // ==========================================================
  //
  // Total Location yang diberikan repository harus 1.860.
  // ==========================================================

  test(
    'getTotalLocation harus menghasilkan 1.860',
    () async {

      final total =
          await repository.getTotalLocation();


      expect(
        total,
        1860,
      );
    },
  );
}

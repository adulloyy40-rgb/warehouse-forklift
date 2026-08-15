// ============================================================
// FILE:
// lib/data/repositories/storage_location_repository_impl.dart
// ============================================================
//
// FUNGSI:
// Implementasi repository Master Storage Location.
//
// ATURAN FINAL GUDANG:
//
// Rack 80:
//   7 Bay
//   Shelving 01–06
//   Position 01–03
//   = 126 lokasi
//
// Rack 81–90:
//   10 Rack
//   7 Bay
//   Shelving 02–06
//   Position 01–03
//   = 1.050 lokasi
//
// Rack 91–94:
//   4 Rack
//   7 Bay
//   Shelving 01–06
//   Position 01–03
//   = 504 lokasi
//
// Rack 95–96:
//   2 Rack
//   5 Bay
//   Shelving 01–06
//   Position 01–03
//   = 180 lokasi
//
// TOTAL:
//   126 + 1.050 + 504 + 180
//   = 1.860 lokasi
// ============================================================

import '../../core/utils/location_code_generator.dart';
import '../../domain/entities/storage_location.dart';
import '../../domain/repositories/storage_location_repository.dart';

// ============================================================
// CLASS:
// StorageLocationRepositoryImpl
// ============================================================

class StorageLocationRepositoryImpl
    implements StorageLocationRepository {

  // ----------------------------------------------------------
  // Constructor.
  // ----------------------------------------------------------

  const StorageLocationRepositoryImpl();

  // ==========================================================
  // GET ALL LOCATIONS
  // ==========================================================
  //
  // Menghasilkan seluruh 1.860 lokasi.
  // ==========================================================

  @override
  Future<List<StorageLocation>> getAllLocations() async {
    final List<StorageLocation> locations = [];

    // --------------------------------------------------------
    // Rack 80
    // --------------------------------------------------------

    _addRackLocations(
      locations,
      rack: 80,
    );

    // --------------------------------------------------------
    // Rack 81–90
    //
    // Shelving 02–06.
    // --------------------------------------------------------

    for (int rack = 81; rack <= 90; rack++) {
      _addRackLocations(
        locations,
        rack: rack,
      );
    }

    // --------------------------------------------------------
    // Rack 91–94
    //
    // Shelving 01–06.
    // --------------------------------------------------------

    for (int rack = 91; rack <= 94; rack++) {
      _addRackLocations(
        locations,
        rack: rack,
      );
    }

    // --------------------------------------------------------
    // Rack 95–96
    //
    // 5 Bay.
    // Shelving 01–06.
    // --------------------------------------------------------

    for (int rack = 95; rack <= 96; rack++) {
      _addRackLocations(
        locations,
        rack: rack,
      );
    }

    return locations;
  }

  // ==========================================================
  // ADD RACK LOCATIONS
  // ==========================================================
  //
  // Mengubah kode lokasi dari generator menjadi
  // StorageLocation entity.
  // ==========================================================

  void _addRackLocations(
    List<StorageLocation> locations, {
    required int rack,
  }) {
    // --------------------------------------------------------
    // Ambil seluruh kode lokasi untuk Rack.
    // Generator sudah mengetahui aturan:
    //
    // Rack 80      → Shelving 01–06
    // Rack 81–90   → Shelving 02–06
    // Rack 91–94   → Shelving 01–06
    // Rack 95–96   → Shelving 01–06
    // --------------------------------------------------------

    final List<String> codes =
        LocationCodeGenerator.generateRackLocations(rack);

    // --------------------------------------------------------
    // Ubah setiap kode menjadi StorageLocation.
    // --------------------------------------------------------

    for (final code in codes) {
      // ------------------------------------------------------
      // Struktur kode:
      //
      // RR BB S PP
      //
      // RR = Rack
      // BB = Bay
      // S  = Shelving
      // PP = Position
      //
      // Contoh:
      //
      // 8101201
      //
      // 81 = Rack
      // 01 = Bay
      // 2  = Shelving
      // 01 = Position
      // ------------------------------------------------------

      final int rackNumber =
          int.parse(code.substring(0, 2));

      final int bayNumber =
          int.parse(code.substring(2, 4));

      final int shelvingNumber =
          int.parse(code.substring(4, 5));

      final int positionNumber =
          int.parse(code.substring(5, 7));

      // ------------------------------------------------------
      // Buat entity StorageLocation.
      // ------------------------------------------------------

      locations.add(
        StorageLocation(
          rack: rackNumber,
          bay: bayNumber,
          shelving: shelvingNumber,
          level: shelvingNumber,
          position: positionNumber,
          code: code,
        ),
      );
    }
  }

  // ==========================================================
  // GET LOCATION BY CODE
  // ==========================================================
  //
  // Mencari satu lokasi berdasarkan kode.
  //
  // Contoh:
  //
  // getLocationByCode('8101201')
  //
  // akan mengembalikan lokasi Rack 81,
  // Bay 01, Shelving 02, Position 01.
  // ==========================================================

  @override
  Future<StorageLocation?> getLocationByCode(
    String code,
  ) async {
    final List<StorageLocation> locations =
        await getAllLocations();

    for (final StorageLocation location in locations) {
      if (location.code == code) {
        return location;
      }
    }

    return null;
  }

  // ==========================================================
  // FIND BY CODE
  // ==========================================================
  //
  // Alias untuk kompatibilitas dengan test lama.
  //
  // Test kita sebelumnya menggunakan:
  //
  // findByCode()
  //
  // Sekarang contract utama menggunakan:
  //
  // getLocationByCode()
  //
  // Kita pertahankan findByCode agar test lama tidak rusak.
  // ==========================================================

  Future<StorageLocation?> findByCode(
    String code,
  ) async {
    return getLocationByCode(code);
  }

  // ==========================================================
  // GET TOTAL LOCATION
  // ==========================================================
  //
  // Mengambil total lokasi dari generator.
  //
  // Tidak menggunakan angka 1.860 secara hard-code.
  // ==========================================================

  @override
  Future<int> getTotalLocation() async {
    final List<StorageLocation> locations =
        await getAllLocations();

    return locations.length;
  }

  // ==========================================================
  // GET AVAILABLE LOCATION
  // ==========================================================
  //
  // Untuk tahap sekarang semua lokasi masih kosong.
  //
  // Jadi:
  //
  // Available = Total
  //
  // Setelah StockPallet dihubungkan,
  // bagian ini akan menghitung lokasi yang benar-benar kosong.
  // ==========================================================

  @override
  Future<int> getAvailableLocation() async {
    return getTotalLocation();
  }
}

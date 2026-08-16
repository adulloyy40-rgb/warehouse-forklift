// ============================================================
// FILE:
// lib/domain/validators/location_validator.dart
// ============================================================
//
// FUNGSI:
// Memvalidasi StorageLocation berdasarkan RackConfiguration.
//
// LocationValidator:
// - tidak membaca Excel
// - tidak menyimpan database
// - tidak mengubah data
//
// LocationValidator hanya menentukan:
// VALID / TIDAK VALID
//
// Aturan Rack tidak ditulis ulang di sini.
// Aturan diambil dari:
// domain/config/rack_configuration.dart
// ============================================================

import '../config/rack_configuration.dart';
import '../entities/storage_location.dart';

// ============================================================
// CLASS: LocationValidator
// ============================================================

class LocationValidator {
  // ==========================================================
  // RANGE RACK
  //
  // Tetap dipertahankan karena test lama menggunakan konstanta
  // ini sebagai bagian dari kontrak validator.
  // ==========================================================

  static const int minRack = 80;

  static const int maxRack = 96;

  // ==========================================================
  // isRackValid()
  //
  // Mengecek apakah Rack mempunyai konfigurasi.
  //
  // Sumber aturan utama:
  // RackConfigurations
  // ==========================================================

  bool isRackValid(int rack) {
    // Pastikan masih berada dalam range dasar.
    if (rack < minRack || rack > maxRack) {
      return false;
    }

    // Pastikan Rack benar-benar memiliki konfigurasi.
    return RackConfigurations.containsRack(rack);
  }

  // ==========================================================
  // getBayCount()
  //
  // Mengambil jumlah Bay dari konfigurasi Rack.
  //
  // Jika Rack tidak dikenal:
  // return 0
  // ==========================================================

  int getBayCount(int rack) {
    final config = RackConfigurations.get(rack);

    if (config == null) {
      return 0;
    }

    return config.bayCount;
  }

  // ==========================================================
  // isBayValid()
  //
  // Mengecek Bay berdasarkan konfigurasi Rack.
  // ==========================================================

  bool isBayValid({required int rack, required int bay}) {
    // Ambil konfigurasi Rack.
    final config = RackConfigurations.get(rack);

    // Rack tidak dikenal.
    if (config == null) {
      return false;
    }

    // Validasi Bay menggunakan konfigurasi.
    return config.isBayValid(bay);
  }

  // ==========================================================
  // isShelvingValid()
  //
  // Mengecek Shelving berdasarkan konfigurasi Rack.
  //
  // Untuk Rack 81–90:
  // Shelving 02–06
  //
  // Untuk Rack tanpa Shelving:
  // konfigurasi menganggap Shelving tidak diperlukan.
  // ==========================================================

  bool isShelvingValid({required int rack, required int? shelving}) {
    // Ambil konfigurasi Rack.
    final config = RackConfigurations.get(rack);

    // Rack tidak dikenal.
    if (config == null) {
      return false;
    }

    // Validasi menggunakan konfigurasi.
    return config.isShelvingValid(shelving);
  }

  // ==========================================================
  // isPositionValid()
  //
  // Mengecek Position berdasarkan konfigurasi Rack.
  //
  // Rack 81–90:
  // Position 01–03
  // ==========================================================

  bool isPositionValid({required int rack, required int? position}) {
    // Ambil konfigurasi Rack.
    final config = RackConfigurations.get(rack);

    // Rack tidak dikenal.
    if (config == null) {
      return false;
    }

    // Validasi menggunakan konfigurasi.
    return config.isPositionValid(position);
  }

  // ==========================================================
  // validate()
  //
  // Validasi StorageLocation secara keseluruhan.
  //
  // Urutan:
  //
  // 1. Rack
  // 2. Bay
  // 3. Shelving
  // 4. Position
  //
  // Semua harus valid.
  // ==========================================================

  bool validate(StorageLocation location) {
    // --------------------------------------------------------
    // 1. Validasi Rack
    // --------------------------------------------------------

    if (!isRackValid(location.rack)) {
      return false;
    }

    // --------------------------------------------------------
    // 2. Validasi Bay
    // --------------------------------------------------------

    if (!isBayValid(rack: location.rack, bay: location.bay)) {
      return false;
    }

    // --------------------------------------------------------
    // 3. Validasi Shelving
    // --------------------------------------------------------

    if (!isShelvingValid(rack: location.rack, shelving: location.shelving)) {
      return false;
    }

    // --------------------------------------------------------
    // 4. Validasi Position
    // --------------------------------------------------------

    if (!isPositionValid(rack: location.rack, position: location.position)) {
      return false;
    }

    // --------------------------------------------------------
    // Semua validasi berhasil.
    // --------------------------------------------------------

    return true;
  }
}

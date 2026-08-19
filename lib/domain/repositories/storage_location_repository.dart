// ============================================================
// FILE:
// lib/domain/repositories/storage_location_repository.dart
// ============================================================
//
// FUNGSI:
// Repository contract untuk mengelola Master Storage Location.
//
// Repository berada di DOMAIN sehingga:
// - tidak mengetahui Excel
// - tidak mengetahui database
// - tidak mengetahui Flutter UI
// - tidak mengetahui DAO
// - tidak mengetahui Drift
//
// Repository hanya menentukan operasi bisnis yang dibutuhkan
// terhadap Storage Location.
// ============================================================

import '../entities/storage_location.dart';

// ============================================================
// ABSTRACT CLASS:
// StorageLocationRepository
// ============================================================

abstract class StorageLocationRepository {
  // ==========================================================
  // GET ALL LOCATIONS
  // ==========================================================
  //
  // Mengambil seluruh Master Storage Location.
  // ==========================================================

  Future<List<StorageLocation>> getAllLocations();

  // ==========================================================
  // GET LOCATION BY CODE
  // ==========================================================
  //
  // Mencari satu lokasi berdasarkan Location Code.
  //
  // Return:
  // - StorageLocation jika ditemukan.
  // - null jika tidak ditemukan.
  // ==========================================================

  Future<StorageLocation?> getLocationByCode(String code);

  // ==========================================================
  // GET TOTAL LOCATION
  // ==========================================================

  Future<int> getTotalLocation();

  // ==========================================================
  // GET AVAILABLE LOCATION
  // ==========================================================
  //
  // Mengambil jumlah lokasi dengan status AVAILABLE.
  // ==========================================================

  Future<int> getAvailableLocation();

  // ==========================================================
  // IS AVAILABLE
  // ==========================================================
  //
  // Mengecek apakah suatu Location Code dapat digunakan
  // untuk menempatkan pallet.
  //
  // Return:
  //
  // true
  //   → lokasi ada dan status AVAILABLE
  //
  // false
  //   → lokasi tidak ada, OCCUPIED, atau BLOCKED
  //
  // Method ini sengaja berada di repository agar Domain
  // tidak mengetahui implementasi database.
  // ==========================================================

  Future<bool> isAvailable(String code);

  // ==========================================================
  // UPDATE STATUS
  // ==========================================================
  //
  // Digunakan untuk perubahan status lokasi.
  //
  // Contoh:
  //
  // AVAILABLE → OCCUPIED
  // OCCUPIED  → AVAILABLE
  // AVAILABLE → BLOCKED
  // BLOCKED    → AVAILABLE
  //
  // Implementasi repository bertugas memvalidasi status
  // dan meneruskannya ke Data Layer.
  // ==========================================================

  Future<bool> updateStatus(
    String locationCode,
    String status,
  );

  /// Inisialisasi Master Storage Location saat database masih kosong.
  Future<void> initializeMasterLocations();
}

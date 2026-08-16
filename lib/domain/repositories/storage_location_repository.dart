// ============================================================
// FILE:
// lib/domain/repositories/storage_location_repository.dart
// ============================================================
//
// FUNGSI:
// Repository contract untuk mengelola Master Storage Location.
//
// Repository ini berada di DOMAIN sehingga:
// - tidak mengetahui Excel
// - tidak mengetahui database
// - tidak mengetahui Flutter UI
// - tidak mengandung business logic tampilan
//
// Repository hanya menentukan:
// "Apa yang bisa dilakukan sistem terhadap data lokasi?"
//
// Implementasinya akan kita buat pada layer DATA.
//
// ============================================================

import '../entities/storage_location.dart';

// ============================================================
// ABSTRACT CLASS: StorageLocationRepository
// ============================================================
//
// Interface/contract untuk penyimpanan Master Storage Location.
//
// Seluruh lokasi gudang yang valid akan dikelola melalui
// repository ini.
//
// Total kapasitas layout yang sudah kita sepakati:
//
// TOTAL LOCATION = 1.860
//
// ============================================================

abstract class StorageLocationRepository {
  // ==========================================================
  // getAllLocations()
  // ==========================================================
  //
  // Mengambil seluruh Master Storage Location.
  //
  // Contoh hasil:
  //
  // 8001101
  // 8001102
  // 8001103
  // ...
  //
  // sampai seluruh 1.860 lokasi.
  //
  // Fungsi ini akan digunakan Dashboard dan halaman Storage.
  // ==========================================================

  Future<List<StorageLocation>> getAllLocations();

  // ==========================================================
  // getLocationByCode()
  // ==========================================================
  //
  // Mencari satu lokasi berdasarkan kode lokasi.
  //
  // Contoh:
  //
  // Input:
  // 8001101
  //
  // Output:
  // StorageLocation dengan code = 8001101
  //
  // Jika tidak ditemukan:
  // return null.
  // ==========================================================

  Future<StorageLocation?> getLocationByCode(String code);

  // ==========================================================
  // getTotalLocation()
  // ==========================================================
  //
  // Mengambil jumlah seluruh lokasi yang terdaftar.
  //
  // Berdasarkan layout proyek kita:
  //
  // TOTAL LOCATION = 1.860
  //
  // Fungsi ini nantinya digunakan Dashboard.
  // ==========================================================

  Future<int> getTotalLocation();

  // ==========================================================
  // getAvailableLocation()
  // ==========================================================
  //
  // Mengambil jumlah lokasi yang belum ditempati pallet.
  //
  // Rumus:
  //
  // Available =
  // Total Location - Occupied Location
  //
  // Catatan:
  // Repository Storage Location hanya mengetahui Master
  // Location.
  //
  // Status occupied akan kita hubungkan dengan StockPallet
  // pada tahap berikutnya.
  // ==========================================================

  Future<int> getAvailableLocation();
}

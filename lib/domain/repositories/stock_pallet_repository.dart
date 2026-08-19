// ============================================================
// FILE:
// lib/domain/repositories/stock_pallet_repository.dart
// ============================================================
//
// FUNGSI:
// Repository contract untuk mengelola data StockPallet.
//
// Repository ini berada di DOMAIN sehingga:
// - Tidak mengetahui database yang digunakan.
// - Tidak membaca file Excel.
// - Tidak mengetahui UI Flutter.
// - Tidak mengetahui apakah data disimpan di Hive,
//   Isar, SQLite, atau database lainnya.
//
// Repository hanya menentukan:
// "Operasi apa saja yang dapat dilakukan terhadap StockPallet?"
//
// Implementasinya nanti berada di:
//
// lib/data/repositories/
//
// Contoh:
//
// StockPalletRepository
//        ↓
// StockPalletRepositoryImpl
//        ↓
// Local Database
// ============================================================

import '../entities/stock_pallet.dart';

// ============================================================
// ABSTRACT CLASS: StockPalletRepository
// ============================================================
//
// Abstract class ini adalah kontrak.
//
// Artinya setiap class yang mengimplementasikan repository
// wajib menyediakan fungsi yang didefinisikan di sini.
// ============================================================

abstract class StockPalletRepository {
  // ==========================================================
  // SAVE
  // ==========================================================
  //
  // FUNGSI:
  // Menyimpan satu data pallet.
  //
  // Contoh:
  //
  // User memasukkan pallet ke lokasi:
  // 8001101
  //
  // Maka StockPallet akan disimpan melalui fungsi ini.
  // ==========================================================

  Future<void> save(StockPallet pallet);

  // ==========================================================
  // SAVE ALL
  // ==========================================================
  //
  // FUNGSI:
  // Menyimpan banyak pallet sekaligus.
  //
  // Digunakan terutama untuk:
  // - Import Excel
  // - Import data storage dalam jumlah besar
  //
  // Implementasi Data Layer akan menggunakan batch database
  // agar proses import tidak melakukan INSERT satu per satu.
  // ==========================================================

  Future<void> saveAll(List<StockPallet> pallets);

  // ==========================================================
  // GET ALL
  // ==========================================================
  //
  // FUNGSI:
  // Mengambil seluruh data pallet yang tersimpan.
  //
  // Nantinya dapat digunakan untuk:
  // - Dashboard
  // - Daftar pallet
  // - Export Excel
  // - Monitoring storage
  // ==========================================================

  Future<List<StockPallet>> getAll();

  // ==========================================================
  // FIND BY LOCATION
  // ==========================================================
  //
  // FUNGSI:
  // Mencari pallet berdasarkan Location Code.
  //
  // Contoh:
  //
  // 8001101
  //
  // Ini penting karena satu lokasi tidak boleh digunakan
  // oleh dua pallet aktif secara bersamaan.
  // ==========================================================

  Future<StockPallet?> findByLocationCode(String locationCode);

  // ==========================================================
  // UPDATE
  // ==========================================================
  //
  // FUNGSI:
  // Memperbarui data pallet yang sudah tersimpan.
  //
  // Contoh:
  // - Tear aktual berubah.
  // - Stack aktual berubah.
  // - Expired Date dikoreksi.
  // ==========================================================

  Future<void> update(StockPallet pallet);

  // ==========================================================
  // DELETE
  // ==========================================================
  //
  // FUNGSI:
  // Menghapus data pallet.
  //
  // Catatan:
  // Penghapusan nantinya dapat kita batasi berdasarkan
  // hak akses user/operator.
  // ==========================================================

  Future<void> deleteByLocationCode(String locationCode);
}

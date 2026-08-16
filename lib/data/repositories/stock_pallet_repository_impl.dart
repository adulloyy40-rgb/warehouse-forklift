// ============================================================
// FILE:
// lib/data/repositories/stock_pallet_repository_impl.dart
// ============================================================
//
// FUNGSI:
// Implementasi StockPalletRepository.
//
// File ini berada di DATA layer.
//
// Tugas:
// - Menyimpan StockPallet.
// - Mengambil seluruh StockPallet.
// - Mencari pallet berdasarkan Location Code.
// - Memperbarui pallet.
// - Menghapus pallet.
//
// PENTING:
// Tahap ini menggunakan penyimpanan memory (in-memory).
//
// Belum menggunakan:
// - Hive
// - Isar
// - SQLite
// - Excel
// - UI
//
// Tujuannya adalah memastikan kontrak Repository sudah benar
// sebelum kita memasang database lokal permanen.
// ============================================================

import '../../domain/entities/stock_pallet.dart';
import '../../domain/repositories/stock_pallet_repository.dart';

// ============================================================
// CLASS: StockPalletRepositoryImpl
// ============================================================
//
// Implementasi konkret dari:
//
// StockPalletRepository
//
// Repository ini nantinya dapat diganti dengan implementasi
// database tanpa mengubah Domain layer.
// ============================================================

class StockPalletRepositoryImpl implements StockPalletRepository {
  // ==========================================================
  // STORAGE SEMENTARA
  // ==========================================================
  //
  // List ini hanya digunakan sebagai penyimpanan sementara
  // selama tahap pengembangan dan testing.
  //
  // Nanti dapat diganti dengan database lokal.
  // ==========================================================

  final List<StockPallet> _pallets = [];

  // ==========================================================
  // SAVE
  // ==========================================================
  //
  // FUNGSI:
  // Menyimpan satu StockPallet.
  //
  // ATURAN:
  // Satu Location Code hanya boleh memiliki satu pallet aktif.
  //
  // Jika Location Code sudah digunakan,
  // proses penyimpanan akan ditolak.
  // ==========================================================

  @override
  Future<void> save(StockPallet pallet) async {
    // Cari apakah Location Code sudah digunakan.

    final existing = await findByLocationCode(pallet.locationCode);

    // Jika sudah ada pallet pada lokasi tersebut,
    // jangan menyimpan data kedua.

    if (existing != null) {
      throw StateError(
        'Location Code ${pallet.locationCode} '
        'sudah digunakan.',
      );
    }

    // Tambahkan pallet ke storage.

    _pallets.add(pallet);
  }

  // ==========================================================
  // GET ALL
  // ==========================================================
  //
  // FUNGSI:
  // Mengambil seluruh StockPallet.
  //
  // Digunakan nantinya untuk:
  // - Dashboard
  // - Monitoring storage
  // - Daftar pallet
  // - Rekap stock
  // - Export Excel
  // ==========================================================

  @override
  Future<List<StockPallet>> getAll() async {
    // Mengembalikan salinan List.
    //
    // Kita tidak mengembalikan List internal secara langsung
    // agar caller tidak dapat memodifikasi storage internal.

    return List<StockPallet>.unmodifiable(_pallets);
  }

  // ==========================================================
  // FIND BY LOCATION CODE
  // ==========================================================
  //
  // FUNGSI:
  // Mencari pallet berdasarkan Location Code.
  //
  // Return:
  // - StockPallet jika ditemukan.
  // - null jika tidak ditemukan.
  // ==========================================================

  @override
  Future<StockPallet?> findByLocationCode(String locationCode) async {
    // Cari pallet berdasarkan Location Code.

    for (final pallet in _pallets) {
      if (pallet.locationCode == locationCode) {
        return pallet;
      }
    }

    // Tidak ditemukan.

    return null;
  }

  // ==========================================================
  // UPDATE
  // ==========================================================
  //
  // FUNGSI:
  // Memperbarui pallet yang sudah tersimpan.
  //
  // Pencarian dilakukan berdasarkan Location Code.
  // ==========================================================

  @override
  Future<void> update(StockPallet pallet) async {
    // Cari index pallet berdasarkan Location Code.

    final index = _pallets.indexWhere(
      (item) => item.locationCode == pallet.locationCode,
    );

    // Jika tidak ditemukan,
    // update tidak dapat dilakukan.

    if (index == -1) {
      throw StateError(
        'Stock pallet dengan Location Code '
        '${pallet.locationCode} tidak ditemukan.',
      );
    }

    // Ganti data lama dengan data baru.

    _pallets[index] = pallet;
  }

  // ==========================================================
  // DELETE BY LOCATION CODE
  // ==========================================================
  //
  // FUNGSI:
  // Menghapus pallet berdasarkan Location Code.
  //
  // Contoh:
  //
  // deleteByLocationCode('8001101')
  //
  // Maka pallet pada lokasi 8001101 akan dihapus.
  // ==========================================================

  @override
  Future<void> deleteByLocationCode(String locationCode) async {
    // Cari pallet berdasarkan Location Code.

    final index = _pallets.indexWhere(
      (item) => item.locationCode == locationCode,
    );

    // Jika tidak ditemukan,
    // tidak ada yang perlu dihapus.

    if (index == -1) {
      return;
    }

    // Hapus pallet.

    _pallets.removeAt(index);
  }
}

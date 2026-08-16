// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/put_away_stock_pallet.dart
// ============================================================
//
// FUNGSI:
// Use Case utama untuk proses PUT AWAY pallet.
//
// ALUR:
//
// UI
//   ↓
// PutAwayStockPallet
//   ↓
// StockPalletRepository
//   ↓
// StockPalletRepositoryImpl
//
// TUGAS USE CASE:
//
// 1. Memastikan Location Code belum digunakan.
// 2. Menyimpan StockPallet.
// 3. Menyerahkan aturan penyimpanan kepada Repository.
//
// ============================================================

import '../../entities/stock_pallet.dart';
import '../../repositories/stock_pallet_repository.dart';

// ============================================================
// CLASS:
// PutAwayStockPallet
// ============================================================

class PutAwayStockPallet {
  // ==========================================================
  // REPOSITORY
  // ==========================================================

  final StockPalletRepository repository;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const PutAwayStockPallet({required this.repository});

  // ==========================================================
  // CALL
  // ==========================================================
  //
  // Menjalankan proses PUT AWAY.
  //
  // Jika lokasi sudah terisi, repository akan menolak
  // penyimpanan.
  // ==========================================================

  Future<void> call(StockPallet pallet) async {
    // --------------------------------------------------------
    // Cek apakah lokasi sudah digunakan.
    // --------------------------------------------------------

    final existing = await repository.findByLocationCode(pallet.locationCode);

    // --------------------------------------------------------
    // Jika lokasi sudah memiliki pallet,
    // PUT AWAY tidak diperbolehkan.
    // --------------------------------------------------------

    if (existing != null) {
      throw StateError('Location Code ${pallet.locationCode} sudah terisi.');
    }

    // --------------------------------------------------------
    // Simpan pallet.
    // --------------------------------------------------------

    await repository.save(pallet);
  }
}

// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/save_stock_pallet.dart
// ============================================================
//
// FUNGSI:
// Use Case untuk menyimpan StockPallet.
//
// ALUR:
//
// UI
//  ↓
// SaveStockPallet
//  ↓
// StockPalletRepository
//  ↓
// StockPalletRepositoryImpl
//
// Use Case ini berada di DOMAIN layer.
//
// Keuntungan:
// - UI tidak langsung berhubungan dengan repository.
// - Aturan bisnis lebih mudah dikembangkan.
// - Mudah dibuat unit test.
// - Clean Architecture tetap terjaga.
// ============================================================

import '../../entities/stock_pallet.dart';
import '../../repositories/stock_pallet_repository.dart';


// ============================================================
// CLASS:
// SaveStockPallet
// ============================================================
//
// FUNGSI:
// Menjalankan proses penyimpanan StockPallet.
// ============================================================

class SaveStockPallet {
  // ==========================================================
  // Repository
  // ==========================================================
  //
  // Repository digunakan sebagai pintu masuk
  // untuk penyimpanan StockPallet.
  // ==========================================================

  final StockPalletRepository repository;


  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const SaveStockPallet({
    required this.repository,
  });


  // ==========================================================
  // CALL
  // ==========================================================
  //
  // FUNGSI:
  // Menyimpan satu StockPallet.
  //
  // Contoh:
  //
  // await saveStockPallet(pallet);
  //
  // Jika Location Code sudah digunakan,
  // repository akan menolak penyimpanan.
  // ==========================================================

  Future<void> call(
    StockPallet pallet,
  ) async {
    await repository.save(pallet);
  }
}

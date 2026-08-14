// ============================================================
// FILE:
// lib/domain/usecases/stock_pallet/find_stock_pallet_by_location.dart
// ============================================================
//
// FUNGSI:
// Mencari StockPallet berdasarkan Location Code.
//
// Contoh:
//
// User scan:
//
// 8001101
//
// Use Case akan mencari pallet pada lokasi tersebut.
// ============================================================

import '../../entities/stock_pallet.dart';
import '../../repositories/stock_pallet_repository.dart';


// ============================================================
// CLASS:
// FindStockPalletByLocation
// ============================================================

class FindStockPalletByLocation {
  // ==========================================================
  // Repository
  // ==========================================================

  final StockPalletRepository repository;


  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const FindStockPalletByLocation({
    required this.repository,
  });


  // ==========================================================
  // CALL
  // ==========================================================
  //
  // Parameter:
  // locationCode
  //
  // Return:
  // StockPallet jika ditemukan.
  //
  // null jika lokasi belum memiliki pallet.
  // ==========================================================

  Future<StockPallet?> call(
    String locationCode,
  ) async {
    return await repository.findByLocationCode(
      locationCode,
    );
  }
}

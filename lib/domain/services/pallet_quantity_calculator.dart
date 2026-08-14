// ============================================================
// FILE:
// lib/domain/services/pallet_quantity_calculator.dart
// ============================================================
//
// FUNGSI:
// Menghitung Quantity pallet berdasarkan:
//
// Tear Aktual
// Stack Aktual
// CONV2
//
// RUMUS:
//
// Qty CTN = Tear Aktual × Stack Aktual
//
// Qty PCS = Qty CTN × CONV2
//
// Contoh:
//
// Tear  = 4
// Stack = 5
// CONV2 = 12
//
// Qty CTN = 4 × 5
//         = 20 CTN
//
// Qty PCS = 20 × 12
//         = 240 PCS
//
// PENTING:
// Service ini hanya bertugas menghitung quantity.
//
// Service ini TIDAK:
// - membaca Excel
// - menyimpan database
// - membaca UI
// - melakukan export Excel
// - mengubah StockPallet
// ============================================================


// ============================================================
// CLASS: PalletQuantityCalculator
// ============================================================
//
// Service untuk perhitungan quantity pallet.
// ============================================================

class PalletQuantityCalculator {
  // ==========================================================
  // calculateQtyCtn()
  // ==========================================================
  //
  // FUNGSI:
  // Menghitung jumlah CTN berdasarkan Tear Aktual
  // dan Stack Aktual.
  //
  // Rumus:
  //
  // Qty CTN = Tear × Stack
  // ==========================================================

  static int calculateQtyCtn({
    required int tear,
    required int stack,
  }) {
    return tear * stack;
  }


  // ==========================================================
  // calculateQtyPcs()
  // ==========================================================
  //
  // FUNGSI:
  // Menghitung jumlah PCS berdasarkan Qty CTN dan CONV2.
  //
  // Rumus:
  //
  // Qty PCS = Qty CTN × CONV2
  // ==========================================================

  static int calculateQtyPcs({
    required int qtyCtn,
    required int conv2,
  }) {
    return qtyCtn * conv2;
  }


  // ==========================================================
  // calculate()
  // ==========================================================
  //
  // FUNGSI:
  // Menghitung Qty CTN dan Qty PCS sekaligus.
  //
  // Return:
  // Map<String, int>
  //
  // Contoh hasil:
  //
  // {
  //   'qtyCtn': 20,
  //   'qtyPcs': 240,
  // }
  // ==========================================================

  static Map<String, int> calculate({
    required int tear,
    required int stack,
    required int conv2,
  }) {
    // --------------------------------------------------------
    // Hitung Qty CTN terlebih dahulu.
    // --------------------------------------------------------

    final qtyCtn = calculateQtyCtn(
      tear: tear,
      stack: stack,
    );


    // --------------------------------------------------------
    // Setelah Qty CTN didapat,
    // hitung Qty PCS.
    // --------------------------------------------------------

    final qtyPcs = calculateQtyPcs(
      qtyCtn: qtyCtn,
      conv2: conv2,
    );


    // --------------------------------------------------------
    // Kembalikan kedua hasil perhitungan.
    // --------------------------------------------------------

    return {
      'qtyCtn': qtyCtn,
      'qtyPcs': qtyPcs,
    };
  }
}

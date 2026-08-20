// ============================================================
// FILE:
// lib/domain/services/stock_pallet_calculator.dart
// ============================================================
//
// FUNGSI:
// Menghitung jumlah CTN dan PCS berdasarkan data pallet.
//
// RUMUS:
//
// Qty CTN = Tear Aktual × Stack Aktual
//
// Qty PCS = Qty CTN × CONV2
//
// ============================================================
//
// CLASS INI TIDAK:
//
// - membaca Excel
// - menyimpan database
// - mengakses UI
// - mengubah StockPallet
// - melakukan validasi lokasi
//
// Class ini hanya bertugas melakukan PERHITUNGAN.
// ============================================================

// ============================================================
// CLASS: StockPalletCalculation
//
// Menyimpan hasil perhitungan pallet.
//
// Hasilnya terdiri dari:
//
// - qtyCtn
// - qtyPcs
// ============================================================

class StockPalletCalculation {
  // ==========================================================
  // qtyCtn
  //
  // Jumlah CTN yang dihitung dari:
  //
  // Tear × Stack
  // ==========================================================

  final int qtyCtn;

  // ==========================================================
  // qtyPcs
  //
  // Jumlah PCS yang dihitung dari:
  //
  // Qty CTN × CONV2
  // ==========================================================

  final int qtyPcs;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const StockPalletCalculation({required this.qtyCtn, required this.qtyPcs});

  // ==========================================================
  // toString()
  //
  // Mempermudah debugging di terminal.
  // ==========================================================

  @override
  String toString() {
    return 'StockPalletCalculation('
        'qtyCtn: $qtyCtn, '
        'qtyPcs: $qtyPcs'
        ')';
  }
}

// ============================================================
// CLASS: StockPalletCalculator
//
// Bertugas menghitung Qty CTN dan Qty PCS.
// ============================================================

class StockPalletCalculator {
  // ==========================================================
  // calculate()
  //
  // Parameter:
  //
  // tear  = Tear aktual pallet
  // stack = Stack aktual pallet
  // conv2 = CONV2 dari Master Item
  //
  // Rumus:
  //
  // Qty CTN = Tear × Stack
  //
  // Qty PCS = Qty CTN × CONV2
  // ==========================================================

  static StockPalletCalculation calculate({
    required int tear,
    required int stack,
    required int conv2,
  }) {
    // --------------------------------------------------------
    // Menghitung jumlah CTN.
    // --------------------------------------------------------

    final int qtyCtn = tear * stack;

    // --------------------------------------------------------
    // Menghitung jumlah PCS.
    //
    // Jumlah CTN dikalikan CONV2.
    // --------------------------------------------------------

    final int qtyPcs = qtyCtn * conv2;

    // --------------------------------------------------------
    // Mengembalikan hasil perhitungan.
    // --------------------------------------------------------

    return StockPalletCalculation(qtyCtn: qtyCtn, qtyPcs: qtyPcs);
  }
}

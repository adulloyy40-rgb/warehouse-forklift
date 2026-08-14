// File:
// lib/domain/entities/stock_pallet.dart

// Entity StockPallet mewakili satu pallet barang
// yang tersimpan pada satu lokasi rak.
class StockPallet {
  // Kode lokasi pallet.
  // Contoh: 8001101.
  final String locationCode;

  // PLU barang yang berada di pallet.
  final String plu;

  // Description barang.
  final String description;

  // Tear aktual yang dimasukkan operator berdasarkan kondisi fisik pallet.
  final int tear;

  // Stack aktual yang dimasukkan operator berdasarkan kondisi fisik pallet.
  final int stack;

  // Jumlah CTN aktual pada pallet.
  // Rumus: tear × stack.
  final int qtyCtn;

  // Jumlah PCS aktual pada pallet.
  // Rumus: qtyCtn × conv2.
  final int qtyPcs;

  // Conv2 dari Master Barang.
  final int conv2;

  // Tanggal expired barang pada pallet.
  final DateTime expiredDate;

  // Tanggal dan waktu saat data dimasukkan ke aplikasi.
  final DateTime inputDate;

  // NIK operator yang melakukan input.
  final String operatorNik;

  // True jika tear dan stack aktual sama dengan master.
  // False jika berbeda.
  final bool sesuaiMaster;

  // Constructor StockPallet.
  const StockPallet({
    required this.locationCode,
    required this.plu,
    required this.description,
    required this.tear,
    required this.stack,
    required this.qtyCtn,
    required this.qtyPcs,
    required this.conv2,
    required this.expiredDate,
    required this.inputDate,
    required this.operatorNik,
    required this.sesuaiMaster,
  });
}

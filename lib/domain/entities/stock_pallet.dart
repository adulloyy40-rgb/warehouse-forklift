// ============================================================
// FILE:
// lib/domain/entities/stock_pallet.dart
//
// FUNGSI:
// Entity domain untuk merepresentasikan satu pallet barang.
//
// CATATAN:
// Entity ini tidak mengetahui Drift, SQLite, DAO, atau database.
//
// Struktur:
// Domain Entity
//      ↓
// StockPalletRepository
// ============================================================

class StockPallet {
  // ----------------------------------------------------------
  // LOCATION
  // ----------------------------------------------------------

  // Kode lokasi pallet.
  //
  // Contoh:
  // 8001101
  final String locationCode;

  // ----------------------------------------------------------
  // MASTER BARANG
  // ----------------------------------------------------------

  // PLU barang.
  final String plu;

  // Barcode barang.
  final String barcode;

  // Deskripsi barang.
  final String description;

  // Harga barang.
  final double price;

  // Retur hari dari master barang.
  final int returHari;

  // Konversi CTN → PCS.
  final int conv2;

  // Tipe barang.
  final String type;

  // ----------------------------------------------------------
  // DATA FISIK PALLET
  // ----------------------------------------------------------

  // Tear aktual pallet.
  final int tear;

  // Stack aktual pallet.
  final int stack;

  // Jumlah CTN.
  //
  // Rumus:
  //
  // tear × stack
  final int qtyCtn;

  // Jumlah PCS.
  //
  // Rumus:
  //
  // qtyCtn × conv2
  final int qtyPcs;

  // ----------------------------------------------------------
  // TANGGAL
  // ----------------------------------------------------------

  // Tanggal expired barang.
  final DateTime expiredDate;

  // Tanggal/waktu pallet pertama kali dimasukkan.
  final DateTime inputDate;

  // ----------------------------------------------------------
  // OPERATOR
  // ----------------------------------------------------------

  // NIK operator yang melakukan proses.
  final String operatorNik;

  // ----------------------------------------------------------
  // VALIDASI MASTER
  // ----------------------------------------------------------

  // true:
  // Tear dan Stack aktual sesuai dengan master.
  //
  // false:
  // berbeda dari master.
  final bool sesuaiMaster;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const StockPallet({
    required this.locationCode,
    required this.plu,
    required this.barcode,
    required this.description,
    required this.price,
    required this.returHari,
    required this.conv2,
    required this.type,
    required this.tear,
    required this.stack,
    required this.qtyCtn,
    required this.qtyPcs,
    required this.expiredDate,
    required this.inputDate,
    required this.operatorNik,
    required this.sesuaiMaster,
  });
}

// ============================================================
// FILE:
// lib/data/database/tables/stock_pallets_table.dart
//
// FUNGSI:
// Mendefinisikan tabel database untuk menyimpan data pallet.
//
// ATURAN:
// 1 lokasi hanya boleh memiliki 1 pallet aktif.
// ============================================================

import 'package:drift/drift.dart';

// ============================================================
// TABLE: StockPallets
// ============================================================

class StockPallets extends Table {
  // ----------------------------------------------------------
  // ID INTERNAL
  //
  // Dibuat otomatis oleh database.
  // ----------------------------------------------------------

  IntColumn get id => integer().autoIncrement()();

  // ----------------------------------------------------------
  // LOCATION
  //
  // Contoh:
  // 8001101
  //
  // Satu lokasi hanya boleh mempunyai satu pallet.
  // ----------------------------------------------------------

  TextColumn get locationCode => text().unique()();

  // ----------------------------------------------------------
  // DATA MASTER ITEM
  // ----------------------------------------------------------

  TextColumn get plu => text()();

  TextColumn get barcode => text()();

  TextColumn get description => text()();

  RealColumn get price => real()();

  IntColumn get returHari => integer()();

  IntColumn get conv2 => integer()();

  TextColumn get type => text()();

  // ----------------------------------------------------------
  // OPERATOR NIK
  //
  // Menyimpan NIK operator yang melakukan proses pallet.
  // ----------------------------------------------------------

  TextColumn get operatorNik => text().withDefault(const Constant(''))();

  // ----------------------------------------------------------
  // KESESUAIAN MASTER
  //
  // true  = Tear dan Stack sesuai Master Item
  // false = terdapat perbedaan
  // ----------------------------------------------------------

  BoolColumn get sesuaiMaster => boolean().withDefault(const Constant(true))();

  // ----------------------------------------------------------
  // DATA PALLET
  //
  // Nilai ini diisi operator saat Put Away/Edit Pallet.
  // ----------------------------------------------------------

  IntColumn get tear => integer()();

  IntColumn get stack => integer()();

  // ----------------------------------------------------------
  // QUANTITY
  //
  // Qty CTN dan Qty PCS merupakan jumlah barang pada pallet.
  // ----------------------------------------------------------

  IntColumn get qtyCtn => integer().withDefault(const Constant(0))();

  IntColumn get qtyPcs => integer().withDefault(const Constant(0))();

  // ----------------------------------------------------------
  // TANGGAL EXPIRED
  //
  // Disimpan sebagai DateTime agar nantinya mudah:
  //
  // - dibandingkan dengan tanggal hari ini
  // - mencari barang yang hampir expired
  // - melakukan filter berdasarkan tanggal
  // ----------------------------------------------------------

  DateTimeColumn get expiredDate => dateTime()();

  // ----------------------------------------------------------
  // AUDIT TIMESTAMP
  //
  // createdAt = kapan pallet pertama kali disimpan.
  //
  // updatedAt = kapan data pallet terakhir diedit.
  // ----------------------------------------------------------

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

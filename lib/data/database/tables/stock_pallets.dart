import 'package:drift/drift.dart';

/// ============================================================
/// TABLE: stock_pallets
/// ============================================================
///
/// Menyimpan data pallet/barang yang benar-benar berada
/// di dalam storage warehouse.
///
/// Berbeda dengan Master Item.
///
/// MASTER ITEM:
///     Data referensi dari Excel.
///
/// STOCK PALLET:
///     Data barang aktual yang masuk ke warehouse.
///
/// Contoh:
///
/// PLU              : 109497
/// Barcode          : 8997035563544
/// Description      : POCARI SWEAT PET 350ML
/// Quantity         : 24
/// Expired Date     : 2026-12-31
/// Location         : A01-01-01
///
/// ============================================================

class StockPallets extends Table {
  /// ----------------------------------------------------------
  /// ID
  /// ----------------------------------------------------------
  ///
  /// Primary key database.
  /// Dibuat otomatis oleh SQLite.
  /// ----------------------------------------------------------

  IntColumn get id => integer().autoIncrement()();

  /// ----------------------------------------------------------
  /// BARCODE
  /// ----------------------------------------------------------
  ///
  /// Barcode aktual barang.
  /// ----------------------------------------------------------

  TextColumn get barcode => text()();

  /// ----------------------------------------------------------
  /// PLU
  /// ----------------------------------------------------------
  ///
  /// PLU barang.
  ///
  /// PLU digunakan sebagai salah satu identitas utama
  /// ketika operator melakukan PUT AWAY.
  /// ----------------------------------------------------------

  TextColumn get plu => text()();

  /// ----------------------------------------------------------
  /// DESCRIPTION
  /// ----------------------------------------------------------
  ///
  /// Nama/deskripsi barang pada saat pallet disimpan.
  ///
  /// Kita simpan snapshot description supaya histori pallet
  /// tetap dapat dibaca walaupun Master Item berubah.
  /// ----------------------------------------------------------

  TextColumn get description => text()();

  /// ----------------------------------------------------------
  /// PRICE
  /// ----------------------------------------------------------
  ///
  /// Harga dari Master Item.
  /// ----------------------------------------------------------

  RealColumn get price => real().withDefault(const Constant(0))();

  /// ----------------------------------------------------------
  /// RETUR HARI
  /// ----------------------------------------------------------
  ///
  /// Informasi retur/expired dari Master Item.
  /// ----------------------------------------------------------

  IntColumn get returHari => integer().withDefault(const Constant(0))();

  /// ----------------------------------------------------------
  /// CONV2
  /// ----------------------------------------------------------
  ///
  /// Konversi barang.
  /// ----------------------------------------------------------

  IntColumn get conv2 => integer().withDefault(const Constant(0))();

  /// ----------------------------------------------------------
  /// TYPE
  /// ----------------------------------------------------------
  ///
  /// Tipe barang.
  /// ----------------------------------------------------------

  TextColumn get type => text().withDefault(const Constant(''))();

  /// ----------------------------------------------------------
  /// MASTER TEAR
  /// ----------------------------------------------------------
  ///
  /// Nilai TEAR dari Master Item.
  /// ----------------------------------------------------------

  IntColumn get masterTear => integer().withDefault(const Constant(0))();

  /// ----------------------------------------------------------
  /// MASTER STACK
  /// ----------------------------------------------------------
  ///
  /// Nilai STACK dari Master Item.
  /// ----------------------------------------------------------

  IntColumn get masterStack => integer().withDefault(const Constant(0))();

  /// ----------------------------------------------------------
  /// QUANTITY
  /// ----------------------------------------------------------
  ///
  /// Jumlah barang aktual pada pallet.
  ///
  /// Contoh:
  /// 24 pcs
  /// ----------------------------------------------------------

  IntColumn get quantity => integer()();

  /// ----------------------------------------------------------
  /// EXPIRED DATE
  /// ----------------------------------------------------------
  ///
  /// Tanggal expired yang WAJIB dimasukkan operator.
  ///
  /// Ini berbeda dengan RETUR HARI.
  ///
  /// RETUR HARI:
  ///     Informasi dari Master Item.
  ///
  /// EXPIRED DATE:
  ///     Tanggal aktual batch barang yang sedang disimpan.
  /// ----------------------------------------------------------

  DateTimeColumn get expiredDate => dateTime()();

  /// ----------------------------------------------------------
  /// LOCATION CODE
  /// ----------------------------------------------------------
  ///
  /// Lokasi pallet berada.
  ///
  /// Contoh:
  /// A01-01-01
  /// ----------------------------------------------------------

  TextColumn get locationCode => text()();

  /// ----------------------------------------------------------
  /// CREATED AT
  /// ----------------------------------------------------------
  ///
  /// Waktu pallet dibuat/disimpan.
  /// ----------------------------------------------------------

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// ----------------------------------------------------------
  /// UPDATED AT
  /// ----------------------------------------------------------
  ///
  /// Waktu terakhir data pallet diperbarui.
  /// ----------------------------------------------------------

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

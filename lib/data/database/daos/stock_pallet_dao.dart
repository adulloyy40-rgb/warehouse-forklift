// ============================================================
// FILE:
// lib/data/database/daos/stock_pallet_dao.dart
//
// FUNGSI:
// DAO (Data Access Object) untuk tabel StockPallets.
//
// DAO menjadi pintu resmi untuk membaca dan mengubah database.
//
// Alur:
//
// Presentation
//     ↓
// UseCase
//     ↓
// Repository
//     ↓
// StockPalletDao
//     ↓
// SQLite / Drift
//
// ATURAN BISNIS:
// 1 lokasi hanya boleh memiliki 1 pallet aktif.
// ============================================================

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/stock_pallets_table.dart';
import '../../models/stock_pallet_summary_row.dart';

part 'stock_pallet_dao.g.dart';

// ============================================================
// CLASS: StockPalletDao
// ============================================================

@DriftAccessor(tables: [StockPallets])
class StockPalletDao extends DatabaseAccessor<AppDatabase>
    with _$StockPalletDaoMixin {
  // ----------------------------------------------------------
  // CONSTRUCTOR
  // ----------------------------------------------------------

  StockPalletDao(super.db);

  // ==========================================================
  // FIND PALLET BY LOCATION
  // ==========================================================

  Future<StockPallet?> findByLocation(String locationCode) {
    final normalizedLocation = locationCode.trim();

    return (select(stockPallets)
          ..where((tbl) => tbl.locationCode.equals(normalizedLocation)))
        .getSingleOrNull();
  }

  // ==========================================================
  // GET ALL PALLETS
  // ==========================================================

  Future<List<StockPallet>> getAllPallets() {
    return select(stockPallets).get();
  }

  // ==========================================================
  // GET STOCK SUMMARY BY PLU
  // ==========================================================
  //
  // Mengambil rekap stok berdasarkan PLU.
  //
  // Total Value dihitung dari:
  //
  // SUM(qty_pcs * price)
  //
  // sehingga harga setiap pallet tetap dihitung sesuai
  // harga yang tersimpan pada pallet tersebut.
  // ==========================================================

  Future<List<StockPalletSummaryRow>> getStockSummaryByPlu() async {
    final rows = await customSelect(
      '''
      SELECT
        plu,
        MAX(barcode) AS barcode,
        MAX(description) AS description,
        MAX(price) AS price,
        COUNT(*) AS total_pallet,
        COALESCE(SUM(qty_ctn), 0) AS total_qty_ctn,
        COALESCE(SUM(qty_pcs), 0) AS total_qty_pcs,
        COALESCE(SUM(qty_pcs * price), 0) AS total_value
      FROM stock_pallets
      GROUP BY plu
      ORDER BY description COLLATE NOCASE ASC
      ''',
      readsFrom: {stockPallets},
    ).get();

    return rows.map((row) {
      return StockPalletSummaryRow(
        plu: row.read<String>('plu'),
        barcode: row.read<String>('barcode'),
        description: row.read<String>('description'),
        price: row.read<double>('price'),
        totalPallet: row.read<int>('total_pallet'),
        totalQtyCtn: row.read<int>('total_qty_ctn'),
        totalQtyPcs: row.read<int>('total_qty_pcs'),
        totalValue: row.read<double>('total_value'),
      );
    }).toList();
  }

  // ==========================================================
  // GET STOCK SUMMARY FOR ONE PLU
  // ==========================================================

  Future<StockPalletSummaryRow?> getStockSummaryForPlu(String plu) async {
    final normalizedPlu = plu.trim();

    if (normalizedPlu.isEmpty) {
      return null;
    }

    final rows = await customSelect(
      '''
      SELECT
        plu,
        MAX(barcode) AS barcode,
        MAX(description) AS description,
        MAX(price) AS price,
        COUNT(*) AS total_pallet,
        COALESCE(SUM(qty_ctn), 0) AS total_qty_ctn,
        COALESCE(SUM(qty_pcs), 0) AS total_qty_pcs,
        COALESCE(SUM(qty_pcs * price), 0) AS total_value
      FROM stock_pallets
      WHERE plu = ?
      GROUP BY plu
      LIMIT 1
      ''',
      variables: [Variable.withString(normalizedPlu)],
      readsFrom: {stockPallets},
    ).get();

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;

    return StockPalletSummaryRow(
      plu: row.read<String>('plu'),
      barcode: row.read<String>('barcode'),
      description: row.read<String>('description'),
      price: row.read<double>('price'),
      totalPallet: row.read<int>('total_pallet'),
      totalQtyCtn: row.read<int>('total_qty_ctn'),
      totalQtyPcs: row.read<int>('total_qty_pcs'),
      totalValue: row.read<double>('total_value'),
    );
  }

  // ==========================================================
  // GET GRAND TOTAL STOCK VALUE
  // ==========================================================

  Future<double> getGrandTotalStockValue() async {
    final row = await customSelect(
      '''
      SELECT
        COALESCE(SUM(qty_pcs * price), 0) AS grand_total_value
      FROM stock_pallets
      ''',
      readsFrom: {stockPallets},
    ).getSingle();

    return row.read<double>('grand_total_value');
  }

  // ==========================================================
  // INSERT PALLET
  // ==========================================================

  Future<int> insertPallet(StockPalletsCompanion pallet) {
    return into(stockPallets).insert(pallet);
  }

  // ==========================================================
  // INSERT BANYAK PALLET
  // ==========================================================
  //
  // Digunakan khusus untuk proses import Excel.
  //
  // Semua pallet dikirim ke SQLite dalam satu batch,
  // sehingga tidak perlu melakukan INSERT satu per satu.
  //
  // ==========================================================

  Future<void> insertPallets(List<StockPalletsCompanion> pallets) async {
    if (pallets.isEmpty) {
      return;
    }

    await batch((batch) {
      batch.insertAll(stockPallets, pallets);
    });
  }

  // ==========================================================
  // UPDATE PALLET
  // ==========================================================

  Future<bool> updatePallet(StockPalletsCompanion pallet) async {
    final count = await update(stockPallets).write(pallet);
    return count > 0;
  }

  // ==========================================================
  // DELETE PALLET BY ID
  // ==========================================================

  Future<int> deletePalletById(int id) {
    return (delete(stockPallets)..where((tbl) => tbl.id.equals(id))).go();
  }
}

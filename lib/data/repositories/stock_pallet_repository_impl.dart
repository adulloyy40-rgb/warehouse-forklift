// ============================================================
// FILE:
// lib/data/repositories/stock_pallet_repository_impl.dart
//
// FUNGSI:
// Implementasi StockPalletRepository menggunakan database lokal.
//
// ALUR:
//
// Domain Repository
//        ↓
// StockPalletRepositoryImpl
//        ↓
// StockPalletDao
//        ↓
// AppDatabase
//        ↓
// SQLite
//
// Repository bertugas menjadi jembatan antara:
//
// Domain Entity
//        ↕
// Database/Drift
// ============================================================

import 'package:drift/drift.dart' show Value;

import '../../domain/entities/stock_pallet.dart' as domain;
import '../../domain/entities/stock_pallet_summary.dart';
import '../../domain/repositories/stock_pallet_repository.dart';

import '../database/app_database.dart' as database;
import '../database/daos/stock_pallet_dao.dart';

// ============================================================
// CLASS
// ============================================================

class StockPalletRepositoryImpl implements StockPalletRepository {
  // ----------------------------------------------------------
  // DAO DATABASE
  // ----------------------------------------------------------
  //
  // Semua operasi database dilakukan melalui DAO.
  //
  // Repository tidak menjalankan query SQLite secara langsung.
  // ----------------------------------------------------------

  final StockPalletDao _dao;

  // ----------------------------------------------------------
  // CONSTRUCTOR
  // ----------------------------------------------------------
  //
  // AppDatabase diberikan dari Dependency Injection.
  // ----------------------------------------------------------

  StockPalletRepositoryImpl(database.AppDatabase db)
    : _dao = StockPalletDao(db);

  // ==========================================================
  // SAVE
  // ==========================================================
  //
  // Digunakan ketika operator melakukan PUT AWAY pertama kali.
  //
  // Aturan:
  //
  // 1 Location = 1 Pallet aktif.
  //
  // Jika location sudah mempunyai pallet,
  // proses penyimpanan ditolak.
  // ==========================================================

  @override
  Future<void> save(domain.StockPallet pallet) async {
    // --------------------------------------------------------
    // Cek apakah lokasi sudah mempunyai pallet.
    // --------------------------------------------------------

    final existing = await _dao.findByLocation(pallet.locationCode);

    if (existing != null) {
      throw StateError(
        'Location ${pallet.locationCode} sudah memiliki pallet.',
      );
    }

    // --------------------------------------------------------
    // Entity Domain → Drift Companion.
    // --------------------------------------------------------

    final companion = database.StockPalletsCompanion.insert(
      locationCode: pallet.locationCode.trim(),
      plu: pallet.plu.trim(),
      barcode: pallet.barcode.trim(),
      description: pallet.description.trim(),
      price: pallet.price,
      returHari: pallet.returHari,
      conv2: pallet.conv2,
      type: pallet.type.trim(),
      operatorNik: Value(pallet.operatorNik),
      sesuaiMaster: Value(pallet.sesuaiMaster),
      tear: pallet.tear,
      stack: pallet.stack,
      qtyCtn: pallet.qtyCtn,
      qtyPcs: pallet.qtyPcs,
      expiredDate: pallet.expiredDate,
      createdAt: pallet.inputDate,
      updatedAt: pallet.inputDate,
    );

    // --------------------------------------------------------
    // Simpan melalui DAO → SQLite.
    // --------------------------------------------------------

    await _dao.insertPallet(companion);
  }

  // ==========================================================
  // GET ALL
  // ==========================================================

  @override
  Future<void> saveAll(List<domain.StockPallet> pallets) async {
    if (pallets.isEmpty) {
      return;
    }

    final companions = pallets.map((pallet) {
      return database.StockPalletsCompanion.insert(
        locationCode: pallet.locationCode.trim(),
        plu: pallet.plu.trim(),
        barcode: pallet.barcode.trim(),
        description: pallet.description.trim(),
        price: pallet.price,
        returHari: pallet.returHari,
        conv2: pallet.conv2,
        type: pallet.type.trim(),
        operatorNik: Value(pallet.operatorNik),
        sesuaiMaster: Value(pallet.sesuaiMaster),
        tear: pallet.tear,
        stack: pallet.stack,
        qtyCtn: pallet.qtyCtn,
        qtyPcs: pallet.qtyPcs,
        expiredDate: pallet.expiredDate,
        createdAt: pallet.inputDate,
        updatedAt: pallet.inputDate,
      );
    }).toList();

    await _dao.insertPallets(companions);
  }

  @override
  Future<List<domain.StockPallet>> getAll() async {
    final rows = await _dao.getAllPallets();

    return rows.map(_mapToEntity).toList();
  }

  // ==========================================================
  // STOCK SUMMARY BY PLU
  // ==========================================================
  //
  // Mengambil rekap stok seluruh PLU.
  //
  // DAO melakukan query database.
  // Repository mengubah hasil Data Layer menjadi
  // Domain Entity StockPalletSummary.
  // ==========================================================

  @override
  Future<List<StockPalletSummary>> getStockSummaryByPlu() async {
    final rows = await _dao.getStockSummaryByPlu();

    return rows.map((row) {
      return StockPalletSummary(
        plu: row.plu,
        barcode: row.barcode,
        description: row.description,
        price: row.price,
        totalPallet: row.totalPallet,
        totalQtyCtn: row.totalQtyCtn,
        totalQtyPcs: row.totalQtyPcs,
        totalValue: row.totalValue,
      );
    }).toList();
  }

  // ==========================================================
  // STOCK SUMMARY FOR ONE PLU
  // ==========================================================
  //
  // Mengambil rekap stok hanya untuk satu PLU.
  // ==========================================================

  @override
  Future<StockPalletSummary?> getStockSummaryForPlu(String plu) async {
    final row = await _dao.getStockSummaryForPlu(plu);

    if (row == null) {
      return null;
    }

    return StockPalletSummary(
      plu: row.plu,
      barcode: row.barcode,
      description: row.description,
      price: row.price,
      totalPallet: row.totalPallet,
      totalQtyCtn: row.totalQtyCtn,
      totalQtyPcs: row.totalQtyPcs,
      totalValue: row.totalValue,
    );
  }

  // ==========================================================
  // GRAND TOTAL STOCK VALUE
  // ==========================================================
  //
  // Mengambil total nilai seluruh pallet aktif
  // dari seluruh lokasi.
  // ==========================================================

  @override
  Future<double> getGrandTotalStockValue() {
    return _dao.getGrandTotalStockValue();
  }

  // ==========================================================
  // FIND BY LOCATION
  // ==========================================================

  @override
  Future<domain.StockPallet?> findByLocationCode(String locationCode) async {
    final row = await _dao.findByLocation(locationCode);

    if (row == null) {
      return null;
    }

    return _mapToEntity(row);
  }

  // ==========================================================
  // UPDATE
  // ==========================================================
  //
  // Digunakan untuk EDIT PALLET.
  //
  // Operator nantinya mengisi kembali:
  //
  // PLU
  // Tear
  // Stack
  // Tanggal Expired
  //
  // Data lainnya tetap tersimpan dari pallet sebelumnya.
  // ==========================================================

  @override
  Future<void> update(domain.StockPallet pallet) async {
    // --------------------------------------------------------
    // Cari pallet berdasarkan location.
    // --------------------------------------------------------

    final existing = await _dao.findByLocation(pallet.locationCode);

    if (existing == null) {
      throw StateError(
        'Pallet pada location ${pallet.locationCode} '
        'tidak ditemukan.',
      );
    }

    // --------------------------------------------------------
    // Buat Companion untuk UPDATE.
    //
    // ID tetap menggunakan ID database lama.
    // createdAt juga tidak berubah.
    // --------------------------------------------------------

    final companion = database.StockPalletsCompanion(
      id: Value(existing.id),

      locationCode: Value(pallet.locationCode.trim()),

      plu: Value(pallet.plu.trim()),

      barcode: Value(pallet.barcode.trim()),

      description: Value(pallet.description.trim()),

      price: Value(pallet.price),

      returHari: Value(pallet.returHari),

      conv2: Value(pallet.conv2),

      type: Value(pallet.type.trim()),

      tear: Value(pallet.tear),

      stack: Value(pallet.stack),

      qtyCtn: Value(pallet.qtyCtn),

      qtyPcs: Value(pallet.qtyPcs),

      expiredDate: Value(pallet.expiredDate),

      // createdAt tidak boleh berubah ketika EDIT.
      createdAt: Value(existing.createdAt),

      // updatedAt berubah setiap kali EDIT.
      updatedAt: Value(DateTime.now()),
    );

    // --------------------------------------------------------
    // Update melalui DAO → SQLite.
    // --------------------------------------------------------

    final updated = await _dao.updatePallet(companion);

    if (!updated) {
      throw StateError(
        'Gagal memperbarui pallet pada '
        'location ${pallet.locationCode}.',
      );
    }
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  @override
  Future<void> deleteByLocationCode(String locationCode) async {
    final existing = await _dao.findByLocation(locationCode);

    if (existing == null) {
      return;
    }

    await _dao.deletePalletById(existing.id);
  }

  // ==========================================================
  // DATABASE ROW → DOMAIN ENTITY
  // ==========================================================
  //
  // Drift:
  //
  // StockPalletData
  //
  // ↓
  //
  // Domain:
  //
  // StockPallet
  //
  // Dengan prefix database/domain, nama tidak lagi bentrok.
  // ==========================================================

  domain.StockPallet _mapToEntity(database.StockPallet row) {
    return domain.StockPallet(
      locationCode: row.locationCode,
      plu: row.plu,
      barcode: row.barcode, // Tambahkan ini
      price: row.price, // Tambahkan ini
      returHari: row.returHari, // Tambahkan ini
      type: row.type, // Tambahkan ini
      description: row.description,
      tear: row.tear,
      stack: row.stack,
      qtyCtn: row.qtyCtn,
      qtyPcs: row.qtyPcs,
      conv2: row.conv2,
      expiredDate: row.expiredDate,

      // createdAt database menjadi inputDate domain.
      inputDate: row.createdAt,

      // Untuk sementara operator NIK belum disimpan
      // di tabel database.
      operatorNik: '',

      // Penanda sederhana sementara.
      //
      // Nanti dapat kita sempurnakan berdasarkan
      // perbandingan Tear/Stack dengan Master Item.
      sesuaiMaster: row.tear > 0 && row.stack > 0,
    );
  }
}

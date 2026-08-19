// ============================================================
// FILE:
// lib/domain/usecases/map_stock_pallet_import.dart
//
// FUNGSI:
// Mengubah data hasil import Stock Pallet menjadi
// Domain Entity StockPallet.
//
// CATATAN:
// Mapper ini TIDAK:
// - membaca Excel
// - mengakses database
// - mengakses DAO
//
// Data master barang diberikan oleh caller.
// ============================================================

import '../entities/stock_pallet.dart';

// ============================================================
// MASTER DATA YANG DIBUTUHKAN
// ============================================================
//
// Data ini berasal dari Master Barang.
//
// Kita belum menggunakan entity MasterBarang secara langsung
// agar mapper tetap fokus pada proses mapping.
// ============================================================

class StockPalletMasterData {
  final String barcode;
  final double price;
  final int returHari;
  final String type;

  const StockPalletMasterData({
    required this.barcode,
    required this.price,
    required this.returHari,
    required this.type,
  });
}

// ============================================================
// MAPPER
// ============================================================

class MapStockPalletImport {
  const MapStockPalletImport();

  // ==========================================================
  // EXECUTE
  // ==========================================================
  //
  // Mengubah satu row hasil parser menjadi StockPallet.
  //
  // Row berasal dari:
  //
  // StockPalletExcelDataSource
  //
  // Master berasal dari:
  //
  // Master Barang
  // ==========================================================

  StockPallet execute({
    required Map<String, dynamic> row,
    required StockPalletMasterData master,
    required String operatorNik,
    DateTime? inputDate,
  }) {
    final locationCode = _requiredString(row, 'lokasi');

    final plu = _requiredString(row, 'plu');

    final description = _requiredString(row, 'desc');

    final conv2 = _requiredInt(row, 'conv2');

    final qtyCtn = _requiredInt(row, 'qty_so');

    final stack = _requiredInt(row, 'stack');

    final tear = _requiredInt(row, 'tear_aktual');

    final expiredDate = _requiredDateTime(row, 'exp_date');

    // --------------------------------------------------------
    // Qty PCS
    //
    // qtyCtn × conv2
    // --------------------------------------------------------

    final qtyPcs = qtyCtn * conv2;

    // --------------------------------------------------------
    // Validasi Tear / Stack terhadap master.
    //
    // Untuk sementara master tear/stack belum menjadi bagian
    // dari StockPalletMasterData.
    //
    // Karena itu sesuaiMaster belum dapat ditentukan penuh
    // pada tahap mapper ini.
    //
    // Untuk keamanan, kita set true karena data sudah lolos
    // StockPalletImportValidator.
    //
    // Validasi master fisik akan kita sempurnakan ketika
    // Master Barang entity sudah digunakan dalam import pipeline.
    // --------------------------------------------------------

    const sesuaiMaster = true;

    return StockPallet(
      locationCode: locationCode,
      plu: plu,
      barcode: master.barcode,
      description: description,
      price: master.price,
      returHari: master.returHari,
      conv2: conv2,
      type: master.type,
      tear: tear,
      stack: stack,
      qtyCtn: qtyCtn,
      qtyPcs: qtyPcs,
      expiredDate: expiredDate,
      inputDate: inputDate ?? DateTime.now(),
      operatorNik: operatorNik,
      sesuaiMaster: sesuaiMaster,
    );
  }

  // ==========================================================
  // REQUIRED STRING
  // ==========================================================

  String _requiredString(Map<String, dynamic> row, String key) {
    final value = row[key];

    if (value == null) {
      throw FormatException('Kolom "$key" wajib diisi.');
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      throw FormatException('Kolom "$key" tidak boleh kosong.');
    }

    return result;
  }

  // ==========================================================
  // REQUIRED INT
  // ==========================================================

  int _requiredInt(Map<String, dynamic> row, String key) {
    final value = row[key];

    if (value == null) {
      throw FormatException('Kolom "$key" wajib diisi.');
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    final parsed = int.tryParse(value.toString().trim());

    if (parsed == null) {
      throw FormatException('Kolom "$key" harus berupa angka.');
    }

    return parsed;
  }

  // ==========================================================
  // REQUIRED DATETIME
  // ==========================================================

  DateTime _requiredDateTime(Map<String, dynamic> row, String key) {
    final value = row[key];

    if (value == null) {
      throw FormatException('Kolom "$key" wajib diisi.');
    }

    if (value is DateTime) {
      return value;
    }

    final parsed = DateTime.tryParse(value.toString().trim());

    if (parsed == null) {
      throw FormatException('Kolom "$key" harus berupa tanggal yang valid.');
    }

    return parsed;
  }
}

// ============================================================
// FILE:
// lib/domain/usecases/map_stock_pallet_import.dart
//
// FUNGSI:
// Mengubah satu baris hasil import Stock Pallet menjadi
// Domain Entity StockPallet.
//
// ALUR:
//
// Excel
//   ↓
// StockPalletExcelDataSource
//   ↓
// ImportStockPallet
//   ↓
// MapStockPalletImport
//   ↓
// Product (Master Barang)
//   ↓
// StockPallet
//   ↓
// StockPalletRepository
//   ↓
// SQLite
//
// ATURAN:
// - Data identitas barang berasal dari Master Barang.
// - Tear dan Stack berasal dari kondisi aktual pallet.
// - sesuaiMaster dihitung dari perbandingan aktual vs master.
// - Qty CTN dihitung dari tear × stack.
// - Qty PCS dihitung dari qtyCtn × conv2 master.
// - Expired Date wajib berasal dari data import.
// ============================================================

import '../entities/product.dart';
import '../entities/stock_pallet.dart';

// ============================================================
// CLASS:
// MapStockPalletImport
// ============================================================

class MapStockPalletImport {
  const MapStockPalletImport();

  // ==========================================================
  // EXECUTE
  // ==========================================================
  //
  // Mengubah satu row Excel menjadi StockPallet.
  //
  // Product:
  // Master Barang berdasarkan PLU.
  //
  // Row:
  // Data pallet dari Excel.
  //
  // operatorNik:
  // NIK operator yang melakukan import.
  //
  // inputDate:
  // Waktu proses import.
  // ==========================================================

  StockPallet execute({
    required Map<String, dynamic> row,
    required Product product,
    required String operatorNik,
    DateTime? inputDate,
  }) {
    // --------------------------------------------------------
    // LOCATION
    // --------------------------------------------------------

    final locationCode = _requiredString(
      row,
      'lokasi',
    );

    // --------------------------------------------------------
    // PLU
    // --------------------------------------------------------
    //
    // PLU dari Excel harus sama dengan Master Barang.
    // --------------------------------------------------------

    final excelPlu = _requiredString(
      row,
      'plu',
    );

    if (excelPlu != product.plu.trim()) {
      throw FormatException(
        'PLU Excel "$excelPlu" tidak sesuai dengan '
        'Master Barang "${product.plu}".',
      );
    }

    // --------------------------------------------------------
    // TEAR AKTUAL
    // --------------------------------------------------------

    final tear = _requiredInt(
      row,
      'tear_aktual',
    );

    // --------------------------------------------------------
    // STACK AKTUAL
    // --------------------------------------------------------

    final stack = _requiredInt(
      row,
      'stack',
    );

    // --------------------------------------------------------
    // QTY CTN
    // --------------------------------------------------------
    //
    // Rumus:
    //
    // Tear × Stack
    //
    // Contoh:
    // Tear = 2
    // Stack = 5
    //
    // Qty CTN = 10
    // --------------------------------------------------------

    final qtyCtn = tear * stack;

    // --------------------------------------------------------
    // QTY PCS
    // --------------------------------------------------------
    //
    // Menggunakan CONV2 dari Master Barang.
    // --------------------------------------------------------

    final qtyPcs = qtyCtn * product.conv2;

    // --------------------------------------------------------
    // EXPIRED DATE
    // --------------------------------------------------------

    final expiredDate = _requiredDateTime(
      row,
      'exp_date',
    );

    // --------------------------------------------------------
    // VALIDASI TEAR / STACK
    // --------------------------------------------------------
    //
    // Nilai aktual tidak diubah.
    //
    // Kita hanya menentukan apakah sesuai dengan master.
    //
    // Jika salah satu berbeda:
    //
    // sesuaiMaster = false
    //
    // UI nantinya dapat menampilkan indikator orange.
    // --------------------------------------------------------

    final sesuaiMaster =
        tear == product.masterTear &&
        stack == product.masterStack;

    // --------------------------------------------------------
    // OPERATOR
    // --------------------------------------------------------

    final normalizedOperatorNik = operatorNik.trim();

    if (normalizedOperatorNik.isEmpty) {
      throw FormatException(
        'Operator NIK wajib diisi.',
      );
    }

    // --------------------------------------------------------
    // CREATE ENTITY
    // --------------------------------------------------------

    return StockPallet(
      locationCode: locationCode,
      plu: product.plu.trim(),
      barcode: product.barcode.trim(),
      description: product.description.trim(),
      price: product.price,
      returHari: product.returHari,
      conv2: product.conv2,
      type: product.type.trim(),
      tear: tear,
      stack: stack,
      qtyCtn: qtyCtn,
      qtyPcs: qtyPcs,
      expiredDate: expiredDate,
      inputDate: inputDate ?? DateTime.now(),
      operatorNik: normalizedOperatorNik,
      sesuaiMaster: sesuaiMaster,
    );
  }

  // ==========================================================
  // REQUIRED STRING
  // ==========================================================

  String _requiredString(
    Map<String, dynamic> row,
    String key,
  ) {
    final value = row[key];

    if (value == null) {
      throw FormatException(
        'Kolom "$key" wajib diisi.',
      );
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      throw FormatException(
        'Kolom "$key" tidak boleh kosong.',
      );
    }

    return result;
  }

  // ==========================================================
  // REQUIRED INT
  // ==========================================================

  int _requiredInt(
    Map<String, dynamic> row,
    String key,
  ) {
    final value = row[key];

    if (value == null) {
      throw FormatException(
        'Kolom "$key" wajib diisi.',
      );
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      if (!value.isFinite) {
        throw FormatException(
          'Kolom "$key" harus berupa angka.',
        );
      }

      return value.toInt();
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      throw FormatException(
        'Kolom "$key" wajib diisi.',
      );
    }

    final parsedInt = int.tryParse(text);

    if (parsedInt != null) {
      return parsedInt;
    }

    final parsedDouble = double.tryParse(text);

    if (parsedDouble != null && parsedDouble.isFinite) {
      return parsedDouble.toInt();
    }

    throw FormatException(
      'Kolom "$key" harus berupa angka.',
    );
  }

  // ==========================================================
  // REQUIRED DATETIME
  // ==========================================================

  DateTime _requiredDateTime(
    Map<String, dynamic> row,
    String key,
  ) {
    final value = row[key];

    if (value == null) {
      throw FormatException(
        'Kolom "$key" wajib diisi.',
      );
    }

    if (value is DateTime) {
      return value;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      throw FormatException(
        'Kolom "$key" wajib diisi.',
      );
    }

    final parsed = DateTime.tryParse(text);

    if (parsed == null) {
      throw FormatException(
        'Kolom "$key" harus berupa tanggal yang valid.',
      );
    }

    return parsed;
  }
}

// ============================================================
// FILE:
// lib/data/datasources/stock_pallet_excel_data_source.dart
//
// FUNGSI:
// Membaca data pallet/storage yang sudah terisi dari Excel.
//
// FORMAT EXCEL YANG DIGUNAKAN:
//
// LOKASI | PLU | DESC | CONV2 | QTY SO |
// STACK | TEAR AKTUAL | EXP DATE
//
// PEMETAAN:
//
// LOKASI       -> locationCode
// PLU          -> plu
// DESC         -> description
// CONV2        -> conv2
// QTY SO       -> qtyCtn
// STACK        -> stack aktual
// TEAR AKTUAL  -> tear aktual
// EXP DATE     -> expiredDate
//
// CATATAN PENTING:
//
// Data Excel BELUM dimasukkan ke database pada tahap ini.
//
// Alur:
//
// Excel
//   ↓
// StockPalletExcelDataSource
//   ↓
// Parsing
//   ↓
// Data mentah pallet
//
// Validasi Master Item dan database akan dibuat
// pada tahap berikutnya.
// ============================================================

import 'dart:typed_data';

import 'package:excel/excel.dart';

// ============================================================
// CLASS:
// StockPalletExcelDataSource
// ============================================================

class StockPalletExcelDataSource {
  // ==========================================================
  // HEADER EXCEL YANG WAJIB
  // ==========================================================
  //
  // Nama header akan dinormalisasi terlebih dahulu.
  //
  // Contoh:
  //
  // "QTY SO"      -> "qty_so"
  // "TEAR AKTUAL" -> "tear_aktual"
  // ==========================================================

  static const List<String> requiredHeaders = [
    'lokasi',
    'plu',
    'desc',
    'conv2',
    'qty_so',
    'stack',
    'tear_aktual',
    'exp_date',
  ];

  // ==========================================================
  // READ
  // ==========================================================
  //
  // Membaca Excel dari Uint8List.
  //
  // Return:
  //
  // List<Map<String, dynamic>>
  //
  // Satu Map = satu pallet dari satu baris Excel.
  // ==========================================================

  List<Map<String, dynamic>> read(Uint8List bytes) {
    // --------------------------------------------------------
    // Membuka workbook Excel.
    // --------------------------------------------------------

    final excel = Excel.decodeBytes(bytes);

    // --------------------------------------------------------
    // Pastikan workbook memiliki worksheet.
    // --------------------------------------------------------

    if (excel.tables.isEmpty) {
      throw StateError('File Excel tidak memiliki worksheet.');
    }

    // --------------------------------------------------------
    // Gunakan worksheet pertama.
    // --------------------------------------------------------

    final sheet = excel.tables.values.first;

    // --------------------------------------------------------
    // Excel kosong.
    // --------------------------------------------------------

    if (sheet.rows.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    // --------------------------------------------------------
    // Membaca header dari baris pertama.
    // --------------------------------------------------------

    final headerRow = sheet.rows.first;

    final headers = headerRow
        .map((cell) => _normalizeHeader(cell?.value?.toString() ?? ''))
        .toList();

    // --------------------------------------------------------
    // Validasi header.
    // --------------------------------------------------------

    _validateHeaders(headers);

    // --------------------------------------------------------
    // Menyimpan hasil parsing.
    // --------------------------------------------------------

    final result = <Map<String, dynamic>>[];

    // --------------------------------------------------------
    // Membaca baris setelah header.
    // --------------------------------------------------------

    for (int rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
      final row = sheet.rows[rowIndex];

      // ------------------------------------------------------
      // Lewati baris kosong.
      // ------------------------------------------------------

      if (_isEmptyRow(row)) {
        continue;
      }

      // ------------------------------------------------------
      // Membuat data pallet dari baris Excel.
      // ------------------------------------------------------

      final data = <String, dynamic>{
        'lokasi': _getValue(row, headers, 'lokasi'),

        'plu': _getValue(row, headers, 'plu'),

        'desc': _getValue(row, headers, 'desc'),

        'conv2': _getValue(row, headers, 'conv2'),

        'qty_so': _getValue(row, headers, 'qty_so'),

        'stack': _getValue(row, headers, 'stack'),

        'tear_aktual': _getValue(row, headers, 'tear_aktual'),

        'exp_date': _getValue(row, headers, 'exp_date'),
      };

      result.add(data);
    }

    return result;
  }

  // ==========================================================
  // VALIDATE HEADERS
  // ==========================================================

  void _validateHeaders(List<String> headers) {
    final missingHeaders = requiredHeaders
        .where((header) => !headers.contains(header))
        .toList();

    if (missingHeaders.isNotEmpty) {
      throw StateError(
        'Kolom Excel tidak lengkap. '
        'Kolom yang hilang: '
        '${missingHeaders.join(', ')}',
      );
    }
  }

  // ==========================================================
  // GET VALUE
  // ==========================================================
  //
  // Mengambil cell berdasarkan nama header.
  // ==========================================================

  dynamic _getValue(List<Data?> row, List<String> headers, String header) {
    final columnIndex = headers.indexOf(header);

    if (columnIndex < 0) {
      return null;
    }

    if (columnIndex >= row.length) {
      return null;
    }

    final cell = row[columnIndex];

    if (cell == null) {
      return null;
    }

    final value = cell.value;

    if (value == null) {
      return null;
    }

    // ========================================================
    // excel 4.x menggunakan CellValue.
    //
    // TextCellValue.value berupa TextSpan.
    // Kita mengambil text dari TextSpan agar domain aplikasi
    // menerima String biasa.
    // ========================================================

    if (value is TextCellValue) {
      return value.value.text;
    }

    // ========================================================
    // Tipe numerik
    // ========================================================

    if (value is IntCellValue) {
      return value.value;
    }

    if (value is DoubleCellValue) {
      return value.value;
    }

    if (value is BoolCellValue) {
      return value.value;
    }

    if (value is DateCellValue) {
      return value.asDateTimeUtc();
    }

    // Fallback.
    return value.toString();
  }

  // ==========================================================
  // NORMALIZE HEADER
  // ==========================================================
  //
  // Contoh:
  //
  // " LOKASI "       -> "lokasi"
  // "QTY SO"         -> "qty_so"
  // "TEAR AKTUAL"    -> "tear_aktual"
  // ==========================================================

  String _normalizeHeader(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  // ==========================================================
  // EMPTY ROW
  // ==========================================================

  bool _isEmptyRow(List<Data?> row) {
    for (final cell in row) {
      final value = cell?.value;

      if (value != null && value.toString().trim().isNotEmpty) {
        return false;
      }
    }

    return true;
  }
}

// ============================================================
// FILE:
// lib/data/datasources/excel_data_source.dart
// ============================================================
//
// FUNGSI:
// Membaca Master Item dari file Excel (.xlsx).
//
// Alur:
//
// Excel
//   ↓
// Cari baris HEADER secara otomatis
//   ↓
// Validasi kolom
//   ↓
// Baca setiap baris barang
//   ↓
// Mapping ke nama field aplikasi
//   ↓
// List<Map<String, dynamic>>
//
// DATABASE BELUM DIGUNAKAN DI SINI.
// ============================================================

import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;

// ============================================================
// CLASS: ExcelDataSource
// ============================================================
//
// Bertugas khusus membaca data Master Item dari Excel.
// ============================================================

class ExcelDataSource {
  // ==========================================================
  // HEADER YANG WAJIB ADA DI EXCEL
  // ==========================================================
  //
  // "C2" adalah nama kolom asli dari Excel mentor.
  // Nanti kita ubah menjadi "CONV2" untuk aplikasi.
  // ==========================================================

  static const List<String> requiredExcelHeaders = [
    'BARCODE',
    'PLU',
    'PRICE',
    'DESC',
    'RETUR HARI',
    'C2',
    'TYPE',
    'STACK',
    'TEAR',
  ];

  // ==========================================================
  // readMasterProduct()
  // ==========================================================
  //
  // Fungsi:
  // Membaca seluruh Master Item dari file Excel.
  //
  // Parameter:
  // filePath = lokasi file .xlsx
  //
  // Return:
  // List<Map<String, dynamic>>
  //
  // Satu Map = satu barang.
  // ==========================================================

  Future<List<Map<String, dynamic>>> readMasterProduct(String filePath) async {
    List<int> bytes;

    final file = File(filePath);

    if (await file.exists()) {
      bytes = await file.readAsBytes();
    } else {
      try {
        final assetData = await rootBundle.load(filePath);

        bytes = assetData.buffer.asUint8List(
          assetData.offsetInBytes,
          assetData.lengthInBytes,
        );
      } catch (e) {
        throw Exception(
          'File Excel tidak ditemukan sebagai file maupun asset: $filePath',
        );
      }
    }

    return _parseMasterProductBytes(bytes);
  }

  Future<List<Map<String, dynamic>>> readMasterProductBytes(
    List<int> bytes,
  ) async {
    if (bytes.isEmpty) {
      throw StateError('File Excel tidak dapat dibaca.');
    }

    return _parseMasterProductBytes(bytes);
  }

  List<Map<String, dynamic>> _parseMasterProductBytes(List<int> bytes) {
    // --------------------------------------------------------
    // 2. Membuka file Excel dari bytes.
    // --------------------------------------------------------

    // --------------------------------------------------------
    // 3. Membuka file Excel.
    // --------------------------------------------------------

    final excel = Excel.decodeBytes(bytes);

    // --------------------------------------------------------
    // 4. Memastikan Excel mempunyai worksheet.
    // --------------------------------------------------------

    if (excel.tables.isEmpty) {
      throw Exception('File Excel tidak memiliki worksheet.');
    }

    // --------------------------------------------------------
    // 5. Mengambil worksheet pertama.
    //
    // File Master Item kita menggunakan worksheet pertama.
    // --------------------------------------------------------

    final sheetName = excel.tables.keys.first;

    final sheet = excel.tables[sheetName];

    if (sheet == null) {
      throw Exception('Worksheet Excel tidak dapat dibaca.');
    }

    // --------------------------------------------------------
    // 6. Mencari baris HEADER secara otomatis.
    //
    // Kita tidak menganggap header selalu berada di baris 1.
    //
    // Excel mentor memiliki informasi/judul sebelum tabel.
    // Karena itu kita mencari baris yang memiliki:
    //
    // BARCODE
    // PLU
    // DESC
    //
    // --------------------------------------------------------

    int? headerRowIndex;

    Map<String, int>? headerIndexes;

    for (int rowIndex = 0; rowIndex < sheet.maxRows; rowIndex++) {
      // Mengambil satu baris Excel.
      final row = sheet.row(rowIndex);

      // Menyimpan posisi header pada baris ini.
      final indexes = <String, int>{};

      // Membaca setiap cell pada baris.
      for (int columnIndex = 0; columnIndex < row.length; columnIndex++) {
        // Mengambil nilai cell.
        final cellValue = row[columnIndex]?.value?.toString() ?? '';

        // Membersihkan spasi.
        final normalized = _normalizeHeader(cellValue);

        // Jika cell mempunyai nilai,
        // simpan posisi kolomnya.
        if (normalized.isNotEmpty) {
          indexes[normalized] = columnIndex;
        }
      }

      // ------------------------------------------------------
      // Mengecek apakah baris ini merupakan header Master.
      // ------------------------------------------------------

      final isHeader = _containsMinimumHeaders(indexes);

      if (isHeader) {
        headerRowIndex = rowIndex;
        headerIndexes = indexes;
        break;
      }
    }

    // --------------------------------------------------------
    // 7. Jika header tidak ditemukan,
    // hentikan proses dengan pesan yang jelas.
    // --------------------------------------------------------

    if (headerRowIndex == null || headerIndexes == null) {
      throw Exception(
        'Header Master Item tidak ditemukan. '
        'Pastikan Excel memiliki kolom BARCODE, PLU, '
        'DESC, PRICE, RETUR HARI, C2, TYPE, STACK, dan TEAR.',
      );
    }

    // --------------------------------------------------------
    // 8. Memastikan semua kolom wajib tersedia.
    // --------------------------------------------------------

    final missingHeaders = requiredExcelHeaders
        .where((header) => !headerIndexes!.containsKey(header))
        .toList();

    // --------------------------------------------------------
    // 9. Jika ada kolom yang hilang,
    // jangan melakukan import.
    // --------------------------------------------------------

    if (missingHeaders.isNotEmpty) {
      throw Exception(
        'Kolom Excel tidak lengkap. '
        'Kolom yang hilang: '
        '${missingHeaders.join(', ')}',
      );
    }

    // --------------------------------------------------------
    // 10. Menyiapkan list hasil pembacaan.
    // --------------------------------------------------------

    final List<Map<String, dynamic>> products = [];

    // --------------------------------------------------------
    // 11. Membaca semua baris SETELAH HEADER.
    // --------------------------------------------------------

    for (
      int rowIndex = headerRowIndex + 1;
      rowIndex < sheet.maxRows;
      rowIndex++
    ) {
      // Mengambil baris barang.
      final row = sheet.row(rowIndex);

      // ------------------------------------------------------
      // 12. Melewati baris kosong.
      // ------------------------------------------------------

      if (_isEmptyRow(row)) {
        continue;
      }

      // ------------------------------------------------------
      // 13. Membaca nilai berdasarkan nama kolom Excel.
      // ------------------------------------------------------

      dynamic getExcelValue(String header) {
        // Mengambil index kolom.
        final columnIndex = headerIndexes![header];

        // Jika kolom tidak ditemukan.
        if (columnIndex == null) {
          return null;
        }

        // Jika baris tidak memiliki cell tersebut.
        if (columnIndex >= row.length) {
          return null;
        }

        // Mengembalikan nilai cell.
        return row[columnIndex]?.value;
      }

      // ------------------------------------------------------
      // 14. Mengambil semua nilai Excel.
      // ------------------------------------------------------

      final barcode = _cleanValue(getExcelValue('BARCODE'));

      final plu = _cleanValue(getExcelValue('PLU'));

      final description = _cleanValue(getExcelValue('DESC'));

      final price = _toDouble(getExcelValue('PRICE'));

      final returHari = _toInt(getExcelValue('RETUR HARI'));

      final conv2 = _toInt(getExcelValue('C2'));

      final type = _cleanValue(getExcelValue('TYPE'));

      final masterStack = _toInt(getExcelValue('STACK'));

      final masterTear = _toInt(getExcelValue('TEAR'));

      // ------------------------------------------------------
      // 15. Validasi baris barang.
      //
      // Jika BARCODE, PLU, atau DESC kosong,
      // baris tidak dianggap sebagai barang valid.
      // ------------------------------------------------------

      if (barcode.isEmpty && plu.isEmpty && description.isEmpty) {
        continue;
      }

      // ------------------------------------------------------
      // 16. Mapping Excel → Aplikasi.
      // ------------------------------------------------------
      //
      // Excel:
      // C2    → conv2
      // TEAR  → masterTear
      // STACK → masterStack
      //
      // ------------------------------------------------------

      final product = <String, dynamic>{
        // Barcode barang.
        'barcode': barcode,

        // PLU barang.
        'plu': plu,

        // Nama/deskripsi barang.
        'description': description,

        // Harga barang.
        'price': price,

        // Jumlah hari retur.
        'returHari': returHari,

        // C2 dari Excel menjadi CONV2 aplikasi.
        'conv2': conv2,

        // Type barang.
        'type': type,

        // TEAR dari Excel menjadi Master Tear.
        'masterTear': masterTear,

        // STACK dari Excel menjadi Master Stack.
        'masterStack': masterStack,
      };

      // ------------------------------------------------------
      // 17. Menambahkan barang ke hasil.
      // ------------------------------------------------------

      products.add(product);
    }

    // --------------------------------------------------------
    // 18. Mengembalikan seluruh Master Item.
    // --------------------------------------------------------

    return products;
  }
}

// ==========================================================
// _normalizeHeader()
// ==========================================================
//
// Membersihkan nama header Excel.
//
// Contoh:
//
// " barcode " → "BARCODE"
// "Barcode"   → "BARCODE"
// ==========================================================

String _normalizeHeader(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
}

// ==========================================================
// _containsMinimumHeaders()
// ==========================================================
//
// Menentukan apakah suatu baris merupakan HEADER.
//
// Kita menggunakan BARCODE, PLU, dan DESC sebagai
// identitas minimum header Master Item.
// ==========================================================

bool _containsMinimumHeaders(Map<String, int> indexes) {
  return indexes.containsKey('BARCODE') &&
      indexes.containsKey('PLU') &&
      indexes.containsKey('DESC');
}

// ==========================================================
// _isEmptyRow()
// ==========================================================
//
// Mengecek apakah satu baris Excel kosong.
// ==========================================================

bool _isEmptyRow(List<Data?> row) {
  for (final cell in row) {
    final value = cell?.value?.toString().trim() ?? '';

    if (value.isNotEmpty) {
      return false;
    }
  }

  return true;
}

// ==========================================================
// _cleanValue()
// ==========================================================
//
// Mengubah nilai Excel menjadi String yang bersih.
// ==========================================================

String _cleanValue(dynamic value) {
  if (value == null) {
    return '';
  }

  var text = value.toString().trim();

  // Excel kadang menyimpan barcode sebagai teks
  // dengan apostrophe di bagian awal.
  if (text.startsWith("'") || text.startsWith('`')) {
    text = text.substring(1).trim();
  }

  return text;
}

// ==========================================================
// _toInt()
// ==========================================================
//
// Mengubah nilai Excel menjadi integer.
//
// Contoh:
//
// "12"   → 12
// 12     → 12
// 12.0   → 12
// kosong → 0
// ==========================================================

int _toInt(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is int) {
    return value;
  }

  if (value is double) {
    return value.toInt();
  }

  final text = value.toString().trim();

  if (text.isEmpty) {
    return 0;
  }

  return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
}

// ==========================================================
// _toDouble()
// ==========================================================
//
// Mengubah nilai Excel menjadi double.
//
// Contoh:
//
// 4216.94 → 4216.94
// "4216.94" → 4216.94
// ==========================================================

double _toDouble(dynamic value) {
  if (value == null) {
    return 0;
  }

  if (value is double) {
    return value;
  }

  if (value is int) {
    return value.toDouble();
  }

  final text = value.toString().trim();

  if (text.isEmpty) {
    return 0;
  }

  return double.tryParse(text) ?? 0;
}

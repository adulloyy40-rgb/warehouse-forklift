// ============================================================
// FILE:
// lib/data/datasources/storage_excel_data_source.dart
//
// FUNGSI:
// Membaca data storage dari file Excel.
//
// DATA YANG DIBACA:
// - Location Code
// - Rack
// - Bay
// - Shelving
// - Position
// - PLU
// - Barcode
// - Description
// - Quantity
//
// PENTING:
// Data Excel TIDAK langsung dianggap valid.
//
// Alur:
//
// Excel
//   ↓
// StorageExcelDataSource
//   ↓
// Parsing
//   ↓
// LocationValidator
//   ↓
// Data valid / data invalid
//
// Database belum digunakan pada tahap ini.
// ============================================================

import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../../domain/validators/location_validator.dart';


// ============================================================
// CLASS: StorageExcelDataSource
// ============================================================

class StorageExcelDataSource {
  // Validator lokasi.
  final LocationValidator locationValidator;

  // Constructor.
  const StorageExcelDataSource({
    required this.locationValidator,
  });


  // ==========================================================
  // read()
  //
  // Membaca file Excel dari bytes.
  //
  // Return:
  // List<Map<String, dynamic>>
  //
  // Setiap baris Excel menjadi satu Map.
  // ==========================================================

  List<Map<String, dynamic>> read(Uint8List bytes) {
    // Membuka workbook Excel dari bytes.
    final excel = Excel.decodeBytes(bytes);

    // Jika tidak ada sheet sama sekali,
    // kembalikan list kosong.
    if (excel.tables.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    // Mengambil sheet pertama.
    final sheet = excel.tables.values.first;

    // Jika sheet kosong.
    if (sheet.rows.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    // --------------------------------------------------------
    // Membaca header.
    // --------------------------------------------------------

    final headerRow = sheet.rows.first;

    final headers = headerRow.map(
      (cell) => _normalizeHeader(
        cell?.value?.toString() ?? '',
      ),
    ).toList();


    // --------------------------------------------------------
    // Menyimpan hasil parsing.
    // --------------------------------------------------------

    final result = <Map<String, dynamic>>[];


    // --------------------------------------------------------
    // Membaca setiap baris data.
    //
    // Mulai dari index 1 karena index 0 adalah header.
    // --------------------------------------------------------

    for (int rowIndex = 1;
        rowIndex < sheet.rows.length;
        rowIndex++) {

      final row = sheet.rows[rowIndex];

      // Lewati baris kosong.
      if (_isEmptyRow(row)) {
        continue;
      }

      final data = <String, dynamic>{};


      // ------------------------------------------------------
      // Memasukkan setiap cell berdasarkan header.
      // ------------------------------------------------------

      for (int columnIndex = 0;
          columnIndex < headers.length;
          columnIndex++) {

        // Jika jumlah cell kurang dari header,
        // nilai dianggap kosong.
        final value = columnIndex < row.length
            ? row[columnIndex]?.value
            : null;

        final header = headers[columnIndex];

        if (header.isNotEmpty) {
          data[header] = value;
        }
      }


      // ------------------------------------------------------
      // Tambahkan data hasil parsing.
      // ------------------------------------------------------

      result.add(data);
    }


    return result;
  }


  // ==========================================================
  // readValidLocations()
  //
  // Membaca Excel dan hanya mengembalikan lokasi yang valid.
  //
  // Ini adalah fungsi yang nantinya penting untuk proses
  // import 1.000 lokasi storage.
  // ==========================================================

  List<Map<String, dynamic>> readValidLocations(
    Uint8List bytes,
  ) {
    // Baca seluruh data terlebih dahulu.
    final rows = read(bytes);

    // Hasil data yang lolos validasi.
    final validRows = <Map<String, dynamic>>[];


    for (final row in rows) {
      // Ambil Rack.
      final rack = _toInt(
        row['rack'],
      );

      // Ambil Bay.
      final bay = _toInt(
        row['bay'],
      );


      // Rack dan Bay harus tersedia.
      if (rack == null || bay == null) {
        continue;
      }


      // Ambil Shelving jika ada.
      final shelving = _toNullableInt(
        row['shelving'],
      );


      // Ambil Position jika ada.
      final position = _toNullableInt(
        row['position'],
      );


      // ------------------------------------------------------
      // Validasi lokasi.
      // ------------------------------------------------------

      final locationIsValid =
          locationValidator.isRackValid(rack) &&
          locationValidator.isBayValid(
            rack: rack,
            bay: bay,
          ) &&
          locationValidator.isShelvingValid(
            rack: rack,
            shelving: shelving,
          ) &&
          locationValidator.isPositionValid(
            rack: rack,
            position: position,
          );


      // ------------------------------------------------------
      // Hanya data VALID yang dimasukkan.
      // ------------------------------------------------------

      if (locationIsValid) {
        validRows.add(row);
      }
    }


    return validRows;
  }


  // ==========================================================
  // _normalizeHeader()
  //
  // Menyamakan format header Excel.
  //
  // Contoh:
  //
  // "Rack"      → "rack"
  // "RACK"      → "rack"
  // " Rack "    → "rack"
  // ==========================================================

  String _normalizeHeader(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(' ', '_');
  }


  // ==========================================================
  // _isEmptyRow()
  //
  // Mengecek apakah seluruh cell pada baris kosong.
  // ==========================================================

  bool _isEmptyRow(
    List<Data?> row,
  ) {
    for (final cell in row) {
      final value = cell?.value;

      if (value != null &&
          value.toString().trim().isNotEmpty) {
        return false;
      }
    }

    return true;
  }


  // ==========================================================
  // _toInt()
  //
  // Konversi nilai Excel menjadi int.
  //
  // Mendukung:
  //
  // 81
  // "81"
  // 81.0
  // "81.0"
  // ==========================================================

  int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    final integerValue = int.tryParse(text);

    if (integerValue != null) {
      return integerValue;
    }

    final doubleValue = double.tryParse(text);

    if (doubleValue != null) {
      return doubleValue.toInt();
    }

    return null;
  }


  // ==========================================================
  // _toNullableInt()
  //
  // Sama seperti _toInt(), tetapi digunakan untuk field
  // yang boleh kosong seperti Shelving dan Position.
  // ==========================================================

  int? _toNullableInt(dynamic value) {
    return _toInt(value);
  }
}

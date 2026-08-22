import 'dart:typed_data';

import 'package:excel/excel.dart';

class StockPalletExcelDataSource {
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

  List<Map<String, dynamic>> read(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);

    if (excel.tables.isEmpty) {
      throw StateError('File Excel tidak memiliki worksheet.');
    }

    final sheet = excel.tables.values.first;
    final rows = sheet.rows;

    if (rows.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    final headerRow = rows.first;

    final headers = List<String>.generate(
      headerRow.length,
      (index) => _normalizeHeader(
        _cellToString(headerRow[index]?.value),
      ),
      growable: false,
    );

    _validateHeaders(headers);

    // Cari index kolom SATU KALI saja.
    final lokasiIndex = headers.indexOf('lokasi');
    final pluIndex = headers.indexOf('plu');
    final descIndex = headers.indexOf('desc');
    final conv2Index = headers.indexOf('conv2');
    final qtySoIndex = headers.indexOf('qty_so');
    final stackIndex = headers.indexOf('stack');
    final tearIndex = headers.indexOf('tear_aktual');
    final expDateIndex = headers.indexOf('exp_date');

    final result = <Map<String, dynamic>>[];

    for (int rowIndex = 1; rowIndex < rows.length; rowIndex++) {
      final row = rows[rowIndex];

      // Baris kosong hanya diperiksa pada kolom yang dibutuhkan.
      if (_isEmptyRequiredRow(
        row,
        lokasiIndex,
        pluIndex,
        descIndex,
        conv2Index,
        qtySoIndex,
        stackIndex,
        tearIndex,
        expDateIndex,
      )) {
        continue;
      }

      result.add({
        'lokasi': _getCellValue(row, lokasiIndex),
        'plu': _getCellValue(row, pluIndex),
        'desc': _getCellValue(row, descIndex),
        'conv2': _getCellValue(row, conv2Index),
        'qty_so': _getCellValue(row, qtySoIndex),
        'stack': _getCellValue(row, stackIndex),
        'tear_aktual': _getCellValue(row, tearIndex),
        'exp_date': _getCellValue(row, expDateIndex),
      });
    }

    return result;
  }

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

  dynamic _getCellValue(List<Data?> row, int index) {
    if (index < 0 || index >= row.length) {
      return null;
    }

    return _cellValue(row[index]?.value);
  }

  dynamic _cellValue(CellValue? value) {
    if (value == null) {
      return null;
    }

    if (value is TextCellValue) {
      return value.value.text ?? '';
    }

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

    return value.toString();
  }

  String _cellToString(CellValue? value) {
    if (value == null) {
      return '';
    }

    if (value is TextCellValue) {
      return value.value.text ?? '';
    }

    if (value is IntCellValue) {
      return value.value.toString();
    }

    if (value is DoubleCellValue) {
      return value.value.toString();
    }

    if (value is BoolCellValue) {
      return value.value.toString();
    }

    if (value is DateCellValue) {
      return value.asDateTimeUtc().toIso8601String();
    }

    return value.toString();
  }

  bool _isEmptyRequiredRow(
    List<Data?> row,
    int lokasiIndex,
    int pluIndex,
    int descIndex,
    int conv2Index,
    int qtySoIndex,
    int stackIndex,
    int tearIndex,
    int expDateIndex,
  ) {
    final indexes = <int>[
      lokasiIndex,
      pluIndex,
      descIndex,
      conv2Index,
      qtySoIndex,
      stackIndex,
      tearIndex,
      expDateIndex,
    ];

    for (final index in indexes) {
      if (index < 0 || index >= row.length) {
        continue;
      }

      final value = row[index]?.value;

      if (value == null) {
        continue;
      }

      if (value is TextCellValue) {
        final text = value.value.text;

        if (text != null && text.trim().isNotEmpty) {
          return false;
        }

        continue;
      }

      return false;
    }

    return true;
  }

  String _normalizeHeader(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_');
  }
}

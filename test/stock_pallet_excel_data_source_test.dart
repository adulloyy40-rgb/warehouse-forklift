import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/data/datasources/stock_pallet_excel_data_source.dart';

void main() {
  late StockPalletExcelDataSource dataSource;

  setUp(() {
    dataSource = StockPalletExcelDataSource();
  });

  Uint8List createExcel({required List<List<dynamic>> rows}) {
    final excel = Excel.createExcel();

    final sheetName = excel.getDefaultSheet();

    if (sheetName == null) {
      throw StateError('Default Excel sheet tidak tersedia.');
    }

    final sheet = excel[sheetName];

    for (final row in rows) {
      sheet.appendRow(
        row.map((value) {
          if (value == null) {
            return TextCellValue('');
          }

          if (value is int) {
            return IntCellValue(value);
          }

          if (value is double) {
            return DoubleCellValue(value);
          }

          return TextCellValue(value.toString());
        }).toList(),
      );
    }

    final bytes = excel.encode();

    if (bytes == null || bytes.isEmpty) {
      throw StateError('Gagal membuat file Excel test.');
    }

    return Uint8List.fromList(bytes);
  }

  group('StockPalletExcelDataSource', () {
    test('Excel tanpa data menghasilkan list kosong', () {
      final bytes = createExcel(
        rows: [
          [
            'LOKASI',
            'PLU',
            'DESC',
            'CONV2',
            'QTY SO',
            'STACK',
            'TEAR AKTUAL',
            'EXP DATE',
          ],
        ],
      );

      final result = dataSource.read(bytes);

      expect(result, isEmpty);
    });

    test('Parser membaca data pallet dengan benar', () {
      final bytes = createExcel(
        rows: [
          [
            'LOKASI',
            'PLU',
            'DESC',
            'CONV2',
            'QTY SO',
            'STACK',
            'TEAR AKTUAL',
            'EXP DATE',
          ],
          ['8001101', '123456', 'BARANG TEST', 24, 10, 5, 2, '2026-12-31'],
        ],
      );

      final result = dataSource.read(bytes);

      expect(result, hasLength(1));

      expect(result[0]['lokasi'], '8001101');
      expect(result[0]['plu'], '123456');
      expect(result[0]['desc'], 'BARANG TEST');
      expect(result[0]['conv2'], 24);
      expect(result[0]['qty_so'], 10);
      expect(result[0]['stack'], 5);
      expect(result[0]['tear_aktual'], 2);
      expect(result[0]['exp_date'], isNotNull);
    });

    test('Header Excel tidak sensitif terhadap huruf besar kecil', () {
      final bytes = createExcel(
        rows: [
          [
            'lokasi',
            'plu',
            'desc',
            'conv2',
            'qty so',
            'stack',
            'tear aktual',
            'exp date',
          ],
          ['8001102', '654321', 'BARANG TEST 2', 12, 20, 4, 3, '2027-01-15'],
        ],
      );

      final result = dataSource.read(bytes);

      expect(result, hasLength(1));
      expect(result[0]['lokasi'], '8001102');
      expect(result[0]['plu'], '654321');
    });

    test('Baris kosong diabaikan', () {
      final bytes = createExcel(
        rows: [
          [
            'LOKASI',
            'PLU',
            'DESC',
            'CONV2',
            'QTY SO',
            'STACK',
            'TEAR AKTUAL',
            'EXP DATE',
          ],
          ['8001103', '777888', 'BARANG TEST 3', 10, 15, 3, 5, '2027-02-20'],
          ['', '', '', '', '', '', '', ''],
          [null, null, null, null, null, null, null, null],
        ],
      );

      final result = dataSource.read(bytes);

      expect(result, hasLength(1));
      expect(result[0]['lokasi'], '8001103');
    });
  });
}

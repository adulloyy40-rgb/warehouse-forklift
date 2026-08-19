import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../entities/stock_pallet.dart';

class StockPalletExportService {
  static const int nearReturnExtraDays = 30;

  const StockPalletExportService();

  Uint8List export(List<StockPallet> pallets) {
    final excel = Excel.createExcel();

    final sheet = excel['Stock Pallet'];

    // ==========================================================
    // HEADER
    // ==========================================================

    final headers = <String>[
      'No',
      'Location Code',
      'PLU',
      'Barcode',
      'Description',
      'Type',
      'Price',
      'CONV2',
      'Retur Hari',
      'Tear Aktual',
      'Stack Aktual',
      'Qty CTN',
      'Qty PCS',
      'Expired Date',
      'Status',
      'Sesuai Master',
      'Operator NIK',
      'Input Date',
    ];

    sheet.appendRow(headers.map((value) => TextCellValue(value)).toList());

    // ==========================================================
    // DATA
    // ==========================================================

    for (var i = 0; i < pallets.length; i++) {
      final pallet = pallets[i];

      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(pallet.locationCode),
        TextCellValue(pallet.plu),
        TextCellValue(pallet.barcode),
        TextCellValue(pallet.description),
        TextCellValue(pallet.type),
        DoubleCellValue(pallet.price),
        IntCellValue(pallet.conv2),
        IntCellValue(pallet.returHari),
        IntCellValue(pallet.tear),
        IntCellValue(pallet.stack),
        IntCellValue(pallet.qtyCtn),
        IntCellValue(pallet.qtyPcs),
        TextCellValue(_formatDate(pallet.expiredDate)),
        TextCellValue(_getStatus(pallet)),
        TextCellValue(pallet.sesuaiMaster ? 'YA' : 'TIDAK'),
        TextCellValue(pallet.operatorNik),
        TextCellValue(_formatDateTime(pallet.inputDate)),
      ]);
    }

    // ==========================================================
    // AUTO WIDTH
    // ==========================================================

    for (var column = 0; column < headers.length; column++) {
      sheet.setColumnWidth(column, _columnWidth(headers[column]));
    }

    // ==========================================================
    // EXPORT
    // ==========================================================

    final bytes = excel.save();

    if (bytes == null || bytes.isEmpty) {
      throw StateError('Gagal membuat file Excel.');
    }

    return Uint8List.fromList(bytes);
  }

  // ==========================================================
  // STATUS PALLET
  // ==========================================================

  String _getStatus(StockPallet pallet) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    final expired = DateTime(
      pallet.expiredDate.year,
      pallet.expiredDate.month,
      pallet.expiredDate.day,
    );

    if (!expired.isAfter(today)) {
      return 'EXPIRED';
    }

    final daysUntilExpired = expired.difference(today).inDays;

    final nearReturnLimit = pallet.returHari + nearReturnExtraDays;

    if (daysUntilExpired <= nearReturnLimit) {
      return 'NEAR RETURN';
    }

    return 'AMAN';
  }

  // ==========================================================
  // FORMAT DATE
  // ==========================================================

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }

  // ==========================================================
  // FORMAT DATE TIME
  // ==========================================================

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute:$second';
  }

  // ==========================================================
  // COLUMN WIDTH
  // ==========================================================

  double _columnWidth(String header) {
    switch (header) {
      case 'No':
        return 8;

      case 'Location Code':
        return 18;

      case 'PLU':
        return 16;

      case 'Barcode':
        return 20;

      case 'Description':
        return 35;

      case 'Type':
        return 14;

      case 'Price':
        return 16;

      case 'CONV2':
      case 'Retur Hari':
      case 'Tear Aktual':
      case 'Stack Aktual':
      case 'Qty CTN':
      case 'Qty PCS':
        return 14;

      case 'Expired Date':
        return 16;

      case 'Status':
        return 18;

      case 'Sesuai Master':
        return 16;

      case 'Operator NIK':
        return 18;

      case 'Input Date':
        return 22;

      default:
        return 15;
    }
  }
}

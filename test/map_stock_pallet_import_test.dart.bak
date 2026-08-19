import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/domain/entities/stock_pallet.dart';
import 'package:warehouse_forklift/domain/usecases/map_stock_pallet_import.dart';

void main() {
  const mapper = MapStockPalletImport();

  const master = StockPalletMasterData(
    barcode: '8999999999999',
    price: 25000,
    returHari: 60,
    type: 'FG',
  );

  Map<String, dynamic> validRow() {
    return {
      'lokasi': '8001101',
      'plu': '123456',
      'desc': 'Barang Test',
      'conv2': 24,
      'qty_so': 10,
      'stack': 2,
      'tear_aktual': 5,
      'exp_date': '2026-12-31',
    };
  }

  group('MapStockPalletImport', () {
    test('memetakan data Excel dan Master Barang menjadi StockPallet', () {
      final result = mapper.execute(
        row: validRow(),
        master: master,
        operatorNik: '12345678',
        inputDate: DateTime(2026, 8, 19, 10, 30),
      );

      expect(result, isA<StockPallet>());

      expect(result.locationCode, '8001101');
      expect(result.plu, '123456');
      expect(result.description, 'Barang Test');

      expect(result.barcode, '8999999999999');
      expect(result.price, 25000);
      expect(result.returHari, 60);
      expect(result.type, 'FG');

      expect(result.conv2, 24);
      expect(result.qtyCtn, 10);
      expect(result.qtyPcs, 240);

      expect(result.stack, 2);
      expect(result.tear, 5);

      expect(result.expiredDate, DateTime(2026, 12, 31));

      expect(result.inputDate, DateTime(2026, 8, 19, 10, 30));

      expect(result.operatorNik, '12345678');
      expect(result.sesuaiMaster, isTrue);
    });

    test('qtyPcs dihitung dari qtyCtn dikali conv2', () {
      final row = validRow()
        ..['qty_so'] = 15
        ..['conv2'] = 12;

      final result = mapper.execute(
        row: row,
        master: master,
        operatorNik: '12345678',
        inputDate: DateTime(2026, 8, 19),
      );

      expect(result.qtyCtn, 15);
      expect(result.qtyPcs, 180);
    });

    test('tanggal expired harus valid', () {
      final row = validRow()..['exp_date'] = 'tanggal-salah';

      expect(
        () => mapper.execute(row: row, master: master, operatorNik: '12345678'),
        throwsA(isA<FormatException>()),
      );
    });

    test('lokasi wajib diisi', () {
      final row = validRow()..['lokasi'] = '';

      expect(
        () => mapper.execute(row: row, master: master, operatorNik: '12345678'),
        throwsA(isA<FormatException>()),
      );
    });

    test('operator NIK diteruskan ke StockPallet', () {
      final result = mapper.execute(
        row: validRow(),
        master: master,
        operatorNik: '99887766',
      );

      expect(result.operatorNik, '99887766');
    });
  });
}

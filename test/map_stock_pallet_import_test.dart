import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/domain/entities/product.dart';
import 'package:warehouse_forklift/domain/entities/stock_pallet.dart';
import 'package:warehouse_forklift/domain/usecases/map_stock_pallet_import.dart';

void main() {
  const mapper = MapStockPalletImport();

  const product = Product(
    barcode: '8999999999999',
    plu: '123456',
    description: 'Barang Test',
    price: 25000,
    returHari: 60,
    conv2: 24,
    type: 'FG',
    masterTear: 5,
    masterStack: 2,
  );

  Map<String, dynamic> validRow() {
    return {
      'lokasi': '8001101',
      'plu': '123456',
      'tear_aktual': 5,
      'stack': 2,
      'exp_date': '2026-12-31',
    };
  }

  group('MapStockPalletImport', () {
    test(
      'memetakan data Excel dan Master Barang menjadi StockPallet',
      () {
        final result = mapper.execute(
          row: validRow(),
          product: product,
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

        // Tear 5 × Stack 2 = 10 CTN.
        expect(result.qtyCtn, 10);

        // 10 CTN × Conv2 24 = 240 PCS.
        expect(result.qtyPcs, 240);

        expect(result.stack, 2);
        expect(result.tear, 5);

        expect(
          result.expiredDate,
          DateTime(2026, 12, 31),
        );

        expect(
          result.inputDate,
          DateTime(2026, 8, 19, 10, 30),
        );

        expect(result.operatorNik, '12345678');

        // Tear dan Stack aktual sama dengan Master Barang.
        expect(result.sesuaiMaster, isTrue);
      },
    );

    test(
      'qtyPcs dihitung dari qtyCtn dikali conv2 Master Barang',
      () {
        const productConv12 = Product(
          barcode: '8999999999999',
          plu: '123456',
          description: 'Barang Test',
          price: 25000,
          returHari: 60,
          conv2: 12,
          type: 'FG',
          masterTear: 5,
          masterStack: 2,
        );

        final row = validRow()
          ..['tear_aktual'] = 5
          ..['stack'] = 2;

        final result = mapper.execute(
          row: row,
          product: productConv12,
          operatorNik: '12345678',
          inputDate: DateTime(2026, 8, 19),
        );

        // 5 × 2 = 10 CTN.
        expect(result.qtyCtn, 10);

        // 10 × 12 = 120 PCS.
        expect(result.qtyPcs, 120);
      },
    );

    test(
      'tanggal expired harus valid',
      () {
        final row = validRow()
          ..['exp_date'] = 'tanggal-salah';

        expect(
          () => mapper.execute(
            row: row,
            product: product,
            operatorNik: '12345678',
          ),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'lokasi wajib diisi',
      () {
        final row = validRow()
          ..['lokasi'] = '';

        expect(
          () => mapper.execute(
            row: row,
            product: product,
            operatorNik: '12345678',
          ),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'operator NIK diteruskan ke StockPallet',
      () {
        final result = mapper.execute(
          row: validRow(),
          product: product,
          operatorNik: '99887766',
        );

        expect(result.operatorNik, '99887766');
      },
    );

    test(
      'PLU Excel harus sama dengan Master Barang',
      () {
        final row = validRow()
          ..['plu'] = '999999';

        expect(
          () => mapper.execute(
            row: row,
            product: product,
            operatorNik: '12345678',
          ),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'tear dan stack berbeda dari master menghasilkan sesuaiMaster false',
      () {
        final row = validRow()
          ..['tear_aktual'] = 4
          ..['stack'] = 2;

        final result = mapper.execute(
          row: row,
          product: product,
          operatorNik: '12345678',
        );

        expect(result.tear, 4);
        expect(result.stack, 2);

        // Nilai aktual tetap disimpan.
        // Hanya status kesesuaian yang menjadi false.
        expect(result.sesuaiMaster, isFalse);

        // Qty tetap dihitung dari kondisi aktual.
        expect(result.qtyCtn, 8);
        expect(result.qtyPcs, 192);
      },
    );
  });
}

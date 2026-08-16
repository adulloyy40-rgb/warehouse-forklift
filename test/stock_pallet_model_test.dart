// ============================================================
// FILE:
// test/stock_pallet_model_test.dart
//
// FUNGSI:
// Menguji StockPalletModel.
//
// TEST:
// 1. Entity dapat diubah menjadi Model.
// 2. Model dapat diubah menjadi Map.
// 3. Model dapat diubah menjadi Export Map.
// 4. sesuaiMaster true  -> YA.
// 5. sesuaiMaster false -> TIDAK.
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/data/models/stock_pallet_model.dart';
import 'package:warehouse_forklift/domain/entities/stock_pallet.dart';

void main() {
  // ==========================================================
  // DATA TEST
  // ==========================================================

  final expiredDate = DateTime(2027, 12, 31);

  final inputDate = DateTime(
    2026,
    8,
    14,
    10,
    30,
  );

  // ==========================================================
  // PALLET TEST
  // ==========================================================
  //
  // Semua field wajib StockPallet harus diisi.
  //
  // Field master barang:
  // - PLU
  // - Barcode
  // - Description
  // - Price
  // - Retur Hari
  // - CONV2
  // - Type
  //
  // Field fisik pallet:
  // - Tear
  // - Stack
  // - Qty CTN
  // - Qty PCS
  // ==========================================================

  final pallet = StockPallet(
    locationCode: '8101201',

    // --------------------------------------------------------
    // MASTER BARANG
    // --------------------------------------------------------

    plu: '123456',

    barcode: '8991234567890',

    description: 'Produk ABC',

    price: 15000,

    returHari: 7,

    conv2: 12,

    type: 'REGULER',

    // --------------------------------------------------------
    // DATA FISIK PALLET
    // --------------------------------------------------------

    tear: 5,

    stack: 3,

    qtyCtn: 15,

    qtyPcs: 180,

    // --------------------------------------------------------
    // TANGGAL
    // --------------------------------------------------------

    expiredDate: expiredDate,

    inputDate: inputDate,

    // --------------------------------------------------------
    // OPERATOR
    // --------------------------------------------------------

    operatorNik: '123456789',

    // --------------------------------------------------------
    // VALIDASI MASTER
    // --------------------------------------------------------

    sesuaiMaster: true,
  );

  // ==========================================================
  // TEST 1
  // ENTITY -> MODEL
  // ==========================================================

  test(
    'StockPallet Entity dapat diubah menjadi Model',
    () {
      final model = StockPalletModel.fromEntity(
        pallet,
      );

      // ------------------------------------------------------
      // LOCATION
      // ------------------------------------------------------

      expect(
        model.locationCode,
        '8101201',
      );

      // ------------------------------------------------------
      // MASTER BARANG
      // ------------------------------------------------------

      expect(
        model.plu,
        '123456',
      );

      expect(
        model.barcode,
        '8991234567890',
      );

      expect(
        model.description,
        'Produk ABC',
      );

      expect(
        model.price,
        15000,
      );

      expect(
        model.returHari,
        7,
      );

      expect(
        model.conv2,
        12,
      );

      expect(
        model.type,
        'REGULER',
      );

      // ------------------------------------------------------
      // DATA PALLET
      // ------------------------------------------------------

      expect(
        model.tear,
        5,
      );

      expect(
        model.stack,
        3,
      );

      expect(
        model.qtyCtn,
        15,
      );

      expect(
        model.qtyPcs,
        180,
      );

      // ------------------------------------------------------
      // TANGGAL
      // ------------------------------------------------------

      expect(
        model.expiredDate,
        expiredDate,
      );

      expect(
        model.inputDate,
        inputDate,
      );

      // ------------------------------------------------------
      // OPERATOR
      // ------------------------------------------------------

      expect(
        model.operatorNik,
        '123456789',
      );

      // ------------------------------------------------------
      // VALIDASI MASTER
      // ------------------------------------------------------

      expect(
        model.sesuaiMaster,
        true,
      );
    },
  );

  // ==========================================================
  // TEST 2
  // MODEL -> MAP
  // ==========================================================

  test(
    'StockPalletModel dapat diubah menjadi Map',
    () {
      final model = StockPalletModel.fromEntity(
        pallet,
      );

      final map = model.toMap();

      // ------------------------------------------------------
      // MASTER BARANG
      // ------------------------------------------------------

      expect(
        map['locationCode'],
        '8101201',
      );

      expect(
        map['plu'],
        '123456',
      );

      expect(
        map['barcode'],
        '8991234567890',
      );

      expect(
        map['description'],
        'Produk ABC',
      );

      expect(
        map['price'],
        15000,
      );

      expect(
        map['returHari'],
        7,
      );

      expect(
        map['conv2'],
        12,
      );

      expect(
        map['type'],
        'REGULER',
      );

      // ------------------------------------------------------
      // PALLET
      // ------------------------------------------------------

      expect(
        map['tear'],
        5,
      );

      expect(
        map['stack'],
        3,
      );

      expect(
        map['qtyCtn'],
        15,
      );

      expect(
        map['qtyPcs'],
        180,
      );

      // ------------------------------------------------------
      // OPERATOR
      // ------------------------------------------------------

      expect(
        map['operatorNik'],
        '123456789',
      );

      expect(
        map['sesuaiMaster'],
        true,
      );
    },
  );

  // ==========================================================
  // TEST 3
  // EXPORT MAP
  // ==========================================================

  test(
    'StockPalletModel menghasilkan Export Map yang benar',
    () {
      final model = StockPalletModel.fromEntity(
        pallet,
      );

      final exportMap = model.toExportMap(
        no: 1,
      );

      // ------------------------------------------------------
      // NOMOR
      // ------------------------------------------------------

      expect(
        exportMap['No'],
        1,
      );

      // ------------------------------------------------------
      // LOCATION
      // ------------------------------------------------------

      expect(
        exportMap['Location Code'],
        '8101201',
      );

      // ------------------------------------------------------
      // MASTER
      // ------------------------------------------------------

      expect(
        exportMap['PLU'],
        '123456',
      );

      expect(
        exportMap['CONV2'],
        12,
      );

      expect(
        exportMap['Description'],
        'Produk ABC',
      );

      // ------------------------------------------------------
      // PALLET
      // ------------------------------------------------------

      expect(
        exportMap['Tear Aktual'],
        5,
      );

      expect(
        exportMap['Stack Aktual'],
        3,
      );

      expect(
        exportMap['Qty CTN'],
        15,
      );

      expect(
        exportMap['Qty PCS'],
        180,
      );

      // ------------------------------------------------------
      // OPERATOR
      // ------------------------------------------------------

      expect(
        exportMap['Operator NIK'],
        '123456789',
      );

      // ------------------------------------------------------
      // VALIDASI MASTER
      // ------------------------------------------------------

      expect(
        exportMap['Sesuai Master'],
        'YA',
      );
    },
  );

  // ==========================================================
  // TEST 4
  // SESUAI MASTER = FALSE
  // ==========================================================
  //
  // Jika sesuaiMaster false,
  // export harus menghasilkan "TIDAK".
  // ==========================================================

  test(
    'Sesuai Master false menjadi TIDAK',
    () {
      final model = StockPalletModel(
        locationCode: '8101202',

        plu: '999999',

        barcode: '8999999999999',

        description: 'Produk XYZ',

        price: 25000,

        returHari: 14,

        conv2: 12,

        type: 'PROMO',

        tear: 4,

        stack: 2,

        qtyCtn: 8,

        qtyPcs: 96,

        expiredDate: expiredDate,

        inputDate: inputDate,

        operatorNik: '987654321',

        sesuaiMaster: false,
      );

      final exportMap = model.toExportMap(
        no: 2,
      );

      expect(
        exportMap['Sesuai Master'],
        'TIDAK',
      );
    },
  );
}

// ============================================================
// FILE:
// test/stock_pallet_model_test.dart
// ============================================================
//
// FUNGSI:
// Menguji StockPalletModel.
//
// Test memastikan:
// - Entity dapat diubah menjadi Model.
// - Model dapat diubah menjadi Map.
// - Data export mempunyai kolom yang benar.
// - Nilai Sesuai Master berubah menjadi YA/TIDAK.
// ============================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/data/models/stock_pallet_model.dart';
import 'package:warehouse_forklift/domain/entities/stock_pallet.dart';

void main() {
  // ----------------------------------------------------------
  // Data contoh yang digunakan oleh beberapa test.
  // ----------------------------------------------------------

  final expiredDate = DateTime(2027, 12, 31);

  final inputDate = DateTime(2026, 8, 14, 10, 30);

  final pallet = StockPallet(
    locationCode: '8101201',
    plu: '123456',
    description: 'Produk ABC',
    tear: 5,
    stack: 3,
    qtyCtn: 15,
    qtyPcs: 180,
    conv2: 12,
    expiredDate: expiredDate,
    inputDate: inputDate,
    operatorNik: '123456789',
    sesuaiMaster: true,
  );


  // ----------------------------------------------------------
  // TEST 1
  // ----------------------------------------------------------
  //
  // Memastikan Entity dapat dibuat menjadi Model.
  // ----------------------------------------------------------

  test(
    'StockPallet Entity dapat diubah menjadi Model',
    () {
      final model =
          StockPalletModel.fromEntity(pallet);

      expect(
        model.locationCode,
        '8101201',
      );

      expect(
        model.plu,
        '123456',
      );

      expect(
        model.conv2,
        12,
      );

      expect(
        model.qtyCtn,
        15,
      );

      expect(
        model.qtyPcs,
        180,
      );

      expect(
        model.sesuaiMaster,
        true,
      );
    },
  );


  // ----------------------------------------------------------
  // TEST 2
  // ----------------------------------------------------------
  //
  // Memastikan Model dapat diubah menjadi Map.
  // ----------------------------------------------------------

  test(
    'StockPalletModel dapat diubah menjadi Map',
    () {
      final model =
          StockPalletModel.fromEntity(pallet);

      final map = model.toMap();

      expect(
        map['locationCode'],
        '8101201',
      );

      expect(
        map['plu'],
        '123456',
      );

      expect(
        map['conv2'],
        12,
      );

      expect(
        map['qtyCtn'],
        15,
      );

      expect(
        map['qtyPcs'],
        180,
      );
    },
  );


  // ----------------------------------------------------------
  // TEST 3
  // ----------------------------------------------------------
  //
  // Memastikan format export Excel sesuai urutan
  // yang sudah kita sepakati.
  // ----------------------------------------------------------

  test(
    'Export Map mempunyai kolom Stock Pallet',
    () {
      final model =
          StockPalletModel.fromEntity(pallet);

      final exportMap =
          model.toExportMap(no: 1);

      expect(
        exportMap['No'],
        1,
      );

      expect(
        exportMap['Location Code'],
        '8101201',
      );

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

      expect(
        exportMap['Expired Date'],
        '2027-12-31T00:00:00.000',
      );

      expect(
        exportMap['Operator NIK'],
        '123456789',
      );

      expect(
        exportMap['Sesuai Master'],
        'YA',
      );
    },
  );


  // ----------------------------------------------------------
  // TEST 4
  // ----------------------------------------------------------
  //
  // Jika sesuaiMaster = false,
  // hasil export harus menjadi TIDAK.
  // ----------------------------------------------------------

  test(
    'Sesuai Master false menjadi TIDAK',
    () {
      final model = StockPalletModel(
        locationCode: '8101202',
        plu: '999999',
        description: 'Produk XYZ',
        tear: 4,
        stack: 2,
        qtyCtn: 8,
        qtyPcs: 96,
        conv2: 12,
        expiredDate: expiredDate,
        inputDate: inputDate,
        operatorNik: '987654321',
        sesuaiMaster: false,
      );

      final exportMap =
          model.toExportMap(no: 2);

      expect(
        exportMap['Sesuai Master'],
        'TIDAK',
      );
    },
  );
}

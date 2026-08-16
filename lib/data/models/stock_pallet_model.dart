// ============================================================
// FILE:
// lib/data/models/stock_pallet_model.dart
//
// FUNGSI:
// Model untuk data StockPallet.
//
// TANGGUNG JAWAB:
// 1. Mengubah Entity → Model
// 2. Mengubah Map → Model
// 3. Mengubah Model → Map
// 4. Mengubah Model → Map untuk export Excel
//
// MODEL INI TIDAK BERISI LOGIKA DATABASE.
// ============================================================

import '../../domain/entities/stock_pallet.dart';

// ============================================================
// CLASS: StockPalletModel
// ============================================================
//
// StockPalletModel mewarisi StockPallet.
//
// Dengan demikian seluruh field dari Entity dapat digunakan
// oleh Data Layer.
//
// ============================================================

class StockPalletModel extends StockPallet {
  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const StockPalletModel({
    required super.locationCode,
    required super.plu,
    required super.barcode,
    required super.description,
    required super.price,
    required super.returHari,
    required super.conv2,
    required super.type,
    required super.tear,
    required super.stack,
    required super.qtyCtn,
    required super.qtyPcs,
    required super.expiredDate,
    required super.inputDate,
    required super.operatorNik,
    required super.sesuaiMaster,
  });

  // ==========================================================
  // FROM ENTITY
  // ==========================================================
  //
  // Mengubah:
  //
  // StockPallet Entity
  //        ↓
  // StockPalletModel
  //
  // Digunakan ketika data dari Domain perlu diproses
  // oleh Data Layer.
  // ==========================================================

  factory StockPalletModel.fromEntity(StockPallet entity) {
    return StockPalletModel(
      locationCode: entity.locationCode,
      plu: entity.plu,
      barcode: entity.barcode,
      description: entity.description,
      price: entity.price,
      returHari: entity.returHari,
      conv2: entity.conv2,
      type: entity.type,
      tear: entity.tear,
      stack: entity.stack,
      qtyCtn: entity.qtyCtn,
      qtyPcs: entity.qtyPcs,
      expiredDate: entity.expiredDate,
      inputDate: entity.inputDate,
      operatorNik: entity.operatorNik,
      sesuaiMaster: entity.sesuaiMaster,
    );
  }

  // ==========================================================
  // FROM MAP
  // ==========================================================
  //
  // Mengubah:
  //
  // Map<String, dynamic>
  //        ↓
  // StockPalletModel
  //
  // Berguna untuk:
  // - JSON
  // - local storage
  // - import data
  // - database adapter
  // ==========================================================

  factory StockPalletModel.fromMap(Map<String, dynamic> map) {
    return StockPalletModel(
      locationCode: map['locationCode']?.toString() ?? '',
      plu: map['plu']?.toString() ?? '',
      barcode: map['barcode']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: _toDouble(map['price']),
      returHari: _toInt(map['returHari']),
      conv2: _toInt(map['conv2']),
      type: map['type']?.toString() ?? '',
      tear: _toInt(map['tear']),
      stack: _toInt(map['stack']),
      qtyCtn: _toInt(map['qtyCtn']),
      qtyPcs: _toInt(map['qtyPcs']),
      expiredDate: _toDateTime(map['expiredDate']),
      inputDate: _toDateTime(map['inputDate']),
      operatorNik: map['operatorNik']?.toString() ?? '',
      sesuaiMaster: _toBool(map['sesuaiMaster']),
    );
  }

  // ==========================================================
  // TO MAP
  // ==========================================================
  //
  // Mengubah:
  //
  // StockPalletModel
  //        ↓
  // Map<String, dynamic>
  //
  // Digunakan untuk penyimpanan data lokal / JSON.
  // ==========================================================

  Map<String, dynamic> toMap() {
    return {
      'locationCode': locationCode,
      'plu': plu,
      'barcode': barcode,
      'description': description,
      'price': price,
      'returHari': returHari,
      'conv2': conv2,
      'type': type,
      'tear': tear,
      'stack': stack,
      'qtyCtn': qtyCtn,
      'qtyPcs': qtyPcs,
      'expiredDate': expiredDate.toIso8601String(),
      'inputDate': inputDate.toIso8601String(),
      'operatorNik': operatorNik,
      'sesuaiMaster': sesuaiMaster,
    };
  }

  // ==========================================================
  // TO EXPORT MAP
  // ==========================================================
  //
  // Format khusus untuk export Excel.
  //
  // URUTAN KOLOM:
  //
  // No
  // Location Code
  // PLU
  // CONV2
  // Description
  // Tear Aktual
  // Stack Aktual
  // Qty CTN
  // Qty PCS
  // Expired Date
  // Input Date
  // Operator NIK
  // Sesuai Master
  //
  // "No" tidak disimpan di Entity.
  // Nomor hanya digunakan untuk laporan/export.
  // ==========================================================

  Map<String, dynamic> toExportMap({required int no}) {
    return {
      'No': no,
      'Location Code': locationCode,
      'PLU': plu,
      'CONV2': conv2,
      'Description': description,
      'Tear Aktual': tear,
      'Stack Aktual': stack,
      'Qty CTN': qtyCtn,
      'Qty PCS': qtyPcs,
      'Expired Date': expiredDate.toIso8601String(),
      'Input Date': inputDate.toIso8601String(),
      'Operator NIK': operatorNik,
      'Sesuai Master': sesuaiMaster ? 'YA' : 'TIDAK',
    };
  }

  // ==========================================================
  // PRIVATE HELPER: TO DOUBLE
  // ==========================================================
  //
  // Mengubah berbagai tipe data menjadi double.
  //
  // Contoh:
  // 10       → 10.0
  // 10.5     → 10.5
  // "10"     → 10.0
  // "10.5"   → 10.5
  // null     → 0.0
  // ==========================================================

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return 0.0;
    }

    return double.tryParse(text) ?? 0.0;
  }

  // ==========================================================
  // PRIVATE HELPER: TO INT
  // ==========================================================
  //
  // Mengubah berbagai tipe data menjadi integer.
  //
  // Contoh:
  // 10       → 10
  // 10.0     → 10
  // "10"     → 10
  // "10.0"   → 10
  // null     → 0
  // ==========================================================

  static int _toInt(dynamic value) {
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

    final intValue = int.tryParse(text);

    if (intValue != null) {
      return intValue;
    }

    final doubleValue = double.tryParse(text);

    if (doubleValue != null) {
      return doubleValue.toInt();
    }

    return 0;
  }

  // ==========================================================
  // PRIVATE HELPER: TO BOOL
  // ==========================================================
  //
  // Mendukung:
  //
  // true
  // false
  // "true"
  // "false"
  // "YA"
  // "TIDAK"
  // "yes"
  // "no"
  // "1"
  // "0"
  //
  // Hasil:
  // YA / true / yes / 1 → true
  // selain itu           → false
  // ==========================================================

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    final text = value?.toString().trim().toLowerCase() ?? '';

    return text == 'true' || text == 'ya' || text == 'yes' || text == '1';
  }

  // ==========================================================
  // PRIVATE HELPER: TO DATETIME
  // ==========================================================
  //
  // Mengubah nilai menjadi DateTime.
  //
  // Jika nilai tidak valid:
  // digunakan Unix Epoch sebagai fallback.
  //
  // 1970-01-01 00:00:00
  // ==========================================================

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.tryParse(text) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}

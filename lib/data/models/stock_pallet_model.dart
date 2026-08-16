// ============================================================
// FILE:
// lib/data/models/stock_pallet_model.dart
// ============================================================
//
// FUNGSI:
// Model untuk data StockPallet.
//
// Model ini menjadi penghubung antara:
//
// Data Layer
//      ↓
// StockPallet Entity
//
// Model menyediakan fungsi:
// - fromEntity()
// - fromMap()
// - toMap()
// - toExportMap()
//
// FORMAT EXPORT EXCEL:
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
// ============================================================

import '../../domain/entities/stock_pallet.dart';

// ============================================================
// CLASS: StockPalletModel
// ============================================================
//
// Model mewarisi Entity StockPallet.
//
// Dengan cara ini data domain tetap dapat digunakan
// oleh Data Layer tanpa membuat struktur data berbeda.
// ============================================================

class StockPalletModel extends StockPallet {
  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  const StockPalletModel({
    required super.locationCode,
    required super.plu,
    required super.description,
    required super.tear,
    required super.stack,
    required super.qtyCtn,
    required super.qtyPcs,
    required super.conv2,
    required super.expiredDate,
    required super.inputDate,
    required super.operatorNik,
    required super.sesuaiMaster,
  });

  // ==========================================================
  // fromEntity()
  // ==========================================================
  //
  // FUNGSI:
  // Mengubah StockPallet Entity menjadi StockPalletModel.
  //
  // Digunakan ketika data dari Domain masuk ke Data Layer.
  // ==========================================================

  factory StockPalletModel.fromEntity(StockPallet entity) {
    return StockPalletModel(
      locationCode: entity.locationCode,
      plu: entity.plu,
      description: entity.description,
      tear: entity.tear,
      stack: entity.stack,
      qtyCtn: entity.qtyCtn,
      qtyPcs: entity.qtyPcs,
      conv2: entity.conv2,
      expiredDate: entity.expiredDate,
      inputDate: entity.inputDate,
      operatorNik: entity.operatorNik,
      sesuaiMaster: entity.sesuaiMaster,
    );
  }

  // ==========================================================
  // fromMap()
  // ==========================================================
  //
  // FUNGSI:
  // Membuat StockPalletModel dari Map.
  //
  // Nantinya berguna untuk:
  // - database
  // - local storage
  // - JSON
  // - pembacaan data
  // ==========================================================

  factory StockPalletModel.fromMap(Map<String, dynamic> map) {
    return StockPalletModel(
      locationCode: map['locationCode']?.toString() ?? '',

      plu: map['plu']?.toString() ?? '',

      description: map['description']?.toString() ?? '',

      tear: _toInt(map['tear']),

      stack: _toInt(map['stack']),

      qtyCtn: _toInt(map['qtyCtn']),

      qtyPcs: _toInt(map['qtyPcs']),

      conv2: _toInt(map['conv2']),

      expiredDate: _toDateTime(map['expiredDate']),

      inputDate: _toDateTime(map['inputDate']),

      operatorNik: map['operatorNik']?.toString() ?? '',

      sesuaiMaster: _toBool(map['sesuaiMaster']),
    );
  }

  // ==========================================================
  // toMap()
  // ==========================================================
  //
  // FUNGSI:
  // Mengubah StockPalletModel menjadi Map.
  //
  // Digunakan untuk penyimpanan data.
  //
  // Contoh:
  //
  // StockPalletModel
  //       ↓
  //     toMap()
  //       ↓
  // Map<String, dynamic>
  // ==========================================================

  Map<String, dynamic> toMap() {
    return {
      'locationCode': locationCode,
      'plu': plu,
      'conv2': conv2,
      'description': description,
      'tear': tear,
      'stack': stack,
      'qtyCtn': qtyCtn,
      'qtyPcs': qtyPcs,

      // DateTime disimpan sebagai String ISO 8601
      // supaya mudah disimpan ke database/JSON.
      'expiredDate': expiredDate.toIso8601String(),

      'inputDate': inputDate.toIso8601String(),

      'operatorNik': operatorNik,

      'sesuaiMaster': sesuaiMaster,
    };
  }

  // ==========================================================
  // toExportMap()
  // ==========================================================
  //
  // FUNGSI:
  // Mengubah data pallet menjadi format yang siap
  // digunakan oleh Excel Export.
  //
  // URUTAN KOLOM SUDAH DIKUNCI:
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
  // No bukan bagian dari Entity.
  // No hanya digunakan saat membuat laporan Excel.
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
  // _toInt()
  // ==========================================================
  //
  // FUNGSI:
  // Mengubah nilai menjadi integer.
  //
  // Mendukung:
  // 10
  // 10.0
  // "10"
  // "10.0"
  // null
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
  // _toBool()
  // ==========================================================
  //
  // FUNGSI:
  // Mengubah berbagai bentuk nilai menjadi boolean.
  //
  // YA / true / yes / 1 → true
  // TIDAK / false / no / 0 → false
  // ==========================================================

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    final text = value?.toString().trim().toLowerCase() ?? '';

    return text == 'true' || text == 'ya' || text == 'yes' || text == '1';
  }

  // ==========================================================
  // _toDateTime()
  // ==========================================================
  //
  // FUNGSI:
  // Mengubah nilai menjadi DateTime.
  //
  // Jika data tanggal tidak valid,
  // digunakan nilai fallback epoch.
  // ==========================================================

  static DateTime _toDateTime(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    final text = value?.toString().trim() ?? '';

    final result = DateTime.tryParse(text);

    return result ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}

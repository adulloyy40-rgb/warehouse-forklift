// ============================================================
// FILE:
// lib/data/models/product_model.dart
// ============================================================
//
// FUNGSI:
// Model data untuk Master Item.
//
// ALUR DATA:
//
// Excel / Database
//       ↓
// ProductModel
//       ↓
// Product Entity
//       ↓
// Domain / UseCase / Presentation
//
// TANGGUNG JAWAB:
// - Membaca data dari Map.
// - Mengubah ProductModel menjadi Product Entity.
// - Mengubah Product Entity menjadi ProductModel.
// - Mengubah ProductModel menjadi Map.
//
// CATATAN:
// masterTear dan masterStack adalah nilai standar dari
// Master Item.
//
// Nilai fisik Tear dan Stack operator TIDAK disimpan
// di ProductModel.
// Nilai fisik tersebut berada di StockPallet.
// ============================================================

import '../../domain/entities/product.dart';

// ============================================================
// CLASS: ProductModel
// ============================================================
//
// ProductModel berada di DATA layer.
//
// Berbeda dengan Product Entity yang berada di DOMAIN layer,
// ProductModel memiliki fungsi tambahan untuk:
// - mapping data
// - membaca Map
// - membuat Map
// - konversi Entity
// ============================================================

class ProductModel {
  // ==========================================================
  // DATABASE ID
  // ==========================================================
  //
  // ID internal SQLite.
  //
  // Nullable karena data baru dari Excel/form belum tentu
  // memiliki ID database.
  // ==========================================================

  final int? id;

  // ==========================================================
  // BARCODE
  // ==========================================================
  //
  // Barcode resmi barang dari Master Item.
  //
  // Contoh:
  // 899999999999
  // ==========================================================

  final String barcode;

  // ==========================================================
  // PLU
  // ==========================================================
  //
  // Kode PLU barang.
  //
  // PLU digunakan operator untuk mencari barang.
  // ==========================================================

  final String plu;

  // ==========================================================
  // DESCRIPTION
  // ==========================================================
  //
  // Nama atau deskripsi barang.
  //
  // Contoh:
  // AQUA AIR MNRL PET 1500ML
  // ==========================================================

  final String description;

  // ==========================================================
  // PRICE
  // ==========================================================
  //
  // Harga barang dari Master Item.
  // ==========================================================

  final double price;

  // ==========================================================
  // RETUR HARI
  // ==========================================================
  //
  // Jumlah hari yang digunakan sebagai acuan retur barang.
  // ==========================================================

  final int returHari;

  // ==========================================================
  // CONV2
  // ==========================================================
  //
  // Konversi jumlah CTN menjadi PCS.
  //
  // Contoh:
  //
  // CONV2 = 12
  //
  // berarti:
  //
  // 1 CTN = 12 PCS
  //
  // Jika:
  //
  // Qty CTN = 10
  //
  // maka:
  //
  // Qty PCS = 10 × 12 = 120 PCS
  // ==========================================================

  final int conv2;

  // ==========================================================
  // TYPE
  // ==========================================================
  //
  // Jenis atau tipe barang.
  //
  // Contoh:
  // FOOD
  // NON FOOD
  // BEVERAGE
  // ==========================================================

  final String type;

  // ==========================================================
  // MASTER TEAR
  // ==========================================================
  //
  // Nilai Tear standar dari Master Item.
  //
  // PENTING:
  // Nilai ini hanya sebagai REFERENSI / PEMBANDING.
  //
  // Tear aktual yang dimasukkan operator disimpan
  // pada StockPallet.
  // ==========================================================

  final int masterTear;

  // ==========================================================
  // MASTER STACK
  // ==========================================================
  //
  // Nilai Stack standar dari Master Item.
  //
  // PENTING:
  // Nilai ini hanya sebagai REFERENSI / PEMBANDING.
  //
  // Stack aktual operator disimpan pada StockPallet.
  // ==========================================================

  final int masterStack;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================
  //
  // Constructor digunakan untuk membuat ProductModel.
  //
  // Semua field dibuat required karena seluruh informasi
  // Master Item dibutuhkan oleh aplikasi.
  // ==========================================================

  const ProductModel({
    this.id,
    required this.barcode,
    required this.plu,
    required this.description,
    required this.price,
    required this.returHari,
    required this.conv2,
    required this.type,
    required this.masterTear,
    required this.masterStack,
  });

  // ==========================================================
  // FROM MAP
  // ==========================================================
  //
  // Mengubah Map menjadi ProductModel.
  //
  // Fungsi ini berguna ketika data berasal dari:
  //
  // - Excel
  // - JSON
  // - Database
  // - Local Storage
  //
  // Contoh:
  //
  // {
  //   'barcode': '899999999999',
  //   'plu': '5867',
  //   'description': 'AQUA AIR MNRL PET 1500ML',
  //   'price': 25000,
  //   'returHari': 30,
  //   'conv2': 12,
  //   'type': 'FOOD',
  //   'masterTear': 8,
  //   'masterStack': 4,
  // }
  // ==========================================================

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      // Membaca ID database jika tersedia.
      id: _toNullableInt(map['id']),

      // Membaca barcode.
      barcode: map['barcode']?.toString().trim() ?? '',

      // Membaca PLU.
      plu: map['plu']?.toString().trim() ?? '',

      // Membaca nama/deskripsi barang.
      description: map['description']?.toString().trim() ?? '',

      // Membaca harga dan memastikan menjadi double.
      price: _toDouble(map['price']),

      // Membaca jumlah hari retur.
      returHari: _toInt(map['returHari']),

      // Membaca nilai konversi CTN → PCS.
      conv2: _toInt(map['conv2']),

      // Membaca tipe barang.
      type: map['type']?.toString().trim() ?? '',

      // Membaca Tear standar dari Master.
      masterTear: _toInt(map['masterTear']),

      // Membaca Stack standar dari Master.
      masterStack: _toInt(map['masterStack']),
    );
  }

  // ==========================================================
  // FROM ENTITY
  // ==========================================================
  //
  // Mengubah Product Entity menjadi ProductModel.
  //
  // Alur:
  //
  // Product Entity
  //       ↓
  // ProductModel
  //
  // Digunakan ketika data dari Domain perlu diproses
  // kembali oleh Data layer.
  // ==========================================================

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      // Mengambil ID database dari Entity.
      id: product.id,

      // Mengambil barcode dari Entity.
      barcode: product.barcode,

      // Mengambil PLU dari Entity.
      plu: product.plu,

      // Mengambil deskripsi dari Entity.
      description: product.description,

      // Mengambil harga dari Entity.
      price: product.price,

      // Mengambil hari retur dari Entity.
      returHari: product.returHari,

      // Mengambil CONV2 dari Entity.
      conv2: product.conv2,

      // Mengambil tipe barang dari Entity.
      type: product.type,

      // Mengambil Master Tear.
      masterTear: product.masterTear,

      // Mengambil Master Stack.
      masterStack: product.masterStack,
    );
  }

  // ==========================================================
  // TO ENTITY
  // ==========================================================
  //
  // Mengubah ProductModel menjadi Product Entity.
  //
  // Alur:
  //
  // ProductModel
  //       ↓
  // Product Entity
  //       ↓
  // Domain
  //
  // Ini penting karena Domain layer sebaiknya bekerja
  // menggunakan Entity, bukan Model.
  // ==========================================================

  Product toEntity() {
    return Product(
      // Mengirim ID database ke Entity.
      id: id,

      // Mengirim barcode ke Entity.
      barcode: barcode,

      // Mengirim PLU ke Entity.
      plu: plu,

      // Mengirim deskripsi ke Entity.
      description: description,

      // Mengirim harga ke Entity.
      price: price,

      // Mengirim hari retur ke Entity.
      returHari: returHari,

      // Mengirim CONV2 ke Entity.
      conv2: conv2,

      // Mengirim tipe barang ke Entity.
      type: type,

      // Mengirim Master Tear.
      masterTear: masterTear,

      // Mengirim Master Stack.
      masterStack: masterStack,
    );
  }

  // ==========================================================
  // TO MAP
  // ==========================================================
  //
  // Mengubah ProductModel menjadi Map.
  //
  // Digunakan untuk:
  //
  // - Database
  // - JSON
  // - Local Storage
  // - Export
  // ==========================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'plu': plu,
      'description': description,
      'price': price,
      'returHari': returHari,
      'conv2': conv2,
      'type': type,
      'masterTear': masterTear,
      'masterStack': masterStack,
    };
  }

  // ==========================================================
  // HELPER: _toNullableInt
  // ==========================================================
  //
  // Mengubah nilai menjadi int nullable.
  //
  // null / kosong / invalid → null.
  // ==========================================================

  static int? _toNullableInt(dynamic value) {
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

    final intValue = int.tryParse(text);

    if (intValue != null) {
      return intValue;
    }

    final doubleValue = double.tryParse(text);

    return doubleValue?.toInt();
  }

  // ==========================================================
  // HELPER: _toInt
  // ==========================================================
  //
  // Mengubah berbagai tipe data menjadi int.
  //
  // Mendukung:
  //
  // int
  // double
  // String
  // null
  //
  // Contoh:
  //
  // 12       → 12
  // 12.0     → 12
  // "12"     → 12
  // "12.0"   → 12
  // null     → 0
  // ==========================================================

  static int _toInt(dynamic value) {
    // Nilai null dianggap 0.
    if (value == null) {
      return 0;
    }

    // Jika sudah int, langsung gunakan.
    if (value is int) {
      return value;
    }

    // Jika double, ambil nilai integer.
    if (value is double) {
      return value.toInt();
    }

    // Mengubah nilai menjadi String.
    final text = value.toString().trim();

    // String kosong dianggap 0.
    if (text.isEmpty) {
      return 0;
    }

    // Coba parsing sebagai int.
    final intValue = int.tryParse(text);

    if (intValue != null) {
      return intValue;
    }

    // Jika gagal, coba parsing sebagai double.
    final doubleValue = double.tryParse(text);

    if (doubleValue != null) {
      return doubleValue.toInt();
    }

    // Jika seluruh parsing gagal,
    // gunakan nilai default 0.
    return 0;
  }

  // ==========================================================
  // HELPER: _toDouble
  // ==========================================================
  //
  // Mengubah berbagai tipe data menjadi double.
  //
  // Contoh:
  //
  // 25000       → 25000.0
  // 25000.50    → 25000.5
  // "25000.50"  → 25000.5
  // null        → 0
  // ==========================================================

  static double _toDouble(dynamic value) {
    // Nilai null dianggap 0.
    if (value == null) {
      return 0;
    }

    // Jika sudah double.
    if (value is double) {
      return value;
    }

    // Jika int, ubah menjadi double.
    if (value is int) {
      return value.toDouble();
    }

    // Mengubah nilai menjadi String.
    final text = value.toString().trim();

    // String kosong dianggap 0.
    if (text.isEmpty) {
      return 0;
    }

    // Coba parsing menjadi double.
    return double.tryParse(text) ?? 0;
  }
}

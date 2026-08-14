// File:
// lib/domain/entities/product.dart

// Entity Product mewakili satu data barang dari Master Barang.
class Product {
  // Barcode barang.
  final String barcode;

  // PLU barang yang digunakan operator untuk mencari barang.
  final String plu;

  // Nama/deskripsi barang.
  final String description;

  // Harga barang dari master jika memang dibutuhkan.
  final double price;

  // Jumlah hari sebelum barang masuk batas retur.
  final int returHari;

  // Konversi CTN ke PCS.
  // Contoh: Conv2 = 12 berarti 1 CTN = 12 PCS.
  final int conv2;

  // Jenis/type barang.
  final String type;

  // Tear standar yang tersimpan di Master.
  // Ini hanya sebagai pembanding, bukan nilai yang memaksa input operator.
  final int masterTear;

  // Stack standar yang tersimpan di Master.
  // Ini juga hanya sebagai pembanding.
  final int masterStack;

  // Constructor untuk membuat object Product.
  const Product({
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
}

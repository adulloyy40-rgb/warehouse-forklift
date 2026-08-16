// ============================================================
// FILE:
// lib/data/repositories/product_repository_impl.dart
// ============================================================
//
// FUNGSI:
// Implementasi ProductRepository.
//
// Repository menjadi penghubung antara:
//
// UI / UseCase
//      ↓
// ProductRepositoryImpl
//      ↓
// ExcelDataSource
//      ↓
// File Excel
//
// PENTING:
// Repository TIDAK menentukan lokasi file Excel secara langsung.
//
// Path Excel diberikan melalui constructor.
// Dengan demikian kode tidak bergantung pada:
//
// test/fixtures/master_barang.xlsx
//
// Ini penting agar nanti aplikasi Android dapat menggunakan
// file import yang dipilih operator.
// ============================================================

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/excel_data_source.dart';

// ============================================================
// CLASS: ProductRepositoryImpl
// ============================================================
//
// Implementasi nyata dari ProductRepository.
// ============================================================

class ProductRepositoryImpl implements ProductRepository {
  // ==========================================================
  // PROPERTY: _dataSource
  // ==========================================================
  //
  // Datasource yang bertugas membaca file Excel.
  // ==========================================================

  final ExcelDataSource _dataSource;

  // ==========================================================
  // PROPERTY: excelFilePath
  // ==========================================================
  //
  // Menyimpan lokasi file Excel Master Barang.
  //
  // Contoh untuk TEST:
  //
  // test/fixtures/master_barang.xlsx
  //
  // Contoh nanti di Android:
  //
  // /storage/emulated/0/Download/master_barang.xlsx
  // ==========================================================

  final String excelFilePath;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================
  //
  // DataSource dan lokasi Excel diberikan dari luar.
  //
  // Keuntungan:
  // Repository tidak tergantung pada lokasi file tertentu.
  // ==========================================================

  ProductRepositoryImpl({
    required this.excelFilePath,
    ExcelDataSource? dataSource,
  }) : _dataSource = dataSource ?? ExcelDataSource();

  // ==========================================================
  // getAllProducts()
  // ==========================================================
  //
  // Fungsi:
  // Mengambil seluruh Master Barang dari Excel.
  //
  // Data mentah dari ExcelDataSource kemudian diubah menjadi
  // Product Entity.
  // ==========================================================

  @override
  Future<List<Product>> getAllProducts() async {
    // --------------------------------------------------------
    // Membaca seluruh data dari Excel.
    // --------------------------------------------------------

    final rows = await _dataSource.readMasterProduct(excelFilePath);

    // --------------------------------------------------------
    // Mengubah setiap Map menjadi Product Entity.
    // --------------------------------------------------------

    return rows.map(_mapToProduct).toList();
  }

  // ==========================================================
  // getProductByPlu()
  // ==========================================================
  //
  // Fungsi:
  // Mencari satu barang berdasarkan PLU.
  //
  // Contoh:
  //
  // PLU 5867
  //      ↓
  // AQUA AIR MNRL PET 1500ML
  // ==========================================================

  @override
  Future<Product?> getProductByPlu(String plu) async {
    // --------------------------------------------------------
    // Membersihkan input PLU.
    // --------------------------------------------------------

    final normalizedPlu = plu.trim();

    // --------------------------------------------------------
    // Jika PLU kosong, langsung return null.
    // --------------------------------------------------------

    if (normalizedPlu.isEmpty) {
      return null;
    }

    // --------------------------------------------------------
    // Mengambil seluruh produk.
    // --------------------------------------------------------

    final products = await getAllProducts();

    // --------------------------------------------------------
    // Mencari PLU yang sama.
    // --------------------------------------------------------

    for (final product in products) {
      if (product.plu.trim() == normalizedPlu) {
        return product;
      }
    }

    // --------------------------------------------------------
    // PLU tidak ditemukan.
    // --------------------------------------------------------

    return null;
  }

  // ==========================================================
  // searchProducts()
  // ==========================================================
  //
  // Fungsi:
  // Search berdasarkan:
  //
  // 1. PLU
  // 2. Barcode
  // 3. Description
  //
  // Fitur ini nantinya digunakan pada Search Item.
  // ==========================================================

  @override
  Future<List<Product>> searchProducts(String query) async {
    // --------------------------------------------------------
    // Membersihkan query dan mengubahnya menjadi lowercase.
    // --------------------------------------------------------

    final normalizedQuery = query.trim().toLowerCase();

    // --------------------------------------------------------
    // Jika query kosong, tampilkan semua produk.
    // --------------------------------------------------------

    if (normalizedQuery.isEmpty) {
      return getAllProducts();
    }

    // --------------------------------------------------------
    // Mengambil seluruh produk.
    // --------------------------------------------------------

    final products = await getAllProducts();

    // --------------------------------------------------------
    // Melakukan pencarian.
    // --------------------------------------------------------

    return products.where((product) {
      // ------------------------------------------------------
      // Cek PLU.
      // ------------------------------------------------------

      final pluMatch = product.plu.toLowerCase().contains(normalizedQuery);

      // ------------------------------------------------------
      // Cek Barcode.
      // ------------------------------------------------------

      final barcodeMatch = product.barcode.toLowerCase().contains(
        normalizedQuery,
      );

      // ------------------------------------------------------
      // Cek Description.
      // ------------------------------------------------------

      final descriptionMatch = product.description.toLowerCase().contains(
        normalizedQuery,
      );

      // ------------------------------------------------------
      // Jika salah satu cocok,
      // masukkan ke hasil pencarian.
      // ------------------------------------------------------

      return pluMatch || barcodeMatch || descriptionMatch;
    }).toList();
  }

  // ==========================================================
  // _mapToProduct()
  // ==========================================================
  //
  // Fungsi:
  // Mengubah Map hasil ExcelDataSource menjadi Product.
  //
  // Mapping:
  //
  // barcode     → barcode
  // plu         → plu
  // description → description
  // price       → price
  // returHari   → returHari
  // conv2       → conv2
  // type        → type
  // masterTear  → masterTear
  // masterStack → masterStack
  // ==========================================================

  Product _mapToProduct(Map<String, dynamic> row) {
    return Product(
      // Barcode barang.
      barcode: row['barcode']?.toString() ?? '',

      // PLU barang.
      plu: row['plu']?.toString() ?? '',

      // Deskripsi barang.
      description: row['description']?.toString() ?? '',

      // Harga barang.
      price: _toDouble(row['price']),

      // Hari retur barang.
      returHari: _toInt(row['returHari']),

      // C2 Excel → conv2 aplikasi.
      conv2: _toInt(row['conv2']),

      // Type barang.
      type: row['type']?.toString() ?? '',

      // TEAR Excel → masterTear aplikasi.
      masterTear: _toInt(row['masterTear']),

      // STACK Excel → masterStack aplikasi.
      masterStack: _toInt(row['masterStack']),
    );
  }

  // ==========================================================
  // _toInt()
  // ==========================================================
  //
  // Fungsi:
  // Mengubah nilai menjadi integer secara aman.
  // ==========================================================

  int _toInt(dynamic value) {
    // Nilai kosong dianggap 0.
    if (value == null) {
      return 0;
    }

    // Jika sudah integer.
    if (value is int) {
      return value;
    }

    // Jika double, ambil bagian integer.
    if (value is double) {
      return value.toInt();
    }

    // Mengubah nilai menjadi String.
    final text = value.toString().trim();

    // String kosong dianggap 0.
    if (text.isEmpty) {
      return 0;
    }

    // Mencoba parsing integer.
    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  // ==========================================================
  // _toDouble()
  // ==========================================================
  //
  // Fungsi:
  // Mengubah nilai menjadi double secara aman.
  // ==========================================================

  double _toDouble(dynamic value) {
    // Nilai kosong dianggap 0.
    if (value == null) {
      return 0;
    }

    // Jika sudah double.
    if (value is double) {
      return value;
    }

    // Jika integer, ubah ke double.
    if (value is int) {
      return value.toDouble();
    }

    // Mengubah nilai menjadi String.
    final text = value.toString().trim();

    // String kosong dianggap 0.
    if (text.isEmpty) {
      return 0;
    }

    // Mencoba parsing double.
    return double.tryParse(text) ?? 0;
  }
}

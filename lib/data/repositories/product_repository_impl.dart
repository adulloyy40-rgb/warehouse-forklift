// ============================================================
// FILE:
// lib/data/repositories/product_repository_impl.dart
// ============================================================
//
// FUNGSI:
// Implementasi ProductRepository.
//
// Optimasi:
// Master Barang hanya dibaca dari Excel satu kali selama
// instance repository masih hidup.
//
// Ini penting untuk proses import Stock Pallet dalam jumlah
// besar agar getProductByPlu() tidak membaca Excel berulang.
// ============================================================

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/excel_data_source.dart';

// ============================================================
// CLASS: ProductRepositoryImpl
// ============================================================

class ProductRepositoryImpl implements ProductRepository {
  // ==========================================================
  // DATASOURCE
  // ==========================================================

  final ExcelDataSource _dataSource;

  // ==========================================================
  // EXCEL FILE PATH
  // ==========================================================

  final String excelFilePath;

  // ==========================================================
  // CACHE MASTER BARANG
  // ==========================================================
  //
  // null:
  // Master Barang belum pernah dibaca.
  //
  // tidak null:
  // Master Barang sudah tersedia di memory.
  //
  // Dengan demikian Excel tidak dibaca berulang kali.
  // ==========================================================

  List<Product>? _productsCache;

  // ==========================================================
  // CONSTRUCTOR
  // ==========================================================

  ProductRepositoryImpl({
    required this.excelFilePath,
    ExcelDataSource? dataSource,
  }) : _dataSource = dataSource ?? ExcelDataSource();

  // ==========================================================
  // GET ALL PRODUCTS
  // ==========================================================

  @override
  Future<List<Product>> getAllProducts() async {
    // --------------------------------------------------------
    // Jika cache sudah tersedia, gunakan cache.
    // --------------------------------------------------------

    final cachedProducts = _productsCache;

    if (cachedProducts != null) {
      return cachedProducts;
    }

    // --------------------------------------------------------
    // Cache belum tersedia.
    // Baca Master Barang satu kali.
    // --------------------------------------------------------

    final rows = await _dataSource.readMasterProduct(excelFilePath);

    // --------------------------------------------------------
    // Mapping Excel → Product.
    // --------------------------------------------------------

    final products = rows.map(_mapToProduct).toList();

    // --------------------------------------------------------
    // Simpan ke cache.
    // --------------------------------------------------------

    _productsCache = List.unmodifiable(products);

    return _productsCache!;
  }

  // ==========================================================
  // GET PRODUCT BY PLU
  // ==========================================================

  @override
  Future<Product?> getProductByPlu(String plu) async {
    // --------------------------------------------------------
    // Normalisasi PLU.
    // --------------------------------------------------------

    final normalizedPlu = plu.trim();

    if (normalizedPlu.isEmpty) {
      return null;
    }

    // --------------------------------------------------------
    // getAllProducts() sekarang menggunakan cache.
    // --------------------------------------------------------

    final products = await getAllProducts();

    // --------------------------------------------------------
    // Cari PLU.
    // --------------------------------------------------------

    for (final product in products) {
      if (product.plu.trim() == normalizedPlu) {
        return product;
      }
    }

    return null;
  }

  // ==========================================================
  // SEARCH PRODUCTS
  // ==========================================================

  @override
  Future<List<Product>> searchProducts(String query) async {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return getAllProducts();
    }

    // --------------------------------------------------------
    // getAllProducts() menggunakan cache.
    // --------------------------------------------------------

    final products = await getAllProducts();

    return products.where((product) {
      final pluMatch = product.plu.toLowerCase().contains(normalizedQuery);

      final barcodeMatch = product.barcode.toLowerCase().contains(
        normalizedQuery,
      );

      final descriptionMatch = product.description.toLowerCase().contains(
        normalizedQuery,
      );

      return pluMatch || barcodeMatch || descriptionMatch;
    }).toList();
  }

  // ==========================================================
  // MAP TO PRODUCT
  // ==========================================================

  Product _mapToProduct(Map<String, dynamic> row) {
    return Product(
      barcode: row['barcode']?.toString() ?? '',
      plu: row['plu']?.toString() ?? '',
      description: row['description']?.toString() ?? '',
      price: _toDouble(row['price']),
      returHari: _toInt(row['returHari']),
      conv2: _toInt(row['conv2']),
      type: row['type']?.toString() ?? '',
      masterTear: _toInt(row['masterTear']),
      masterStack: _toInt(row['masterStack']),
    );
  }

  // ==========================================================
  // TO INT
  // ==========================================================

  int _toInt(dynamic value) {
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

    return int.tryParse(text) ?? double.tryParse(text)?.toInt() ?? 0;
  }

  // ==========================================================
  // TO DOUBLE
  // ==========================================================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return 0;
    }

    return double.tryParse(text) ?? 0;
  }
}

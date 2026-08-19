// ============================================================
// FILE:
// lib/domain/validators/stock_pallet_import_validator.dart
// ============================================================
//
// FUNGSI:
// Memvalidasi data Stock Pallet hasil parsing Excel.
//
// Validator ini TIDAK:
// - membaca file Excel
// - mengakses database
// - mengakses DAO
// - mengubah data
//
// Input:
// Map<String, dynamic>
//
// Output:
// true  = data valid
// false = data tidak valid
// ============================================================

class StockPalletImportValidator {
  const StockPalletImportValidator();

  // ==========================================================
  // validate()
  //
  // Validasi satu baris hasil parser Excel.
  // ==========================================================

  bool validate(Map<String, dynamic> data) {
    // --------------------------------------------------------
    // 1. LOKASI
    // --------------------------------------------------------

    final lokasi = _toStringValue(data['lokasi']);

    if (lokasi == null || lokasi.isEmpty) {
      return false;
    }

    // --------------------------------------------------------
    // 2. PLU
    // --------------------------------------------------------

    final plu = _toStringValue(data['plu']);

    if (plu == null || plu.isEmpty) {
      return false;
    }

    // --------------------------------------------------------
    // 3. CONV2
    // --------------------------------------------------------

    final conv2 = _toInt(data['conv2']);

    if (conv2 == null || conv2 <= 0) {
      return false;
    }

    // --------------------------------------------------------
    // 4. QTY SO
    // --------------------------------------------------------

    final qtySo = _toInt(data['qty_so']);

    if (qtySo == null || qtySo < 0) {
      return false;
    }

    // --------------------------------------------------------
    // 5. STACK
    // --------------------------------------------------------

    final stack = _toInt(data['stack']);

    if (stack == null || stack <= 0) {
      return false;
    }

    // --------------------------------------------------------
    // 6. TEAR AKTUAL
    // --------------------------------------------------------

    final tearAktual = _toInt(data['tear_aktual']);

    if (tearAktual == null || tearAktual <= 0) {
      return false;
    }

    // --------------------------------------------------------
    // 7. EXP DATE
    // --------------------------------------------------------

    if (!_isValidDate(data['exp_date'])) {
      return false;
    }

    // --------------------------------------------------------
    // Semua aturan dasar terpenuhi.
    // --------------------------------------------------------

    return true;
  }

  // ==========================================================
  // _toStringValue()
  // ==========================================================

  String? _toStringValue(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  // ==========================================================
  // _toInt()
  //
  // Mendukung:
  // 10
  // "10"
  // 10.0
  // "10.0"
  // ==========================================================

  int? _toInt(dynamic value) {
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

    final integerValue = int.tryParse(text);

    if (integerValue != null) {
      return integerValue;
    }

    final doubleValue = double.tryParse(text);

    if (doubleValue != null) {
      return doubleValue.toInt();
    }

    return null;
  }

  // ==========================================================
  // _isValidDate()
  //
  // Mendukung:
  // DateTime
  // String tanggal yang dapat diparse DateTime.parse()
  // ==========================================================

  bool _isValidDate(dynamic value) {
    if (value == null) {
      return false;
    }

    if (value is DateTime) {
      return true;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return false;
    }

    return DateTime.tryParse(text) != null;
  }
}

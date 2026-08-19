import '../database/app_database.dart' as db;
import '../../core/utils/location_code_generator.dart';
import '../../data/database/daos/storage_location_dao.dart';
import '../../domain/entities/storage_location.dart' as domain;
import '../../domain/repositories/storage_location_repository.dart';

/// ============================================================
/// StorageLocationRepositoryImpl
/// ============================================================
///
/// Repository Master Storage Location.
///
/// SOURCE OF TRUTH:
///     SQLite / Drift
///
/// LocationCodeGenerator hanya digunakan ketika melakukan
/// inisialisasi master location pertama kali.
///
/// Setelah data masuk database:
///
/// Repository
///     ↓
/// DAO
///     ↓
/// Drift
///     ↓
/// SQLite
///
/// Repository tidak lagi membuat 1.860 location setiap query.
/// ============================================================

class StorageLocationRepositoryImpl
    implements StorageLocationRepository {
  final StorageLocationDao dao;

  StorageLocationRepositoryImpl([
    StorageLocationDao? dao,
  ]) : dao = dao ?? _createDao();

  static StorageLocationDao _createDao() {
    throw StateError(
      'StorageLocationRepositoryImpl membutuhkan StorageLocationDao. '
      'Gunakan StorageLocationRepositoryImpl(database.storageLocationDao) '
      'pada dependency injection.',
    );
  }

  /// ==========================================================
  /// GET ALL LOCATIONS
  /// ==========================================================
  ///
  /// Mengambil seluruh lokasi dari database.
  /// ==========================================================

  @override
  Future<List<domain.StorageLocation>> getAllLocations() async {
    final rows = await dao.getAllLocations();

    return rows
        .map((row) => domain.StorageLocation(
              rack: _parseRack(row.locationCode),
              bay: _parseBay(row.locationCode),
              shelving: _parseShelving(row.locationCode),
              position: _parsePosition(row.locationCode),
              code: row.locationCode,
            ))
        .toList();
  }

  /// ==========================================================
  /// GET LOCATION BY CODE
  /// ==========================================================

  @override
  Future<domain.StorageLocation?> getLocationByCode(String code) async {
    final normalizedCode = code.trim();

    if (normalizedCode.isEmpty) {
      return null;
    }

    final row = await dao.findByCode(normalizedCode);

    if (row == null) {
      return null;
    }

    return domain.StorageLocation(
      rack: _parseRack(row.locationCode),
      bay: _parseBay(row.locationCode),
      shelving: _parseShelving(row.locationCode),
      position: _parsePosition(row.locationCode),
      code: row.locationCode,
    );
  }

  /// ==========================================================
  /// FIND BY CODE
  /// ==========================================================
  ///
  /// Dipertahankan untuk kompatibilitas dengan kode lama/test.
  /// ==========================================================

  Future<domain.StorageLocation?> findByCode(String code) {
    return getLocationByCode(code);
  }

  /// ==========================================================
  /// TOTAL LOCATION
  /// ==========================================================

  @override
  Future<int> getTotalLocation() {
    return dao.getTotalLocation();
  }

  /// ==========================================================
  /// AVAILABLE LOCATION
  /// ==========================================================

  @override
  Future<int> getAvailableLocation() {
    return dao.getAvailableLocation();
  }

  /// ==========================================================
  /// OCCUPIED LOCATION
  /// ==========================================================

  Future<int> getOccupiedLocation() {
    return dao.getOccupiedLocation();
  }

  /// ==========================================================
  /// BLOCKED LOCATION
  /// ==========================================================

  Future<int> getBlockedLocation() {
    return dao.getBlockedLocation();
  }

  /// ==========================================================
  /// INITIALIZE MASTER LOCATIONS
  /// ==========================================================
  ///
  /// Membuat master location berdasarkan konfigurasi
  /// LocationCodeGenerator dan menyimpannya ke database.
  ///
  /// Method ini hanya memasukkan location yang belum ada.
  ///
  /// Aman dipanggil berulang kali karena DAO menggunakan
  /// InsertMode.insertOrIgnore.
  /// ==========================================================

  Future<void> initializeMasterLocations() async {
    final existingTotal = await dao.getTotalLocation();

    if (existingTotal > 0) {
      return;
    }

    final locations = <db.StorageLocationsCompanion>[];

    for (int rack = 80; rack <= 96; rack++) {
      final codes =
          LocationCodeGenerator.generateRackLocations(rack);

      for (final code in codes) {
        locations.add(
          db.StorageLocationsCompanion.insert(
            locationCode: code,
          ),
        );
      }
    }

    await dao.insertLocations(locations);
  }

  /// ==========================================================
  /// IS AVAILABLE
  /// ==========================================================
  ///
  /// Mengecek apakah lokasi:
  ///
  /// 1. Terdaftar di master location.
  /// 2. Statusnya AVAILABLE.
  ///
  /// Return:
  ///
  /// true  -> lokasi dapat digunakan.
  /// false -> lokasi tidak ditemukan / OCCUPIED / BLOCKED.
  /// ==========================================================

  @override
  Future<bool> isAvailable(String code) async {
    final normalizedCode = code.trim();

    if (normalizedCode.isEmpty) {
      return false;
    }

    final location = await dao.findByCode(normalizedCode);

    if (location == null) {
      return false;
    }

    return location.status.trim().toUpperCase() == 'AVAILABLE';
  }

  /// ==========================================================
  /// UPDATE STATUS
  /// ==========================================================
  ///
  /// Digunakan ketika:
  ///
  /// AVAILABLE → OCCUPIED
  /// OCCUPIED  → AVAILABLE
  /// AVAILABLE → BLOCKED
  /// BLOCKED    → AVAILABLE
  /// ==========================================================

  @override
  Future<bool> updateStatus(
    String locationCode,
    String status,
  ) async {
    final normalizedCode = locationCode.trim();
    final normalizedStatus = status.trim().toUpperCase();

    const validStatuses = {
      'AVAILABLE',
      'OCCUPIED',
      'BLOCKED',
    };

    if (normalizedCode.isEmpty) {
      throw ArgumentError('Location Code tidak boleh kosong.');
    }

    if (!validStatuses.contains(normalizedStatus)) {
      throw ArgumentError(
        'Status lokasi tidak valid: $status. '
        'Gunakan AVAILABLE, OCCUPIED, atau BLOCKED.',
      );
    }

    final location = await dao.findByCode(normalizedCode);

    if (location == null) {
      return false;
    }

    return dao.updateStatus(
      normalizedCode,
      normalizedStatus,
    );
  }

  /// ==========================================================
  /// PARSER LOCATION CODE
  /// ==========================================================

  int _parseRack(String code) {
    _validateCode(code);
    return int.parse(code.substring(0, 2));
  }

  int _parseBay(String code) {
    _validateCode(code);
    return int.parse(code.substring(2, 4));
  }

  int _parseShelving(String code) {
    _validateCode(code);
    return int.parse(code.substring(4, 5));
  }

  int _parsePosition(String code) {
    _validateCode(code);
    return int.parse(code.substring(5, 7));
  }

  void _validateCode(String code) {
    final normalized = code.trim();

    if (normalized.length != 7 ||
        int.tryParse(normalized) == null) {
      throw FormatException(
        'Location Code tidak valid: "$code". '
        'Kode harus terdiri dari 7 digit.',
      );
    }
  }
}

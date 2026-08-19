import '../database/app_database.dart' as db;
import '../../domain/entities/storage_location.dart' as domain;
import '../../core/utils/location_code_generator.dart';

/// ============================================================
/// MODEL: StorageLocationModel
/// ============================================================
///
/// Menjadi jembatan antara:
///
/// Drift Database
///      ↓
/// StorageLocationModel
///      ↓
/// Domain StorageLocation
///
/// Database menyimpan locationCode sebagai identitas utama.
/// Struktur rack/bay/shelving/position diturunkan dari kode.
/// ============================================================

class StorageLocationModel {
  /// ID database.
  final int id;

  /// Kode lokasi.
  final String locationCode;

  /// Status database:
  /// AVAILABLE
  /// OCCUPIED
  /// BLOCKED
  final String status;

  /// Waktu lokasi dibuat.
  final DateTime createdAt;

  /// Waktu lokasi terakhir diperbarui.
  final DateTime updatedAt;

  const StorageLocationModel({
    required this.id,
    required this.locationCode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ==========================================================
  /// FROM DRIFT ROW
  /// ==========================================================
  ///
  /// Mengubah row hasil query Drift menjadi Model.
  /// ==========================================================

  factory StorageLocationModel.fromDatabase(
    db.StorageLocation row,
  ) {
    return StorageLocationModel(
      id: row.id,
      locationCode: row.locationCode,
      status: row.status,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// ==========================================================
  /// TO DOMAIN ENTITY
  /// ==========================================================
  ///
  /// Mengubah Model menjadi Domain Entity.
  ///
  /// Struktur lokasi diperoleh dari locationCode.
  /// ==========================================================

  domain.StorageLocation toEntity() {
    final code = locationCode.trim();

    if (code.length != 7) {
      throw FormatException(
        'Location Code tidak valid: "$locationCode". '
        'Kode lokasi harus terdiri dari 7 digit.',
      );
    }

    final rack = int.tryParse(code.substring(0, 2));
    final bay = int.tryParse(code.substring(2, 4));
    final shelving = int.tryParse(code.substring(4, 5));
    final position = int.tryParse(code.substring(5, 7));

    if (rack == null ||
        bay == null ||
        shelving == null ||
        position == null) {
      throw FormatException(
        'Location Code tidak dapat diparsing: "$locationCode".',
      );
    }

    final expectedCode = LocationCodeGenerator.generateCode(
      rack: rack,
      bay: bay,
      shelving: shelving,
      position: position,
    );

    if (expectedCode != code) {
      throw FormatException(
        'Location Code tidak konsisten: "$locationCode".',
      );
    }

    return domain.StorageLocation(
      rack: rack,
      bay: bay,
      shelving: shelving,
      position: position,
      code: code,
    );
  }

  /// ==========================================================
  /// FROM DOMAIN
  /// ==========================================================
  ///
  /// Membuat Model dari Domain Entity.
  ///
  /// Status dan timestamp diberikan oleh layer database/repository.
  /// ==========================================================

  factory StorageLocationModel.fromEntity(
    domain.StorageLocation entity, {
    required int id,
    String status = 'AVAILABLE',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now();

    return StorageLocationModel(
      id: id,
      locationCode: entity.code.trim(),
      status: status,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  @override
  String toString() {
    return 'StorageLocationModel('
        'id: $id, '
        'locationCode: $locationCode, '
        'status: $status, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}

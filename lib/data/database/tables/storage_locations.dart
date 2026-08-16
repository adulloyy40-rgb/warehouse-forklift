import 'package:drift/drift.dart';

/// ============================================================
/// TABLE: storage_locations
/// ============================================================
///
/// Menyimpan master lokasi rak storage.
///
/// Contoh:
///
/// A01-01-01
/// A01-01-02
/// A01-01-03
///
/// Setiap lokasi memiliki status:
/// - AVAILABLE  → bisa digunakan
/// - OCCUPIED   → sudah ditempati pallet
/// - BLOCKED    → tidak boleh digunakan
/// ============================================================

class StorageLocations extends Table {
  /// ----------------------------------------------------------
  /// ID database
  /// ----------------------------------------------------------
  ///
  /// Primary key otomatis.
  /// ----------------------------------------------------------
  IntColumn get id => integer().autoIncrement()();

  /// ----------------------------------------------------------
  /// LOCATION CODE
  /// ----------------------------------------------------------
  ///
  /// Contoh:
  /// A01-01-01
  ///
  /// Dibuat unique agar satu kode lokasi tidak boleh
  /// muncul dua kali di database.
  /// ----------------------------------------------------------
  TextColumn get locationCode =>
      text().unique()();

  /// ----------------------------------------------------------
  /// STATUS LOKASI
  /// ----------------------------------------------------------
  ///
  /// Nilai awal:
  /// AVAILABLE
  ///
  /// Status akan berubah ketika pallet masuk/keluar.
  /// ----------------------------------------------------------
  TextColumn get status =>
      text().withDefault(const Constant('AVAILABLE'))();

  /// ----------------------------------------------------------
  /// CREATED AT
  /// ----------------------------------------------------------
  ///
  /// Waktu lokasi dibuat.
  /// ----------------------------------------------------------
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  /// ----------------------------------------------------------
  /// UPDATED AT
  /// ----------------------------------------------------------
  ///
  /// Waktu terakhir lokasi diperbarui.
  /// ----------------------------------------------------------
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

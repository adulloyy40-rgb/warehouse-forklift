import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/storage_locations.dart';

part 'storage_location_dao.g.dart';

@DriftAccessor(tables: [StorageLocations])
class StorageLocationDao extends DatabaseAccessor<AppDatabase>
    with _$StorageLocationDaoMixin {
  StorageLocationDao(super.db);

  Future<List<StorageLocation>> getAllLocations() {
    return select(storageLocations).get();
  }

  Future<StorageLocation?> findByCode(String locationCode) {
    final normalizedCode = locationCode.trim();

    return (select(storageLocations)
          ..where(
            (tbl) => tbl.locationCode.equals(normalizedCode),
          ))
        .getSingleOrNull();
  }

  Future<int> getTotalLocation() async {
    final count = countAll();

    final query = selectOnly(storageLocations)
      ..addColumns([count]);

    final result = await query.getSingle();

    return result.read(count) ?? 0;
  }

  Future<int> getAvailableLocation() async {
    final count = countAll();

    final query = selectOnly(storageLocations)
      ..addColumns([count])
      ..where(
        storageLocations.status.equals('AVAILABLE'),
      );

    final result = await query.getSingle();

    return result.read(count) ?? 0;
  }

  Future<int> getOccupiedLocation() async {
    final count = countAll();

    final query = selectOnly(storageLocations)
      ..addColumns([count])
      ..where(
        storageLocations.status.equals('OCCUPIED'),
      );

    final result = await query.getSingle();

    return result.read(count) ?? 0;
  }

  Future<int> getBlockedLocation() async {
    final count = countAll();

    final query = selectOnly(storageLocations)
      ..addColumns([count])
      ..where(
        storageLocations.status.equals('BLOCKED'),
      );

    final result = await query.getSingle();

    return result.read(count) ?? 0;
  }

  Future<int> insertLocation(
    StorageLocationsCompanion location,
  ) {
    return into(storageLocations).insert(location);
  }

  Future<void> insertLocations(
    List<StorageLocationsCompanion> locations,
  ) async {
    await batch((batch) {
      batch.insertAll(
        storageLocations,
        locations,
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  Future<bool> updateStatus(
    String locationCode,
    String status,
  ) async {
    final normalizedCode = locationCode.trim();

    final updated = await (update(storageLocations)
          ..where(
            (tbl) => tbl.locationCode.equals(normalizedCode),
          ))
        .write(
      StorageLocationsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return updated > 0;
  }
}

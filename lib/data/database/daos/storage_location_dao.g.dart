// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_location_dao.dart';

// ignore_for_file: type=lint
mixin _$StorageLocationDaoMixin on DatabaseAccessor<AppDatabase> {
  $StorageLocationsTable get storageLocations =>
      attachedDatabase.storageLocations;
  StorageLocationDaoManager get managers => StorageLocationDaoManager(this);
}

class StorageLocationDaoManager {
  final _$StorageLocationDaoMixin _db;
  StorageLocationDaoManager(this._db);
  $$StorageLocationsTableTableManager get storageLocations =>
      $$StorageLocationsTableTableManager(
        _db.attachedDatabase,
        _db.storageLocations,
      );
}

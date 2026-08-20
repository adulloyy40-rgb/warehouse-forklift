// ============================================================
// FILE:
// lib/domain/usecases/storage_location/get_all_storage_locations.dart
//
// FUNGSI:
// Mengambil seluruh Master Storage Location.
//
// ALUR:
//
// Presentation
//     ↓
// GetAllStorageLocations
//     ↓
// StorageLocationRepository
//     ↓
// Data Layer
// ============================================================

import '../../entities/storage_location.dart';
import '../../repositories/storage_location_repository.dart';

class GetAllStorageLocations {
  final StorageLocationRepository repository;

  const GetAllStorageLocations({required this.repository});

  Future<List<StorageLocation>> call() async {
    return repository.getAllLocations();
  }
}

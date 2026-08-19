import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:warehouse_forklift/data/database/app_database.dart';
import 'package:warehouse_forklift/data/repositories/storage_location_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'initializeMasterLocations membuat tepat 1860 lokasi',
    () async {
      final database = AppDatabase(
        executor: NativeDatabase.memory(),
      );

      final repository = StorageLocationRepositoryImpl(
        database.storageLocationDao,
      );

      final before = await repository.getTotalLocation();

      expect(
        before,
        0,
        reason: 'Database test harus dimulai tanpa Storage Location.',
      );

      await repository.initializeMasterLocations();

      final after = await repository.getTotalLocation();

      expect(
        after,
        1860,
        reason: 'Master Storage Location harus berjumlah 1860.',
      );

      final locations = await repository.getAllLocations();

      expect(
        locations.length,
        1860,
        reason: 'Repository harus membaca kembali 1860 lokasi.',
      );

      await database.close();
    },
  );
}

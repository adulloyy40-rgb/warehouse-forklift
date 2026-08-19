import 'package:flutter/material.dart';

import 'core/di/app_dependencies.dart';
import 'presentation/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dependencies = AppDependencies.instance;

  await dependencies.storageLocationRepository
      .initializeMasterLocations();

  runApp(const WarehouseForkliftApp());
}

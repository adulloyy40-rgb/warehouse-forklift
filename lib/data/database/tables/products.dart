import 'package:drift/drift.dart';

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get barcode => text().unique()();

  TextColumn get plu => text().unique()();

  TextColumn get description => text()();

  RealColumn get price => real().withDefault(const Constant(0))();

  IntColumn get returHari => integer().withDefault(const Constant(0))();

  IntColumn get conv2 => integer().withDefault(const Constant(0))();

  TextColumn get type => text().withDefault(const Constant(''))();

  IntColumn get masterTear => integer().withDefault(const Constant(0))();

  IntColumn get masterStack => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

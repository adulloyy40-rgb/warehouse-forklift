// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_pallet_dao.dart';

// ignore_for_file: type=lint
mixin _$StockPalletDaoMixin on DatabaseAccessor<AppDatabase> {
  $StockPalletsTable get stockPallets => attachedDatabase.stockPallets;
  StockPalletDaoManager get managers => StockPalletDaoManager(this);
}

class StockPalletDaoManager {
  final _$StockPalletDaoMixin _db;
  StockPalletDaoManager(this._db);
  $$StockPalletsTableTableManager get stockPallets =>
      $$StockPalletsTableTableManager(_db.attachedDatabase, _db.stockPallets);
}

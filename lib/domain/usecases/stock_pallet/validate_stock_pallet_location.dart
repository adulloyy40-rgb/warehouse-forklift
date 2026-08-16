import '../../repositories/stock_pallet_repository.dart';

class ValidateStockPalletLocation {
  final StockPalletRepository repository;

  const ValidateStockPalletLocation({required this.repository});

  Future<bool> call(String locationCode) async {
    final normalizedCode = locationCode.trim();

    if (normalizedCode.isEmpty) {
      return false;
    }

    final existing = await repository.findByLocationCode(normalizedCode);

    return existing == null;
  }
}

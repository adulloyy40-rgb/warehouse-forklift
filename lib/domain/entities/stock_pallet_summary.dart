class StockPalletSummary {
  final String plu;
  final String barcode;
  final String description;
  final double price;
  final int totalPallet;
  final int totalQtyCtn;
  final int totalQtyPcs;
  final double totalValue;

  const StockPalletSummary({
    required this.plu,
    required this.barcode,
    required this.description,
    required this.price,
    required this.totalPallet,
    required this.totalQtyCtn,
    required this.totalQtyPcs,
    required this.totalValue,
  });
}

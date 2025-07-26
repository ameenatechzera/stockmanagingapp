class SavedProduct {
  final String barcode;
  final String name;
  final String unit;
  final String productCode;
  final String conversionRate;
  final String cost;
  final String quantity;

  SavedProduct({
    required this.barcode,
    required this.name,
    required this.unit,
    required this.productCode,
    required this.conversionRate,
    required this.cost,
    required this.quantity,
  });
  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'unit': unit,
      'product_code': productCode,
      'conversion_rate': conversionRate,
      'cost': cost,
      'quantity': quantity,
    };
  }
}

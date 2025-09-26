class SavedProduct {
  final String barcode;
  final String itemcode;
  final String unit;
  final String conversion;
  final String itemdescription;
  final String quantity;
  final String? deviceNumber;

  SavedProduct({
    required this.barcode,
    required this.itemcode,
    required this.unit,
    required this.conversion,
    required this.itemdescription,
    required this.quantity,
    this.deviceNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'itemcode': itemcode,
      'unit': unit,
      'conversion': conversion,
      'itemdescription': itemdescription,
      'quantity': quantity,
      'deviceNumber': deviceNumber,
    };
  }
}

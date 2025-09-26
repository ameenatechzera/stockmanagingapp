class StockInventoryItem {
  final String barcode;
  final String itemCode;
  final String unit;
  final String conversion;
  final String itemDescription;
  final String quantity;

  StockInventoryItem({
    required this.barcode,
    required this.itemCode,
    required this.unit,
    required this.conversion,
    required this.itemDescription,
    required this.quantity,
  });

  static StockInventoryItem fromExcelRow(
    List<dynamic> row,
    List<String> header,
  ) {
    Map<String, dynamic> stock = {};
    for (int i = 0; i < header.length; i++) {
      final key = header[i].toLowerCase().trim();
      final value = i < row.length ? row[i]?.toString().trim() : null;

      if (key == 'barcode' && value != null) {
        stock[key] = value.replaceAll('`', '');
      } else {
        stock[key] = value;
      }
    }

    if ((stock['barcode'] ?? '').isEmpty) {
      throw FormatException('Empty barcode in row: $row');
    }
    if ((stock['itemcode'] ?? '').isEmpty) {
      throw FormatException('Empty itemcode in row: $row');
    }
    if ((stock['unit'] ?? '').isEmpty) {
      throw FormatException('Empty uomid in row: $row');
    }
    if ((stock['quantity'] ?? '').isEmpty) {
      throw FormatException('Empty quantity in row: $row');
    }

    return StockInventoryItem(
      barcode: stock['barcode'] ?? '',
      itemCode: stock['itemcode'] ?? '',
      unit: stock['unit'] ?? '',
      conversion: stock['conversion'] ?? '1',
      itemDescription: stock['itemdescription'] ?? '',
      quantity: stock['quantity'] ?? '0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'itemcode': itemCode,
      'unit': unit,
      'conversion': conversion,
      'itemdescription': itemDescription,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'StockInventoryItem(barcode: $barcode, itemCode: $itemCode, unit: $unit, '
        'conversion: $conversion, itemDescription: $itemDescription, quantity: $quantity)';
  }
}

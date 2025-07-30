import 'package:excel/excel.dart';

class StockInventoryItem {
  final String barcode;
  final String itemCode;
  final String uomId;
  final String conversion;
  final String itemDescription;
  final String quantity;

  StockInventoryItem({
    required this.barcode,
    required this.itemCode,
    required this.uomId,
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

      // Remove any backticks from barcode
      if (key == 'barcode' && value != null) {
        stock[key] = value.replaceAll('`', '');
      } else {
        stock[key] = value;
      }
    }

    // Validate required fields
    if ((stock['barcode'] ?? '').isEmpty) {
      throw FormatException('Empty barcode in row: $row');
    }
    if ((stock['itemcode'] ?? '').isEmpty) {
      throw FormatException('Empty itemcode in row: $row');
    }
    if ((stock['uomid'] ?? '').isEmpty) {
      throw FormatException('Empty uomid in row: $row');
    }
    if ((stock['quantity'] ?? '').isEmpty) {
      throw FormatException('Empty quantity in row: $row');
    }

    return StockInventoryItem(
      barcode: stock['barcode'] ?? '',
      itemCode: stock['itemcode'] ?? '',
      uomId: stock['uomid'] ?? '',
      conversion: stock['conversion'] ?? '1',
      itemDescription: stock['itemdescription'] ?? '',
      quantity: stock['quantity'] ?? '0', // Default to '0' if null
    );
  }

  // Map for database insert/update (keys match DB columns)
  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'itemcode': itemCode,
      'uomid': uomId,
      'conversion': conversion,
      'itemdescription': itemDescription,
      'quantity': quantity,
    };
  }

  @override
  String toString() {
    return 'StockInventoryItem(barcode: $barcode, itemCode: $itemCode, uomId: $uomId, '
        'conversion: $conversion, itemDescription: $itemDescription, quantity: $quantity)';
  }
}

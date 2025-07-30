// import 'package:excel/excel.dart';

// class StockItem {
//   final String barcode;
//   final String name;
//   final String unit;
//   final String? productCode;
//   final double? conversionRate;
//   final double? cost;

//   StockItem({
//     required this.barcode,
//     required this.name,
//     required this.unit,
//     this.productCode,
//     this.conversionRate,
//     this.cost,
//   });

//   // Factory to create from Excel row and header
//   factory StockItem.fromExcelRow(List<Data?> row, List<String> header) {
//     Map<String, dynamic> stock = {};
//     for (int i = 0; i < header.length && i < row.length; i++) {
//       stock[header[i]] = row[i]?.value;
//     }

//     return StockItem(
//       barcode: stock['barcode']?.toString() ?? '',
//       name: stock['name']?.toString() ?? '',
//       unit: stock['unit']?.toString() ?? '',
//       productCode: stock['product code']?.toString(),
//       conversionRate: double.tryParse(
//         stock['conversion rate']?.toString() ?? '',
//       ),
//       cost: double.tryParse(stock['cost']?.toString() ?? ''),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'barcode': barcode,
//       'name': name,
//       'unit': unit,
//       'product_code_nm': productCode,
//       'conversion_rate_nm': conversionRate,
//       'cost_nm': cost,
//     };
//   }
// }
import 'package:excel/excel.dart';

class StockItem {
  final String barcode;
  final String itemCode;
  final String uomId;
  final String conversion;
  final String itemDescription;

  StockItem({
    required this.barcode,
    required this.itemCode,
    required this.uomId,
    required this.conversion,
    required this.itemDescription,
  });

  // Create StockItem from Excel row & header
  // factory StockItem.fromExcelRow(List<Data?> row, List<String> header) {
  //   Map<String, dynamic> stock = {};
  //   for (int i = 0; i < header.length && i < row.length; i++) {
  //     stock[header[i]] = row[i]?.value;
  //   }
  // static StockItem fromExcelRow(List<dynamic> row, List<String> header) {
  //   Map<String, dynamic> stock = {};
  //   for (int i = 0; i < header.length; i++) {
  //     final key = header[i].toLowerCase().trim();
  //     final value = i < row.length ? row[i]?.toString().trim() : null;
  //     stock[key] =
  //         value; // stock[header[i]] = i < row.length ? row[i]?.toString() : null;
  //   }
  //   return StockItem(
  //     barcode: stock['barcode'] ?? '',
  //     itemCode: stock['itemcode'] ?? '',
  //     uomId: stock['uomid'] ?? '',
  //     conversion: double.tryParse(stock['conversion'] ?? ''),
  //     itemDescription: stock['itemdescription'] ?? '',
  //   );
  // }
  static StockItem fromExcelRow(List<dynamic> row, List<String> header) {
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

    // Debug print the mapped values
    //  print('🧾 Mapped values: $stock');

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

    return StockItem(
      barcode: stock['barcode'] ?? '',
      itemCode: stock['itemcode'] ?? '',
      uomId: stock['uomid'] ?? '',
      conversion: stock['conversion'] ?? '1',
      itemDescription: stock['itemdescription'] ?? '',
    );
  } // Map for database insert/update (keys match DB columns)

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'itemcode': itemCode,
      'uomid': uomId,
      'conversion': conversion,
      'itemdescription': itemDescription,
    };
  }
}

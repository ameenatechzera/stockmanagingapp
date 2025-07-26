import 'package:excel/excel.dart';

class StockItem {
  final String barcode;
  final String name;
  final String unit;
  final String? productCode;
  final double? conversionRate;
  final double? cost;

  StockItem({
    required this.barcode,
    required this.name,
    required this.unit,
    this.productCode,
    this.conversionRate,
    this.cost,
  });

  // Factory to create from Excel row and header
  factory StockItem.fromExcelRow(List<Data?> row, List<String> header) {
    Map<String, dynamic> stock = {};
    for (int i = 0; i < header.length && i < row.length; i++) {
      stock[header[i]] = row[i]?.value;
    }

    return StockItem(
      barcode: stock['barcode']?.toString() ?? '',
      name: stock['name']?.toString() ?? '',
      unit: stock['unit']?.toString() ?? '',
      productCode: stock['product code']?.toString(),
      conversionRate: double.tryParse(
        stock['conversion rate']?.toString() ?? '',
      ),
      cost: double.tryParse(stock['cost']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'name': name,
      'unit': unit,
      'product_code_nm': productCode,
      'conversion_rate_nm': conversionRate,
      'cost_nm': cost,
    };
  }
}

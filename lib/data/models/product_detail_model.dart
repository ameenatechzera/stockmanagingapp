// class SavedProduct {
//   final String barcode;
//   final String name;
//   final String unit;
//   final String productCode;
//   final String conversionRate;
//   final String cost;
//   final String quantity;

//   SavedProduct({
//     required this.barcode,
//     required this.name,
//     required this.unit,
//     required this.productCode,
//     required this.conversionRate,
//     required this.cost,
//     required this.quantity,
//   });
//   Map<String, dynamic> toMap() {
//     return {
//       'barcode': barcode,
//       'name': name,
//       'unit': unit,
//       'product_code': productCode,
//       'conversion_rate': conversionRate,
//       'cost': cost,
//       'quantity': quantity,
//     };
//   }
// }
class SavedProduct {
  final String barcode;
  final String itemcode;
  final String uomid;
  final String conversion;
  final String itemdescription;
  final String quantity;

  SavedProduct({
    required this.barcode,
    required this.itemcode,
    required this.uomid,
    required this.conversion,
    required this.itemdescription,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'itemcode': itemcode,
      'uomid': uomid,
      'conversion': conversion,
      'itemdescription': itemdescription,
      'quantity': quantity,
    };
  }
}

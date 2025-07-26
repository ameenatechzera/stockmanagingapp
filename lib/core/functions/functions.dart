import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stockapp/data/models/stock_model.dart';
import 'package:stockapp/data/services/db_helper.dart';

Future<void> pickFileAndSave(BuildContext context) async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );
    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      final bytes = File(filePath).readAsBytesSync();
      final excel = Excel.decodeBytes(bytes);
      Sheet? sheet;
      try {
        sheet = excel.tables.values.firstWhere((s) => s.rows.isNotEmpty);
      } catch (e) {
        // No sheet found
        sheet = null;
      }

      if (sheet == null) {
        print('No non-empty sheets found.');
        return;
      }

      //final sheet = excel.tables.values.first;
      //final sheet = excel['Stock'];

      if (sheet == null || sheet.rows.isEmpty) {
        print('Excel sheet is empty.');
        return;
      }

      final header =
          sheet.rows.first
              .map((cell) => cell?.value.toString().toLowerCase() ?? '')
              .toList();
      debugPrint('Imported Excel Headers: $header');

      // Define the expected headers
      final masterHeaders = [
        'barcode',
        'name',
        'unit',
        'product code',
        'conversion rate',
        'cost',
      ];
      final stockHeaders = [
        'barcode',
        'name',
        'unit',
        'product code',
        'conversion rate',
        'cost',
        'quantity',
      ];

      // Sort for comparison
      final sortedHeader = [...header]..sort();
      final sortedMaster = [...masterHeaders]..sort();
      final sortedStock = [...stockHeaders]..sort();

      if (!(listEquals(sortedHeader, sortedMaster) ||
          listEquals(sortedHeader, sortedStock))) {
        print('❌ File format does not match master or stock data columns.');
        showMessageDialog(
          context,
          '❌ Invalid Excel format. Please use the correct template.',
          isError: true,
        );

        return;
      }

      if (!header.contains('barcode') ||
          !header.contains('name') ||
          !header.contains('unit')) {
        print('Mandatory columns (barcode, name, unit) missing!');
        return;
      }

      final db = await StockDatabase.instance.database;

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        final stockItem = StockItem.fromExcelRow(row, header);
        await db.insert(
          'stock',
          stockItem.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      print('Stock data imported successfully!');

      showMessageDialog(context, '✅ Stock data imported successfully!');

      final storedData = await db.query('stock');
      print('📦 Stored Stock Records:');
      for (final row in storedData) {
        print(row);
      }
    } else {
      print('User cancelled the picker.');
    }
  } catch (e) {
    print('Error importing Excel file: $e');
  }
}

// Future<void> exportStockToExcel(BuildContext context) async {
//   late BuildContext dialogContext;
//   try {
//     // Show loading dialog and capture its context
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (ctx) {
//         dialogContext = ctx; // capture the dialog context here
//         return const Center(child: CircularProgressIndicator());
//       },
//     );
//     final db = await StockDatabase.instance.database;
//     final data = await db.query(
//       'selected_stock',
//     ); // Exporting selected_stock table

//     if (data.isEmpty) {
//       print('No data to export.');
//       Navigator.pop(dialogContext); // Close dialog
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('No data to export.')));

//       return;
//     }

//     final excel = Excel.createExcel();
//     final Sheet sheet = excel['SelectedStock'];

//     // Add header
//     final headers = [
//       'Barcode',
//       'Name',
//       'Unit',
//       'Product Code',
//       'Conversion Rate',
//       'Cost',
//       'Quantity',
//     ];
//     sheet.appendRow([
//       TextCellValue('Barcode'),
//       TextCellValue('Name'),
//       TextCellValue('Unit'),
//       TextCellValue('Product Code'),
//       TextCellValue('Conversion Rate'),
//       TextCellValue('Cost'),
//       TextCellValue('Quantity'),
//     ]);

//     // Add rows
//     for (final row in data) {
//       sheet.appendRow([
//         TextCellValue(row['barcode']?.toString() ?? ''),
//         TextCellValue(row['name']?.toString() ?? ''),
//         TextCellValue(row['unit']?.toString() ?? ''),
//         TextCellValue(row['product_code_nm']?.toString() ?? ''),
//         TextCellValue(row['conversion_rate_nm']?.toString() ?? ''),
//         TextCellValue(row['cost_nm']?.toString() ?? ''),
//         TextCellValue(row['quantity']?.toString() ?? ''),
//       ]);
//     }

//     // Save file
//     //final directory = await getExternalStorageDirectory();
//     final path = '/storage/emulated/0/Download'; // Fallback for Android
//     final fileName =
//         'exported_selected_stock_${DateTime.now().millisecondsSinceEpoch}.xlsx';
//     final file = File('$path/$fileName');
//     await file.writeAsBytes(excel.encode()!);

//     print('✅ File saved to: $file');
//     Navigator.pop(dialogContext);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('✅ Exported Successfully to Downloads\n$fileName'),
//       ),
//     );
//   } catch (e) {
//     print('❌ Failed to export: $e');
//     Navigator.pop(dialogContext); // Close dialog
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text('❌ Failed to export: $e')));
//   }
// }

Future<void> exportStockToExcel(BuildContext context, String outputPath) async {
  final products = await StockDatabase.instance.getAllSavedProducts();
  print("Fetched ${products.length} products from DB");

  final excel = Excel.createExcel();
  final Sheet sheet = excel['Stock'];

  // ✅ Add header row
  sheet.appendRow([
    // TextCellValue('S.No'),
    TextCellValue('Barcode'),
    TextCellValue('Name'),
    TextCellValue('Unit'),
    TextCellValue('Product Code'),
    TextCellValue('Conversion Rate'),
    TextCellValue('Cost'),
    TextCellValue('Quantity'),
  ]);

  // ✅ Add data rows
  for (int i = 0; i < products.length; i++) {
    final product = products[i];
    sheet.appendRow([
      // IntCellValue(i + 1),
      TextCellValue(product.barcode),
      TextCellValue(product.name),
      TextCellValue(product.unit),
      TextCellValue(product.productCode ?? ''),
      TextCellValue(product.conversionRate?.toString() ?? ''),
      TextCellValue(product.cost.toString()),
      TextCellValue(product.quantity),
    ]);
  }

  // Delete the default empty sheet
  if (excel.tables.containsKey('Sheet1')) {
    excel.delete('Sheet1');
  }
  final fileBytes = excel.encode();
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final file = File('$outputPath/stocks_$timestamp.xlsx');
  // final file = File('$outputPath/stocks.xlsx');
  await file.writeAsBytes(fileBytes!);
  showMessageDialog(context, '✅ Exported Successfully ');
}

void showMessageDialog(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  showDialog(
    context: context,
    builder:
        (_) => AlertDialog(
          title: Text(isError ? 'Error' : 'Success'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}

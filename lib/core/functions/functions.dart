import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stockapp/data/models/stock_inventory_model.dart';
import 'package:stockapp/data/models/stock_model.dart';
import 'package:stockapp/data/services/db_helper.dart';
import 'dart:async';

bool _isPickingFile = false;

Future<void> pickFileAndSave(
  BuildContext context, {
  required String importType,
}) async {
  if (_isPickingFile) return;
  _isPickingFile = true;
  try {
    final db = await StockDatabase.instance.database;
    final tableName = importType == 'data' ? 'stock' : 'stock_inventory';

    final existingCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
        ) ??
        0;

    if (existingCount > 0) {
      final shouldClear = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              contentPadding: const EdgeInsets.all(12),
              titlePadding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),

              title: const Text('Warning: Existing Data Found'),
              content: const Text(
                'Do you want to clear the table before importing?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Clear & Import'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ],
            ),
      );

      if (shouldClear == null || !shouldClear) {
        _isPickingFile = false;
        return;
      }

      final confirmClear = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              contentPadding: const EdgeInsets.all(12),
              titlePadding: const EdgeInsets.only(top: 12, left: 12, right: 12),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),

              title: const Text('Confirm Clear'),
              content: const Text(
                'This will permanently delete all existing records. Continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Clear'),
                ),
              ],
            ),
      );

      if (confirmClear != true) {
        _isPickingFile = false;
        return;
      }

      await db.delete(tableName);
      await StockDatabase.instance.clearSelectedStockTable();
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'csv'],
    );

    if (result == null || result.files.single.path == null) {
      print('User cancelled file picker.');
      return;
    }

    await Future.delayed(const Duration(milliseconds: 100));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => ProgressDialog(
                  title:
                      'Importing ${importType == 'data' ? 'Master Data' : 'Stock Inventory'}...',
                  //total: 0,
                  //current: progresss,
                ),
          ),
    );
    final filePath = result.files.single.path!;
    final bytes = await File(filePath).readAsBytes();

    print('📄 File Info:');
    print('  Path: $filePath');
    print('  Size: ${bytes.length} bytes');

    final List<List<dynamic>> rows = await compute(parseExcel, bytes);

    print('📊 Excel Data Summary:');
    print('  Total rows: ${rows.length}');
    if (rows.isNotEmpty) {
      print('  Headers: ${rows.first}');
      print('  First data row: ${rows.length > 1 ? rows[1] : "N/A"}');
      print('  Last data row: ${rows.isNotEmpty ? rows.last : "N/A"}');
    }

    if (rows.length <= 1) {
      hideLoadingDialog(context);
      showMessageDialog(context, '❌ Excel file is empty.', isError: true);
      return;
    }

    final header =
        rows.first
            .map((cell) => cell?.toString().toLowerCase().trim() ?? '')
            .toList();

    print('🔍 Cleaned Headers: $header');
    final masterHeaders = [
      'barcode',
      'itemcode',
      'unit',
      'conversion',
      'itemdescription',
    ];
    final stockHeaders = [...masterHeaders, 'quantity'];

    if ((importType == 'data' && !listEquals(header, masterHeaders)) ||
        (importType == 'stock' && !listEquals(header, stockHeaders))) {
      hideLoadingDialog(context);
      print('❌ Invalid Excel column headers: $header');
      showMessageDialog(
        context,
        '❌ Invalid Excel format for ${importType == 'data' ? 'master data' : 'stock inventory'}.\n'
        'Expected columns: ${importType == 'data' ? masterHeaders.join(', ') : stockHeaders.join(', ')}',
        isError: true,
      );
      return;
    }

    final tableInfo = await db.rawQuery('PRAGMA table_info(stock)');
    print('🗄️ Stock table schema:');
    for (var column in tableInfo) {
      print('  ${column['name']}: ${column['type']}');
    }
    const batchSize = 500;
    int successCount = 0;
    int errorCount = 0;
    final totalRows = rows.length - 1;
    final progress = ValueNotifier<int>(0);
    hideLoadingDialog(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => ProgressDialog(
            title:
                'Importing ${importType == 'data' ? 'Master Data' : 'Stock Inventory'}...',

            total: totalRows,
            current: progress,
          ),
    );

    await Future.delayed(Duration.zero);
    for (int i = 1; i < rows.length; i += batchSize) {
      final end = (i + batchSize < rows.length) ? i + batchSize : rows.length;
      final batch = db.batch();

      for (int j = i; j < end; j++) {
        final row = rows[j];

        try {
          if (importType == 'data') {
            final item = StockItem.fromExcelRow(row, header);
            batch.insert('stock', item.toMap());
          } else {
            final item = StockInventoryItem.fromExcelRow(row, header);
            batch.insert('stock_inventory', item.toMap());
          }

          successCount++;
        } catch (e) {
          errorCount++;
          print('❌ Error processing row $j: ${e.toString()}');
        }
        progress.value++;
      }

      try {
        await batch.commit(noResult: true);
        print('✅ Committed batch ${i ~/ batchSize + 1} (rows $i-$end)');
      } catch (e) {
        print('❌ Batch commit error: $e');
      }
    }

    // NEW: Print import summary
    print('📊 Import Summary:');
    print('  Total rows processed: ${rows.length - 1}');
    print('  Successfully imported: $successCount');
    print('  Failed to import: $errorCount');

    // NEW: Verify the imported data
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName'),
    );
    print('✅ Total rows in $tableName table: $count');

    // NEW: Print sample data from database
    final sampleData = await db.query(tableName, limit: 5);
    print('🔍 Sample database records:');
    for (var row in sampleData) {
      print('  $row');
    }

    //hideLoadingDialog(context);

    Navigator.of(context, rootNavigator: true).pop();
    showMessageDialog(
      context,
      '✅ Imported ${rows.length - 1} rows to ${importType == 'data' ? 'stock' : 'stock inventory'}!\n'
      ' ($successCount success, $errorCount errors)',
    );
  } catch (e) {
    hideLoadingDialog(context);
    print('❌ Error importing file: $e');
    showMessageDialog(
      context,
      '❌ Import failed: ${e.toString()}',
      isError: true,
    );
  } finally {
    _isPickingFile = false;
  }
}

List<List<dynamic>> parseExcel(Uint8List bytes) {
  try {
    final excel = Excel.decodeBytes(bytes);
    Sheet? sheet;

    try {
      sheet = excel.tables.values.firstWhere((s) => s.rows.isNotEmpty);
    } catch (e) {
      sheet = null;
    }

    if (sheet == null) {
      print('⚠️ No non-empty sheets found in Excel file');
      return [];
    }

    // Convert Data objects to their values
    return sheet.rows
        .map((row) => row.map((cell) => cell?.value).toList())
        .toList();
  } catch (e) {
    print('❌ Error parsing Excel: $e');
    rethrow;
  }
}

Future<void> exportStockToExcel(BuildContext context, String outputPath) async {
  final products = await StockDatabase.instance.getAllSavedProducts();
  print("Fetched ${products.length} products from DB");

  final excel = Excel.createExcel();
  final Sheet sheet = excel['Stock'];

  // ✅ Add header row
  sheet.appendRow([
    // TextCellValue('S.No'),
    TextCellValue('Barcode'),
    TextCellValue('Itemcode'),
    TextCellValue('Unit'),
    TextCellValue('Conversion'),
    TextCellValue('Itemdescription'),
    TextCellValue('Quantity'),
    TextCellValue('DeviceNumber'),
  ]);

  // ✅ Add data rows
  for (int i = 0; i < products.length; i++) {
    final product = products[i];
    sheet.appendRow([
      // IntCellValue(i + 1),
      TextCellValue(product.barcode),
      TextCellValue(product.itemcode),
      TextCellValue(product.unit),
      TextCellValue(product.conversion ?? ''),
      TextCellValue(product.itemdescription ?? ''),
      TextCellValue(product.quantity),
      TextCellValue(product.deviceNumber ?? ''),
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

void showLoadingDialog(
  BuildContext context, [
  String message = 'Importing...',
]) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder:
        (_) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        ),
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pop();
}

class ProgressDialog extends StatelessWidget {
  final String title;
  final int? total;
  final ValueNotifier<int>? current;

  const ProgressDialog({
    super.key,
    required this.title,
    this.total,
    this.current,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (total != null && current != null) {
      // Determinate mode
      content = ValueListenableBuilder<int>(
        valueListenable: current!,
        builder: (context, value, _) {
          final percent = total == 0 ? 0.0 : value / total!;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: percent),
              const SizedBox(height: 16),
              Text('Imported $value of $total rows'),
            ],
          );
        },
      );
    } else {
      // Indeterminate mode
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          LinearProgressIndicator(), // no value = indeterminate animation
          SizedBox(height: 16),
          Text('Parsing Excel file...'),
        ],
      );
    }

    return AlertDialog(title: Text(title), content: content);
  }
}

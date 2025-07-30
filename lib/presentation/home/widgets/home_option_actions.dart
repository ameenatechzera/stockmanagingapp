import 'package:flutter/material.dart';
import 'package:stockapp/core/functions/functions.dart';
import 'package:stockapp/data/services/db_helper.dart';
import 'package:stockapp/presentation/stock/pages/barcode_details_screen.dart';
import 'package:stockapp/presentation/stock/pages/export_preview_screen.dart';

class HomeOptionActions {
  static Future<void> handleTap(BuildContext context, String label) async {
    if (label == 'Import Stock') {
      // showDialog(
      //   context: context,
      //   builder:
      //       (context) => AlertDialog(
      //         title: const Text("Select Import Type"),
      //         content: Column(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             ListTile(
      //               leading: const Icon(Icons.storage),
      //               title: const Text('Data'),
      //               onTap: () async {
      //                 Navigator.pop(context);
      //                 await pickFileAndSave(context);
      //               },
      //             ),
      //             ListTile(
      //               leading: const Icon(Icons.insert_drive_file),
      //               title: const Text('Stock'),
      //               onTap: () async {
      //                 Navigator.pop(context); // Close the dialog
      //                 // await pickFileAndSave(context, importType: 'data');
      //               },
      //             ),
      //           ],
      //         ),
      //       ),
      // );
      final importType = await showDialog<String>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Select Import Type"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Data'),
                    onTap: () => Navigator.pop(context, 'data'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: const Text('Stock'),
                    onTap: () => Navigator.pop(context, 'stock'),
                  ),
                ],
              ),
            ),
      );

      if (importType == 'data') {
        await pickFileAndSave(context, importType: 'data');
      } else if (importType == 'stock') {
        await pickFileAndSave(
          context,
          importType: 'stock',
        ); // Handle stock import
      }
    }
    // await pickFileAndSave(context);
    else if (label == 'Scan Barcode') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return BarcodeDetailsScreen();
          },
        ),
      );
      // final scannedCode = await Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
      // );
      // try {
      //   if (scannedCode != null) {
      //     final db = await StockDatabase.instance.database;
      //     final normalizedCode = scannedCode.toString().trim().toLowerCase();
      //     print('🔍 Scanned barcode: "$normalizedCode"');
      //     // final all = await db.query('stock');
      //     // for (final row in all) {
      //     //   print('📦 DB Row Barcode: "${row['barcode']}"');
      //     // }

      //     final result = await db.query(
      //       'stock',

      //       // where: 'barcode = ?',
      //       // whereArgs: [scannedCode.toString()],
      //       where: 'LOWER(TRIM(barcode)) = ?',
      //       whereArgs: [normalizedCode],
      //     );

      //     if (result.isNotEmpty) {
      //       final stock = result.first;

      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (_) => ProductDetailsScreen(stock: stock),
      //         ),
      //       );
      //     } else {
      //       showDialog(
      //         context: context,
      //         builder:
      //             (_) => AlertDialog(
      //               title: const Text("Product Not Found"),
      //               content: Text(
      //                 "No product found with barcode: $scannedCode",
      //               ),
      //               actions: [
      //                 TextButton(
      //                   onPressed: () => Navigator.pop(context),
      //                   child: const Text("OK"),
      //                 ),
      //               ],
      //             ),
      //       );
      //     }
      //   }
      // } catch (e) {
      //   print('Scanning error: ${e.toString()}');
      // }
    } else if (label == 'Export Stock') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExportPreviewScreen()),
      );
      //await exportStockToExcel(context);
    } else if (label == 'Clear Stock') {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text("Confirm Clear"),
              content: const Text(
                "Are you sure you want to clear all imported stock data?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Clear"),
                ),
              ],
            ),
      );

      if (confirm == true) {
        await StockDatabase.instance.clearMasterStockTable();
        await StockDatabase.instance.clearSelectedStockTable();
        await StockDatabase.instance.clearStockInventoryTable();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stock data cleared successfully")),
        );
      }
    }
  }
}

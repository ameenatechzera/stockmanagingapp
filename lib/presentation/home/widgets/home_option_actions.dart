import 'package:flutter/material.dart';
import 'package:stockapp/core/functions/functions.dart';
import 'package:stockapp/data/services/db_helper.dart';
import 'package:stockapp/presentation/stock/pages/barcode_scanner_screen.dart';
import 'package:stockapp/presentation/stock/pages/export_preview_screen.dart';
import 'package:stockapp/presentation/stock/pages/product_details_screen.dart';

class HomeOptionActions {
  static Future<void> handleTap(BuildContext context, String label) async {
    if (label == 'Import Stock') {
      await pickFileAndSave(context);
    } else if (label == 'Scan Barcode') {
      final scannedCode = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
      );

      if (scannedCode != null) {
        final db = await StockDatabase.instance.database;

        final result = await db.query(
          'stock',
          where: 'barcode = ?',
          whereArgs: [scannedCode.toString()],
        );

        if (result.isNotEmpty) {
          final stock = result.first;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailsScreen(stock: stock),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text("Product Not Found"),
                  content: Text("No product found with barcode: $scannedCode"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK"),
                    ),
                  ],
                ),
          );
        }
      }
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
        await StockDatabase.instance.clearImportedStockTable();
        await StockDatabase.instance.clearStockTable();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Stock data cleared successfully")),
        );
      }
    }
  }
}

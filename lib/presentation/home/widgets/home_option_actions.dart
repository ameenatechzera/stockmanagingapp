import 'package:flutter/material.dart';
import 'package:stockapp/core/functions/functions.dart';
import 'package:stockapp/data/services/db_helper.dart';
import 'package:stockapp/presentation/stock/pages/barcode_details_screen.dart';
import 'package:stockapp/presentation/stock/pages/export_preview_screen.dart';

class HomeOptionActions {
  static Future<void> handleTap(BuildContext context, String label) async {
    if (label == 'Import Product') {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder:
            (dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 24,
              ),
              titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),

              title: Text(
                "Please see the supported .csv format foritemmaster ",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/images/Screenshot 2025-08-06 132003.png',
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Text(
                    'Always check barcode column values '
                    'doesnt contain "1.37058E+11" type values '
                    'these entries will be skipped.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                Center(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      // 3️⃣ Finally pick & save according to type
                      // if (importType == 'data') {
                      await pickFileAndSave(context, importType: 'data');
                      // } else {
                      //   await pickFileAndSave(context, importType: 'stock');
                      // }
                    },
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
      );
    }
    // await pickFileAndSave(context);
    else if (label == 'Stock Take') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return BarcodeDetailsScreen();
          },
        ),
      );
    } else if (label == 'Export Stock') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExportPreviewScreen()),
      );
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

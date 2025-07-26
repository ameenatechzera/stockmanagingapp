import 'package:flutter/material.dart';
import 'package:stockapp/core/colors/colors.dart';
import 'package:stockapp/data/models/product_detail_model.dart';
import 'package:stockapp/data/services/db_helper.dart';
import 'package:stockapp/presentation/stock/widgets/table_row.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> stock;
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );

  ProductDetailsScreen({super.key, required this.stock});

  Future<void> _saveProduct(BuildContext context) async {
    final quantity = _quantityController.text;

    final savedProduct = SavedProduct(
      barcode: stock['barcode'] ?? '',
      name: stock['name'] ?? '',
      unit: stock['unit'] ?? '',
      productCode: stock['product_code_nm'] ?? '',
      conversionRate: stock['conversion_rate_nm']?.toString() ?? '0',
      cost: stock['cost_nm']?.toString() ?? '0',
      quantity: quantity,
    );

    try {
      await StockDatabase.instance.insertOrUpdateSelectedStock(savedProduct);

      final savedList = await StockDatabase.instance.getAllSavedProducts();
      for (var item in savedList) {
        print(
          "✔️ Saved: ${item.barcode}, ${item.name}, ${item.quantity}, ${item.conversionRate}, ${item.productCode}, ${item.cost}",
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Product saved successfully ✅"),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save product: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: kwhite,
        title: const Text(
          "Product Details",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: kwhite,
          ),
        ),
        backgroundColor: Color(0xFF1C1243), // Top

        elevation: 3,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C1243), // Top
              Color.fromARGB(255, 22, 8, 20), // Bottom
            ],
          ),
        ),
        // color: Colors.grey[100],
        padding: const EdgeInsets.all(20),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                Table(
                  columnWidths: const {
                    0: IntrinsicColumnWidth(),
                    1: FlexColumnWidth(),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    buildTableRow("Barcode", stock['barcode']),
                    buildTableRow("Name", stock['name']),
                    buildTableRow("Unit", stock['unit']),
                    buildTableRow(
                      "Product Code",
                      stock['product_code_nm'] ?? 'N/A',
                    ),
                    buildTableRow(
                      "Conversion Rate",
                      stock['conversion_rate_nm']?.toString() ?? 'N/A',
                    ),
                    buildTableRow(
                      "Cost",
                      stock['cost_nm']?.toString() ?? 'N/A',
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "Enter Quantity",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: kwhite,
                    hintText: "Enter quantity",
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff43e97b), Color(0xff38f9d7)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _saveProduct(context),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text("Save", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

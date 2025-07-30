import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stockapp/core/colors/colors.dart';
import 'package:stockapp/data/services/db_helper.dart';
import 'package:stockapp/data/models/product_detail_model.dart';
import 'package:stockapp/core/functions/functions.dart';

class ExportPreviewScreen extends StatelessWidget {
  const ExportPreviewScreen({super.key});

  Future<List<SavedProduct>> _loadSavedProducts() async {
    return await StockDatabase.instance.getAllSavedProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: kwhite,
        title: const Text("Export Preview", style: TextStyle(color: kwhite)),
        backgroundColor: Color(0xFF1C1243), // Top
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
        child: FutureBuilder<List<SavedProduct>>(
          future: _loadSavedProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  "No products to export.",
                  style: TextStyle(color: kwhite),
                ),
              );
            }

            final products = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: Text(
                          '${index + 1}', // Serial number
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        title: Text(
                          product.itemcode,
                          style: TextStyle(color: kwhite),
                        ),
                        subtitle: Text(
                          "Qty: ${product.quantity}",
                          style: TextStyle(color: kwhite),
                        ),
                        // trailing: Text(
                        //   "${product.conversion}",
                        //   style: TextStyle(color: kwhite),
                        // ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff43e97b), Color(0xff38f9d7)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.file_download),
                        label: const Text("Export to Excel"),
                        onPressed: () async {
                          String? selectedDirectory =
                              await FilePicker.platform.getDirectoryPath();
                          if (selectedDirectory != null) {
                            await exportStockToExcel(
                              context,
                              selectedDirectory,
                            );
                          }
                          //await exportStockToExcel(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),

                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

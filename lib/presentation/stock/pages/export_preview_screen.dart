import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockapp/core/colors/colors.dart';
import 'package:stockapp/core/theme/theme_provider.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 36,
        foregroundColor: kwhite,
        title: Text(
          "Export Preview",
          style: TextStyle(
            color: kwhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1C1243),
        actions: [
          FutureBuilder<List<SavedProduct>>(
            future: _loadSavedProducts(),
            builder: (context, snapshot) {
              final hasProducts = snapshot.hasData && snapshot.data!.isNotEmpty;
              return IconButton(
                onPressed:
                    hasProducts
                        ? () async {
                          String? selectedDirectory =
                              await FilePicker.platform.getDirectoryPath();
                          if (selectedDirectory != null) {
                            await exportStockToExcel(
                              context,
                              selectedDirectory,
                            );
                          }
                        }
                        : null,
                icon: Icon(
                  Icons.upload_file_rounded,
                  color: hasProducts ? kwhite : Colors.grey,
                ),
                tooltip:
                    hasProducts ? 'Export to Excel' : 'No products to export',
              );
            },
          ),
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: kwhite,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
          ),
        ], // Top
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient:
              isDarkMode
                  ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF1C1243), // Top
                      Color.fromARGB(255, 22, 8, 20), // Bottom
                    ],
                  )
                  : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFF5F7FA), Color(0xFFE4E7EB)],
                  ),
        ),
        child: FutureBuilder<List<SavedProduct>>(
          future: _loadSavedProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: isDarkMode ? kwhite : Colors.black,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: TextStyle(color: isDarkMode ? kwhite : Colors.black),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "No products to export.",
                  style: TextStyle(color: isDarkMode ? kwhite : Colors.black),
                ),
              );
            }

            final products = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: products.length,
                    separatorBuilder:
                        (context, index) => Divider(
                          color:
                              isDarkMode
                                  ? Colors.white.withOpacity(0.2)
                                  : Color(0xFF1C1243).withOpacity(0.3),
                          thickness: 1,
                          // indent: 16,
                          // endIndent: 16,
                          height: 0,
                        ),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        dense: true,
                        leading: Text(
                          '${index + 1}', // Serial number
                          style: TextStyle(
                            color: isDarkMode ? kwhite : Colors.black,
                            fontSize: 14,
                          ),
                        ),
                        title: Text(
                          (product.itemdescription.isNotEmpty == true)
                              ? product.itemdescription
                              : 'Unknown',
                          style: TextStyle(
                            color: isDarkMode ? kwhite : Colors.black,
                          ),
                        ),

                        subtitle: Text(
                          "${product.barcode}",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? kwhite : Colors.black,
                          ),
                        ),
                        trailing: Text(
                          "Qty: ${product.quantity}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? kwhite : Colors.black,
                          ),
                        ),
                        tileColor:
                            isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                      );
                    },
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

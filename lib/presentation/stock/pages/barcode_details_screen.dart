import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockapp/core/colors/colors.dart';
import 'package:stockapp/core/theme/theme_provider.dart';
import 'package:stockapp/data/models/product_detail_model.dart';
import 'package:stockapp/data/services/db_helper.dart';
import 'package:stockapp/presentation/stock/pages/export_preview_screen.dart';

class BarcodeDetailsScreen extends StatefulWidget {
  const BarcodeDetailsScreen({super.key});

  @override
  State<BarcodeDetailsScreen> createState() => _BarcodeDetailsScreenState();
}

class _BarcodeDetailsScreenState extends State<BarcodeDetailsScreen> {
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController unitController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController conversionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final FocusNode barcodeFocus = FocusNode();
  final FocusNode quantityFocus = FocusNode();
  Timer? _debounce;

  Map<String, dynamic>? lastScannedProduct;
  List<Map<String, dynamic>> scannedProductsHistory = [];
  int totalItems = 0;
  int totalQuantity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      barcodeFocus.requestFocus();
      updateSummary();
    });
  }

  @override
  void dispose() {
    barcodeController.dispose();
    itemCodeController.dispose();
    unitController.dispose();
    descriptionController.dispose();
    conversionController.dispose();
    quantityController.dispose();
    barcodeFocus.dispose();
    quantityFocus.dispose();
    super.dispose();
    _debounce?.cancel();
  }

  InputDecoration inputDecoration(String label, [Widget? suffix]) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
        ThemeMode.dark;
    return InputDecoration(
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white : Colors.black,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white : Colors.black,
          width: 1,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isDarkMode ? Colors.white54 : Colors.black54,
          width: 1,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      suffixIcon: suffix,
      suffixIconConstraints: const BoxConstraints(
        minHeight: 35,
        minWidth: 35,
        maxHeight: 35,
        maxWidth: 35,
      ),
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isDarkMode ? Colors.white70 : Colors.black54,
      ),
    );
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    Widget? suffix,
    FocusNode? focusNode,
    Function(String)? onSubmitted,
    bool isLastField = false,
  }) {
    final isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).themeMode ==
        ThemeMode.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 55,
            child: Text(
              label,
              style: TextStyle(
                color: isDarkMode ? kwhite : Colors.black,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TextFormField(
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
                fontSize: 12,
              ),
              cursorColor: isDarkMode ? kwhite : Colors.black,
              controller: controller,
              focusNode: focusNode,
              onFieldSubmitted: (value) {
                if (onSubmitted != null) {
                  onSubmitted(value);
                }
                if (isLastField) {
                  _saveProduct();
                }
              },
              textInputAction:
                  isLastField ? TextInputAction.done : TextInputAction.next,
              decoration: inputDecoration('', suffix),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Color.fromARGB(255, 22, 8, 20) : kwhite,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 36,
        foregroundColor: kwhite,
        title: Text(
          'Stock Taking',
          style: TextStyle(
            color: kwhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Color(0xFF1C1243) : Color(0xFF1C1243),
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              size: 16,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!isDarkMode);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient:
                isDarkMode
                    ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1C1243),
                        Color.fromARGB(255, 22, 8, 20),
                      ],
                    )
                    : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF5F7FA), Color(0xFFF5F7FA)],
                    ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                SizedBox(height: 10),
                buildField(
                  'Barcode',
                  barcodeController,
                  focusNode: barcodeFocus,
                  onSubmitted: (value) async {
                    final barcode = value.trim();
                    final product = await fetchProductByBarcode(barcode);
                    if (product != null) {
                      itemCodeController.text = product['itemcode'] ?? '';
                      unitController.text = product['unit'] ?? '';
                      descriptionController.text =
                          product['itemdescription'] ?? '';
                      conversionController.text =
                          product['conversion']?.toString() ?? '';
                    } else {
                      final add = await _showAddProductDialog(context, barcode);
                      if (add == true) {
                        FocusScope.of(context).requestFocus(quantityFocus);
                      } else {
                        // Cancel → just refocus barcode
                        barcodeController.clear();
                        FocusScope.of(context).requestFocus(barcodeFocus);
                      }
                      return;
                    }
                    FocusScope.of(context).requestFocus(quantityFocus);
                  },

                  suffix: Container(
                    margin: const EdgeInsets.only(right: 12),
                    height: 20,
                    width: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        barcodeController.clear();
                        itemCodeController.clear();
                        unitController.clear();
                        descriptionController.clear();
                        conversionController.clear();
                        quantityController.clear();
                        FocusScope.of(context).requestFocus(barcodeFocus);
                      },
                    ),
                  ),
                ),
                buildField('ItemCode', itemCodeController),
                buildField('Description', descriptionController),
                buildField('Unit', unitController),

                buildField('Conversion', conversionController),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDarkMode ? Colors.white : Colors.black,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quantity',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            final current =
                                int.tryParse(quantityController.text) ?? 0;
                            if (current > 0) {
                              quantityController.text =
                                  (current - 1).toString();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              color:
                                  isDarkMode
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.1),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              Icons.remove,
                              color: isDarkMode ? Colors.white : Colors.black,
                              size: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: quantityController,
                            focusNode: quantityFocus,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _saveProduct(),
                            textAlign: TextAlign.center,
                            cursorColor:
                                isDarkMode ? Colors.white : Colors.black,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),

                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 6,
                              ),
                              hintText: '0',
                              hintStyle: TextStyle(
                                color:
                                    isDarkMode
                                        ? Colors.white54
                                        : Colors.black54,
                              ),
                              filled: true,
                              fillColor:
                                  isDarkMode
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.03),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  width: 1,
                                ),
                              ),
                            ),

                            onChanged: _onQuantityChanged,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            final current =
                                int.tryParse(quantityController.text) ?? 0;
                            quantityController.text = (current + 1).toString();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              color:
                                  isDarkMode
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.1),
                            ),
                            padding: const EdgeInsets.all(6),

                            child: Icon(
                              Icons.add,
                              color: isDarkMode ? Colors.white : Colors.black,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isDarkMode
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Last Scanned Product',
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  if (scannedProductsHistory.isNotEmpty) {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder:
                                          (_) => AlertDialog(
                                            contentPadding:
                                                const EdgeInsets.all(12),
                                            titlePadding: const EdgeInsets.only(
                                              top: 12,
                                              left: 12,
                                              right: 12,
                                            ),
                                            actionsPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            title: const Text(
                                              'Confirm Deletion',
                                            ),
                                            content: const Text(
                                              'Are you sure you want to remove the last scanned product?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      false,
                                                    ),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed:
                                                    () => Navigator.pop(
                                                      context,
                                                      true,
                                                    ),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                    );
                                    if (confirm == true) {
                                      final db =
                                          await StockDatabase.instance.database;
                                      await db.delete(
                                        'selected_stock',
                                        where: 'id = ?',
                                        whereArgs: [
                                          scannedProductsHistory.first['id'],
                                        ],
                                      );
                                      await updateSummary();
                                    }
                                  }
                                },
                                customBorder: const CircleBorder(),
                                splashColor: (isDarkMode
                                        ? Colors.white
                                        : Colors.red)
                                    .withOpacity(0.3),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color:
                                        isDarkMode ? Colors.white : Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (scannedProductsHistory.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Barcode: ${scannedProductsHistory.first['barcode'] ?? ''}',
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                'ItemCode: ${scannedProductsHistory.first['itemcode'] ?? ''}',
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          Text(
                            'Description: ${scannedProductsHistory.first['itemdescription'] ?? ''}',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Unit: ${scannedProductsHistory.first['unit'] ?? ''}',
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Conversion: ${scannedProductsHistory.first['conversion'] ?? ''}',
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Quantity: ${scannedProductsHistory.first['quantity'] ?? ''}',
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ] else
                          Text(
                            'No product scanned yet',
                            style: TextStyle(
                              color:
                                  isDarkMode ? Colors.white70 : Colors.black54,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color:
                        isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: SizedBox(
                          width: 400,
                          child: Text(
                            'Summary',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Items: $totalItems',
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                              // const SizedBox(height: 4),
                              Text(
                                'Total Quantity: $totalQuantity',
                                style: TextStyle(
                                  color:
                                      isDarkMode
                                          ? Colors.white70
                                          : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ExportPreviewScreen();
                                  },
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  isDarkMode ? Colors.white : Colors.black,
                              backgroundColor:
                                  isDarkMode
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.black.withOpacity(0.03),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: BorderSide(
                                  color:
                                      isDarkMode
                                          ? Colors.white38
                                          : Colors.black38,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: const Text(
                              'Preview',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchProductByBarcode(String barcode) async {
    final db = await StockDatabase.instance.database;
    var result = await db.query(
      'stock_inventory',
      where: 'LOWER(barcode) = ?',
      whereArgs: [barcode.toLowerCase()],
    );
    if (result.isNotEmpty) return result.first;
    result = await db.query(
      'stock',
      where: 'LOWER(barcode) = ?',
      whereArgs: [barcode.toLowerCase()],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateSummary() async {
    final db = await StockDatabase.instance.database;
    final products = await db.query('selected_stock', orderBy: 'id DESC');
    final itemCountResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM selected_stock',
    );
    final quantitySumResult = await db.rawQuery(
      'SELECT SUM(CAST(quantity AS INTEGER)) as total FROM selected_stock',
    );
    setState(() {
      scannedProductsHistory = products;
      totalItems = itemCountResult.first['count'] as int? ?? 0;
      totalQuantity = quantitySumResult.first['total'] as int? ?? 0;
    });
  }

  Future<void> _saveProduct() async {
    final barcode = barcodeController.text.trim();
    final qtyText = quantityController.text.trim();
    final deviceNumber = await getDeviceNumber();
    if (deviceNumber == null || deviceNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Device number not set. Please set it in settings.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (barcode.isEmpty || qtyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '❌ Please scan a product or enter a barcode a quantity.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      // Send focus back to whichever is empty
      if (barcode.isEmpty) {
        FocusScope.of(context).requestFocus(barcodeFocus);
      } else {
        FocusScope.of(context).requestFocus(quantityFocus);
      }
      return;
    }

    final product = SavedProduct(
      barcode: barcodeController.text.trim(),
      itemcode: itemCodeController.text.trim(),
      unit: unitController.text.trim(),
      conversion: conversionController.text.trim(),
      itemdescription: descriptionController.text.trim(),
      quantity: quantityController.text.trim(),
      deviceNumber: deviceNumber,
    );
    print('😂😂😂$deviceNumber');
    try {
      await StockDatabase.instance.insertOrUpdateSelectedStock(product);
      await updateSummary();
      barcodeController.clear();
      itemCodeController.clear();
      unitController.clear();
      conversionController.clear();
      descriptionController.clear();
      quantityController.clear();
      FocusScope.of(context).requestFocus(barcodeFocus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating, // float so margin works
          margin: const EdgeInsets.symmetric(),
          padding: const EdgeInsets.symmetric(
            // reduce internal padding
            vertical: 4,
            horizontal: 12,
          ),
          content: ConstrainedBox(
            // force a shorter min height
            constraints: const BoxConstraints(minHeight: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle, size: 20, color: Colors.white),
                SizedBox(width: 6),
                Text('Product saved for exporting'),
              ],
            ),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error saving product: ${e.toString()}')),
      );
    }
  } // 1) Above your build, add a helper:

  Future<bool?> _showOverflowDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            // title: const Text(
            //   'Quantity Too Large',
            //   style: TextStyle(fontSize: 16),
            // ),
            content: const Text(
              'You’ve entered large quantity. Do you want to continue?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  quantityController.clear();
                  FocusScope.of(context).requestFocus(quantityFocus);
                  Navigator.pop(context, false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  void _onQuantityChanged(String value) {
    // Cancel any pending timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Start a new one
    _debounce = Timer(const Duration(milliseconds: 800), () async {
      // This runs 800ms after the last keystroke
      if (value.length > 3) {
        final shouldContinue = await _showOverflowDialog(context);
        if (shouldContinue == true) {
          _saveProduct();
        }
        // if false, dialog already cleared & refocused
      }
    });
  }

  Future<bool?> _showAddProductDialog(BuildContext context, String barcode) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            // title: const Text('No Product Found'),
            content: Text(
              'No product was found for barcode “$barcode”.\nDo you want to add it?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Continue'),
              ),
            ],
          ),
    );
  }

  Future<String?> getDeviceNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceNumber = prefs.getString('device_number');
    print('DEBUG: Fetched device number from SharedPreferences: $deviceNumber');
    return deviceNumber;
  }
}

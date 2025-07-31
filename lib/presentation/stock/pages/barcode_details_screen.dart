import 'package:flutter/material.dart';
import 'package:stockapp/core/colors/colors.dart';
import 'package:stockapp/data/models/product_detail_model.dart';
import 'package:stockapp/data/services/db_helper.dart';

class BarcodeDetailsScreen extends StatefulWidget {
  const BarcodeDetailsScreen({super.key});

  @override
  State<BarcodeDetailsScreen> createState() => _BarcodeDetailsScreenState();
}

class _BarcodeDetailsScreenState extends State<BarcodeDetailsScreen> {
  final TextEditingController barcodeController = TextEditingController();
  final TextEditingController itemCodeController = TextEditingController();
  final TextEditingController uomIdController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController conversionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();

  final FocusNode barcodeFocus = FocusNode();
  final FocusNode quantityFocus = FocusNode();
  Map<String, dynamic>? lastScannedProduct;
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
    uomIdController.dispose();
    descriptionController.dispose();
    conversionController.dispose();
    quantityController.dispose();
    barcodeFocus.dispose();
    quantityFocus.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String label, [Widget? suffix]) {
    return InputDecoration(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white, width: 2),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white54),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      suffixIcon: suffix,
    );
  }

  Widget buildField(
    String label,
    TextEditingController controller, {
    Widget? suffix,
    FocusNode? focusNode,
    Function(String)? onSubmitted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: kwhite, fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              style: const TextStyle(color: Colors.white),
              cursorColor: kwhite,
              controller: controller,
              focusNode: focusNode,
              onFieldSubmitted: onSubmitted,
              decoration: inputDecoration(label, suffix),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        foregroundColor: kwhite,
        title: const Text('Barcode Details', style: TextStyle(color: kwhite)),
        backgroundColor: const Color(0xFF1C1243),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1C1243), Color.fromARGB(255, 22, 8, 20)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    buildField(
                      'Barcode',
                      barcodeController,
                      focusNode: barcodeFocus,
                      onSubmitted: (value) async {
                        final product = await fetchProductByBarcode(
                          value.trim(),
                        );

                        if (product != null) {
                          itemCodeController.text = product['itemcode'] ?? '';
                          uomIdController.text = product['uomid'] ?? '';
                          descriptionController.text =
                              product['itemdescription'] ?? '';
                          conversionController.text =
                              product['conversion']?.toString() ?? '';
                          setState(() {
                            lastScannedProduct = product;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("❌ Product not found"),
                            ),
                          );
                          itemCodeController.clear();
                          uomIdController.clear();
                          descriptionController.clear();
                          conversionController.clear();
                        }
                        FocusScope.of(context).requestFocus(quantityFocus);
                      },
                      suffix: Container(
                        margin: const EdgeInsets.only(right: 18),
                        height: 28,
                        width: 28,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            barcodeController.clear();
                            itemCodeController.clear();
                            uomIdController.clear();
                            descriptionController.clear();
                            conversionController.clear();
                            quantityController.clear();

                            FocusScope.of(context).requestFocus(barcodeFocus);
                          },
                        ),
                      ),
                    ),
                    buildField('ItemCode', itemCodeController),
                    buildField('UOMID', uomIdController),
                    buildField('Description', descriptionController),
                    buildField('Conversion', conversionController),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                // Decrement Button
                                GestureDetector(
                                  onTap: () {
                                    final current =
                                        int.tryParse(quantityController.text) ??
                                        0;
                                    if (current > 0) {
                                      quantityController.text =
                                          (current - 1).toString();
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white),
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Quantity Input
                                Expanded(
                                  child: TextFormField(
                                    controller: quantityController,
                                    focusNode: quantityFocus,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted:
                                        (_) => FocusScope.of(context).unfocus(),
                                    textAlign: TextAlign.center,
                                    cursorColor: Colors.white,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 12,
                                          ),
                                      hintText: '0',
                                      hintStyle: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.05),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Increment Button
                                GestureDetector(
                                  onTap: () {
                                    final current =
                                        int.tryParse(quantityController.text) ??
                                        0;
                                    quantityController.text =
                                        (current + 1).toString();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white),
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 24),
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //       horizontal: 12,
                    //       vertical: 10,
                    //     ),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white.withOpacity(0.1),
                    //       borderRadius: BorderRadius.circular(8),
                    //       border: Border.all(color: Colors.white),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         const Text(
                    //           'Quantity:',
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 18,
                    //           ),
                    //         ),
                    //         const SizedBox(width: 16),
                    //         Expanded(
                    //           child: TextFormField(
                    //             controller: quantityController,
                    //             focusNode: quantityFocus,
                    //             keyboardType: TextInputType.number,
                    //             textInputAction: TextInputAction.done,
                    //             onFieldSubmitted:
                    //                 (_) => FocusScope.of(context).unfocus(),
                    //             cursorColor: Colors.white,
                    //             style: const TextStyle(color: Colors.white),
                    //             decoration: const InputDecoration(
                    //               isDense: true,
                    //               contentPadding: EdgeInsets.symmetric(
                    //                 horizontal: 12,
                    //                 vertical: 10,
                    //               ),
                    //               enabledBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(color: Colors.white),
                    //               ),
                    //               focusedBorder: OutlineInputBorder(
                    //                 borderSide: BorderSide(
                    //                   color: Colors.white,
                    //                   width: 2,
                    //                 ),
                    //               ),
                    //               hintText: 'Enter quantity',
                    //               hintStyle: TextStyle(color: Colors.white70),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // const Text(
                            //   'Last Scanned Product:',
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontWeight: FontWeight.bold,
                            //   ),
                            // ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Last Scanned Product:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        lastScannedProduct = null;
                                      });
                                      // TODO: Clear scanned product fields or state
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    tooltip: 'Clear',
                                    splashRadius: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (lastScannedProduct != null) ...[
                              Text(
                                'Barcode: ${lastScannedProduct!['barcode'] ?? ''}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'ItemCode: ${lastScannedProduct!['itemcode'] ?? ''}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'UOMID: ${lastScannedProduct!['uomid'] ?? ''}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Description: ${lastScannedProduct!['itemdescription'] ?? ''}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Conversion: ${lastScannedProduct!['conversion'] ?? ''}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                'Quantity: ${quantityController.text}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ] else
                              const Text(
                                'No product scanned yet',
                                style: TextStyle(color: Colors.white70),
                              ),

                            // const Text(
                            //   'Barcode:  12345678',
                            //   style: TextStyle(color: Colors.white),
                            // ),
                            // const Text(
                            //   'ItemCode: ITM001',
                            //   style: TextStyle(color: Colors.white),
                            // ),
                            // const Text(
                            //   'UOMID:   PCS',
                            //   style: TextStyle(color: Colors.white),
                            // ),
                            // const Text(
                            //   'Description: Sample Item',
                            //   style: TextStyle(color: Colors.white),
                            // ),
                            // const Text(
                            //   'Conversion: 1.0',
                            //   style: TextStyle(color: Colors.white),
                            // ),
                            // const Text(
                            //   'Quantity: 2.0',
                            //   style: TextStyle(color: Colors.white),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 145,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Summary',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Row with info and Preview button
                            Row(
                              children: [
                                // Info column
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Text(
                                    //   'Total Items: 5',
                                    //   style: TextStyle(
                                    //     color: Colors.white70,
                                    //     fontSize: 16,
                                    //   ),
                                    // ),
                                    // SizedBox(height: 6),
                                    // Text(
                                    //   'Total Quantity: 23',
                                    //   style: TextStyle(
                                    //     color: Colors.white70,
                                    //     fontSize: 16,
                                    //   ),
                                    // ),
                                    Text(
                                      'Total Items: $totalItems',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Total Quantity: $totalQuantity',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),

                                // Preview Button
                                TextButton(
                                  onPressed: () {
                                    // TODO: Add your preview logic here
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor: Colors.white.withOpacity(
                                      0.05,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ),
                                  child: const Text('Preview'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final product = SavedProduct(
                            barcode: barcodeController.text.trim(),
                            itemcode: itemCodeController.text.trim(),
                            uomid: uomIdController.text.trim(),
                            conversion: conversionController.text.trim(),
                            itemdescription:
                                descriptionController.text
                                    .trim(), // ⚠️ keep as String!
                            quantity: quantityController.text.trim(),
                          );

                          try {
                            await StockDatabase.instance
                                .insertOrUpdateSelectedStock(product);
                            await updateSummary();
                            // Optional: clear fields after save
                            barcodeController.clear();
                            itemCodeController.clear();
                            uomIdController.clear();
                            conversionController.clear();
                            descriptionController.clear();
                            quantityController.clear();

                            FocusScope.of(context).requestFocus(barcodeFocus);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✅ Product saved to selected_stock',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '❌ Error saving product: ${e.toString()}',
                                ),
                              ),
                            );
                          }
                        },

                        // print('Saving...');
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> fetchProductByBarcode(String barcode) async {
    final db = await StockDatabase.instance.database;

    // Try stock_inventory first
    var result = await db.query(
      'stock_inventory',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (result.isNotEmpty) return result.first;

    // Then try stock
    result = await db.query(
      'stock',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );

    if (result.isNotEmpty) return result.first;

    return null;
  }

  Future<void> updateSummary() async {
    final db = await StockDatabase.instance.database;

    final itemCountResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM selected_stock',
    );
    final quantitySumResult = await db.rawQuery(
      'SELECT SUM(CAST(quantity AS INTEGER)) as total FROM selected_stock',
    );

    setState(() {
      totalItems = itemCountResult.first['count'] as int? ?? 0;
      totalQuantity = quantitySumResult.first['total'] as int? ?? 0;
    });
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stockapp/data/models/product_detail_model.dart';

class StockDatabase {
  static final StockDatabase instance = StockDatabase._init();
  static Database? _database;

  StockDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('stock.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stock(
         id INTEGER PRIMARY KEY AUTOINCREMENT,
  barcode TEXT,
      itemcode TEXT NOT NULL,
      unit TEXT NOT NULL,
      conversion TEXT,
      itemdescription TEXT
      )
    ''');
    // Stock inventory table (with quantity)
    await db.execute('''
    CREATE TABLE stock_inventory(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      barcode TEXT ,
      itemcode TEXT NOT NULL,
      unit TEXT NOT NULL,
      conversion TEXT,
      itemdescription TEXT,
      quantity TEXT NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE selected_stock(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      barcode TEXT,
      itemcode TEXT,
      unit TEXT,
      conversion REAL,
      itemdescription TEXT,
      quantity TEXT,
      device_number TEXT
    )
  ''');
  }

  // ✅ INSERT FUNCTION
  Future<void> insertSelectedStock(SavedProduct product) async {
    final db = await instance.database;
    await db.insert('selected_stock', {
      'barcode': product.barcode,
      'itemcode': product.itemcode,
      'unit': product.unit,
      'conversion': product.conversion,
      'itemdescription': product.itemdescription,
      'quantity': product.quantity,
      'device_number': product.deviceNumber ?? '',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ✅ FETCH ALL SAVED PRODUCTS
  Future<List<SavedProduct>> getAllSavedProducts() async {
    final db = await instance.database;
    final result = await db.query('selected_stock', orderBy: 'id ASC');

    return result
        .map(
          (json) => SavedProduct(
            barcode: json['barcode'] as String,
            itemcode: json['itemcode'] as String,
            unit: json['unit'] as String,
            conversion: json['conversion']?.toString() ?? '',
            itemdescription: json['itemdescription']?.toString() ?? '',
            quantity: json['quantity']?.toString() ?? '',
            deviceNumber: json['device_number'].toString(),
          ),
        )
        .toList();
  }

  Future<void> insertOrUpdateSelectedStock(SavedProduct product) async {
    final db = await instance.database;

    await db.insert('selected_stock', {
      'barcode': product.barcode,
      'itemcode': product.itemcode,
      'unit': product.unit,
      'conversion': product.conversion,
      'itemdescription': product.itemdescription,
      'quantity': product.quantity,
      'device_number': product.deviceNumber ?? '',
    });

    print('✅ Inserted product: ${product.barcode} | Qty: ${product.quantity}');
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> clearSelectedStockTable() async {
    final db = await instance.database;
    await db.delete('selected_stock');
  }

  Future<void> clearMasterStockTable() async {
    final db = await instance.database;
    await db.delete('stock');
  }

  Future<void> clearStockInventoryTable() async {
    final db = await instance.database;
    await db.delete('stock_inventory');
  }

  Future<File?> exportDatabaseToDevice() async {
    try {
      // 1. Get the source database file
      final dbPath = await getDatabasesPath();
      final srcFile = File('$dbPath/stock.db');

      // 2. Read the file bytes (required for mobile platforms)
      final bytes = await srcFile.readAsBytes();

      // 3. Let user choose save location
      final String? selectedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Database Backup',
        fileName: 'stock_db_${DateTime.now().millisecondsSinceEpoch}.db',
        allowedExtensions: ['db'],
        bytes: bytes, // Provide the file bytes
      );

      if (selectedPath == null) return null; // User cancelled

      // 4. On desktop platforms, we still need to manually copy the file
      if (!Platform.isAndroid && !Platform.isIOS) {
        final destFile = File(selectedPath);
        await srcFile.copy(destFile.path);
        return destFile;
      }

      // 5. For mobile, the file is already saved by FilePicker
      return File(selectedPath);
    } catch (e) {
      print('Error exporting database: $e');
      rethrow;
    }
  }

  Future<bool> importDatabase(BuildContext context) async {
    try {
      // 1. First show the file picker
      FilePickerResult? result;
      try {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['db'], // No dot prefix
          dialogTitle: 'Select Database Backup',
        );
      } catch (e) {
        // Fallback if custom type fails
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          dialogTitle: 'Select Database Backup (.db file)',
        );
      }

      // 2. Check if user cancelled
      if (result == null || result.files.isEmpty) {
        return false; // User cancelled
      }

      // 3. Get the selected file
      final file = result.files.first;
      if (file.path == null) {
        throw Exception('No file path available');
      }

      // 4. Verify it's a .db file
      if (!file.path!.toLowerCase().endsWith('.db')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a .db database file')),
        );
        return false;
      }

      // 5. Show confirmation dialog
      final confirm =
          await showDialog<bool>(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Confirm Import'),
                  content: const Text(
                    'This will overwrite your current database',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Import'),
                    ),
                  ],
                ),
          ) ??
          false;

      if (!confirm) return false;

      // 6. Proceed with import
      final dbPath = await getDatabasesPath();
      final destFile = File('$dbPath/stock.db');

      // Close existing database first
      await _database?.close();
      _database = null;

      // Copy the file
      await File(file.path!).copy(destFile.path);

      // Reopen database
      _database = await _initDB('stock.db');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Database imported successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}

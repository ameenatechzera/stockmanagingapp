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
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stock(
        barcode TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        product_code_nm TEXT,
        conversion_rate_nm REAL,
        cost_nm REAL
      )
    ''');
    await db.execute('''
    CREATE TABLE selected_stock(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      barcode TEXT UNIQUE,
      name TEXT,
      unit TEXT,
      product_code_nm TEXT,
      conversion_rate_nm REAL,
      cost_nm REAL,
      quantity TEXT
    )
  ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE selected_stock(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT,
        name TEXT,
        unit TEXT,
        product_code_nm TEXT,
        conversion_rate_nm REAL,
        cost_nm REAL,
        quantity TEXT
      )
    ''');
    }
  }

  // ✅ INSERT FUNCTION
  Future<void> insertSelectedStock(SavedProduct product) async {
    final db = await instance.database;
    await db.insert('selected_stock', {
      'barcode': product.barcode,
      'name': product.name,
      'unit': product.unit,
      'product_code_nm': product.productCode,
      'conversion_rate_nm': double.tryParse(product.conversionRate) ?? 0.0,
      'cost_nm': double.tryParse(product.cost) ?? 0.0,
      'quantity': product.quantity,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // ✅ FETCH ALL SAVED PRODUCTS
  Future<List<SavedProduct>> getAllSavedProducts() async {
    final db = await instance.database;
    final result = await db.query('selected_stock');

    return result
        .map(
          (json) => SavedProduct(
            barcode: json['barcode'] as String,
            name: json['name'] as String,
            unit: json['unit'] as String,
            productCode: json['product_code_nm']?.toString() ?? '',
            conversionRate: json['conversion_rate_nm']?.toString() ?? '',
            cost: json['cost_nm']?.toString() ?? '',
            quantity: json['quantity']?.toString() ?? '',
          ),
        )
        .toList();
  }

  Future<void> insertOrUpdateSelectedStock(SavedProduct product) async {
    final db = await instance.database;

    // Check if the product already exists
    final existing = await db.query(
      'selected_stock',
      where: 'barcode = ?',
      whereArgs: [product.barcode],
    );

    if (existing.isNotEmpty) {
      // Get existing quantity
      // final existingQty =
      //     int.tryParse(existing.first['quantity'].toString()) ?? 0;
      // final newQty = int.tryParse(product.quantity.toString()) ?? 0;
      // final totalQty = existingQty + newQty;

      // Prepare updated data
      final updatedData = {
        'barcode': product.barcode,
        'name': product.name,
        'unit': product.unit,
        'product_code_nm': product.productCode,
        'conversion_rate_nm': double.tryParse(product.conversionRate) ?? 0.0,
        'cost_nm': double.tryParse(product.cost) ?? 0.0,
        'quantity': product.quantity,
        // totalQty.toString(),
      };

      // Update existing record
      await db.update(
        'selected_stock',
        updatedData,
        where: 'barcode = ?',
        whereArgs: [product.barcode],
      );

      print(
        '🔁 Updated product: ${product.barcode} | Qty: ${product.quantity}',
      );
    } else {
      // Insert new product
      await db.insert('selected_stock', {
        'barcode': product.barcode,
        'name': product.name,
        'unit': product.unit,
        'product_code_nm': product.productCode,
        'conversion_rate_nm': double.tryParse(product.conversionRate) ?? 0.0,
        'cost_nm': double.tryParse(product.cost) ?? 0.0,
        'quantity': product.quantity,
      });

      print(
        '✅ Inserted product: ${product.barcode} | Qty: ${product.quantity}',
      );
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> clearStockTable() async {
    final db = await instance.database;
    await db.delete('selected_stock'); // only clears imported stock
  }

  Future<void> clearImportedStockTable() async {
    final db = await instance.database;
    await db.delete('stock');
  }
}

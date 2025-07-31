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
    return await openDatabase(path, version: 2, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stock(
         id INTEGER PRIMARY KEY AUTOINCREMENT,
  barcode TEXT,
      itemcode TEXT NOT NULL,
      uomid TEXT NOT NULL,
      conversion TEXT,
      itemdescription TEXT
      )
    ''');
    // Stock inventory table (with quantity)
    await db.execute('''
    CREATE TABLE stock_inventory(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      barcode TEXT UNIQUE,
      itemcode TEXT NOT NULL,
      uomid TEXT NOT NULL,
      conversion TEXT,
      itemdescription TEXT,
      quantity TEXT NOT NULL
    )
  ''');
    await db.execute('''
    CREATE TABLE selected_stock(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      barcode TEXT UNIQUE,
      itemcode TEXT,
      uomid TEXT,
      conversion REAL,
      itemdescription TEXT,
      quantity TEXT
    )
  ''');
  }

  // Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
  //   if (oldVersion < 2) {
  //     await db.execute('''
  //     CREATE TABLE selected_stock(
  //       id INTEGER PRIMARY KEY AUTOINCREMENT,
  //       barcode TEXT,
  //       name TEXT,
  //       unit TEXT,
  //       product_code_nm TEXT,
  //       conversion_rate_nm REAL,
  //       cost_nm REAL,
  //       quantity TEXT
  //     )
  //   ''');
  //   }
  // }

  // ✅ INSERT FUNCTION
  Future<void> insertSelectedStock(SavedProduct product) async {
    final db = await instance.database;
    await db.insert('selected_stock', {
      'barcode': product.barcode,
      'itemcode': product.itemcode,
      'uomid': product.uomid,
      'conversion': product.conversion,
      'itemdescription': product.itemdescription,
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
            itemcode: json['itemcode'] as String,
            uomid: json['uomid'] as String,
            conversion: json['conversion']?.toString() ?? '',
            itemdescription: json['itemdescription']?.toString() ?? '',
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
        'itemcode': product.itemcode,
        'uomid': product.uomid,
        'conversion': product.conversion,
        'itemdescription': product.itemdescription,

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
        'itemcode': product.itemcode,
        'uomid': product.uomid,
        'conversion': product.conversion,
        'itemdescription': product.itemdescription,
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

  Future<void> clearSelectedStockTable() async {
    final db = await instance.database;
    await db.delete('selected_stock'); // only clears imported stock
  }

  Future<void> clearMasterStockTable() async {
    final db = await instance.database;
    await db.delete('stock');
  }

  Future<void> clearStockInventoryTable() async {
    final db = await instance.database;
    await db.delete('stock_inventory');
  }
}

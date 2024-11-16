import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/inventory_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'inventory_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE inventory(name TEXT PRIMARY KEY, quantity INTEGER, price REAL)',
        );
      },
      version: 1,
    );
  }

  Future<void> insertInventoryItem(InventoryItem item) async {
    final db = await database;
    await db.insert(
      'inventory',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<InventoryItem>> getInventoryItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('inventory');

    return List.generate(maps.length, (i) {
      return InventoryItem.fromMap(maps[i]);
    });
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    final db = await database;
    await db.update(
      'inventory',
      item.toMap(),
      where: 'name = ?',
      whereArgs: [item.name],
    );
  }

  Future<void> deleteInventoryItem(String name) async {
    final db = await database;
    await db.delete(
      'inventory',
      where: 'name = ?',
      whereArgs: [name],
    );
  }
}

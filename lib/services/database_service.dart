import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cashflow_item.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'manabe_masaref.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cashflow_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            jalaliDate TEXT NOT NULL,
            gregorianDate TEXT NOT NULL,
            description TEXT NOT NULL,
            amount INTEGER NOT NULL,
            type TEXT NOT NULL,
            includeInBalance INTEGER NOT NULL,
            source TEXT NOT NULL,
            sourceFileName TEXT,
            uniqueKey TEXT NOT NULL UNIQUE,
            balanceAfter INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<List<CashflowItem>> getItems() async {
    final db = await database;
    final rows = await db.query(
      'cashflow_items',
      orderBy: 'gregorianDate ASC, id ASC',
    );
    final items = rows.map(CashflowItem.fromMap).toList();
    return _withRunningBalance(items);
  }

  Future<int> insertItem(CashflowItem item) async {
    final db = await database;
    return db.insert(
      'cashflow_items',
      item.toMap()..remove('id'),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> updateInclude(int id, bool include) async {
    final db = await database;
    await db.update(
      'cashflow_items',
      {'includeInBalance': include ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteItem(int id) async {
    final db = await database;
    await db.delete('cashflow_items', where: 'id = ?', whereArgs: [id]);
  }

  List<CashflowItem> _withRunningBalance(List<CashflowItem> items) {
    var balance = 0;
    return items.map((item) {
      balance += item.signedAmount;
      return item.copyWith(balanceAfter: balance);
    }).toList();
  }
}

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/financial_item.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();
  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'tak_cashflow.db');
    _db = await openDatabase(path, version: 1, onCreate: _create);
    return _db!;
  }

  Future<void> _create(Database database, int version) async {
    await database.execute('''
      CREATE TABLE financial_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        document_date TEXT NOT NULL,
        cash_effect_date TEXT NOT NULL,
        document_number TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        kind TEXT NOT NULL,
        source_type TEXT NOT NULL,
        source_name TEXT NOT NULL,
        status TEXT NOT NULL,
        include_in_forecast INTEGER NOT NULL DEFAULT 1,
        is_active INTEGER NOT NULL DEFAULT 1,
        unique_key TEXT NOT NULL UNIQUE,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
    await database.execute('''
      CREATE TABLE bank_balances(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bank_name TEXT NOT NULL UNIQUE,
        amount REAL NOT NULL,
        balance_date TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> upsertBankBalance(BankBalance balance) async {
    final database = await db;
    await database.insert('bank_balances', balance.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BankBalance>> getBankBalances() async {
    final database = await db;
    final rows = await database.query('bank_balances', orderBy: 'bank_name');
    return rows.map(BankBalance.fromMap).toList();
  }

  Future<double> totalBankBalance() async {
    final database = await db;
    final rows = await database.rawQuery('SELECT SUM(amount) AS total FROM bank_balances');
    return ((rows.first['total'] ?? 0) as num).toDouble();
  }

  Future<void> deleteBankBalance(int id) async {
    final database = await db;
    await database.delete('bank_balances', where: 'id=?', whereArgs: [id]);
  }

  Future<int> insertManualItem(FinancialItem item) async {
    final database = await db;
    return database.insert('financial_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<ImportResult> syncExcelItems(List<FinancialItem> items, String kind) async {
    final database = await db;
    var inserted = 0;
    var updated = 0;
    var preserved = 0;
    var removed = 0;
    final nowKeys = items.map((e) => e.uniqueKey).toSet();

    await database.transaction((txn) async {
      final oldRows = await txn.query('financial_items', where: 'source_type=? AND kind=? AND is_active=1', whereArgs: ['excel', kind]);
      final oldByKey = {for (final r in oldRows) r['unique_key'].toString(): FinancialItem.fromMap(r)};

      for (final item in items) {
        final old = oldByKey[item.uniqueKey];
        if (old == null) {
          await txn.insert('financial_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
          inserted++;
        } else {
          final merged = item.copyWith(
            id: old.id,
            includeInForecast: old.includeInForecast,
            isActive: 1,
            createdAt: old.createdAt,
          );
          await txn.update('financial_items', merged.toMap(), where: 'unique_key=?', whereArgs: [item.uniqueKey]);
          preserved++;
        }
      }

      for (final old in oldByKey.values) {
        if (!nowKeys.contains(old.uniqueKey)) {
          await txn.update('financial_items', {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()}, where: 'id=?', whereArgs: [old.id]);
          removed++;
        }
      }
    });
    return ImportResult(inserted: inserted, updated: updated, preserved: preserved, removed: removed, total: items.length);
  }

  Future<List<FinancialItem>> getActiveItems({String? kind}) async {
    final database = await db;
    final rows = await database.query(
      'financial_items',
      where: kind == null ? 'is_active=1' : 'is_active=1 AND kind=?',
      whereArgs: kind == null ? null : [kind],
      orderBy: 'cash_effect_date ASC, amount ASC',
    );
    return rows.map(FinancialItem.fromMap).toList();
  }

  Future<List<FinancialItem>> getForecastItems() async {
    final database = await db;
    final rows = await database.query(
      'financial_items',
      where: 'is_active=1 AND include_in_forecast=1',
      orderBy: 'cash_effect_date ASC, amount ASC',
    );
    return rows.map(FinancialItem.fromMap).toList();
  }

  Future<void> toggleForecast(int id, bool include) async {
    final database = await db;
    await database.update('financial_items', {'include_in_forecast': include ? 1 : 0, 'updated_at': DateTime.now().toIso8601String()}, where: 'id=?', whereArgs: [id]);
  }

  Future<void> deactivateItem(int id) async {
    final database = await db;
    await database.update('financial_items', {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()}, where: 'id=?', whereArgs: [id]);
  }
}

class ImportResult {
  final int inserted;
  final int updated;
  final int preserved;
  final int removed;
  final int total;
  const ImportResult({required this.inserted, required this.updated, required this.preserved, required this.removed, required this.total});
}

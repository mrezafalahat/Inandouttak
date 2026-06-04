import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/bank_balance.dart';
import '../models/cash_item.dart';
import '../models/financial_item.dart' as fin;

class ExcelSyncResult {
  final int total;
  final int inserted;
  final int preserved;
  final int removed;
  const ExcelSyncResult({required this.total, required this.inserted, required this.preserved, required this.removed});
}

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

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE cash_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stable_key TEXT UNIQUE,
        date TEXT,
        effect_date TEXT,
        doc_no TEXT,
        description TEXT,
        amount INTEGER,
        item_type TEXT,
        source_type TEXT,
        source_name TEXT,
        status TEXT,
        include_in_forecast INTEGER DEFAULT 1,
        active INTEGER DEFAULT 1
      )
    ''');
    await db.execute('CREATE INDEX idx_cash_effect_date ON cash_items(effect_date)');
    await db.execute('CREATE INDEX idx_cash_key ON cash_items(stable_key)');

    await db.execute('''
      CREATE TABLE bank_balances(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bank_name TEXT,
        amount INTEGER,
        date TEXT
      )
    ''');
  }

  Future<List<CashItem>> getItems() async {
    final database = await db;
    final rows = await database.query('cash_items', orderBy: 'effect_date ASC, id ASC');
    return rows.map(CashItem.fromMap).toList();
  }

  Future<List<CashItem>> getActiveForecastItems() async {
    final database = await db;
    final rows = await database.query(
      'cash_items',
      where: 'active = 1 AND include_in_forecast = 1',
      orderBy: 'effect_date ASC, id ASC',
    );
    return rows.map(CashItem.fromMap).toList();
  }

  Future<void> upsertItem(CashItem item) async {
    final database = await db;
    final existing = await database.query('cash_items', where: 'stable_key = ?', whereArgs: [item.stableKey], limit: 1);
    if (existing.isEmpty) {
      await database.insert('cash_items', item.toMap());
    } else {
      final old = CashItem.fromMap(existing.first);
      final merged = item.toMap()
        ..['include_in_forecast'] = old.includeInForecast ? 1 : 0
        ..['active'] = 1;
      await database.update('cash_items', merged, where: 'stable_key = ?', whereArgs: [item.stableKey]);
    }
  }

  Future<ExcelSyncResult> syncExcelItems(List<dynamic> newItems, String itemType) async {
    final database = await db;
    final cashItems = newItems.map((e) {
      if (e is CashItem) return e;
      if (e is fin.FinancialItem) return _financialToCash(e);
      throw ArgumentError('Unsupported item type: ${e.runtimeType}');
    }).toList();

    var inserted = 0;
    var preserved = 0;
    final keys = cashItems.map((e) => e.stableKey).toSet();
    for (final item in cashItems) {
      final existing = await database.query('cash_items', where: 'stable_key = ?', whereArgs: [item.stableKey], limit: 1);
      if (existing.isEmpty) {
        inserted++;
      } else {
        preserved++;
      }
      await upsertItem(item);
    }

    var removed = 0;
    final current = await database.query('cash_items', where: 'item_type = ? AND source_type = ?', whereArgs: [itemType, 'excel']);
    for (final row in current) {
      final key = row['stable_key'] as String;
      if (!keys.contains(key)) {
        removed++;
        await database.update('cash_items', {'active': 0}, where: 'stable_key = ?', whereArgs: [key]);
      }
    }
    return ExcelSyncResult(total: cashItems.length, inserted: inserted, preserved: preserved, removed: removed);
  }

  Future<void> toggleInclude(CashItem item) async {
    final database = await db;
    await database.update('cash_items', {'include_in_forecast': item.includeInForecast ? 0 : 1}, where: 'id = ?', whereArgs: [item.id]);
  }

  Future<void> toggleForecast(int id, bool include) async {
    final database = await db;
    await database.update('cash_items', {'include_in_forecast': include ? 1 : 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addManualItem(CashItem item) async => upsertItem(item);

  Future<void> insertManualItem(fin.FinancialItem item) async => upsertItem(_financialToCash(item));

  Future<void> deactivateItem(dynamic itemOrId) async {
    final database = await db;
    final id = itemOrId is CashItem ? itemOrId.id : itemOrId as int;
    await database.update('cash_items', {'active': 0}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addBankBalance(BankBalance balance) async {
    final database = await db;
    await database.insert('bank_balances', balance.toMap());
  }

  Future<void> upsertBankBalance(BankBalance balance) async => addBankBalance(balance);

  Future<List<BankBalance>> getBankBalances() async {
    final database = await db;
    final rows = await database.query('bank_balances', orderBy: 'id DESC');
    return rows.map(BankBalance.fromMap).toList();
  }

  Future<int> totalBankBalance() async {
    final balances = await getBankBalances();
    final latestByBank = <String, BankBalance>{};
    for (final b in balances) {
      latestByBank.putIfAbsent(b.bankName, () => b);
    }
    return latestByBank.values.fold<int>(0, (sum, b) => sum + b.amount);
  }

  Future<List<fin.FinancialItem>> getActiveItems({String? kind}) async {
    final database = await db;
    final rows = await database.query(
      'cash_items',
      where: kind == null ? 'active = 1' : 'active = 1 AND item_type = ?',
      whereArgs: kind == null ? null : [kind],
      orderBy: 'effect_date ASC, id ASC',
    );
    return rows.map((e) => _cashToFinancial(CashItem.fromMap(e))).toList();
  }

  Future<List<fin.FinancialItem>> getForecastItems() async {
    final cash = await getActiveForecastItems();
    return cash.map(_cashToFinancial).toList();
  }

  CashItem _financialToCash(fin.FinancialItem item) => CashItem(
        id: item.id,
        stableKey: item.uniqueKey,
        date: item.documentDate,
        effectDate: item.cashEffectDate,
        docNo: item.documentNumber,
        description: item.description,
        amount: item.amount.round(),
        itemType: item.kind,
        sourceType: item.sourceType,
        sourceName: item.sourceName,
        status: item.status,
        includeInForecast: item.includeInForecast == 1,
        active: item.isActive == 1,
      );

  fin.FinancialItem _cashToFinancial(CashItem item) => fin.FinancialItem(
        id: item.id,
        documentDate: item.date,
        cashEffectDate: item.effectDate,
        documentNumber: item.docNo,
        description: item.description,
        amount: item.amount.toDouble(),
        kind: item.itemType,
        sourceType: item.sourceType,
        sourceName: item.sourceName,
        status: item.status,
        includeInForecast: item.includeInForecast ? 1 : 0,
        isActive: item.active ? 1 : 0,
        uniqueKey: item.stableKey,
        createdAt: '',
        updatedAt: '',
      );
}

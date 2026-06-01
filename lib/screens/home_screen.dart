import 'package:flutter/material.dart';
import '../models/bank_balance.dart';
import '../models/cash_item.dart';
import '../services/database_service.dart';
import '../services/excel_import_service.dart';
import '../utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseService.instance;
  final importer = ExcelImportService();
  List<CashItem> items = [];
  int bankTotal = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    items = await db.getItems();
    bankTotal = await db.totalBankBalance();
    setState(() => loading = false);
  }

  int get forecastTotal => items.where((e) => e.active && e.includeInForecast).fold<int>(bankTotal, (s, e) => s + e.amount);

  Future<void> _importExcel(bool receivable) async {
    final res = await importer.pickAndParse(receivable: receivable);
    if (res == null) return;
    await db.syncExcelItems(res.items, receivable ? 'receivable' : 'payable');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${res.items.length} ردیف از ${res.fileName} خوانده شد')));
    await _load();
  }

  Future<void> _addBankBalanceDialog() async {
    final bankCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ثبت موجودی بانک'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: bankCtrl, decoration: const InputDecoration(labelText: 'نام بانک')),
          TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مبلغ')),
          TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'تاریخ مثال 1403/03/12')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لغو')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ثبت')),
        ],
      ),
    );
    if (ok == true) {
      await db.addBankBalance(BankBalance(bankName: bankCtrl.text, amount: parseMoney(amountCtrl.text), date: normalizeDate(dateCtrl.text)));
      await _load();
    }
  }

  Future<void> _addManualDialog(bool income) async {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(income ? 'دریافت دستی' : 'پرداخت دستی'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'شرح')),
          TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مبلغ')),
          TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'تاریخ اثر نقدی')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لغو')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('ثبت')),
        ],
      ),
    );
    if (ok == true) {
      final amount = parseMoney(amountCtrl.text).abs() * (income ? 1 : -1);
      final date = normalizeDate(dateCtrl.text);
      final item = CashItem(
        stableKey: 'manual-${DateTime.now().microsecondsSinceEpoch}',
        date: date,
        effectDate: date,
        docNo: '',
        description: descCtrl.text,
        amount: amount,
        itemType: income ? 'manual_income' : 'manual_expense',
        sourceType: 'manual',
        sourceName: 'manual',
        status: 'active',
        includeInForecast: true,
        active: true,
      );
      await db.addManualItem(item);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('پیش‌بینی نقدینگی تک')),
        body: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _summaryCard(),
                    const SizedBox(height: 12),
                    _actions(),
                    const SizedBox(height: 12),
                    Text('اسناد و برنامه‌های آینده', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    ...items.map(_itemTile),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _summaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('خلاصه کلی'),
          const SizedBox(height: 8),
          Text('موجودی بانک‌ها: ${formatMoney(bankTotal)}'),
          Text('مانده پیش‌بینی‌شده: ${formatMoney(forecastTotal)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (forecastTotal < 0) const Text('هشدار: کسری نقدینگی', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _actions() {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      FilledButton(onPressed: _addBankBalanceDialog, child: const Text('موجودی بانک')),
      FilledButton(onPressed: () => _importExcel(true), child: const Text('ورود فایل دریافتنی')),
      FilledButton(onPressed: () => _importExcel(false), child: const Text('ورود فایل پرداختنی')),
      OutlinedButton(onPressed: () => _addManualDialog(true), child: const Text('دریافت دستی')),
      OutlinedButton(onPressed: () => _addManualDialog(false), child: const Text('پرداخت دستی')),
    ]);
  }

  Widget _itemTile(CashItem item) {
    final color = item.amount >= 0 ? Colors.green : Colors.red;
    return Card(
      child: ListTile(
        title: Text(item.description.isEmpty ? item.docNo : item.description),
        subtitle: Text('تاریخ اثر: ${item.effectDate} | ${item.sourceType} | ${item.status}'),
        leading: Switch(value: item.includeInForecast && item.active, onChanged: item.active ? (_) async { await db.toggleInclude(item); await _load(); } : null),
        trailing: Text(formatMoney(item.amount), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        onLongPress: item.sourceType == 'manual' ? () async { await db.deactivateItem(item); await _load(); } : null,
      ),
    );
  }
}

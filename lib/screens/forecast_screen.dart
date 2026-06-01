import 'package:flutter/material.dart';
import '../models/financial_item.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  double opening = 0;
  List<FinancialItem> items = [];
  List<_ForecastRow> rows = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    opening = await DatabaseService.instance.totalBankBalance();
    items = await DatabaseService.instance.getForecastItems();
    rows = _buildRows(opening, items);
    if (mounted) setState(() {});
  }

  List<_ForecastRow> _buildRows(double start, List<FinancialItem> items) {
    final grouped = <String, List<FinancialItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.cashEffectDate, () => []).add(item);
    }
    final dates = grouped.keys.toList()..sort();
    var balance = start;
    final out = <_ForecastRow>[];
    for (final d in dates) {
      final dayItems = grouped[d]!;
      dayItems.sort((a, b) => a.amount.compareTo(b.amount)); // پرداخت‌ها اول
      var dayIn = 0.0;
      var dayOut = 0.0;
      var minDuringDay = balance;
      for (final item in dayItems) {
        balance += item.amount;
        if (item.amount >= 0) {
          dayIn += item.amount;
        } else {
          dayOut += item.amount;
        }
        if (balance < minDuringDay) minDuringDay = balance;
      }
      out.add(_ForecastRow(date: d, receipts: dayIn, payments: dayOut, balance: balance, minDuringDay: minDuringDay, count: dayItems.length));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final danger = rows.where((r) => r.minDuringDay < 0).cast<_ForecastRow?>().firstOrNull;
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('موجودی نقد پایه: ${AppFormatters.money(opening)} ریال', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('موارد داخل محاسبه: ${items.length}'),
                const SizedBox(height: 8),
                Text(danger == null ? 'فعلاً کسری منفی دیده نمی‌شود.' : 'اولین هشدار کسری: ${danger.date} | کمترین مانده همان روز: ${AppFormatters.money(danger.minDuringDay)} ریال', style: TextStyle(color: danger == null ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map((r) => Card(
                child: ListTile(
                  title: Text(r.date),
                  subtitle: Text('تعداد سند: ${r.count} | کمترین مانده روز: ${AppFormatters.money(r.minDuringDay)}'),
                  trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('دریافت: ${AppFormatters.money(r.receipts)}'),
                    Text('پرداخت: ${AppFormatters.money(r.payments)}'),
                    Text('مانده: ${AppFormatters.money(r.balance)}', style: TextStyle(fontWeight: FontWeight.bold, color: r.balance < 0 ? Colors.red : null)),
                  ]),
                ),
              )),
        ],
      ),
    );
  }
}

class _ForecastRow {
  final String date;
  final double receipts;
  final double payments;
  final double balance;
  final double minDuringDay;
  final int count;
  const _ForecastRow({required this.date, required this.receipts, required this.payments, required this.balance, required this.minDuringDay, required this.count});
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

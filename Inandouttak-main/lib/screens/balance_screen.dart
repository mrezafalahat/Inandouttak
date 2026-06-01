import 'package:flutter/material.dart';
import '../models/financial_item.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({super.key});

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  final bankCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  final dateCtrl = TextEditingController(text: AppFormatters.todayJalali());
  List<BankBalance> balances = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    balances = await DatabaseService.instance.getBankBalances();
    if (mounted) setState(() {});
  }

  Future<void> save() async {
    if (bankCtrl.text.trim().isEmpty) return;
    await DatabaseService.instance.upsertBankBalance(BankBalance(
      bankName: bankCtrl.text.trim(),
      amount: AppFormatters.parseMoney(amountCtrl.text),
      balanceDate: AppFormatters.normalizeDate(dateCtrl.text),
      updatedAt: DateTime.now().toIso8601String(),
    ));
    bankCtrl.clear();
    amountCtrl.clear();
    await load();
  }

  @override
  Widget build(BuildContext context) {
    final total = balances.fold<double>(0, (p, e) => p + e.amount);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('موجودی کل بانک‌ها: ${AppFormatters.money(total)} ریال', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(controller: bankCtrl, decoration: const InputDecoration(labelText: 'نام بانک / حساب')),
              TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'موجودی')),
              TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'تاریخ موجودی مثل 1403/03/12')),
              const SizedBox(height: 12),
              FilledButton(onPressed: save, child: const Text('ثبت / بروزرسانی موجودی')),
            ]),
          ),
        ),
        const SizedBox(height: 12),
        ...balances.map((b) => Card(
              child: ListTile(
                title: Text(b.bankName),
                subtitle: Text('تاریخ موجودی: ${b.balanceDate}'),
                trailing: Text('${AppFormatters.money(b.amount)} ریال'),
              ),
            )),
      ],
    );
  }
}

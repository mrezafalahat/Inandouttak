import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../models/financial_item.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';

class ManualItemScreen extends StatefulWidget {
  const ManualItemScreen({super.key});

  @override
  State<ManualItemScreen> createState() => _ManualItemScreenState();
}

class _ManualItemScreenState extends State<ManualItemScreen> {
  final dateCtrl = TextEditingController(text: AppFormatters.todayJalali());
  final descCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String type = 'manual_payment';

  Future<void> save() async {
    final amountAbs = AppFormatters.parseMoney(amountCtrl.text).abs();
    if (amountAbs == 0 || descCtrl.text.trim().isEmpty) return;
    final now = DateTime.now().toIso8601String();
    final date = AppFormatters.normalizeDate(dateCtrl.text);
    final amount = type == 'manual_receipt' ? amountAbs : -amountAbs;
    final key = sha1.convert('$type|$date|$amountAbs|${descCtrl.text}|$now'.codeUnits).toString();
    await DatabaseService.instance.insertManualItem(FinancialItem(
      documentDate: date,
      cashEffectDate: date,
      documentNumber: 'MANUAL-${DateTime.now().millisecondsSinceEpoch}',
      description: descCtrl.text.trim(),
      amount: amount.toDouble(),
      kind: type,
      sourceType: 'manual',
      sourceName: 'ثبت دستی',
      status: 'فعال',
      includeInForecast: 1,
      isActive: 1,
      uniqueKey: key,
      createdAt: now,
      updatedAt: now,
    ));
    descCtrl.clear();
    amountCtrl.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ثبت شد')));
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('ثبت دریافت/پرداخت دستی', style: Theme.of(context).textTheme.titleLarge),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'نوع'),
                  items: const [
                    DropdownMenuItem(value: 'manual_payment', child: Text('پرداخت دستی / پول لازم دارم')),
                    DropdownMenuItem(value: 'manual_receipt', child: Text('دریافت دستی / پول می‌آید')),
                  ],
                  onChanged: (v) => setState(() => type = v ?? type),
                ),
                TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'تاریخ اثر نقدی')),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'شرح')),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'مبلغ')),
                const SizedBox(height: 12),
                FilledButton(onPressed: save, child: const Text('ثبت در پیش‌بینی')),
              ]),
            ),
          ),
        ],
      );
}

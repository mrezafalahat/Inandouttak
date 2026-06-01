import 'package:flutter/material.dart';
import '../models/financial_item.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen({super.key});

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  List<FinancialItem> items = [];
  String filter = 'all';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    items = await DatabaseService.instance.getActiveItems(kind: filter == 'all' ? null : filter);
    if (mounted) setState(() {});
  }

  String titleOf(FinancialItem item) {
    if (item.kind == 'receivable') return 'دریافتنی ${item.documentNumber}';
    if (item.kind == 'payable') return 'پرداختنی ${item.documentNumber}';
    if (item.kind == 'manual_receipt') return 'دریافت دستی';
    return 'پرداخت دستی';
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              value: filter,
              decoration: const InputDecoration(labelText: 'فیلتر'),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('همه موارد فعال')),
                DropdownMenuItem(value: 'receivable', child: Text('دریافتنی‌ها')),
                DropdownMenuItem(value: 'payable', child: Text('پرداختنی‌ها')),
                DropdownMenuItem(value: 'manual_receipt', child: Text('دریافت دستی')),
                DropdownMenuItem(value: 'manual_payment', child: Text('پرداخت دستی')),
              ],
              onChanged: (v) async {
                filter = v ?? 'all';
                await load();
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: load,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  final positive = item.amount >= 0;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(titleOf(item)),
                      subtitle: Text('${item.description}\nتاریخ سند: ${item.documentDate} | اثر نقدی: ${item.cashEffectDate}\nمنبع: ${item.sourceName} | وضعیت: ${item.status}'),
                      isThreeLine: true,
                      leading: Switch(
                        value: item.includeInForecast == 1,
                        onChanged: (v) async {
                          await DatabaseService.instance.toggleForecast(item.id!, v);
                          await load();
                        },
                      ),
                      trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('${positive ? '+' : ''}${AppFormatters.money(item.amount)}', style: TextStyle(fontWeight: FontWeight.bold, color: positive ? Colors.green : Colors.red)),
                        if (item.sourceType == 'manual')
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              await DatabaseService.instance.deactivateItem(item.id!);
                              await load();
                            },
                          ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
}

import 'package:flutter/material.dart';
import '../models/cashflow_item.dart';
import '../services/database_service.dart';
import '../widgets/cashflow_card.dart';
import '../widgets/cashflow_table.dart';
import '../widgets/summary_card.dart';
import 'add_item_screen.dart';
import 'import_excel_screen.dart';

enum ViewMode { card, table }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CashflowItem> _items = [];
  ViewMode _viewMode = ViewMode.card;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await DatabaseService.instance.getItems();
    setState(() => _items = items);
  }

  int get _totalPositive => _items
      .where((e) => e.includeInBalance && e.type == CashflowType.positive)
      .fold(0, (sum, e) => sum + e.amount);

  int get _totalNegative => _items
      .where((e) => e.includeInBalance && e.type == CashflowType.negative)
      .fold(0, (sum, e) => sum + e.amount);

  int get _finalBalance => _items.isEmpty ? 0 : _items.last.balanceAfter;

  Future<void> _openAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddItemScreen()),
    );
    if (result == true) _load();
  }

  Future<void> _openImportExcel() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ImportExcelScreen()),
    );
    _load();
  }

  Future<void> _toggleInclude(CashflowItem item, bool include) async {
    if (item.id == null) return;
    await DatabaseService.instance.updateInclude(item.id!, include);
    _load();
  }

  Future<void> _delete(CashflowItem item) async {
    if (item.id == null) return;
    await DatabaseService.instance.deleteItem(item.id!);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('منابع و مصارف'),
          actions: [
            IconButton(
              onPressed: _openImportExcel,
              icon: const Icon(Icons.upload_file),
              tooltip: 'ورود اکسل',
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openAdd,
          icon: const Icon(Icons.add),
          label: const Text('افزودن'),
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SummaryCard(
                totalPositive: _totalPositive,
                totalNegative: _totalNegative,
                finalBalance: _finalBalance,
              ),
              const SizedBox(height: 16),
              SegmentedButton<ViewMode>(
                segments: const [
                  ButtonSegment(value: ViewMode.card, label: Text('کارت'), icon: Icon(Icons.view_agenda)),
                  ButtonSegment(value: ViewMode.table, label: Text('جدول'), icon: Icon(Icons.table_chart)),
                ],
                selected: {_viewMode},
                onSelectionChanged: (s) => setState(() => _viewMode = s.first),
              ),
              const SizedBox(height: 16),
              if (_items.isEmpty)
                const _EmptyState()
              else if (_viewMode == ViewMode.card)
                ..._items.map((item) => CashflowCard(
                      item: item,
                      onIncludeChanged: (v) => _toggleInclude(item, v),
                      onDelete: () => _delete(item),
                    ))
              else
                CashflowTable(
                  items: _items,
                  onIncludeChanged: _toggleInclude,
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: const Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 56),
            SizedBox(height: 12),
            Text('هنوز ردیفی ثبت نشده است.'),
            SizedBox(height: 6),
            Text('از دکمه افزودن، اولین منبع یا مصرف را وارد کن.'),
          ],
        ),
      ),
    );
  }
}

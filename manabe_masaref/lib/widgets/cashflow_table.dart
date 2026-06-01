import 'package:flutter/material.dart';
import '../models/cashflow_item.dart';
import '../utils/formatters.dart';

class CashflowTable extends StatelessWidget {
  final List<CashflowItem> items;
  final void Function(CashflowItem item, bool include) onIncludeChanged;

  const CashflowTable({
    super.key,
    required this.items,
    required this.onIncludeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('✓')),
            DataColumn(label: Text('تاریخ')),
            DataColumn(label: Text('شرح')),
            DataColumn(label: Text('مبلغ')),
            DataColumn(label: Text('نوع')),
            DataColumn(label: Text('منبع')),
            DataColumn(label: Text('مانده')),
          ],
          rows: items.map((item) {
            final isPositive = item.type == CashflowType.positive;
            return DataRow(
              cells: [
                DataCell(Checkbox(
                  value: item.includeInBalance,
                  onChanged: (v) => onIncludeChanged(item, v ?? false),
                )),
                DataCell(Text(item.jalaliDate)),
                DataCell(SizedBox(width: 160, child: Text(item.description, overflow: TextOverflow.ellipsis))),
                DataCell(Text(formatMoney(item.amount))),
                DataCell(Text(isPositive ? '+' : '-')),
                DataCell(Text(item.source == CashflowSource.excel ? 'Excel' : 'Manual')),
                DataCell(Text(formatMoney(item.balanceAfter))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/cashflow_item.dart';
import '../utils/formatters.dart';

class CashflowCard extends StatelessWidget {
  final CashflowItem item;
  final ValueChanged<bool> onIncludeChanged;
  final VoidCallback onDelete;

  const CashflowCard({
    super.key,
    required this.item,
    required this.onIncludeChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = item.type == CashflowType.positive;
    final color = isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 78,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.jalaliDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(
                    '${isPositive ? '+' : '-'}${formatMoney(item.amount)}',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'مانده: ${formatMoney(item.balanceAfter)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Switch(
                  value: item.includeInBalance,
                  onChanged: onIncludeChanged,
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

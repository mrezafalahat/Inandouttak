import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class SummaryCard extends StatelessWidget {
  final int totalPositive;
  final int totalNegative;
  final int finalBalance;

  const SummaryCard({
    super.key,
    required this.totalPositive,
    required this.totalNegative,
    required this.finalBalance,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = finalBalance >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF14532D), const Color(0xFF16A34A)]
              : [const Color(0xFF7F1D1D), const Color(0xFFDC2626)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مانده کل', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            '${isPositive ? '+' : ''}${formatMoney(finalBalance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _mini('دریافتی‌ها', '+${formatMoney(totalPositive)}')),
              const SizedBox(width: 12),
              Expanded(child: _mini('پرداختی‌ها', '-${formatMoney(totalNegative)}')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mini(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

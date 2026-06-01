import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

String formatMoney(int value) {
  return NumberFormat.decimalPattern('en_US').format(value);
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');

    final formatted =
        NumberFormat.decimalPattern('en_US').format(int.parse(digits));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

String todayJalali() {
  final j = Jalali.now();
  return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
}

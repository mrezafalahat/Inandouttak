import 'package:intl/intl.dart';

final NumberFormat _moneyFormat = NumberFormat.decimalPattern('en_US');

String formatMoney(int value) => _moneyFormat.format(value);

int parseMoney(String raw) {
  var s = raw.trim();
  s = s.replaceAll(',', '').replaceAll('٬', '').replaceAll('،', '');
  s = s.replaceAll(RegExp(r'[^0-9\-]'), '');
  if (s.isEmpty || s == '-') return 0;
  return int.tryParse(s) ?? 0;
}

String normalizePersianDigits(String input) {
  const fa = '۰۱۲۳۴۵۶۷۸۹';
  const ar = '٠١٢٣٤٥٦٧٨٩';
  var out = input;
  for (var i = 0; i < 10; i++) {
    out = out.replaceAll(fa[i], '$i').replaceAll(ar[i], '$i');
  }
  return out;
}

String normalizeDate(String raw) {
  var s = normalizePersianDigits(raw.trim());
  s = s.replaceAll('-', '/').replaceAll('.', '/');
  final parts = s.split('/').where((e) => e.trim().isNotEmpty).toList();
  if (parts.length >= 3) {
    final y = parts[0].padLeft(4, '0');
    final m = parts[1].padLeft(2, '0');
    final d = parts[2].padLeft(2, '0');
    return '$y/$m/$d';
  }
  return s;
}

String addDaysToJalaliText(String date, int days) {
  // نسخه ساده برای پیش‌بینی اولیه: اگر تبدیل دقیق لازم شد بعداً تقویم کامل اضافه می‌کنیم.
  // فعلاً اگر تاریخ قابل تبدیل نبود همان تاریخ را برمی‌گرداند.
  return date;
}

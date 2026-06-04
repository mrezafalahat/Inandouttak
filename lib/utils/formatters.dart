import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

final NumberFormat _moneyFormat = NumberFormat.decimalPattern('en_US');

String formatMoney(num value) => _moneyFormat.format(value.round());

int parseMoney(String raw) {
  var s = normalizePersianDigits(raw.trim());
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

String addDaysToJalaliText(String date, int days) => AppFormatters.addJalaliDays(date, days);

class AppFormatters {
  static String money(num value) => formatMoney(value);
  static int parseMoney(String raw) => parseMoneyTop(raw);
  static String normalizeDate(String raw) => normalizeDateTop(raw);
  static String normalizeDigits(String input) => normalizePersianDigits(input);
  static String normalizeText(String input) => normalizePersianDigits(input.trim()).replaceAll(RegExp(r'\s+'), ' ');

  static String todayJalali() {
    final j = Jalali.now();
    return '${j.year.toString().padLeft(4, '0')}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  static String addJalaliDays(String date, int days) {
    final normalized = normalizeDate(date);
    final parts = normalized.split('/');
    if (parts.length < 3) return normalized;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return normalized;
    try {
      final g = Jalali(y, m, d).toGregorian().dateTime.add(Duration(days: days));
      final j = Gregorian.fromDateTime(g).toJalali();
      return '${j.year.toString().padLeft(4, '0')}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return normalized;
    }
  }
}

int parseMoneyTop(String raw) => parseMoney(raw);
String normalizeDateTop(String raw) => normalizeDate(raw);

import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

class AppFormatters {
  static final NumberFormat _money = NumberFormat('#,##0', 'en_US');

  static String money(num value) => _money.format(value.round()).replaceAll(',', '٬');

  static double parseMoney(String input) {
    var s = input
        .replaceAll('٬', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('ریال', '')
        .trim();
    s = normalizeDigits(s);
    if (s.isEmpty || s == '-') return 0;
    return double.tryParse(s) ?? 0;
  }

  static String normalizeDigits(String input) {
    const fa = '۰۱۲۳۴۵۶۷۸۹';
    const ar = '٠١٢٣٤٥٦٧٨٩';
    var out = input;
    for (var i = 0; i < 10; i++) {
      out = out.replaceAll(fa[i], '$i').replaceAll(ar[i], '$i');
    }
    return out;
  }

  static String normalizeDate(String input) {
    var s = normalizeDigits(input).trim();
    if (s.isEmpty) return '';
    s = s.replaceAll('-', '/').replaceAll('.', '/');
    final match = RegExp(r'(\d{2,4})/(\d{1,2})/(\d{1,2})').firstMatch(s);
    if (match == null) return s;
    var y = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final d = int.parse(match.group(3)!);
    if (y < 100) y += 1400;
    return '${y.toString().padLeft(4, '0')}/${m.toString().padLeft(2, '0')}/${d.toString().padLeft(2, '0')}';
  }

  static String todayJalali() {
    final j = Jalali.now();
    return '${j.year.toString().padLeft(4, '0')}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
  }

  static String addJalaliDays(String date, int days) {
    final p = normalizeDate(date).split('/');
    if (p.length != 3) return date;
    try {
      final j = Jalali(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
      final next = j.addDays(days);
      return '${next.year.toString().padLeft(4, '0')}/${next.month.toString().padLeft(2, '0')}/${next.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return date;
    }
  }

  static String normalizeText(String input) => input
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

import 'package:intl/intl.dart';
import 'package:shamsi_date/shamsi_date.dart';

String formatMoney(int value) {
  final formatter = NumberFormat.decimalPattern('en_US');
  return formatter.format(value);
}

String todayJalali() {
  final j = Jalali.now();
  return '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
}

String jalaliToGregorianIso(String jalaliDate) {
  final clean = jalaliDate.replaceAll('-', '/');
  final parts = clean.split('/');
  if (parts.length != 3) return DateTime.now().toIso8601String().substring(0, 10);

  final jy = int.parse(parts[0]);
  final jm = int.parse(parts[1]);
  final jd = int.parse(parts[2]);
  final g = Jalali(jy, jm, jd).toGregorian();
  return '${g.year.toString().padLeft(4, '0')}-${g.month.toString().padLeft(2, '0')}-${g.day.toString().padLeft(2, '0')}';
}

String normalizeText(String value) {
  return value.trim().replaceAll(RegExp(r'\s+'), ' ');
}

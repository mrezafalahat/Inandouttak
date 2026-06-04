import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:excel/excel.dart';
import '../models/financial_item.dart';
import 'formatters.dart';

class ExcelImporter {
  static Future<List<FinancialItem>> parseTakExcel({
    required String path,
    required String kind,
    required String sourceName,
    int receivableDelayDays = 3,
  }) async {
    final bytes = await File(path).readAsBytes();
    final book = Excel.decodeBytes(bytes);
    final List<List<String>> rows = [];
    for (final name in book.tables.keys) {
      final sheet = book.tables[name];
      if (sheet == null) continue;
      for (final row in sheet.rows) {
        rows.add(row.map((c) => c?.value?.toString().trim() ?? '').toList());
      }
      if (rows.isNotEmpty) break;
    }
    if (rows.isEmpty) return [];

    final headerIndex = _findHeaderIndex(rows);
    if (headerIndex < 0) throw Exception('ردیف عنوان ستون‌ها پیدا نشد.');
    final headers = rows[headerIndex].map(AppFormatters.normalizeText).toList();
    final amountCol = _findColumn(headers, ['مبلغ', 'مبلغ چک']);
    final docCol = _findColumn(headers, ['شماره', 'شماره سند', 'شماره چک']);
    final descCol = _findColumn(headers, ['شرح', 'توضیحات']);
    final checkDateCol = _findColumn(headers, ['تاریخ چک', 'سررسید']);
    final statusCol = _findColumn(headers, ['وضعیت']);
    final effectCol = kind == 'receivable'
        ? _findColumn(headers, ['تاریخ وصول یا واگذاری چک', 'تاریخ وصول', 'تاریخ واگذاری'])
        : -1;
    final bankCol = _findColumn(headers, ['نام بانک', 'بانک']);

    if (amountCol < 0 || checkDateCol < 0) {
      throw Exception('ستون مبلغ یا تاریخ چک در فایل پیدا نشد.');
    }

    final now = DateTime.now().toIso8601String();
    final List<FinancialItem> items = [];
    for (var i = headerIndex + 1; i < rows.length; i++) {
      final row = rows[i];
      String v(int col) => col >= 0 && col < row.length ? row[col].trim() : '';
      final rawAmount = v(amountCol);
      final amountAbs = AppFormatters.parseMoney(rawAmount).abs();
      if (amountAbs == 0) continue;
      final docDate = AppFormatters.normalizeDate(v(checkDateCol));
      if (docDate.isEmpty) continue;
      var effectDate = effectCol >= 0 ? AppFormatters.normalizeDate(v(effectCol)) : '';
      if (effectDate.isEmpty || effectDate == '0000/00/00') {
        effectDate = kind == 'receivable' ? AppFormatters.addJalaliDays(docDate, receivableDelayDays) : docDate;
      }
      final amount = kind == 'receivable' ? amountAbs : -amountAbs;
      final docNo = AppFormatters.normalizeDigits(v(docCol));
      final desc = AppFormatters.normalizeText(v(descCol));
      final status = AppFormatters.normalizeText(v(statusCol));
      final bank = AppFormatters.normalizeText(v(bankCol));
      final keyText = '$kind|$docNo|$docDate|${amountAbs.round()}|$desc|$bank';
      final key = sha1.convert(keyText.codeUnits).toString();
      items.add(FinancialItem(
        documentDate: docDate,
        cashEffectDate: effectDate,
        documentNumber: docNo.isEmpty ? 'row-${i + 1}' : docNo,
        description: desc.isEmpty ? sourceName : desc,
        amount: amount.toDouble(),
        kind: kind,
        sourceType: 'excel',
        sourceName: sourceName,
        status: status.isEmpty ? 'باز' : status,
        includeInForecast: 1,
        isActive: 1,
        uniqueKey: key,
        createdAt: now,
        updatedAt: now,
      ));
    }
    return items;
  }

  static int _findHeaderIndex(List<List<String>> rows) {
    for (var i = 0; i < rows.length && i < 20; i++) {
      final text = rows[i].join(' ');
      if (text.contains('مبلغ') && (text.contains('تاریخ') || text.contains('شرح'))) return i;
    }
    return -1;
  }

  static int _findColumn(List<String> headers, List<String> candidates) {
    for (final c in candidates) {
      final idx = headers.indexWhere((h) => h.contains(c));
      if (idx >= 0) return idx;
    }
    return -1;
  }
}

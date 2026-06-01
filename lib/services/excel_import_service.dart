import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import '../models/cash_item.dart';
import '../utils/formatters.dart';

class ExcelImportResult {
  final List<CashItem> items;
  final String fileName;
  const ExcelImportResult(this.items, this.fileName);
}

class ExcelImportService {
  Future<ExcelImportResult?> pickAndParse({required bool receivable}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
      withData: false,
    );
    if (result == null || result.files.single.path == null) return null;
    final file = File(result.files.single.path!);
    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final tableName = excel.tables.keys.first;
    final sheet = excel.tables[tableName];
    if (sheet == null) return ExcelImportResult(const [], result.files.single.name);

    final rows = sheet.rows.map((r) => r.map((c) => c?.value?.toString().trim() ?? '').toList()).toList();
    if (rows.isEmpty) return ExcelImportResult(const [], result.files.single.name);

    final headerIndex = _findHeaderRow(rows);
    final headers = rows[headerIndex].map((e) => e.trim()).toList();
    final idx = _mapColumns(headers);
    final items = <CashItem>[];

    for (var i = headerIndex + 1; i < rows.length; i++) {
      final row = rows[i];
      String cell(String key) {
        final index = idx[key];
        if (index == null || index < 0 || index >= row.length) return '';
        return row[index].trim();
      }

      final amountAbs = parseMoney(cell('amount')).abs();
      if (amountAbs == 0) continue;
      final docNo = cell('docNo');
      final date = normalizeDate(cell('date'));
      final effectDate = normalizeDate(cell('effectDate').isNotEmpty ? cell('effectDate') : cell('date'));
      final desc = cell('description');
      final status = cell('status');
      final party = cell('party');
      final signedAmount = receivable ? amountAbs : -amountAbs;
      final type = receivable ? 'receivable' : 'payable';
      final keyRaw = '$type|$docNo|$date|$amountAbs|$party|$desc';
      final stableKey = sha1.convert(utf8.encode(keyRaw)).toString();

      items.add(CashItem(
        stableKey: stableKey,
        date: date,
        effectDate: effectDate,
        docNo: docNo,
        description: desc.isEmpty ? party : desc,
        amount: signedAmount,
        itemType: type,
        sourceType: 'excel',
        sourceName: result.files.single.name,
        status: status,
        includeInForecast: true,
        active: true,
      ));
    }
    return ExcelImportResult(items, result.files.single.name);
  }

  int _findHeaderRow(List<List<String>> rows) {
    for (var i = 0; i < rows.length && i < 20; i++) {
      final line = rows[i].join(' ');
      if (line.contains('مبلغ') && (line.contains('تاریخ') || line.contains('شرح') || line.contains('شماره'))) return i;
    }
    return 0;
  }

  Map<String, int> _mapColumns(List<String> headers) {
    int find(List<String> words) {
      for (var i = 0; i < headers.length; i++) {
        final h = headers[i].replaceAll('ي', 'ی').replaceAll('ك', 'ک');
        if (words.any((w) => h.contains(w))) return i;
      }
      return -1;
    }

    return {
      'docNo': find(['شماره', 'سند', 'چک']),
      'amount': find(['مبلغ']),
      'date': find(['تاریخ چک', 'سررسید', 'تاریخ']),
      'effectDate': find(['تاریخ وصول', 'واگذاری', 'اثر']),
      'description': find(['شرح', 'توضیح']),
      'status': find(['وضعیت']),
      'party': find(['پرداخت', 'دریافت', 'طرف', 'نام']),
    };
  }
}

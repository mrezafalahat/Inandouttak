import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../utils/excel_importer.dart';

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  String kind = 'receivable';
  bool loading = false;
  String message = 'فایل اکسل دریافتنی یا پرداختنی را انتخاب کن. فایل جدید با لیست قبلی تطبیق داده می‌شود.';

  Future<void> pickAndImport() async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xls', 'xlsx']);
    if (picked == null || picked.files.single.path == null) return;
    setState(() {
      loading = true;
      message = 'در حال بررسی فایل...';
    });
    try {
      final path = picked.files.single.path!;
      final items = await ExcelImporter.parseTakExcel(
        path: path,
        kind: kind,
        sourceName: picked.files.single.name,
      );
      final result = await DatabaseService.instance.syncExcelItems(items, kind);
      setState(() {
        message = '''نتیجه بررسی فایل:
کل ردیف‌های خوانده‌شده: ${result.total}
چک‌های جدید: ${result.inserted}
چک‌های باقی‌مانده از قبل: ${result.preserved}
خارج‌شده از پیش‌بینی چون در فایل جدید نبودند: ${result.removed}

تیک‌های قبلی روی اسنادی که هنوز در فایل هستند حفظ شد.''';
      });
    } catch (e) {
      setState(() => message = 'خطا در خواندن فایل: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('ورود و تطبیق اکسل', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: kind,
                  decoration: const InputDecoration(labelText: 'نوع فایل'),
                  items: const [
                    DropdownMenuItem(value: 'receivable', child: Text('اسناد دریافتنی / ورودی')),
                    DropdownMenuItem(value: 'payable', child: Text('اسناد پرداختنی / خروجی')),
                  ],
                  onChanged: loading ? null : (v) => setState(() => kind = v ?? kind),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: loading ? null : pickAndImport,
                  icon: const Icon(Icons.upload_file),
                  label: Text(loading ? 'در حال بررسی...' : 'انتخاب فایل و Sync'),
                ),
                const SizedBox(height: 16),
                Text(message),
              ]),
            ),
          ),
        ],
      );
}

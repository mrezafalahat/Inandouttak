import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _fileName = result.files.first.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ورود اکسل')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.upload_file, size: 70),
                  const SizedBox(height: 16),
                  const Text(
                    'این صفحه اسکلت اولیه ورود اکسل است. در مرحله بعد انتخاب ستون تاریخ، شرح و مبلغ به آن اضافه می‌شود.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.file_open),
                    label: const Text('انتخاب فایل اکسل'),
                  ),
                  if (_fileName != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'فایل انتخاب‌شده: $_fileName',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

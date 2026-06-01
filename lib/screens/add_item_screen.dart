import 'package:flutter/material.dart';
import '../models/cashflow_item.dart';
import '../services/database_service.dart';
import '../utils/formatters.dart';
import '../utils/unique_key_builder.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController(text: todayJalali());
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  CashflowType _type = CashflowType.positive;
  bool _include = true;

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = int.parse(_amountController.text.replaceAll(',', '').trim());
    final jalaliDate = _dateController.text.trim();
    final description = _descriptionController.text.trim();

    final item = CashflowItem(
      jalaliDate: jalaliDate,
      gregorianDate: jalaliToGregorianIso(jalaliDate),
      description: description,
      amount: amount,
      type: _type,
      includeInBalance: _include,
      source: CashflowSource.manual,
      uniqueKey: buildUniqueKey(
        jalaliDate: jalaliDate,
        description: description,
        amount: amount,
      ),
    );

    await DatabaseService.instance.insertItem(item);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('افزودن ردیف')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'تاریخ شمسی',
                        hintText: '1405/03/01',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'تاریخ را وارد کن' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'شرح',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'شرح را وارد کن' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'مبلغ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final value = v?.replaceAll(',', '').trim() ?? '';
                        if (value.isEmpty) return 'مبلغ را وارد کن';
                        if (int.tryParse(value) == null) return 'مبلغ باید عدد باشد';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<CashflowType>(
                      segments: const [
                        ButtonSegment(
                          value: CashflowType.positive,
                          label: Text('مثبت'),
                          icon: Icon(Icons.arrow_downward),
                        ),
                        ButtonSegment(
                          value: CashflowType.negative,
                          label: Text('منفی'),
                          icon: Icon(Icons.arrow_upward),
                        ),
                      ],
                      selected: {_type},
                      onSelectionChanged: (s) => setState(() => _type = s.first),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: _include,
                      title: const Text('در محاسبات باشد'),
                      onChanged: (v) => setState(() => _include = v),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save),
                        label: const Text('ذخیره'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

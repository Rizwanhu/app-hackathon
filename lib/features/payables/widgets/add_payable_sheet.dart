import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/models/finance_models.dart';

class AddPayableSheet extends StatefulWidget {
  const AddPayableSheet({super.key});

  @override
  State<AddPayableSheet> createState() => _AddPayableSheetState();
}

class _AddPayableSheetState extends State<AddPayableSheet> {
  final _vendor = TextEditingController();
  final _amount = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _vendor.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pickDue() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _due,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 3),
    );
    if (picked != null) setState(() => _due = picked);
  }

  void _save() {
    final raw = _amount.text.trim().replaceAll(',', '');
    final value = double.tryParse(raw);
    if (_vendor.text.trim().isEmpty || value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter vendor name and a valid amount.')),
      );
      return;
    }
    final p = Payable(
      id: 'p_${DateTime.now().microsecondsSinceEpoch}',
      vendorName: _vendor.text.trim(),
      amount: value,
      dueDate: _due,
      reminderEnabled: false,
      isPaid: false,
    );
    Navigator.of(context).pop(p);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  'Add payable',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _vendor,
              decoration: const InputDecoration(
                labelText: 'Vendor / supplier',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
              decoration: const InputDecoration(
                labelText: 'Amount owed (PKR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _pickDue,
              icon: const Icon(Icons.event),
              label: Text('Due date: ${_due.toString().split(' ').first}'),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}

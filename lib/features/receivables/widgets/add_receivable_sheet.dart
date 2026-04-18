import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/mock/mock_store.dart';

class AddReceivableSheet extends StatefulWidget {
  const AddReceivableSheet({super.key});

  @override
  State<AddReceivableSheet> createState() => _AddReceivableSheetState();
}

class _AddReceivableSheetState extends State<AddReceivableSheet> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _amount = TextEditingController();
  DateTime _due = DateTime.now().add(const Duration(days: 7));

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
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
    if (_name.text.trim().isEmpty || value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter name and a valid amount.')),
      );
      return;
    }
    final r = Receivable(
      id: 'r_${DateTime.now().microsecondsSinceEpoch}',
      contactName: _name.text.trim(),
      phoneNumber: _phone.text.trim().replaceAll(RegExp(r'[^\d]'), ''),
      amount: value,
      dueDate: _due,
      status: ReceivableStatus.pending,
      riskScore: 55,
      followUps: const [],
    );
    Navigator.of(context).pop(r);
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
                  'Add receivable',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Customer name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'WhatsApp number',
                hintText: '92300xxxxxxx',
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

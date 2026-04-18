import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/models/finance_models.dart';

class AddTransactionSheet extends StatefulWidget {
  final CashTransaction? existing;
  final TransactionType? initialType;

  const AddTransactionSheet({super.key, this.existing, this.initialType});

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _amount = TextEditingController();
  final _contact = TextEditingController();
  final _note = TextEditingController();

  TransactionType _type = TransactionType.income;
  String _category = 'Sales';
  DateTime _date = DateTime.now();
  bool _receipt = false;

  static const _incomeCats = ['Sales', 'Service', 'Other'];
  static const _expenseCats = ['Stock', 'Rent', 'Salaries', 'Utilities', 'Marketing', 'Payable', 'Other'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _amount.text = e.amount.toStringAsFixed(0);
      _contact.text = e.contactName;
      _note.text = e.note;
      _type = e.type;
      _category = e.category;
      _date = e.date;
      _receipt = e.hasReceipt;
    } else {
      if (widget.initialType != null) {
        _type = widget.initialType!;
      }
      _category = _type == TransactionType.income ? _incomeCats.first : _expenseCats.first;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    _contact.dispose();
    _note.dispose();
    super.dispose();
  }

  List<String> get _cats => _type == TransactionType.income ? _incomeCats : _expenseCats;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final raw = _amount.text.trim().replaceAll(',', '');
    final value = double.tryParse(raw);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount.')),
      );
      return;
    }

    final id = widget.existing?.id ?? 'tx_${DateTime.now().microsecondsSinceEpoch}';
    final tx = CashTransaction(
      id: id,
      type: _type,
      amount: value,
      category: _category,
      contactName: _contact.text.trim(),
      date: _date,
      note: _note.text.trim(),
      hasReceipt: _receipt,
    );
    Navigator.of(context).pop(tx);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, bottom: bottom + AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Text(
                  widget.existing == null ? 'Add transaction' : 'Edit transaction',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
              decoration: const InputDecoration(
                labelText: 'Amount (PKR)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(value: TransactionType.income, label: Text('Sale / Income')),
                ButtonSegment(value: TransactionType.expense, label: Text('Expense')),
              ],
              selected: {_type},
              onSelectionChanged: (s) {
                setState(() {
                  _type = s.first;
                  _category = _cats.first;
                });
              },
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _cats
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _cats.first),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _contact,
              decoration: const InputDecoration(
                labelText: 'Contact / vendor / customer',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_month),
              label: Text('Date: ${_date.toLocal().toString().split(' ').first}'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _note,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SwitchListTile(
              value: _receipt,
              onChanged: (v) => setState(() {
                _receipt = v;
                if (v) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receipt photo: simulated for demo (no upload).')),
                  );
                }
              }),
              title: const Text('Attach receipt (demo)'),
              secondary: const Icon(Icons.photo_camera_outlined),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _save,
              child: Text(widget.existing == null ? 'Save' : 'Update'),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

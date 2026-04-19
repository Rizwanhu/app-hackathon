import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final raw = _amount.text.trim().replaceAll(',', '');
    final value = double.tryParse(raw);
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount.'),
          backgroundColor: AppColors.expenseRed,
        ),
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
    final isIncome = _type == TransactionType.income;
    final activeColor = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.existing == null ? Icons.add_circle_outline_rounded : Icons.edit_rounded, 
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.existing == null ? 'Add Transaction' : 'Edit Transaction',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // --- TYPE SELECTOR ---
            SegmentedButton<TransactionType>(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return activeColor.withOpacity(0.15);
                  }
                  return AppColors.surface;
                }),
                foregroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) return activeColor;
                  return AppColors.textSecondary;
                }),
                side: MaterialStateProperty.all(const BorderSide(color: AppColors.borderLight)),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: TransactionType.income, 
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Sale / Income', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                ButtonSegment(
                  value: TransactionType.expense, 
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Expense', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) {
                setState(() {
                  _type = s.first;
                  _category = _cats.first;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // --- AMOUNT ---
            TextField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: activeColor),
              decoration: InputDecoration(
                labelText: 'Amount (PKR)',
                prefixIcon: Icon(Icons.payments_rounded, color: activeColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: activeColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // --- CATEGORY & CONTACT ---
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: AppColors.primary),
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: _cats.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
                    onChanged: (v) => setState(() => _category = v ?? _cats.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            TextField(
              controller: _contact,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: isIncome ? 'Customer / Source (Optional)' : 'Vendor / Payee (Optional)',
                prefixIcon: const Icon(Icons.person_outline_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // --- DATE PICKER ---
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_rounded, color: AppColors.textSecondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Transaction Date', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text(
                            DateFormat.yMMMd().format(_date),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit_calendar_rounded, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // --- NOTE ---
            TextField(
              controller: _note,
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Add a Note',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.notes_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // --- RECEIPT TOGGLE ---
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                value: _receipt,
                onChanged: (v) => setState(() {
                  _receipt = v;
                  if (v) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receipt simulated for demo.'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }),
                activeColor: AppColors.primary,
                title: const Text('Attach Receipt', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Simulated for demo', style: TextStyle(fontSize: 12)),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _receipt ? AppColors.primary.withOpacity(0.1) : AppColors.surfaceSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: _receipt ? AppColors.primary : AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // --- SAVE BUTTON ---
            FilledButton.icon(
              onPressed: _save,
              icon: Icon(widget.existing == null ? Icons.check_circle_outline_rounded : Icons.save_as_rounded),
              label: Text(widget.existing == null ? 'Save Transaction' : 'Update Transaction'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: activeColor, // Dynamic color (Green for income, Red for expense)
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
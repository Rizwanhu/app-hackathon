import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/mock/mock_store.dart';

class PayableTile extends StatelessWidget {
  final Payable p;
  final VoidCallback onMarkPaid;
  final ValueChanged<bool> onReminderChanged;

  const PayableTile({
    super.key,
    required this.p,
    required this.onMarkPaid,
    required this.onReminderChanged,
  });

  Color _urgencyColor() {
    final d = p.daysToDue;
    if (d <= 0) return AppColors.expenseRed;
    if (d <= 7) return AppColors.warningAmber;
    return AppColors.incomeGreen;
  }

  String _urgencyLabel() {
    final d = p.daysToDue;
    if (d < 0) return 'Overdue ${-d}d';
    if (d == 0) return 'Due today';
    if (d <= 7) return 'Due in $d days';
    return 'Later';
  }

  @override
  Widget build(BuildContext context) {
    final c = _urgencyColor();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.vendorName,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _urgencyLabel(),
                    style: TextStyle(color: c, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              p.amount.toPkr(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              'Due ${DateFormat.yMMMd().format(p.dueDate)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMarkPaid,
                    child: const Text('Mark paid'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Switch(
                  value: p.reminderEnabled,
                  onChanged: onReminderChanged,
                ),
              ],
            ),
            Text(
              'Local reminder (demo)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

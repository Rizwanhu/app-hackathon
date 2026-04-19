import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/models/finance_models.dart';

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
    if (d <= 0) return AppColors.expenseRed; // Overdue or Due Today
    if (d <= 7) return AppColors.warningAmber; // Due soon
    return AppColors.incomeGreen; // Later
  }

  String _urgencyLabel() {
    final d = p.daysToDue;
    if (d < 0) return 'Overdue ${-d}d';
    if (d == 0) return 'Due Today';
    if (d <= 7) return 'Due in $d days';
    return 'Later';
  }

  IconData _urgencyIcon() {
    final d = p.daysToDue;
    if (d <= 0) return Icons.error_outline_rounded;
    if (d <= 7) return Icons.schedule_rounded;
    return Icons.check_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final c = _urgencyColor();
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.3)), // Border matches urgency
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.05), // Subtle glow matching urgency
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    p.vendorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_urgencyIcon(), size: 12, color: c),
                      const SizedBox(width: 4),
                      Text(
                        _urgencyLabel(),
                        style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // --- AMOUNTS & DATES ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Amount to Pay', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      p.amount.toPkr(),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Due Date', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.yMMMd().format(p.dueDate),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: AppColors.borderLight, height: 1),
            ),

            // --- ACTIONS ---
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Mark as Paid'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.incomeGreen,
                      side: const BorderSide(color: AppColors.incomeGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Row(
                  children: [
                    const Icon(Icons.notifications_active_rounded, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Transform.scale(
                      scale: 0.85, // Switch ko thora neat rakhne ke liye
                      child: Switch(
                        value: p.reminderEnabled,
                        onChanged: onReminderChanged,
                        activeColor: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
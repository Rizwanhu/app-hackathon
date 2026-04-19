import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/models/finance_models.dart';
import 'risk_badge.dart';

class ReceivableCard extends StatelessWidget {
  final Receivable r;
  final VoidCallback onOpen;

  const ReceivableCard({super.key, required this.r, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Modern Avatar for Contact
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        r.contactName.isNotEmpty ? r.contactName.substring(0, 1).toUpperCase() : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        r.contactName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                      ),
                    ),
                    RiskBadge(riskScore: r.riskScore),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Text(
                      r.amount.toPkr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: -0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    _StatusChip(status: r.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(
                      r.isOverdue ? Icons.timer_off_rounded : Icons.calendar_today_rounded,
                      size: 14,
                      color: r.isOverdue ? AppColors.expenseRed : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      r.isOverdue
                          ? '${r.daysPastDue} days overdue'
                          : r.daysPastDue < 0
                              ? 'Due in ${-r.daysPastDue} days'
                              : 'Due today',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: r.isOverdue ? AppColors.expenseRed : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ReceivableStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    // Smart Color Coding for Status
    switch (status) {
      case ReceivableStatus.pending:
        bgColor = AppColors.warningAmber.withOpacity(0.15);
        textColor = AppColors.warningAmber;
        label = 'Pending';
        break;
      case ReceivableStatus.promised:
        bgColor = AppColors.infoBlue.withOpacity(0.15);
        textColor = AppColors.infoBlue;
        label = 'Promised';
        break;
      case ReceivableStatus.partial:
        bgColor = AppColors.primary.withOpacity(0.15);
        textColor = AppColors.primary;
        label = 'Partial';
        break;
      case ReceivableStatus.paid:
        bgColor = AppColors.incomeGreen.withOpacity(0.15);
        textColor = AppColors.incomeGreen;
        label = 'Paid';
        break;
      case ReceivableStatus.disputed:
        bgColor = AppColors.expenseRed.withOpacity(0.15);
        textColor = AppColors.expenseRed;
        label = 'Disputed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
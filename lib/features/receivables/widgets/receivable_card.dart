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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      r.contactName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  RiskBadge(riskScore: r.riskScore),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    r.amount.toPkr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  _StatusChip(status: r.status),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
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
    final label = switch (status) {
      ReceivableStatus.pending => 'Pending',
      ReceivableStatus.promised => 'Promised',
      ReceivableStatus.partial => 'Partial',
      ReceivableStatus.paid => 'Paid',
      ReceivableStatus.disputed => 'Disputed',
    };
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

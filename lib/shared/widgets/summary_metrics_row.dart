import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/currency_extension.dart';

class SummaryMetricsRow extends StatelessWidget {
  final double totalSales;
  final double totalExpenses;
  final double receivables;
  final double payables;

  const SummaryMetricsRow({
    super.key,
    required this.totalSales,
    required this.totalExpenses,
    required this.receivables,
    required this.payables,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - AppSpacing.sm) / 2;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _MetricTile(
              width: w,
              label: 'Total sales',
              value: totalSales.toPkr(),
              color: AppColors.incomeGreen,
              icon: Icons.trending_up,
            ),
            _MetricTile(
              width: w,
              label: 'Total expenses',
              value: totalExpenses.toPkr(),
              color: AppColors.expenseRed,
              icon: Icons.trending_down,
            ),
            _MetricTile(
              width: w,
              label: 'Receivables',
              value: receivables.toPkr(),
              color: AppColors.infoBlue,
              icon: Icons.people_alt,
            ),
            _MetricTile(
              width: w,
              label: 'Payables',
              value: payables.toPkr(),
              color: AppColors.warningAmber,
              icon: Icons.payments,
            ),
          ],
        );
      },
    );
  }
}

class _MetricTile extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MetricTile({
    required this.width,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.borderLight),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

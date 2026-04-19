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
        // Hum spacing ko thora behter manage kar rahe hain
        final gap = AppSpacing.md;
        final w = (c.maxWidth - gap) / 2;
        
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            _MetricTile(
              width: w,
              label: 'Total Sales',
              value: totalSales.toPkr(),
              color: AppColors.incomeGreen,
              icon: Icons.trending_up_rounded,
            ),
            _MetricTile(
              width: w,
              label: 'Total Expenses',
              value: totalExpenses.toPkr(),
              color: AppColors.expenseRed,
              icon: Icons.trending_down_rounded,
            ),
            _MetricTile(
              width: w,
              label: 'Receivables',
              value: receivables.toPkr(),
              color: AppColors.infoBlue,
              icon: Icons.account_balance_wallet_rounded,
            ),
            _MetricTile(
              width: w,
              label: 'Payables',
              value: payables.toPkr(),
              color: AppColors.warningAmber,
              icon: Icons.outbond_rounded,
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
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
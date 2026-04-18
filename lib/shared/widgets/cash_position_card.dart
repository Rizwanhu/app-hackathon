import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/currency_extension.dart';

class CashPositionCard extends StatelessWidget {
  final double netCash;
  final double trendPctVsLastMonth;
  final String currencyLabel;

  const CashPositionCard({
    super.key,
    required this.netCash,
    required this.trendPctVsLastMonth,
    this.currencyLabel = 'PKR',
  });

  @override
  Widget build(BuildContext context) {
    final positive = netCash >= 0;
    final trendUp = trendPctVsLastMonth >= 0;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Net cash position',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: netCash),
              duration: const Duration(milliseconds: 650),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return Text(
                  value.toPkr(symbol: currencyLabel),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: positive ? AppColors.incomeGreen : AppColors.expenseRed,
                      ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  trendUp ? Icons.trending_up : Icons.trending_down,
                  size: 18,
                  color: trendUp ? AppColors.incomeGreen : AppColors.expenseRed,
                ),
                const SizedBox(width: 6),
                Text(
                  '${trendUp ? '+' : ''}${trendPctVsLastMonth.toStringAsFixed(1)}% vs last month',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

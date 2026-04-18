import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/currency_extension.dart';

class ForecastInlineCard extends StatelessWidget {
  final double day7;
  final double day14;
  final double day30;
  final bool riskNegative;

  const ForecastInlineCard({
    super.key,
    required this.day7,
    required this.day14,
    required this.day30,
    required this.riskNegative,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Cash forecast (demo)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _row('Day 7', day7),
            _row('Day 14', day14),
            _row('Day 30', day30),
            const SizedBox(height: AppSpacing.sm),
            if (riskNegative)
              const Text(
                'Risk: projected cash may dip negative — tighten collections.',
                style: TextStyle(color: AppColors.expenseRed, fontWeight: FontWeight.w700),
              )
            else
              const Text(
                'Outlook: stable with current trends.',
                style: TextStyle(color: AppColors.incomeGreen, fontWeight: FontWeight.w700),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            v.toPkr(),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

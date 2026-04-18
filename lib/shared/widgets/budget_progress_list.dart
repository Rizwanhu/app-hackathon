import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class BudgetProgressList extends StatelessWidget {
  final Map<String, double> categoryToBudget;
  final Map<String, double> categoryToSpent;

  const BudgetProgressList({
    super.key,
    required this.categoryToBudget,
    required this.categoryToSpent,
  });

  @override
  Widget build(BuildContext context) {
    final keys = categoryToBudget.keys.toList()..sort();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget vs actual',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...keys.map((k) {
          final cap = categoryToBudget[k] ?? 0;
          final spent = categoryToSpent[k] ?? 0;
          final ratio = cap <= 0 ? 0.0 : (spent / cap).clamp(0.0, 1.2);
          final warn = ratio >= 0.8;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        k,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${(ratio * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: warn ? AppColors.warningAmber : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 10,
                    backgroundColor: AppColors.surfaceSecondary,
                    color: warn ? AppColors.warningAmber : AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Spent ${spent.toStringAsFixed(0)} / budget ${cap.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

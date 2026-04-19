import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/extensions/currency_extension.dart';

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
    
    if (keys.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget vs Actual',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...keys.map((k) {
            final cap = categoryToBudget[k] ?? 0;
            final spent = categoryToSpent[k] ?? 0;
            final ratio = cap <= 0 ? 0.0 : (spent / cap);
            
            // Smart color logic based on spending threshold
            Color barColor = AppColors.primary;
            if (ratio >= 1.0) {
              barColor = AppColors.expenseRed; // Over budget (Red)
            } else if (ratio >= 0.8) {
              barColor = AppColors.warningAmber; // Near limit (Amber)
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          k,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        '${(ratio * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: barColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: ratio.clamp(0.0, 1.0), // UI clip, actual ratio shown in text
                      minHeight: 8, // Slim and modern progress bar
                      backgroundColor: AppColors.surfaceSecondary,
                      color: barColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ${spent.toPkr()}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Limit: ${cap.toPkr()}',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
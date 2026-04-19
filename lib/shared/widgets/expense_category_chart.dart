import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class ExpenseCategoryChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const ExpenseCategoryChart({super.key, required this.categoryTotals});

  static const _palette = [
    AppColors.primary,
    AppColors.warningAmber,
    AppColors.infoBlue,
    AppColors.expenseRed,
    AppColors.accent,
    AppColors.primaryLight,
  ];

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    if (entries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(Icons.pie_chart_outline_rounded, size: 48, color: AppColors.borderLight),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'No expenses recorded yet.',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    final total = entries.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) {
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
            'Expense Breakdown',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4, // Thora zyada space clean look ke liye
                    centerSpaceRadius: 35, // Doughnut style
                    sections: List.generate(entries.length, (i) {
                      final e = entries[i];
                      final pct = e.value / total;
                      return PieChartSectionData(
                        value: e.value,
                        title: '${(pct * 100).toStringAsFixed(0)}%',
                        color: _palette[i % _palette.length],
                        radius: 40,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: entries.take(5).map((e) {
                    final i = entries.indexOf(e);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _palette[i % _palette.length],
                              shape: BoxShape.circle, // Circle color indicator
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              e.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, 
                                  color: AppColors.textSecondary,
                                  fontSize: 13),
                            ),
                          ),
                          Text(
                            e.value.toStringAsFixed(0),
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, 
                                color: AppColors.textPrimary,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
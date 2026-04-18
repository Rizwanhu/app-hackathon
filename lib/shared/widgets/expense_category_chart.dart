import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class ExpenseCategoryChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const ExpenseCategoryChart({super.key, required this.categoryTotals});

  static const _palette = [
    AppColors.primary,
    AppColors.infoBlue,
    AppColors.warningAmber,
    AppColors.expenseRed,
    AppColors.incomeGreen,
    AppColors.accent,
  ];

  @override
  Widget build(BuildContext context) {
    final entries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (entries.isEmpty) {
      return Text(
        'No expense categories yet this month.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
      );
    }

    final total = entries.fold<double>(0, (s, e) => s + e.value);
    if (total <= 0) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expense breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            SizedBox(
              height: 160,
              width: 160,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 44,
                  sections: List.generate(entries.length, (i) {
                    final e = entries[i];
                    final pct = e.value / total;
                    return PieChartSectionData(
                      value: e.value,
                      title: '${(pct * 100).toStringAsFixed(0)}%',
                      color: _palette[i % _palette.length],
                      radius: 52,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: entries.take(6).map((e) {
                  final i = entries.indexOf(e);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: _palette[i % _palette.length],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.key,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          e.value.toStringAsFixed(0),
                          style: const TextStyle(fontWeight: FontWeight.w700),
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
    );
  }
}

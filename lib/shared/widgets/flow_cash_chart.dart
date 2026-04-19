import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/models/finance_models.dart';

class FlowCashChart extends StatelessWidget {
  final ChartPeriod period;
  final ValueChanged<ChartPeriod> onPeriodChanged;
  final List<({DateTime day, double inflow, double outflow})> bars;
  final ValueChanged<int> onBarSelected;

  const FlowCashChart({
    super.key,
    required this.period,
    required this.onPeriodChanged,
    required this.bars,
    required this.onBarSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = bars
        .map((b) => b.inflow > b.outflow ? b.inflow : b.outflow)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final capY = maxY <= 0 ? 1000.0 : maxY * 1.15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Cash flow',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            SegmentedButton<ChartPeriod>(
              segments: const [
                ButtonSegment(value: ChartPeriod.week, label: Text('Week')),
                ButtonSegment(value: ChartPeriod.month, label: Text('Month')),
                ButtonSegment(value: ChartPeriod.quarter, label: Text('3 Mo')),
              ],
              selected: {period},
              onSelectionChanged: (s) => onPeriodChanged(s.first),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: capY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: capY / 4,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: AppColors.borderLight,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, _) => Text(
                      _k(v),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _labelInterval(bars.length),
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= bars.length) return const SizedBox.shrink();
                      if (i % _labelEvery(bars.length) != 0) {
                        return const SizedBox.shrink();
                      }
                      final d = bars[i].day;
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          DateFormat.Md().format(d),
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(bars.length, (i) {
                final b = bars[i];
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: b.inflow,
                      width: 6,
                      color: AppColors.incomeGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    BarChartRodData(
                      toY: b.outflow,
                      width: 6,
                      color: AppColors.expenseRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                  barsSpace: 4,
                );
              }),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final b = bars[group.x.toInt()];
                    final label = rodIndex == 0 ? 'Inflow' : 'Outflow';
                    final val = rodIndex == 0 ? b.inflow : b.outflow;
                    return BarTooltipItem(
                      '$label\n${val.toStringAsFixed(0)}',
                      const TextStyle(color: Colors.white, fontSize: 12),
                    );
                  },
                ),
                touchCallback: (event, resp) {
                  if (!event.isInterestedForInteractions) return;
                  final spot = resp?.spot;
                  if (spot == null) return;
                  onBarSelected(spot.touchedBarGroupIndex);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _LegendDot(color: AppColors.incomeGreen, label: 'Inflows'),
            const SizedBox(width: AppSpacing.md),
            _LegendDot(color: AppColors.expenseRed, label: 'Outflows'),
          ],
        ),
      ],
    );
  }

  static String _k(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  static double _labelInterval(int n) {
    if (n <= 10) return 1;
    if (n <= 30) return 3;
    return 7;
  }

  static int _labelEvery(int n) {
    if (n <= 10) return 1;
    if (n <= 30) return 3;
    return 7;
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

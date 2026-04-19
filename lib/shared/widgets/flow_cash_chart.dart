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
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: const Text(
          'No data available for this period.',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    final maxY = bars
        .map((b) => b.inflow > b.outflow ? b.inflow : b.outflow)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final capY = maxY <= 0 ? 1000.0 : maxY * 1.15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cash Flow',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
            ),
            // Modernized Segmented Button
            SegmentedButton<ChartPeriod>(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppColors.primary.withOpacity(0.1);
                    }
                    return AppColors.surface;
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppColors.primary;
                    }
                    return AppColors.textSecondary;
                  },
                ),
                side: MaterialStateProperty.all(
                  const BorderSide(color: AppColors.borderLight),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: ChartPeriod.week, label: Text('Week', style: TextStyle(fontSize: 12))),
                ButtonSegment(value: ChartPeriod.month, label: Text('Month', style: TextStyle(fontSize: 12))),
                ButtonSegment(value: ChartPeriod.quarter, label: Text('3 Mo', style: TextStyle(fontSize: 12))),
              ],
              selected: {period},
              onSelectionChanged: (s) => onPeriodChanged(s.first),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              maxY: capY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: capY > 0 ? capY / 4 : 250,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: AppColors.borderLight,
                  strokeWidth: 1,
                  dashArray: [5, 5], // Dotted lines for a cleaner look
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40, // Increased size for larger numbers
                    getTitlesWidget: (v, _) => Text(
                      _k(v),
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: _labelInterval(bars.length),
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= bars.length) return const SizedBox.shrink();
                      if (i % _labelEvery(bars.length) != 0) {
                        return const SizedBox.shrink();
                      }
                      final d = bars[i].day;
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          DateFormat.Md().format(d),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
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
                  barsSpace: 4,
                  barRods: [
                    BarChartRodData(
                      toY: b.inflow,
                      width: 8, // Thicker bars
                      color: AppColors.incomeGreen,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: capY,
                        color: AppColors.surfaceSecondary, // Grey background for empty space
                      ),
                    ),
                    BarChartRodData(
                      toY: b.outflow,
                      width: 8,
                      color: AppColors.expenseRed,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: capY,
                        color: AppColors.surfaceSecondary,
                      ),
                    ),
                  ],
                );
              }),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipPadding: const EdgeInsets.all(8),
                  tooltipMargin: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final label = rodIndex == 0 ? 'Inflow' : 'Outflow';
                    final val = rodIndex == 0 ? bars[group.x.toInt()].inflow : bars[group.x.toInt()].outflow;
                    return BarTooltipItem(
                      '$label\n',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      children: [
                        TextSpan(
                          text: NumberFormat.currency(
                            locale: 'en_PK',
                            symbol: 'PKR ',
                            decimalDigits: 0,
                          ).format(val),
                          style: TextStyle(
                            color: rodIndex == 0 ? AppColors.incomeGreen : AppColors.expenseRed,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ],
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
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Centered legend
          children: [
            _LegendDot(color: AppColors.incomeGreen, label: 'Inflows'),
            const SizedBox(width: AppSpacing.xl),
            _LegendDot(color: AppColors.expenseRed, label: 'Outflows'),
          ],
        ),
      ],
    );
  }

  static String _k(double v) {
    if (v == 0) return '0';
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}k';
    return v.toStringAsFixed(0);
  }

  static double _labelInterval(int n) {
    if (n <= 7) return 1;
    if (n <= 14) return 2;
    if (n <= 31) return 5;
    return 10;
  }

  static int _labelEvery(int n) {
    if (n <= 7) return 1;
    if (n <= 14) return 2;
    if (n <= 31) return 5;
    return 10;
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ],
    );
  }
}
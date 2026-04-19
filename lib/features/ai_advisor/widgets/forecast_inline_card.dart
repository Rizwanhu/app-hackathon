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
    return Container(
      decoration: BoxDecoration(
        // AI wali feel dene ke liye halka sa gradient
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.timeline_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Cash Forecast (AI Demo)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        letterSpacing: -0.5,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // --- FORECAST ROWS ---
            _buildRow('Next 7 Days', day7),
            _buildRow('Next 14 Days', day14),
            _buildRow('Next 30 Days', day30),
            
            const SizedBox(height: AppSpacing.md),
            
            // --- SMART ALERT BOX ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: riskNegative 
                    ? AppColors.expenseRed.withOpacity(0.1) 
                    : AppColors.incomeGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: riskNegative 
                      ? AppColors.expenseRed.withOpacity(0.3) 
                      : AppColors.incomeGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    riskNegative ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                    color: riskNegative ? AppColors.expenseRed : AppColors.incomeGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      riskNegative
                          ? 'Risk Alert: Projected cash may dip negative. Tighten collections immediately.'
                          : 'Outlook Stable: Cash flow is projected to remain healthy.',
                      style: TextStyle(
                        color: riskNegative ? AppColors.expenseRed : AppColors.incomeGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern dotted line row design
  Widget _buildRow(String label, double v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label, 
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Flex(
                    direction: Axis.horizontal,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      (constraints.constrainWidth() / 6).floor(),
                      (index) => Container(width: 3, height: 1.5, color: AppColors.borderLight),
                    ),
                  );
                },
              ),
            ),
          ),
          Text(
            v.toPkr(),
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
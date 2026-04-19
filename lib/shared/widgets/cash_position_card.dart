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

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24), // Thora zyada round
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.04), // Halka sa green glow
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Net Cash Position',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: netCash),
            duration: const Duration(milliseconds: 800), // Thora slow for premium feel
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value.toPkr(symbol: currencyLabel),
                  style: TextStyle(
                    fontSize: 36, // Bara aur bold amount
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    color: positive ? AppColors.textPrimary : AppColors.expenseRed,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              // Modern Pill for Trend
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: trendUp
                      ? AppColors.incomeGreen.withOpacity(0.1)
                      : AppColors.expenseRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      size: 16,
                      color: trendUp ? AppColors.incomeGreen : AppColors.expenseRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${trendUp ? '+' : ''}${trendPctVsLastMonth.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: trendUp ? AppColors.incomeGreen : AppColors.expenseRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'vs last month',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
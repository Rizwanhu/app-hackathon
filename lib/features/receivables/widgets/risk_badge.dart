import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class RiskBadge extends StatelessWidget {
  final int riskScore;

  const RiskBadge({super.key, required this.riskScore});

  @override
  Widget build(BuildContext context) {
    final high = riskScore >= 70;
    final med = riskScore >= 40 && !high;
    final color = high
        ? AppColors.expenseRed
        : med
            ? AppColors.warningAmber
            : AppColors.incomeGreen;
    final label = high ? 'High risk' : med ? 'Medium' : 'Reliable';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        '$label • $riskScore',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}

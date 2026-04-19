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
            
    final label = high ? 'High Risk' : med ? 'Medium' : 'Reliable';
    
    // Har risk level ke liye ek pyara sa icon
    final iconData = high 
        ? Icons.warning_rounded 
        : med 
            ? Icons.info_outline_rounded 
            : Icons.check_circle_outline_rounded;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            '$label • $riskScore',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/models/finance_models.dart';

class TransactionTile extends StatelessWidget {
  final CashTransaction tx;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.tx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TransactionType.income;
    final color = isIncome ? AppColors.incomeGreen : AppColors.expenseRed;
    // Modern rounded icons
    final icon = isIncome ? Icons.south_west_rounded : Icons.north_east_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // --- AVATAR ICON ---
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                
                // --- TRANSACTION DETAILS ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Smart fallback: Agar naam khali hai to category ko heading bana do
                        tx.contactName.isEmpty ? tx.category : tx.contactName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              tx.contactName.isEmpty 
                                  ? DateFormat.yMMMd().format(tx.date) 
                                  : '${tx.category} • ${DateFormat.yMMMd().format(tx.date)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Receipt icon inline with date/category
                          if (tx.hasReceipt) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.primary),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                
                // --- AMOUNT ---
                Text(
                  '${isIncome ? '+' : '-'}${tx.amount.toPkr()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: -0.3, // Modern tight spacing
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
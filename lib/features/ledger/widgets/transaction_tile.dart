import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
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
    final icon = isIncome ? Icons.south_west : Icons.north_east;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.borderLight),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          tx.contactName.isEmpty ? '—' : tx.contactName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${tx.category} • ${DateFormat.yMMMd().format(tx.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isIncome ? '+' : '-'}${tx.amount.toPkr()}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            if (tx.hasReceipt)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Icon(Icons.receipt_long, size: 16, color: AppColors.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

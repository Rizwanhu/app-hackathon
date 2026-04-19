import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/data/app_store_scope.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/models/finance_models.dart';
import '../../../shared/widgets/cash_position_card.dart';
import '../../../shared/widgets/flow_cash_chart.dart';
import '../../ledger/widgets/add_transaction_sheet.dart';
import '../../receivables/widgets/add_receivable_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ChartPeriod _period = ChartPeriod.week;

  // --- Logic remains identical to original ---
  Future<void> _openAddTx({TransactionType? initialType}) async {
    final tx = await showModalBottomSheet<CashTransaction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      builder: (_) => AddTransactionSheet(initialType: initialType),
    );
    if (tx == null || !mounted) return;
    final err = await appStore.addTransaction(tx);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.expenseRed),
      );
    }
  }

  Future<void> _openAddReceivable() async {
    final r = await showModalBottomSheet<Receivable>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      builder: (_) => const AddReceivableSheet(),
    );
    if (r == null || !mounted) return;
    final err = await appStore.addReceivable(r);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.expenseRed),
      );
      return;
    }
    context.push('/app/dashboard/receivables');
  }

  void _showDayDrillDown(DateTime day) {
    final items = appStore.transactionsOnDay(day);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Transactions — ${day.day}/${day.month}',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text('No transactions recorded.', textAlign: TextAlign.center),
                )
              else
                ...items.map(
                  (t) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: t.type == TransactionType.income
                            ? AppColors.incomeGreen.withOpacity(0.1)
                            : AppColors.expenseRed.withOpacity(0.1),
                        child: Icon(
                          t.type == TransactionType.income ? Icons.add_rounded : Icons.remove_rounded,
                          color: t.type == TransactionType.income ? AppColors.incomeGreen : AppColors.expenseRed,
                        ),
                      ),
                      title: Text(t.contactName.isEmpty ? t.category : t.contactName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(t.category),
                      trailing: Text(
                        '${t.type == TransactionType.income ? '+' : '-'}${t.amount.toPkr()}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: t.type == TransactionType.income ? AppColors.incomeGreen : AppColors.expenseRed,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _quickActions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildActionTile(Icons.add_shopping_cart, 'Add Sale', AppColors.incomeGreen, () {
                  Navigator.pop(ctx);
                  _openAddTx(initialType: TransactionType.income);
                }),
                _buildActionTile(Icons.receipt_long, 'Add Expense', AppColors.expenseRed, () {
                  Navigator.pop(ctx);
                  _openAddTx(initialType: TransactionType.expense);
                }),
                _buildActionTile(Icons.person_add_alt_1, 'Add Receivable', AppColors.primary, () {
                  Navigator.pop(ctx);
                  _openAddReceivable();
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) {
        final warn = appStore.categoriesOverBudget80;
        final bars = appStore.chartBars(_period);

        return Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _quickActions,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Quick add'),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 100),
            children: [
              if (appStore.lastError != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Material(
                    color: AppColors.warningAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline_rounded, color: Colors.orange.shade800, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              appStore.lastError!,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (warn.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    'Over 80% of budget: ${warn.join(', ')}',
                    style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.w700),
                  ),
                ),
              CashPositionCard(
                netCash: appStore.netCash,
                trendPctVsLastMonth: appStore.trendVsLastMonthPct,
                currencyLabel: appStore.profile.currency,
              ),
              const SizedBox(height: 16),
              FlowCashChart(
                period: _period,
                onPeriodChanged: (p) => setState(() => _period = p),
                bars: bars,
                onBarSelected: (i) {
                  if (i < 0 || i >= bars.length) return;
                  _showDayDrillDown(bars[i].day);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
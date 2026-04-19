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

  Future<void> _openAddTx({TransactionType? initialType}) async {
    final tx = await showModalBottomSheet<CashTransaction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddTransactionSheet(initialType: initialType),
    );
    if (tx == null || !mounted) return;
    final err = await appStore.addTransaction(tx);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _openAddReceivable() async {
    final r = await showModalBottomSheet<Receivable>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddReceivableSheet(),
    );
    if (r == null || !mounted) return;
    final err = await appStore.addReceivable(r);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    context.push('/app/dashboard/receivables');
  }

  void _showDayDrillDown(DateTime day) {
    final items = appStore.transactionsOnDay(day);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Transactions — ${day.toString().split(' ').first}',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: AppSpacing.md),
              if (items.isEmpty)
                const Text('No transactions on this day.')
              else
                ...items.map(
                  (t) => ListTile(
                    leading: Icon(
                      t.type == TransactionType.income ? Icons.south_west : Icons.north_east,
                      color: t.type == TransactionType.income
                          ? AppColors.incomeGreen
                          : AppColors.expenseRed,
                    ),
                    title: Text(t.contactName.isEmpty ? t.category : t.contactName),
                    subtitle: Text(t.category),
                    trailing: Text(
                      '${t.type == TransactionType.income ? '+' : '-'}${t.amount.toPkr()}',
                      style: const TextStyle(fontWeight: FontWeight.w900),
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
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.add_shopping_cart),
                title: const Text('Add sale'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openAddTx(initialType: TransactionType.income);
                },
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Add expense'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openAddTx(initialType: TransactionType.expense);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1),
                title: const Text('Add receivable'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openAddReceivable();
                },
              ),
            ],
          ),
        );
      },
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

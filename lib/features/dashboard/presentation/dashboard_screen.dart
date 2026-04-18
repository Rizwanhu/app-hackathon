import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/mock/mock_scope.dart';
import '../../../core/mock/mock_store.dart';
import '../../../shared/widgets/budget_progress_list.dart';
import '../../../shared/widgets/cash_position_card.dart';
import '../../../shared/widgets/expense_category_chart.dart';
import '../../../shared/widgets/flow_cash_chart.dart';
import '../../../shared/widgets/insight_card.dart';
import '../../../shared/widgets/summary_metrics_row.dart';
import '../../ledger/widgets/add_transaction_sheet.dart';
import '../../receivables/widgets/add_receivable_sheet.dart';
import '../../../shared/widgets/app_scaffold.dart';

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
    if (tx == null) return;
    mockStore.addTransaction(tx);
  }

  Future<void> _openAddReceivable() async {
    final r = await showModalBottomSheet<Receivable>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddReceivableSheet(),
    );
    if (r == null) return;
    mockStore.addReceivable(r);
    if (!mounted) return;
    context.go('/app/receivables');
  }

  void _showDayDrillDown(DateTime day) {
    final items = mockStore.transactionsOnDay(day);
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
    animation: mockStore,
    builder: (context, _) {
      final warn = mockStore.categoriesOverBudget80;
      final bars = mockStore.chartBars(_period);
      final spentMap = {
        for (final k in mockStore.categoryBudgets.keys) k: mockStore.expenseThisMonthForCategory(k),
      };

      // USE A BASIC SCAFFOLD WITHOUT AN APPBAR
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _quickActions,
          icon: const Icon(Icons.add),
          label: const Text('Quick add'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16), // Add some padding
          children: [
            if (warn.isNotEmpty)
              // ... your existing warning widget code
            CashPositionCard(
              netCash: mockStore.netCash,
              trendPctVsLastMonth: mockStore.trendVsLastMonthPct,
              currencyLabel: mockStore.profile.currency,
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
            // ... add the rest of your dashboard widgets (charts, metrics, etc.) here
            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      );
    },
  );
}
}

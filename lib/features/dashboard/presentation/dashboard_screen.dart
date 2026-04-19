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
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.surface,
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Quick Actions'),
          ),
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: AppColors.background,
                title: Text('Dashboard', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                centerTitle: false,
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (appStore.lastError != null)
                      _buildAlert(appStore.lastError!, AppColors.expenseRed),
                    if (warn.isNotEmpty)
                      _buildAlert('Budget Warning: ${warn.join(', ')}', AppColors.warningAmber),
                    
                    CashPositionCard(
                      netCash: appStore.netCash,
                      trendPctVsLastMonth: appStore.trendVsLastMonthPct,
                      currencyLabel: appStore.profile.currency,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: FlowCashChart(
                        period: _period,
                        onPeriodChanged: (p) => setState(() => _period = p),
                        bars: bars,
                        onBarSelected: (i) {
                          if (i < 0 || i >= bars.length) return;
                          _showDayDrillDown(bars[i].day);
                        },
                      ),
                    ),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlert(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}
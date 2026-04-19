import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/data/app_store_scope.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../core/models/finance_models.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/transaction_tile.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  DateTimeRange? _range;
  String? _categoryFilter;
  final _contactQ = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _contactQ.dispose();
    super.dispose();
  }

  List<CashTransaction> _filtered(List<CashTransaction> all) {
    var list = all.toList();
    final tab = _tabs.index;
    if (tab == 1) {
      list = list.where((t) => t.type == TransactionType.income).toList();
    } else if (tab == 2) {
      list = list.where((t) => t.type == TransactionType.expense).toList();
    }

    final r = _range;
    if (r != null) {
      list = list
          .where((t) => !t.date.isBefore(r.start) && !t.date.isAfter(r.end))
          .toList();
    }

    final cat = _categoryFilter;
    if (cat != null && cat.isNotEmpty) {
      list = list.where((t) => t.category == cat).toList();
    }

    final q = _contactQ.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((t) => t.contactName.toLowerCase().contains(q)).toList();
    }

    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Set<String> _categories(List<CashTransaction> all) {
    return all.map((t) => t.category).toSet();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDateRange: _range ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _addOrEdit([CashTransaction? existing]) async {
    final tx = await showModalBottomSheet<CashTransaction>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      showDragHandle: true,
      builder: (_) => AddTransactionSheet(existing: existing),
    );
    if (tx == null || !mounted) return;
    final err = existing == null
        ? await appStore.addTransaction(tx)
        : await appStore.updateTransaction(tx.id, tx);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.expenseRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) {
        final all = appStore.transactions;
        final cats = _categories(all);
        final list = _filtered(all);

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addOrEdit(),
            child: const Icon(Icons.add_rounded),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- PREMIUM TAB BAR ---
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: TabBar(
                  controller: _tabs,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Income'),
                    Tab(text: 'Expenses'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // --- SEARCH BAR ---
              TextField(
                controller: _contactQ,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  hintText: 'Search contact or vendor...',
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // --- FILTERS ---
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    ActionChip(
                      onPressed: _pickRange,
                      backgroundColor: _range == null ? AppColors.surface : AppColors.primary.withOpacity(0.1),
                      side: BorderSide(color: _range == null ? AppColors.borderLight : AppColors.primary),
                      avatar: Icon(Icons.date_range_rounded, size: 16, color: _range == null ? AppColors.textSecondary : AppColors.primary),
                      label: Text(
                        _range == null ? 'Date Range' : 'Filtered',
                        style: TextStyle(color: _range == null ? AppColors.textSecondary : AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (_range != null) ...[
                      const SizedBox(width: 8),
                      ActionChip(
                        onPressed: () => setState(() => _range = null),
                        backgroundColor: AppColors.surfaceSecondary,
                        side: const BorderSide(color: AppColors.borderLight),
                        label: const Text('Clear', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _categoryFilter,
                          hint: const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                          items: [
                            const DropdownMenuItem<String?>(value: null, child: Text('All Categories')),
                            ...cats.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                          ],
                          onChanged: (v) => setState(() => _categoryFilter = v),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // --- LIST VIEW ---
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => appStore.refresh(),
                  child: list.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            EmptyState(
                              icon: Icons.receipt_long_rounded,
                              title: 'No transactions match',
                              subtitle: 'Adjust filters or add a new entry from +.',
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: list.length,
                          itemBuilder: (context, i) {
                            final t = list[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16), // Prevents background bleeding
                                child: Dismissible(
                                  key: ValueKey(t.id),
                                  direction: DismissDirection.horizontal,
                                  background: Container(
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 24),
                                    color: AppColors.infoBlue.withOpacity(0.15),
                                    child: const Icon(Icons.edit_rounded, color: AppColors.infoBlue),
                                  ),
                                  secondaryBackground: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 24),
                                    color: AppColors.expenseRed.withOpacity(0.15),
                                    child: const Icon(Icons.delete_rounded, color: AppColors.expenseRed),
                                  ),
                                  confirmDismiss: (dir) async {
                                    if (dir == DismissDirection.startToEnd) {
                                      await _addOrEdit(t);
                                      return false; // Don't dismiss, just edit
                                    }
                                    if (dir == DismissDirection.endToStart) {
                                      final err = await appStore.deleteTransaction(t.id);
                                      if (!context.mounted) return false;
                                      if (err != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(err), backgroundColor: AppColors.expenseRed),
                                        );
                                        return false;
                                      }
                                      return true;
                                    }
                                    return false;
                                  },
                                  child: TransactionTile(tx: t, onTap: () => _addOrEdit(t)),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }
}
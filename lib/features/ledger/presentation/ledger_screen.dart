import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/data/app_store_scope.dart';
import '../../../core/models/finance_models.dart';
import '../../../shared/widgets/app_scaffold.dart';
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
    // `appStore.transactions` is unmodifiable; always work on a mutable copy.
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
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _addOrEdit([CashTransaction? existing]) async {
    final tx = await showModalBottomSheet<CashTransaction>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => AddTransactionSheet(existing: existing),
    );
    if (tx == null || !mounted) return;
    final err = existing == null
        ? await appStore.addTransaction(tx)
        : await appStore.updateTransaction(tx.id, tx);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
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

        return AppScaffold(
          title: 'Ledger',
          floatingActionButton: FloatingActionButton(
            onPressed: () => _addOrEdit(),
            child: const Icon(Icons.add),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TabBar(
                controller: _tabs,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Income'),
                  Tab(text: 'Expenses'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _contactQ,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search contact…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(_range == null ? 'Date range' : 'Filter: range set'),
                  ),
                  if (_range != null)
                    TextButton(
                      onPressed: () => setState(() => _range = null),
                      child: const Text('Clear range'),
                    ),
                  DropdownButton<String?>(
                    value: _categoryFilter,
                    hint: const Text('Category'),
                    items: [
                      const DropdownMenuItem<String?>(value: null, child: Text('All categories')),
                      ...cats.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (v) => setState(() => _categoryFilter = v),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => appStore.refresh(),
                  child: list.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('No transactions match filters.')),
                          ],
                        )
                      : ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, i) {
                            final t = list[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Dismissible(
                                key: ValueKey(t.id),
                                direction: DismissDirection.horizontal,
                                background: Container(
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 18),
                                  color: Colors.blue.shade100,
                                  child: const Icon(Icons.edit),
                                ),
                                secondaryBackground: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 18),
                                  color: Colors.red.shade100,
                                  child: const Icon(Icons.delete),
                                ),
                                confirmDismiss: (dir) async {
                                  if (dir == DismissDirection.startToEnd) {
                                    await _addOrEdit(t);
                                    return false;
                                  }
                                  if (dir == DismissDirection.endToStart) {
                                    final err = await appStore.deleteTransaction(t.id);
                                    if (!context.mounted) return false;
                                    if (err != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(err)),
                                      );
                                      return false;
                                    }
                                    return true;
                                  }
                                  return false;
                                },
                                child: TransactionTile(tx: t, onTap: () => _addOrEdit(t)),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

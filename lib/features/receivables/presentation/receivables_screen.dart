import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/data/app_store_scope.dart';
import '../../../core/models/finance_models.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../widgets/add_receivable_sheet.dart';
import '../widgets/receivable_card.dart';
import '../widgets/receivable_detail_sheet.dart';

class ReceivablesScreen extends StatelessWidget {
  const ReceivablesScreen({super.key});

  Future<void> _openAdd(BuildContext context) async {
    final r = await showModalBottomSheet<Receivable>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const AddReceivableSheet(),
    );
    if (r == null || !context.mounted) return;
    final err = await appStore.addReceivable(r);
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  void _openDetail(BuildContext context, String id) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        maxChildSize: 0.92,
        minChildSize: 0.45,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: ReceivableDetailSheet(receivableId: id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) {
        final list = appStore.sortedReceivables();

        return AppScaffold(
          title: 'Receivables',
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAdd(context),
            child: const Icon(Icons.person_add_alt_1),
          ),
          body: list.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('No receivables yet. Tap + to add one.')),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final r = list[i];
                    return ReceivableCard(
                      r: r,
                      onOpen: () => _openDetail(context, r.id),
                    );
                  },
                ),
        );
      },
    );
  }
}

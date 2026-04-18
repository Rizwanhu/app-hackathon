import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/mock/mock_scope.dart';
import '../../../core/mock/mock_store.dart';
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
    if (r != null) mockStore.addReceivable(r);
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
      animation: mockStore,
      builder: (context, _) {
        final list = mockStore.sortedReceivables();

        return AppScaffold(
          title: 'Receivables',
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openAdd(context),
            child: const Icon(Icons.person_add_alt_1),
          ),
          body: ListView.separated(
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

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/data/app_store_scope.dart';
import '../../../core/models/finance_models.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/add_receivable_sheet.dart';
import '../widgets/receivable_card.dart';
import '../widgets/receivable_detail_sheet.dart';

class ReceivablesScreen extends StatelessWidget {
  const ReceivablesScreen({super.key});

  Future<void> _openAdd(BuildContext context) async {
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
    if (r == null || !context.mounted) return;
    final err = await appStore.addReceivable(r);
    if (!context.mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: AppColors.expenseRed),
      );
    }
  }

  void _openDetail(BuildContext context, String id) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        maxChildSize: 0.92,
        minChildSize: 0.45,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          physics: const BouncingScrollPhysics(),
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
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAdd(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Add New', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          body: list.isEmpty
              ? const EmptyState(
                  icon: Icons.groups_outlined,
                  title: 'No receivables yet',
                  subtitle: 'Tap Add New to record money owed by a customer.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100),
                  physics: const BouncingScrollPhysics(),
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

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/data/app_store_scope.dart';
import '../../../core/models/finance_models.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../widgets/add_payable_sheet.dart';
import '../widgets/payable_tile.dart';

class PayablesScreen extends StatelessWidget {
  const PayablesScreen({super.key});

  Future<void> _openAdd(BuildContext context) async {
    final p = await showModalBottomSheet<Payable>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface, // Ensure surface color
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      builder: (_) => const AddPayableSheet(),
    );
    if (p == null || !context.mounted) return;
    final err = await appStore.addPayable(p);
    if (!context.mounted) return;
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
        final list = appStore.sortedPayablesOpen();

        return AppScaffold(
          title: 'Payables',
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAdd(context),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_card_rounded),
            label: const Text('Add Payable', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          body: list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          size: 48,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'All Caught Up!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'You have no open payables right now.\nTap "Add Payable" when a new bill arrives.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 80), // Offset for optical center
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100), // Padding for FAB
                  physics: const BouncingScrollPhysics(),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return PayableTile(
                      p: p,
                      onMarkPaid: () {
                        appStore.markPayablePaid(p.id).then((err) {
                          if (!context.mounted) return;
                          if (err != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(err), backgroundColor: AppColors.expenseRed),
                            );
                          } else {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment marked successfully!'), backgroundColor: AppColors.incomeGreen),
                            );
                          }
                        });
                      },
                      onReminderChanged: (v) {
                        if (v == p.reminderEnabled) return;
                        appStore.togglePayableReminder(p.id);
                        if (v && appStore.notificationsEnabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Reminder set for ${p.vendorName}'),
                              backgroundColor: AppColors.primary,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
        );
      },
    );
  }
}
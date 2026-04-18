import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/mock/mock_scope.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../widgets/payable_tile.dart';

class PayablesScreen extends StatelessWidget {
  const PayablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mockStore,
      builder: (context, _) {
        final list = mockStore.sortedPayablesOpen();

        return AppScaffold(
          title: 'Payables',
          body: list.isEmpty
              ? const Center(child: Text('No open payables. Great job!'))
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 88),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final p = list[i];
                    return PayableTile(
                      p: p,
                      onMarkPaid: () => mockStore.markPayablePaid(p.id),
                      onReminderChanged: (v) {
                        if (v == p.reminderEnabled) return;
                        mockStore.togglePayableReminder(p.id);
                        if (v && mockStore.notificationsEnabled) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reminder set for ${p.vendorName} (demo — no real push).',
                              ),
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

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/data/app_store_scope.dart';
import '../../../core/models/finance_models.dart';
import '../../../core/services/whatsapp_service.dart';
import 'risk_badge.dart';

class ReceivableDetailSheet extends StatefulWidget {
  final String receivableId;

  const ReceivableDetailSheet({super.key, required this.receivableId});

  @override
  State<ReceivableDetailSheet> createState() => _ReceivableDetailSheetState();
}

class _ReceivableDetailSheetState extends State<ReceivableDetailSheet> {
  final _followUpNote = TextEditingController();

  @override
  void dispose() {
    _followUpNote.dispose();
    super.dispose();
  }

  Receivable? _find() {
    for (final r in appStore.receivables) {
      if (r.id == widget.receivableId) return r;
    }
    return null;
  }

  String _message(Receivable r) {
    final name = r.contactName;
    final amt = r.amount.toPkr();
    final due = DateFormat.yMMMd().format(r.dueDate);
    final overdue = r.daysPastDue > 0 ? '${r.daysPastDue} days overdue' : 'due soon';
    return 'Assalam o Alaikum $name,\n\n'
        'Quick reminder: $amt from the invoice dated $due is still pending ($overdue).\n\n'
        'Please let us know when we can expect payment.\n\n'
        '— ${appStore.profile.businessName}';
  }

  Future<void> _openWhatsApp(Receivable r) async {
    final ok = await WhatsAppService.sendMessage(
      phoneNumber: r.phoneNumber,
      message: _message(r),
    );
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) {
        final r = _find();
        if (r == null) {
          return const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Text('Receivable not found.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      r.contactName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  RiskBadge(riskScore: r.riskScore),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('${r.amount.toPkr()} • Due ${DateFormat.yMMMd().format(r.dueDate)}'),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<ReceivableStatus>(
                value: r.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: ReceivableStatus.values
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                    .toList(),
                onChanged: (v) async {
                  if (v == null) return;
                  final err = await appStore.updateReceivableStatus(r.id, v);
                  if (!context.mounted) return;
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Follow-up log', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.sm),
              ...r.followUps.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, size: 6, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(child: Text(line)),
                    ],
                  ),
                ),
              ),
              if (r.followUps.isEmpty)
                Text(
                  'No follow-ups yet.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _followUpNote,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Add follow-up note',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: () async {
                  final note = _followUpNote.text.trim();
                  if (note.isEmpty) return;
                  final err = await appStore.addReceivableFollowUp(r.id, note);
                  _followUpNote.clear();
                  if (!context.mounted) return;
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                  }
                },
                child: const Text('Save note'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: () => _openWhatsApp(r),
                icon: const Icon(Icons.chat),
                label: const Text('Follow-up template → WhatsApp'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }
}

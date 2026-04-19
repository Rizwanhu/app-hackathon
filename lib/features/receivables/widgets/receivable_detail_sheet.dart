import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
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
        const SnackBar(
          content: Text('Could not open WhatsApp.'),
          backgroundColor: AppColors.expenseRed,
        ),
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
            child: Center(child: Text('Receivable not found.', style: TextStyle(color: AppColors.textMuted))),
          );
        }

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg, // Keyboard padding
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER INFO ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Text(
                      r.contactName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.contactName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        RiskBadge(riskScore: r.riskScore),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // --- AMOUNT & DATE BOX ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Amount Due', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(r.amount.toPkr(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.expenseRed)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Due Date', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(DateFormat.yMMMd().format(r.dueDate), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // --- STATUS DROPDOWN ---
              DropdownButtonFormField<ReceivableStatus>(
                initialValue: r.status,
                icon: const Icon(Icons.arrow_drop_down_circle_rounded, color: AppColors.primary),
                decoration: InputDecoration(
                  labelText: 'Current Status',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
                ),
                items: ReceivableStatus.values
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) async {
                  if (v == null) return;
                  final err = await appStore.updateReceivableStatus(r.id, v);
                  if (!context.mounted) return;
                  if (err != null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: AppColors.expenseRed));
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // --- FOLLOW-UP LOG ---
              const Text('Follow-up Log', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                child: r.followUps.isEmpty
                    ? const Center(child: Text('No follow-ups recorded yet.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: r.followUps.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Icon(Icons.circle, size: 8, color: AppColors.primary),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    r.followUps[index],
                                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: AppSpacing.md),

              // --- ADD NOTE ---
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _followUpNote,
                      decoration: InputDecoration(
                        hintText: 'Add a quick note...',
                        hintStyle: const TextStyle(fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
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
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // --- WHATSAPP BUTTON ---
              FilledButton.icon(
                onPressed: () => _openWhatsApp(r),
                icon: const Icon(Icons.chat_rounded),
                label: const Text('Send Reminder via WhatsApp'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366), // Official WhatsApp Color
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
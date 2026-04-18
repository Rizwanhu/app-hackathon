import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/mock/mock_scope.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/forecast_inline_card.dart';

class _ChatItem {
  final bool isUser;
  final String text;
  final Widget? extra;

  const _ChatItem({required this.isUser, required this.text, this.extra});
}

class AiAdvisorScreen extends StatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _items = <_ChatItem>[
    const _ChatItem(
      isUser: false,
      text:
          'Hi — I’m your FlowSense advisor (demo). Ask about cash, overdue customers, or spending. I’ll answer using your on-device mock data.',
    ),
  ];

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendPreset(String q) {
    _input.text = q;
    _send();
  }

  void _send() {
    final q = _input.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _items.add(_ChatItem(isUser: true, text: q));
    });
    _input.clear();
    _scrollBottom();

    final lower = q.toLowerCase();
    final s = mockStore;

    Widget? extra;
    String reply;

    if (lower.contains('forecast') ||
        lower.contains('predict') ||
        lower.contains('august')) {
      final base = s.netCash;
      extra = ForecastInlineCard(
        day7: base + base * 0.02,
        day14: base + base * 0.04,
        day30: base - base * 0.03,
        riskNegative: base < 50000,
      );
      reply =
          'Here’s a simple forward-looking view based on your current mock ledger. Tap the card for the headline numbers.';
    } else if (lower.contains('owe') || lower.contains('receivable') || lower.contains('customer')) {
      final list = [...s.receivables]..sort((a, b) => b.amount.compareTo(a.amount));
      final top = list.isEmpty ? '—' : list.first.contactName;
      reply =
          'Total receivables pending: ${s.totalReceivablesPending.toPkr()}. Largest balance right now: $top.';
    } else if (lower.contains('restock') || lower.contains('week') || lower.contains('cash')) {
      reply =
          'Net cash right now is about ${s.netCash.toPkr()}. Payables open: ${s.totalPayablesOpen.toPkr()}. If collections stay steady, you likely have room for a small restock — keep an eye on overdue receivables.';
    } else if (lower.contains('spend') || lower.contains('overspend') || lower.contains('utility')) {
      final map = s.expenseByCategoryThisMonth();
      final topEntry = map.entries.isEmpty
          ? null
          : (map.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first;
      reply = topEntry == null
          ? 'No expense categories recorded for this month yet.'
          : 'Top spend category this month: ${topEntry.key} at ${topEntry.value.toPkr()}.';
    } else {
      reply =
          'Snapshot: net cash ${s.netCash.toPkr()}, receivables ${s.totalReceivablesPending.toPkr()}, payables ${s.totalPayablesOpen.toPkr()}. Try a suggestion chip for a sharper answer.';
    }

    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        _items.add(_ChatItem(isUser: false, text: reply, extra: extra));
      });
      _scrollBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'AI Advisor',
      body: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _Chip(label: 'Cash next week?', onTap: () => _sendPreset('Will I have enough cash to restock next week?')),
                _Chip(label: 'Who owes most?', onTap: () => _sendPreset('Which customer owes the most?')),
                _Chip(label: 'Overspending?', onTap: () => _sendPreset('Where am I overspending this month?')),
                _Chip(label: '30-day forecast', onTap: () => _sendPreset('Predict my cash position for next 30 days')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final m = _items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment:
                        m.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      ChatBubble(text: m.text, isUser: m.isUser),
                      if (m.extra != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        m.extra!,
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Ask FlowSense…',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              FilledButton(
                onPressed: _send,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ActionChip(
        label: Text(label),
        onPressed: onTap,
      ),
    );
  }
}

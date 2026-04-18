import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/extensions/currency_extension.dart';
import '../../../core/mock/mock_scope.dart';
import '../widgets/chat_bubble.dart';

class _ChatItem {
  final bool isUser;
  final String text;
  const _ChatItem({required this.isUser, required this.text});
}

class AiAdvisorScreen extends StatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_ChatItem> _items = [
    const _ChatItem(isUser: false, text: 'Hi — I’m FlowSense AI. How can I help with your business today?'),
  ];

  late GenerativeModel _model;
  bool _isTyping = false;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    // Fetch key from environment
    _apiKey = dotenv.env['GEMINI_API_KEY'];
    
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey!,
      );
    }
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final q = _input.text.trim();
    if (q.isEmpty || _isTyping) return;

    // Safety check for API Key
    if (_apiKey == null || _apiKey!.isEmpty) {
      setState(() {
        _items.add(const _ChatItem(isUser: false, text: "Error: GEMINI_API_KEY is missing from .env file."));
      });
      return;
    }

    setState(() {
      _items.add(_ChatItem(isUser: true, text: q));
      _isTyping = true;
    });
    _input.clear();
    _scrollBottom();

    try {
      final s = mockStore;
      final prompt = '''
        Context: Small Business Financial Data
        - Net Cash: ${s.netCash.toPkr()}
        - Receivables: ${s.totalReceivablesPending.toPkr()}
        - Payables: ${s.totalPayablesOpen.toPkr()}
        
        Question: $q
        Answer concisely as a financial expert.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (mounted) {
        setState(() {
          _items.add(_ChatItem(isUser: false, text: response.text ?? "I'm having trouble thinking..."));
          _isTyping = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _items.add(const _ChatItem(isUser: false, text: "Connection failed. Please check your internet or API key quota."));
          _isTyping = false;
        });
      }
    }
    _scrollBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Advisor'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _items.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: ChatBubble(text: _items[i].text, isUser: _items[i].isUser),
              ),
            ),
          ),
          if (_isTyping) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(hintText: 'Ask your business question...', border: OutlineInputBorder()),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(onPressed: _send, icon: const Icon(Icons.send)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
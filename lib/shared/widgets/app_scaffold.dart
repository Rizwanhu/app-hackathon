import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}


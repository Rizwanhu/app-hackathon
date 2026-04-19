import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool usePadding;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.usePadding = true, // Default true taakay purana code break na ho
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0, // Scroll karne par color change na ho
        centerTitle: false, // Modern left-aligned look
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary, // Back button ka color
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800, // Bold aur sharp title
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        actions: actions != null
            ? [
                // Thori si padding actions ke right side par
                ...actions!,
                const SizedBox(width: AppSpacing.sm),
              ]
            : null,
      ),
      body: usePadding
          ? Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: body,
            )
          : body,
      floatingActionButton: floatingActionButton,
    );
  }
}
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final bg = isUser ? AppColors.primary : AppColors.surfaceSecondary;
    final fg = isUser ? Colors.white : AppColors.textPrimary;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              text,
              style: TextStyle(color: fg, height: 1.35, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_scope.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Settings',
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.md),
          const Text('Settings skeleton'),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () {
              authNotifier.setMockLoggedIn(false);
              context.go('/login');
            },
            child: const Text('Sign out (mock)'),
          ),
        ],
      ),
    );
  }
}


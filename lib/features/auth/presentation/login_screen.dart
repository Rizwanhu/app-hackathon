import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_scope.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    final ok = Validators.isNonEmpty(_email.text) &&
        Validators.isNonEmpty(_password.text);
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email + password.')),
      );
      return;
    }

    // Backend intentionally not implemented yet.
    authNotifier.setMockLoggedIn(true);
    context.go('/app/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Login',
      body: ListView(
        children: [
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _login,
            child: const Text('Log in'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => context.go('/signup'),
            child: const Text('No account? Sign up'),
          ),
        ],
      ),
    );
  }
}


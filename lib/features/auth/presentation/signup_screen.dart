import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_scope.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/mock/mock_scope.dart';
import '../../../core/mock/mock_store.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _businessName = TextEditingController();
  final _industry = TextEditingController();
  final _currency = TextEditingController(text: 'PKR');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _businessName.dispose();
    _industry.dispose();
    _currency.dispose();
    super.dispose();
  }

  void _createAccount() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    mockStore.updateProfile(
      BusinessProfile(
        businessName: _businessName.text.trim().isEmpty ? 'My business' : _businessName.text.trim(),
        industry: _industry.text.trim().isEmpty ? 'General' : _industry.text.trim(),
        currency: _currency.text.trim().isEmpty ? 'PKR' : _currency.text.trim(),
      ),
    );
    authNotifier.setMockLoggedIn(true);
    context.go('/app/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create account',
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: AppSpacing.md),
            Text(
              'Business setup',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _businessName,
              decoration: const InputDecoration(
                labelText: 'Business name',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  Validators.isNonEmpty(v ?? '') ? null : 'Enter a business name.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _industry,
              decoration: const InputDecoration(
                labelText: 'Industry',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _currency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (!Validators.isEmail(v ?? '')) return 'Enter a valid email.';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if ((v ?? '').trim().length < 6) return 'Use at least 6 characters.';
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _createAccount,
              child: const Text('Create account'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Log in'),
            ),
          ],
        ),
      ),
    );
  }
}

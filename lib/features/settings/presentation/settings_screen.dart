import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/auth/auth_scope.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/mock/mock_scope.dart';
import '../../../core/mock/mock_store.dart';
import '../../../shared/widgets/app_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _bizName = TextEditingController();
  final _industry = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bizName.text = mockStore.profile.businessName;
    _industry.text = mockStore.profile.industry;
  }

  @override
  void dispose() {
    _bizName.dispose();
    _industry.dispose();
    super.dispose();
  }

  void _saveProfile() {
    mockStore.updateProfile(
      BusinessProfile(
        businessName: _bizName.text.trim().isEmpty ? 'My business' : _bizName.text.trim(),
        industry: _industry.text.trim().isEmpty ? 'General' : _industry.text.trim(),
        currency: mockStore.profile.currency,
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved (local demo).')),
    );
  }

  String _csvExport() {
    final buf = StringBuffer('type,amount,category,contact,date,note\n');
    final fmt = DateFormat('yyyy-MM-dd');
    for (final t in mockStore.transactions) {
      final type = t.type == TransactionType.income ? 'income' : 'expense';
      buf.writeln(
        '$type,${t.amount},${t.category},${_escape(t.contactName)},${fmt.format(t.date)},${_escape(t.note)}',
      );
    }
    return buf.toString();
  }

  String _escape(String s) {
    if (s.contains(',') || s.contains('"')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: mockStore,
      builder: (context, _) {
        return AppScaffold(
          title: 'Settings',
          body: ListView(
            children: [
              Text(
                'Business profile',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _bizName,
                decoration: const InputDecoration(
                  labelText: 'Business name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _industry,
                decoration: const InputDecoration(
                  labelText: 'Industry',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton(onPressed: _saveProfile, child: const Text('Save profile')),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Category budgets (monthly)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.md),
              ...mockStore.categoryBudgets.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.key,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                          Text(
                            '${e.value.toStringAsFixed(0)} PKR',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      Slider(
                        value: e.value.clamp(5000, 500000),
                        min: 5000,
                        max: 500000,
                        divisions: 99,
                        label: e.value.toStringAsFixed(0),
                        onChanged: (v) => mockStore.setBudget(e.key, v),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile(
                value: mockStore.notificationsEnabled,
                onChanged: (v) => mockStore.setNotifications(v),
                title: const Text('Notifications'),
                subtitle: const Text('Payable reminders & daily summary (demo)'),
              ),
              SwitchListTile(
                value: mockStore.biometricLockEnabled,
                onChanged: (v) => mockStore.setBiometricLock(v),
                title: const Text('Biometric lock'),
                subtitle: const Text('Simulated — no real device auth yet'),
              ),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ],
                selected: {mockStore.themeMode},
                onSelectionChanged: (s) => mockStore.updateThemeMode(s.first),
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _csvExport()));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('CSV copied to clipboard (demo export).')),
                  );
                },
                icon: const Icon(Icons.copy),
                label: const Text('Export transactions as CSV (copy)'),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'PDF / cloud export can plug in later — this hackathon build uses clipboard CSV.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(
                onPressed: () {
                  authNotifier.setMockLoggedIn(false);
                  context.go('/login');
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        );
      },
    );
  }
}

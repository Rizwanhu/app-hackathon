import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_scope.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/data/app_store_scope.dart';
import '../../../core/models/finance_models.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await appStore.refresh();
      if (!mounted) return;
      setState(() {
        _bizName.text = appStore.profile.businessName;
        _industry.text = appStore.profile.industry;
      });
    });
  }

  @override
  void dispose() {
    _bizName.dispose();
    _industry.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final err = await appStore.persistBusinessProfile(_bizName.text, _industry.text);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business profile saved.')),
      );
    }
  }

  String _csvExport() {
    final buf = StringBuffer('type,amount,category,contact,date,note\n');
    final fmt = DateFormat('yyyy-MM-dd');
    for (final t in appStore.transactions) {
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
      animation: appStore,
      builder: (context, _) {
        final user =
            SupabaseService.isInitialized ? SupabaseService.client.auth.currentUser : null;
        return AppScaffold(
          title: 'Settings',
          body: ListView(
            children: [
              Text(
                'Account',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user == null ? 'Not signed in' : 'Signed in',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(user?.email ?? '—'),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Password is not stored or shown for security.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (user?.email != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: user!.email!));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Email copied.')),
                            );
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy email'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
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
              if (!appStore.hasSavedBudgets)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Text(
                    'No budget row exists in Supabase yet. A budget record is created when you move any slider and save a value for the current month.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ...appStore.categoryBudgets.entries.map((e) {
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
                        onChanged: (v) {
                          appStore.setBudget(e.key, v).then((err) {
                            if (!context.mounted) return;
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                            }
                          });
                        },
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
                value: appStore.notificationsEnabled,
                onChanged: (v) => appStore.setNotifications(v),
                title: const Text('Notifications'),
                subtitle: const Text('Payable reminders & daily summary (demo)'),
              ),
              SwitchListTile(
                value: appStore.biometricLockEnabled,
                onChanged: (v) => appStore.setBiometricLock(v),
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
                selected: {appStore.themeMode},
                onSelectionChanged: (s) => appStore.updateThemeMode(s.first),
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
                onPressed: () async {
                  try {
                    if (SupabaseService.isInitialized) {
                      await SupabaseService.client.auth.signOut();
                    }
                  } catch (_) {
                    authNotifier.setMockLoggedIn(false);
                  }
                  if (!context.mounted) return;
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

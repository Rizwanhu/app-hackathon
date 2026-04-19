import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/auth_scope.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/data/app_store_scope.dart';
import '../../../core/models/finance_models.dart';
import '../../../shared/widgets/app_scaffold.dart';
// Maan lete hain ke aapka folder structure ye hai, isay check kar lein:
import '../../../views/old_dashboard_screen.dart'; 

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err), backgroundColor: AppColors.expenseRed,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business profile saved successfully.'),
          backgroundColor: AppColors.incomeGreen,
        ),
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

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appStore,
      builder: (context, _) {
        final user = SupabaseService.isInitialized ? SupabaseService.client.auth.currentUser : null;
        
        return AppScaffold(
          title: 'Settings',
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              // --- ACCOUNT SECTION ---
              _buildSectionHeader('Account', Icons.shield_rounded),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: user == null ? AppColors.expenseRed.withOpacity(0.1) : AppColors.incomeGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            user == null ? Icons.person_off_rounded : Icons.verified_user_rounded,
                            color: user == null ? AppColors.expenseRed : AppColors.incomeGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user == null ? 'Not signed in' : 'Signed in securely',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                              ),
                              if (user?.email != null)
                                Text(user!.email!, style: const TextStyle(color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (user?.email != null) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(color: AppColors.borderLight),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: user!.email!));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email copied.'), backgroundColor: AppColors.primary),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        label: const Text('Copy Email Address'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
                      ),
                    ],
                  ],
                ),
              ),

              // --- BUSINESS PROFILE ---
              _buildSectionHeader('Business Profile', Icons.storefront_rounded),
              _buildCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _bizName,
                      decoration: const InputDecoration(
                        labelText: 'Business Name',
                        prefixIcon: Icon(Icons.business_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _industry,
                      decoration: const InputDecoration(
                        labelText: 'Industry',
                        prefixIcon: Icon(Icons.category_rounded),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Profile'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),

              // --- BUDGETS ---
              _buildSectionHeader('Category Budgets', Icons.pie_chart_rounded),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!appStore.hasSavedBudgets)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.infoBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, color: AppColors.infoBlue, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Move sliders to set monthly budget limits.',
                                style: TextStyle(color: AppColors.infoBlue, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ...appStore.categoryBudgets.entries.map((e) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text('${e.value.toStringAsFixed(0)} PKR', 
                                  style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
                              ],
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: AppColors.primary.withOpacity(0.2),
                                thumbColor: AppColors.primary,
                                overlayColor: AppColors.primary.withOpacity(0.1),
                                valueIndicatorColor: AppColors.primary,
                              ),
                              child: Slider(
                                value: e.value.clamp(5000, 500000),
                                min: 5000,
                                max: 500000,
                                divisions: 99,
                                label: e.value.toStringAsFixed(0),
                                onChanged: (v) {
                                  appStore.setBudget(e.key, v).then((err) {
                                    if (!context.mounted) return;
                                    if (err != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(err), backgroundColor: AppColors.expenseRed));
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // --- CLASSIC VIEW BUTTON ---
              _buildSectionHeader('App View', Icons.dashboard_customize_rounded),
              _buildCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
                  ),
                  title: const Text('Classic Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Switch back to the original simple layout', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OldDashboardScreen()),
                    );
                  },
                ),
              ),

              // --- PREFERENCES ---
              _buildSectionHeader('Preferences', Icons.tune_rounded),
              _buildCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: appStore.notificationsEnabled,
                      onChanged: (v) => appStore.setNotifications(v),
                      activeColor: AppColors.primary,
                      title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Reminders & daily summary', style: TextStyle(fontSize: 12)),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(color: AppColors.borderLight),
                    SwitchListTile(
                      value: appStore.biometricLockEnabled,
                      onChanged: (v) => appStore.setBiometricLock(v),
                      activeColor: AppColors.primary,
                      title: const Text('Biometric Lock', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Require fingerprint/face to open', style: TextStyle(fontSize: 12)),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(color: AppColors.borderLight),
                    const SizedBox(height: AppSpacing.sm),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<ThemeMode>(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                          if (states.contains(MaterialState.selected)) return AppColors.primary.withOpacity(0.1);
                          return Colors.transparent;
                        }),
                      ),
                      segments: const [
                        ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded), label: Text('Light')),
                        ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_rounded), label: Text('Dark')),
                        ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.phone_android_rounded), label: Text('Auto')),
                      ],
                      selected: {appStore.themeMode},
                      onSelectionChanged: (s) => appStore.updateThemeMode(s.first),
                    ),
                  ],
                ),
              ),

              // --- EXPORT & SIGN OUT ---
              _buildSectionHeader('Data & Security', Icons.security_rounded),
              _buildCard(
                child: Column(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _csvExport()));
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('CSV copied to clipboard!'), backgroundColor: AppColors.primary),
                        );
                      },
                      icon: const Icon(Icons.file_download_rounded),
                      label: const Text('Export to CSV'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton.icon(
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
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expenseRed,
                        side: const BorderSide(color: AppColors.expenseRed),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}
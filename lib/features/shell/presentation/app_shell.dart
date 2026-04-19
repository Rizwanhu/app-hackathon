import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../ledger/presentation/ledger_screen.dart';
import '../../ai_advisor/presentation/ai_advisor_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/data/app_store_scope.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => appStore.refresh());
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onBottomNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: return 'Dashboard';
      case 1: return 'Ledger';
      case 2: return 'AI Advisor';
      default: return 'FlowSense';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      
      // --- PREMIUM APPBAR ---
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          _getTitle(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 22,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // --- MODERN DRAWER ---
      drawer: Drawer(
        backgroundColor: AppColors.surface,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppColors.primary),
              accountName: const Text("SME Owner", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              accountEmail: const Text("owner@business.com"),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
                  ],
                ),
                child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 36),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerTile(context, Icons.person_outline, 'My Profile', '/app/dashboard/profile'),
                  _buildDrawerTile(context, Icons.call_received_rounded, 'Receivables', '/app/dashboard/receivables'),
                  _buildDrawerTile(context, Icons.call_made_rounded, 'Payables', '/app/dashboard/payables'),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(height: 32, color: AppColors.borderLight),
                  ),
                  _buildDrawerTile(context, Icons.settings_outlined, 'Settings', '/app/dashboard/settings'),
                ],
              ),
            ),
          ],
        ),
      ),

      // --- SWIPEABLE BODY ---
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(), // Modern iOS like bounce
        children: const [
          DashboardScreen(),
          LedgerScreen(),
          AiAdvisorScreen(),
        ],
      ),

      // --- PREMIUM BOTTOM NAVIGATION ---
      bottomNavigationBar: _buildPremiumNavBar(),
    );
  }

  // Helper method Drawer ke items ke liye
  Widget _buildDrawerTile(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      onTap: () {
        Navigator.pop(context); // Drawer close karo
        context.push(route);    // Nayi screen par jao
      },
    );
  }

  // Helper method Bottom Bar ke liye
  Widget _buildPremiumNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary);
            }
            return const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 26);
            }
            return const IconThemeData(color: AppColors.textSecondary, size: 24);
          }),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onBottomNavTapped,
          height: 70,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Ledger',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined),
              selectedIcon: Icon(Icons.auto_awesome_rounded),
              label: 'AI Advisor',
            ),
          ],
        ),
      ),
    );
  }
}
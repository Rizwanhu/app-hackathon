import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../ledger/presentation/ledger_screen.dart';
import '../../ai_advisor/presentation/ai_advisor_screen.dart';
import '../../../core/constants/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

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
      // --- THE APPBAR LIVES HERE NOW ---
      appBar: AppBar(
        title: Text(_getTitle()),
        centerTitle: true,
        // The 3-line menu icon will appear here automatically because of 'drawer' below
      ),

      // --- THE DRAWER (3-line menu) ---
      drawer: Drawer(
        child: Column(
          children: [
            const UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              accountName: Text("SME Owner"),
              accountEmail: Text("owner@business.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.primary),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
                context.push('/app/dashboard/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_received),
              title: const Text('Receivables'),
              onTap: () {
                Navigator.pop(context);
                context.push('/app/dashboard/receivables');
              },
            ),
            ListTile(
              leading: const Icon(Icons.call_made),
              title: const Text('Payables'),
              onTap: () {
                Navigator.pop(context);
                context.push('/app/dashboard/payables');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                context.push('/app/dashboard/settings');
              },
            ),
          ],
        ),
      ),

      // --- SWIPEABLE BODY ---
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: const [
          DashboardScreen(),
          LedgerScreen(),
          AiAdvisorScreen(),
        ],
      ),

      // --- BOTTOM NAVIGATION ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Ledger'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Advisor'),
        ],
      ),
    );
  }
}
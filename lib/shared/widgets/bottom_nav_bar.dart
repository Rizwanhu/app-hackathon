import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Ledger'),
        NavigationDestination(icon: Icon(Icons.people_alt), label: 'Receivables'),
        NavigationDestination(icon: Icon(Icons.payments), label: 'Payables'),
        NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'AI'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}


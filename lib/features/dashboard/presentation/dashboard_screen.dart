import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Dashboard',
      body: Center(
        child: Text('FlowSense dashboard skeleton'),
      ),
    );
  }
}


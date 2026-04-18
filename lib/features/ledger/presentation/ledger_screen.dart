import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Ledger',
      body: Center(child: Text('Ledger skeleton')),
    );
  }
}


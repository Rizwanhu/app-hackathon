import 'package:flutter/material.dart';

import '../../../shared/widgets/app_scaffold.dart';

class PayablesScreen extends StatelessWidget {
  const PayablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Payables',
      body: Center(child: Text('Payables skeleton')),
    );
  }
}


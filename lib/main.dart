import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'controllers/cash_flow_bloc.dart';
import 'views/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your credentials from the dashboard
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(
    BlocProvider(
      create: (context) => CashFlowBloc(),
      child: const FlowSenseApp(),
    ),
  );
}

class FlowSenseApp extends StatelessWidget {
  const FlowSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlowSense SME',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1A6B4A), // Professional Emerald Green
      ),
      home: const DashboardScreen(),
    );
  }
}
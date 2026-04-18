import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  // 1. Ensure Flutter is ready for async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the .env file from the project root
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found. Ensure it is in the root folder.");
  }

  // 3. Initialize Supabase via our shared service so router/auth stay in sync.
  await SupabaseService.initialize();

  runApp(const FlowSenseApp());
}
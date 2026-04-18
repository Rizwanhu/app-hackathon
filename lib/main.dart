import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';

Future<void> main() async {
  // 1. Ensure Flutter is ready for async calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load the .env file from the project root
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: .env file not found. Ensure it is in the root folder.");
  }

  // 3. Initialize Supabase directly
  // We use the direct keys from dotenv here for simplicity as requested
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const FlowSenseApp());
}
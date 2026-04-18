import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  // These getters pull the values from the .env file in your project root
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
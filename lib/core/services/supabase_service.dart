import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/env.dart';

/// Centralized Supabase initialization.
///
/// For now this stays intentionally "light": if env vars aren't provided,
/// the app still boots (useful for UI-only development).
class SupabaseService {
  static SupabaseClient? _client;

  static SupabaseClient get client {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase not initialized. Provide env vars and restart.');
    }
    return client;
  }

  static bool get isInitialized => _client != null;

  static Future<void> initialize() async {
    final url = Env.supabaseUrl.trim();
    final anonKey = Env.supabaseAnonKey.trim();
    if (url.isEmpty || anonKey.isEmpty) {
      return;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
  }
}


import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

class AuthService {
  SupabaseClient get _client {
    if (!SupabaseService.isInitialized) {
      throw StateError(
        'Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY in .env.',
      );
    }
    return SupabaseService.client;
  }

  /// Sign Up with Email, Password, and Username
  /// Ensure "Confirm Email" is OFF in Supabase Dashboard for direct login
  Future<AuthResponse> signUp(String email, String password, String username) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );
      return response;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'An unexpected error occurred during signup.';
    }
  }

  /// Login with Email and Password
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Login failed. Please check your internet connection.';
    }
  }

  /// Sign Out
  Future<void> signOut() async => _client.auth.signOut();

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => _client.auth.currentSession != null;
}

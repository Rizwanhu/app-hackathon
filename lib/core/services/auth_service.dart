import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign Up with Email and Password
  /// Note: Ensure "Confirm Email" is OFF in Supabase Auth settings for demo.
  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email, 
        password: password
      );
      return response;
    } on AuthException catch (e) {
      // Catching specific Supabase Auth errors (e.g., Email already exists)
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during signup.');
    }
  }

  /// Login with Email and Password
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email, 
        password: password
      );
      return response;
    } on AuthException catch (e) {
      // Catching specific login errors (e.g., Invalid credentials)
      throw Exception(e.message);
    } catch (e) {
      throw Exception('An unexpected error occurred during login.');
    }
  }

  /// Sends a Password Reset Link to the user's email
  /// Requires Deep Linking setup in Supabase Dashboard
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.flowsense://reset-callback/',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Sign Out the current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw Exception('Logout failed.');
    }
  }

  /// Helper to get the current logged in user
  User? get currentUser => _supabase.auth.currentUser;

  /// Helper to check if a user is currently authenticated
  bool get isAuthenticated => _supabase.auth.currentSession != null;
}
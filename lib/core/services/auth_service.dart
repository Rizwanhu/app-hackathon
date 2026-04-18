import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign Up with Email, Password, and Username
  /// Ensure "Confirm Email" is OFF in Supabase Dashboard for direct login
  Future<AuthResponse> signUp(String email, String password, String username) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        // metadata allows our SQL trigger to see the username
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
      final response = await _supabase.auth.signInWithPassword(
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
  Future<void> signOut() async => await _supabase.auth.signOut();

  /// Helpers
  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => _supabase.auth.currentSession != null;
}
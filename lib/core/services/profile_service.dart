import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final _supabase = Supabase.instance.client;

  User? get currentUser => _supabase.auth.currentUser;

  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return await _supabase.from('profiles').select().eq('id', user.id).maybeSingle();
  }

  Future<void> updateProfile({required String username, String? avatarUrl}) async {
    final user = currentUser;
    if (user == null) return;

    // Use UPSERT: It inserts if missing, updates if exists.
    await _supabase.from('profiles').upsert({
      'id': user.id,
      'username': username,
      'email': user.email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
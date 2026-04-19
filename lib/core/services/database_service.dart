import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final _supabase = Supabase.instance.client;

  // --- AUTH HELPER ---
  User? get user => _supabase.auth.currentUser;

  // ==========================================
  // 1. PROFILE FUNCTIONALITY
  // Table: profiles | Columns: id, username, email, avatar_url
  // ==========================================
  
  Future<Map<String, dynamic>?> getProfile() async {
    if (user == null) return null;
    return await _supabase.from('profiles').select().eq('id', user!.id).maybeSingle();
  }

  Future<void> saveProfile({required String username, String? avatarUrl}) async {
    if (user == null) return;
    await _supabase.from('profiles').upsert({
      'id': user!.id,
      'username': username,
      'email': user!.email,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================
  // 2. LEDGER / TRANSACTIONS FUNCTIONALITY
  // Table: transactions | Columns: id, user_id, description, amount, category, type, date
  // ==========================================

  Future<List<Map<String, dynamic>>> getTransactions() async {
    if (user == null) return [];
    return await _supabase
        .from('transactions')
        .select()
        .eq('user_id', user!.id)
        .order('date', ascending: false);
  }

  Future<void> addTransaction({
    required String description,
    required double amount,
    required String category,
    required String type, // 'income' or 'expense'
  }) async {
    if (user == null) return;
    await _supabase.from('transactions').insert({
      'user_id': user!.id,
      'description': description,
      'amount': amount,
      'category': category,
      'type': type,
      'date': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================
  // 3. STORAGE HELPER (For Images)
  // Bucket: avatars
  // ==========================================
  
  Future<String> uploadImage(String fileName, dynamic fileSource) async {
    // This works for both File (Mobile) and Bytes (Web/Edge)
    await _supabase.storage.from('avatars').uploadBinary(fileName, fileSource);
    return _supabase.storage.from('avatars').getPublicUrl(fileName);
  }
}
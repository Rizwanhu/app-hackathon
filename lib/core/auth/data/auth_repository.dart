import '../../../core/services/supabase_service.dart';

class AuthRepository {
  Future<void> signOut() async {
    if (!SupabaseService.isInitialized) return;
    await SupabaseService.client.auth.signOut();
  }
}


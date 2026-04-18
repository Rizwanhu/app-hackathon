import 'package:supabase_flutter/supabase_flutter.dart' show User;

import '../../core/services/supabase_service.dart';
import '../api_result.dart';
import '../models/profile_model.dart';
import 'supabase_repository_base.dart';

class ProfileRepository extends SupabaseRepositoryBase {
  User? get currentUser => SupabaseService.client.auth.currentUser;

  Future<ApiResult<ProfileModel?>> fetchProfile() {
    return guard(() async {
      final user = SupabaseService.client.auth.currentUser;
      if (user == null) return null;
      final row = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (row == null) return null;
      return ProfileModel.fromJson(Map<String, dynamic>.from(row));
    });
  }

  Future<ApiResult<ProfileModel>> upsertProfile({
    required String username,
    String? avatarUrl,
  }) {
    return guard(() async {
      final user = SupabaseService.client.auth.currentUser!;
      final model = ProfileModel(id: user.id, email: user.email);
      final payload = model.toUpsertJson(
        username: username,
        email: user.email,
        avatarUrl: avatarUrl,
      );
      final row = await SupabaseService.client.from('profiles').upsert(payload).select().single();
      return ProfileModel.fromJson(Map<String, dynamic>.from(row));
    });
  }
}

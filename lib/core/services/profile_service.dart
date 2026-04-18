import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/api_result.dart';
import '../../data/models/profile_model.dart';
import '../../services/sme_app_services.dart';

/// User profile + avatar flows; delegates to [SmeAppServices] repositories.
class ProfileService {
  ProfileService({SmeAppServices? services})
      : _services = services ?? SmeAppServices.instance;

  final SmeAppServices _services;

  User? get currentUser => _services.profile.currentUser;

  Future<ApiResult<ProfileModel?>> fetchProfile() => _services.profile.fetchProfile();

  Future<ApiResult<ProfileModel>> saveProfile({
    required String username,
    String? avatarUrl,
  }) {
    return _services.profile.upsertProfile(username: username, avatarUrl: avatarUrl);
  }

  /// Backward-compatible map shape for older UI code.
  Future<Map<String, dynamic>?> getProfile() async {
    final result = await fetchProfile();
    if (result.isFailure || result.dataOrNull == null) return null;
    final p = result.dataOrNull!;
    return {
      'id': p.id,
      'username': p.username,
      'avatar_url': p.avatarUrl,
      'email': p.email,
      'updated_at': p.updatedAt?.toIso8601String(),
    };
  }

  Future<ApiResult<ProfileModel>> updateProfile({
    required String username,
    String? avatarUrl,
  }) {
    return saveProfile(username: username, avatarUrl: avatarUrl);
  }
}

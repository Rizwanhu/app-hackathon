import 'dart:io';

import '../../core/services/supabase_service.dart';
import '../api_result.dart';
import 'supabase_repository_base.dart';

/// Avatar uploads must use path `{user_id}/{fileName}` for RLS.
class StorageRepository extends SupabaseRepositoryBase {
  static const String avatarsBucket = 'avatars';

  Future<ApiResult<String>> uploadAvatarFile({
    required File file,
    required String fileExtension,
  }) {
    return guard(() async {
      final uid = SupabaseService.client.auth.currentUser!.id;
      final safeExt = fileExtension.replaceAll('.', '');
      final name = '${DateTime.now().millisecondsSinceEpoch}.$safeExt';
      final path = '$uid/$name';
      await SupabaseService.client.storage.from(avatarsBucket).upload(path, file);
      return SupabaseService.client.storage.from(avatarsBucket).getPublicUrl(path);
    });
  }
}

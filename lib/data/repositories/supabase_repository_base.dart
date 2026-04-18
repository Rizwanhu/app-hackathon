import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/services/supabase_service.dart';
import '../api_result.dart';

/// Shared guard + error mapping for Postgres / auth failures.
abstract class SupabaseRepositoryBase {
  Future<ApiResult<T>> guard<T>(Future<T> Function() action) async {
    if (!SupabaseService.isInitialized) {
      return ApiFailure(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to .env.',
      );
    }
    if (SupabaseService.client.auth.currentSession == null) {
      return ApiFailure('You must be signed in to access this data.');
    }
    try {
      return ApiSuccess(await action());
    } on PostgrestException catch (e) {
      return ApiFailure(e.message, code: e.code);
    } on AuthException catch (e) {
      return ApiFailure(e.message);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
}

import '../../core/services/supabase_service.dart';
import '../api_result.dart';
import '../models/business_model.dart';
import 'supabase_repository_base.dart';

class BusinessRepository extends SupabaseRepositoryBase {
  Future<ApiResult<BusinessModel>> getOrCreatePrimary({
    String defaultName = 'My business',
    String currency = 'PKR',
    String? industry,
  }) {
    return guard(() async {
      final uid = SupabaseService.client.auth.currentUser!.id;
      final existing = await SupabaseService.client
          .from('businesses')
          .select()
          .eq('owner_id', uid)
          .order('created_at')
          .limit(1)
          .maybeSingle();
      if (existing != null) {
        return BusinessModel.fromJson(Map<String, dynamic>.from(existing));
      }
      final row = await SupabaseService.client
          .from('businesses')
          .insert({
            'owner_id': uid,
            'name': defaultName,
            if (industry != null) 'industry': industry,
            'currency': currency,
          })
          .select()
          .single();
      return BusinessModel.fromJson(Map<String, dynamic>.from(row));
    });
  }

  Future<ApiResult<BusinessModel>> updateBusiness({
    required String businessId,
    String? name,
    String? industry,
    String? currency,
  }) {
    return guard(() async {
      final payload = <String, dynamic>{
        if (name != null) 'name': name,
        if (industry != null) 'industry': industry,
        if (currency != null) 'currency': currency,
      };
      if (payload.isEmpty) {
        final row = await SupabaseService.client.from('businesses').select().eq('id', businessId).single();
        return BusinessModel.fromJson(Map<String, dynamic>.from(row));
      }
      final row = await SupabaseService.client
          .from('businesses')
          .update(payload)
          .eq('id', businessId)
          .select()
          .single();
      return BusinessModel.fromJson(Map<String, dynamic>.from(row));
    });
  }

  Future<ApiResult<List<BusinessModel>>> listOwned() {
    return guard(() async {
      final uid = SupabaseService.client.auth.currentUser!.id;
      final rows = await SupabaseService.client.from('businesses').select().eq('owner_id', uid).order('created_at');
      final list = rows as List<dynamic>;
      return list.map((e) => BusinessModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    });
  }
}

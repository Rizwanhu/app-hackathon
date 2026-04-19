import '../../core/services/supabase_service.dart';
import '../api_result.dart';
import '../models/budget_model.dart';
import 'supabase_repository_base.dart';

class BudgetRepository extends SupabaseRepositoryBase {
  Future<ApiResult<List<BudgetModel>>> listForBusinessAndMonth(String businessId, String monthYear) {
    return guard(() async {
      final rows = await SupabaseService.client
          .from('budgets')
          .select()
          .eq('business_id', businessId)
          .eq('month_year', monthYear)
          .order('category');
      final list = rows as List<dynamic>;
      return list.map((e) => BudgetModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    });
  }

  Future<ApiResult<BudgetModel>> upsert({
    required String businessId,
    required String category,
    required double monthlyLimit,
    required String monthYear,
  }) {
    return guard(() async {
      final uid = SupabaseService.client.auth.currentUser!.id;
      // Some dashboard-created schemas miss the UNIQUE(user_id, category, month_year)
      // constraint, which breaks PostgREST upsert(onConflict: ...).
      // So we do a safe "select then update/insert" flow.
      final existing = await SupabaseService.client
          .from('budgets')
          .select()
          .eq('business_id', businessId)
          .eq('user_id', uid)
          .eq('category', category)
          .eq('month_year', monthYear)
          .maybeSingle();

      if (existing != null) {
        final row = await SupabaseService.client
            .from('budgets')
            .update({'monthly_limit': monthlyLimit})
            .eq('id', existing['id'])
            .select()
            .single();
        return BudgetModel.fromJson(Map<String, dynamic>.from(row));
      }

      final payload = {
        'business_id': businessId,
        'user_id': uid,
        'category': category,
        'monthly_limit': monthlyLimit,
        'month_year': monthYear,
      };
      final row =
          await SupabaseService.client.from('budgets').insert(payload).select().single();
      return BudgetModel.fromJson(Map<String, dynamic>.from(row));
    });
  }
}

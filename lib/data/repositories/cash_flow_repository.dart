import '../../core/services/supabase_service.dart';
import '../api_result.dart';
import '../models/cash_flow_summary_model.dart';
import 'supabase_repository_base.dart';

class CashFlowRepository extends SupabaseRepositoryBase {
  Future<ApiResult<List<CashFlowSummaryModel>>> summaryForCurrentUser() {
    return guard(() async {
      final uid = SupabaseService.client.auth.currentUser!.id;
      final rows = await SupabaseService.client
          .from('cash_flow_summary')
          .select()
          .eq('user_id', uid)
          .order('month', ascending: false);
      final list = rows as List<dynamic>;
      return list.map((e) => CashFlowSummaryModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    });
  }
}

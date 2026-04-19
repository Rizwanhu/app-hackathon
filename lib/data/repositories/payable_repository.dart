import '../../core/services/supabase_service.dart';
import '../api_result.dart';
import '../models/payable_model.dart';
import 'supabase_repository_base.dart';

class PayableRepository extends SupabaseRepositoryBase {
  Future<ApiResult<List<PayableModel>>> listForBusiness(String businessId) {
    return guard(() async {
      final rows = await SupabaseService.client
          .from('payables')
          .select()
          .eq('business_id', businessId)
          .order('due_date');
      final list = rows as List<dynamic>;
      return list.map((e) => PayableModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    });
  }

  Future<ApiResult<PayableModel>> create({
    required String businessId,
    String? contactId,
    required double amount,
    required DateTime dueDate,
    String status = 'pending',
    String? description,
    String? category,
  }) {
    return guard(() async {
      final payload = PayableModel(
        id: '',
        businessId: businessId,
        contactId: contactId,
        amount: amount,
        dueDate: dueDate,
        status: status,
      ).toInsertJson(
        businessId: businessId,
        contactId: contactId,
        amount: amount,
        dueDate: dueDate,
        status: status,
        description: description,
        category: category,
      );
      final row = await SupabaseService.client.from('payables').insert(payload).select().single();
      return PayableModel.fromJson(Map<String, dynamic>.from(row));
    });
  }

  Future<ApiResult<PayableModel>> updateStatus({
    required String id,
    required String status,
  }) {
    return guard(() async {
      final row = await SupabaseService.client
          .from('payables')
          .update({'status': status})
          .eq('id', id)
          .select()
          .single();
      return PayableModel.fromJson(Map<String, dynamic>.from(row));
    });
  }
}

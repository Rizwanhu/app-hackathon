import '../../core/services/supabase_service.dart';
import '../api_result.dart';
import '../models/receivable_model.dart';
import 'supabase_repository_base.dart';

class ReceivableRepository extends SupabaseRepositoryBase {
  Future<ApiResult<List<ReceivableModel>>> listForBusiness(String businessId) {
    return guard(() async {
      final rows = await SupabaseService.client
          .from('receivables')
          // Join contact details for UI (requires FK receivables.contact_id -> contacts.id)
          .select('id,business_id,contact_id,amount,amount_paid,due_date,status,note,created_at,contacts(name,phone)')
          .eq('business_id', businessId)
          .order('due_date');
      final list = rows as List<dynamic>;
      return list
          .map((e) => ReceivableModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    });
  }

  Future<ApiResult<ReceivableModel>> create(ReceivableModel draft) {
    return guard(() async {
      final payload = draft.toInsertJson(
        businessId: draft.businessId,
        contactId: draft.contactId,
        amount: draft.amount,
        amountPaid: draft.amountPaid,
        dueDate: draft.dueDate,
        status: draft.status,
        note: draft.note,
      );
      final row = await SupabaseService.client
          .from('receivables')
          .insert(payload)
          .select('id,business_id,contact_id,amount,amount_paid,due_date,status,note,created_at,contacts(name,phone)')
          .single();
      return ReceivableModel.fromJson(Map<String, dynamic>.from(row));
    });
  }

  Future<ApiResult<ReceivableModel>> updateRow({
    required String id,
    String? status,
    String? note,
  }) {
    return guard(() async {
      final payload = <String, dynamic>{
        if (status != null) 'status': status,
        if (note != null) 'note': note,
      };
      if (payload.isEmpty) {
        final row = await SupabaseService.client
            .from('receivables')
            .select()
            .eq('id', id)
            .single();
        return ReceivableModel.fromJson(Map<String, dynamic>.from(row));
      }
      final row = await SupabaseService.client
          .from('receivables')
          .update(payload)
          .eq('id', id)
          .select()
          .single();
      return ReceivableModel.fromJson(Map<String, dynamic>.from(row));
    });
  }
}

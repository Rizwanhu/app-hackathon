import '../../core/services/supabase_service.dart';
import '../api_result.dart';
import '../models/transaction_model.dart';
import 'supabase_repository_base.dart';

class TransactionRepository extends SupabaseRepositoryBase {
  Future<ApiResult<List<TransactionModel>>> listForBusiness(String businessId, {int? limit}) {
    return guard(() async {
      var q = SupabaseService.client
          .from('transactions')
          .select()
          .eq('business_id', businessId)
          .order('transaction_date', ascending: false);
      if (limit != null) q = q.limit(limit);
      final rows = await q;
      final list = rows as List<dynamic>;
      return list.map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    });
  }

  Future<ApiResult<TransactionModel>> create({
    required String businessId,
    required String type,
    required double amount,
    required String category,
    String? description,
    DateTime? transactionDate,
  }) {
    return guard(() async {
      final uid = SupabaseService.client.auth.currentUser!.id;
      final payload = TransactionModel(
        id: '',
        businessId: businessId,
        userId: uid,
        type: type,
        amount: amount,
        category: category,
        description: description,
        transactionDate: transactionDate ?? DateTime.now(),
      ).toInsertJson(
        businessId: businessId,
        userId: uid,
        type: type,
        amount: amount,
        category: category,
        description: description,
        transactionDate: transactionDate,
      );
      final row = await SupabaseService.client.from('transactions').insert(payload).select().single();
      return TransactionModel.fromJson(Map<String, dynamic>.from(row));
    });
  }

  Future<ApiResult<TransactionModel>> update({
    required String id,
    String? type,
    double? amount,
    String? category,
    String? description,
    DateTime? transactionDate,
  }) {
    return guard(() async {
      final payload = <String, dynamic>{
        if (type != null) 'type': type,
        if (amount != null) 'amount': amount,
        if (category != null) 'category': category,
        if (description != null) 'description': description,
        if (transactionDate != null)
          'transaction_date':
              '${transactionDate.year.toString().padLeft(4, '0')}-${transactionDate.month.toString().padLeft(2, '0')}-${transactionDate.day.toString().padLeft(2, '0')}',
      };
      if (payload.isEmpty) {
        final row = await SupabaseService.client.from('transactions').select().eq('id', id).single();
        return TransactionModel.fromJson(Map<String, dynamic>.from(row));
      }
      final row =
          await SupabaseService.client.from('transactions').update(payload).eq('id', id).select().single();
      return TransactionModel.fromJson(Map<String, dynamic>.from(row));
    });
  }

  Future<ApiResult<void>> delete(String id) {
    return guard(() async {
      await SupabaseService.client.from('transactions').delete().eq('id', id);
    });
  }
}

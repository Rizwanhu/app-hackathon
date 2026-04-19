import '../../core/services/supabase_service.dart';
import '../api_result.dart';
import '../models/contact_model.dart';
import 'supabase_repository_base.dart';

class ContactRepository extends SupabaseRepositoryBase {
  Future<ApiResult<List<ContactModel>>> listForBusiness(String businessId) {
    return guard(() async {
      final rows =
          await SupabaseService.client.from('contacts').select().eq('business_id', businessId).order('name');
      final list = rows as List<dynamic>;
      return list.map((e) => ContactModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    });
  }

  Future<ApiResult<ContactModel>> create({
    required String businessId,
    required String name,
    String? phone,
    String? email,
    String? type,
  }) {
    return guard(() async {
      final uid = SupabaseService.client.auth.currentUser!.id;
      final payload = ContactModel(
        id: '',
        businessId: businessId,
        userId: uid,
        name: name,
      ).toInsertJson(
        businessId: businessId,
        userId: uid,
        name: name,
        phone: phone,
        email: email,
        type: type,
      );
      final row = await SupabaseService.client.from('contacts').insert(payload).select().single();
      return ContactModel.fromJson(Map<String, dynamic>.from(row));
    });
  }
}

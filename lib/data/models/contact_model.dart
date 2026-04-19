import 'json_helpers.dart';

class ContactModel {
  final String id;
  final String businessId;
  final String userId;
  final String name;
  final String? phone;
  final String? email;
  final String? type;
  final DateTime? createdAt;

  const ContactModel({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.name,
    this.phone,
    this.email,
    this.type,
    this.createdAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      type: json['type'] as String?,
      createdAt: parseSupabaseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toInsertJson({
    required String businessId,
    required String userId,
    required String name,
    String? phone,
    String? email,
    String? type,
  }) {
    return {
      'business_id': businessId,
      'user_id': userId,
      'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (type != null) 'type': type,
    };
  }
}

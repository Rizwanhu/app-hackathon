import 'json_helpers.dart';

class BusinessModel {
  final String id;
  final String ownerId;
  final String name;
  final String? industry;
  final String currency;
  final DateTime? createdAt;

  const BusinessModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.industry,
    required this.currency,
    this.createdAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      industry: json['industry'] as String?,
      currency: (json['currency'] as String?) ?? 'PKR',
      createdAt: parseSupabaseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toInsertJson({
    required String ownerId,
    required String name,
    String? industry,
    String currency = 'PKR',
  }) {
    return {
      'owner_id': ownerId,
      'name': name,
      if (industry != null) 'industry': industry,
      'currency': currency,
    };
  }
}

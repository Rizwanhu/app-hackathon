import 'json_helpers.dart';

class PayableModel {
  final String id;
  final String businessId;
  final String? userId;
  final String? contactId;
  final double amount;
  final DateTime dueDate;
  final String status;
  final String? description;
  final String? category;
  final DateTime? createdAt;

  const PayableModel({
    required this.id,
    required this.businessId,
    this.userId,
    this.contactId,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.description,
    this.category,
    this.createdAt,
  });

  factory PayableModel.fromJson(Map<String, dynamic> json) {
    return PayableModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      userId: json['user_id'] as String?,
      contactId: json['contact_id'] as String?,
      amount: parseMoney(json['amount']),
      dueDate: parseSupabaseDate(json['due_date']) ?? DateTime.now(),
      status: json['status'] as String? ?? 'pending',
      description: json['description'] as String?,
      category: json['category'] as String?,
      createdAt: parseSupabaseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toInsertJson({
    required String businessId,
    String? contactId,
    required double amount,
    required DateTime dueDate,
    String status = 'pending',
    String? description,
    String? category,
  }) {
    final d = dueDate;
    return {
      'business_id': businessId,
      if (contactId != null) 'contact_id': contactId,
      'amount': amount,
      'due_date':
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      'status': status,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
    };
  }
}

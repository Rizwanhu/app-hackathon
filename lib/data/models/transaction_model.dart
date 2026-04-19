import 'json_helpers.dart';

class TransactionModel {
  final String id;
  final String businessId;
  final String userId;
  final String type;
  final double amount;
  final String category;
  final String? description;
  final DateTime transactionDate;
  final DateTime? createdAt;

  const TransactionModel({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    this.description,
    required this.transactionDate,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      amount: parseMoney(json['amount']),
      category: json['category'] as String,
      description: json['description'] as String?,
      transactionDate: parseSupabaseDate(json['transaction_date']) ?? DateTime.now(),
      createdAt: parseSupabaseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toInsertJson({
    required String businessId,
    required String userId,
    required String type,
    required double amount,
    required String category,
    String? description,
    DateTime? transactionDate,
  }) {
    final d = transactionDate ?? DateTime.now();
    return {
      'business_id': businessId,
      'user_id': userId,
      'type': type,
      'amount': amount,
      'category': category,
      if (description != null) 'description': description,
      'transaction_date':
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
    };
  }
}

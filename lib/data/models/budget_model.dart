import 'json_helpers.dart';

class BudgetModel {
  final String id;
  final String businessId;
  final String userId;
  final String category;
  final double monthlyLimit;
  final String monthYear;

  const BudgetModel({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.category,
    required this.monthlyLimit,
    required this.monthYear,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      userId: json['user_id'] as String,
      category: json['category'] as String,
      monthlyLimit: parseMoney(json['monthly_limit']),
      monthYear: json['month_year'] as String,
    );
  }

  Map<String, dynamic> toInsertJson({
    required String businessId,
    required String userId,
    required String category,
    required double monthlyLimit,
    required String monthYear,
  }) {
    return {
      'business_id': businessId,
      'user_id': userId,
      'category': category,
      'monthly_limit': monthlyLimit,
      'month_year': monthYear,
    };
  }

  static String monthYearFromDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';
}

import 'json_helpers.dart';

class CashFlowSummaryModel {
  final String userId;
  final DateTime month;
  final double totalIncome;
  final double totalExpense;
  final double netCash;

  const CashFlowSummaryModel({
    required this.userId,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCash,
  });

  factory CashFlowSummaryModel.fromJson(Map<String, dynamic> json) {
    return CashFlowSummaryModel(
      userId: json['user_id'] as String,
      month: parseSupabaseDate(json['month']) ?? DateTime.now(),
      totalIncome: parseMoney(json['total_income']),
      totalExpense: parseMoney(json['total_expense']),
      netCash: parseMoney(json['net_cash']),
    );
  }
}

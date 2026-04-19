import 'json_helpers.dart';

class ReceivableModel {
  final String id;
  final String businessId;
  final String contactId;
  final double amount;
  final double amountPaid;
  final DateTime dueDate;
  final String status;
  final String? note;
  final DateTime? createdAt;
  final String? contactName;
  final String? contactPhone;

  const ReceivableModel({
    required this.id,
    required this.businessId,
    required this.contactId,
    required this.amount,
    required this.amountPaid,
    required this.dueDate,
    required this.status,
    this.note,
    this.createdAt,
    this.contactName,
    this.contactPhone,
  });

  factory ReceivableModel.fromJson(Map<String, dynamic> json) {
    final contact = json['contacts'];
    final contactMap = contact is Map ? Map<String, dynamic>.from(contact) : null;
    return ReceivableModel(
      id: json['id'] as String,
      businessId: (json['business_id'] ?? '') as String,
      contactId: (json['contact_id'] ?? '') as String,
      amount: parseMoney(json['amount']),
      amountPaid: parseMoney(json['amount_paid']),
      dueDate: parseSupabaseDate(json['due_date']) ?? DateTime.now(),
      status: (json['status'] as String?) ?? 'pending',
      note: json['note'] as String?,
      createdAt: parseSupabaseDate(json['created_at']),
      contactName: contactMap?['name'] as String?,
      contactPhone: contactMap?['phone'] as String?,
    );
  }

  Map<String, dynamic> toInsertJson({
    required String businessId,
    required String contactId,
    required double amount,
    double amountPaid = 0,
    required DateTime dueDate,
    String status = 'pending',
    String? note,
  }) {
    final d = dueDate;
    return {
      'business_id': businessId,
      'contact_id': contactId,
      'amount': amount,
      'amount_paid': amountPaid,
      'due_date':
          '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      'status': status,
      if (note != null) 'note': note,
    };
  }
}

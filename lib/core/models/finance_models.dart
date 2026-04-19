
enum TransactionType { income, expense }

class CashTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String category;
  final String contactName;
  final DateTime date;
  final String note;
  final bool hasReceipt;

  const CashTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.contactName,
    required this.date,
    required this.note,
    this.hasReceipt = false,
  });

  CashTransaction copyWith({
    TransactionType? type,
    double? amount,
    String? category,
    String? contactName,
    DateTime? date,
    String? note,
    bool? hasReceipt,
  }) {
    return CashTransaction(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      contactName: contactName ?? this.contactName,
      date: date ?? this.date,
      note: note ?? this.note,
      hasReceipt: hasReceipt ?? this.hasReceipt,
    );
  }
}

enum ReceivableStatus { pending, promised, partial, paid, disputed }

class Receivable {
  final String id;
  final String contactName;
  final String phoneNumber;
  final double amount;
  final DateTime dueDate;
  final ReceivableStatus status;
  final int riskScore;
  final List<String> followUps;

  const Receivable({
    required this.id,
    required this.contactName,
    required this.phoneNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.riskScore,
    required this.followUps,
  });

  int get daysPastDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return today.difference(due).inDays;
  }

  bool get isOverdue => daysPastDue > 0 && status != ReceivableStatus.paid;

  Receivable copyWith({
    double? amount,
    DateTime? dueDate,
    ReceivableStatus? status,
    int? riskScore,
    List<String>? followUps,
  }) {
    return Receivable(
      id: id,
      contactName: contactName,
      phoneNumber: phoneNumber,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      riskScore: riskScore ?? this.riskScore,
      followUps: followUps ?? this.followUps,
    );
  }
}

class Payable {
  final String id;
  final String vendorName;
  final double amount;
  final DateTime dueDate;
  final bool reminderEnabled;
  final bool isPaid;

  const Payable({
    required this.id,
    required this.vendorName,
    required this.amount,
    required this.dueDate,
    required this.reminderEnabled,
    required this.isPaid,
  });

  int get daysToDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  Payable copyWith({
    double? amount,
    DateTime? dueDate,
    bool? reminderEnabled,
    bool? isPaid,
  }) {
    return Payable(
      id: id,
      vendorName: vendorName,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      isPaid: isPaid ?? this.isPaid,
    );
  }
}

class BusinessProfile {
  final String businessName;
  final String industry;
  final String currency;

  const BusinessProfile({
    required this.businessName,
    required this.industry,
    required this.currency,
  });
}

enum ChartPeriod { week, month, quarter }

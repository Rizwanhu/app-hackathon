import 'package:flutter/material.dart';

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

/// In-memory mock data + mutations for UI-only flows.
class MockStore extends ChangeNotifier {
  MockStore() {
    _seed();
  }

  ThemeMode themeMode = ThemeMode.light;
  bool biometricLockEnabled = false;
  bool notificationsEnabled = true;

  BusinessProfile profile = const BusinessProfile(
    businessName: 'Raja Traders',
    industry: 'Retail / General Store',
    currency: 'PKR',
  );

  final List<CashTransaction> _transactions = [];
  final List<Receivable> _receivables = [];
  final List<Payable> _payables = [];

  final Map<String, double> categoryBudgets = {
    'Stock': 200000,
    'Rent': 60000,
    'Salaries': 150000,
    'Utilities': 30000,
    'Marketing': 20000,
  };

  int _insightIndex = 0;

  List<String> get rotatingInsights => const [
        'Cash is healthy but 3 clients are 14+ days overdue — act now.',
        'Utilities spending is up vs last month — review bills.',
        'Receivables cover most payables this week — good buffer.',
      ];

  String get currentInsight =>
      rotatingInsights[_insightIndex % rotatingInsights.length];

  void nextInsight() {
    _insightIndex++;
    notifyListeners();
  }

  List<CashTransaction> get transactions => List.unmodifiable(_transactions);
  List<Receivable> get receivables => List.unmodifiable(_receivables);
  List<Payable> get payables => List.unmodifiable(_payables);

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  double get netCash => totalIncome - totalExpense;

  double get totalReceivablesPending => _receivables
      .where((r) => r.status != ReceivableStatus.paid)
      .fold(0.0, (s, r) => s + r.amount);

  double get totalPayablesOpen =>
      _payables.where((p) => !p.isPaid).fold(0.0, (s, p) => s + p.amount);

  /// Net cash from transactions in previous calendar month (mock trend).
  double get lastMonthNetCash {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month, 0);
    return _netInRange(start, end);
  }

  double _netInRange(DateTime start, DateTime end) {
    double inflow = 0, outflow = 0;
    for (final t in _transactions) {
      if (t.date.isBefore(start) || t.date.isAfter(end)) continue;
      if (t.type == TransactionType.income) {
        inflow += t.amount;
      } else {
        outflow += t.amount;
      }
    }
    return inflow - outflow;
  }

  double get trendVsLastMonthPct {
    final prev = lastMonthNetCash;
    if (prev == 0) return netCash >= 0 ? 100 : -100;
    return ((netCash - prev) / prev.abs()) * 100;
  }

  /// Expense total for category in current calendar month.
  Map<String, double> expenseByCategoryThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    final map = <String, double>{};
    for (final t in _transactions) {
      if (t.type != TransactionType.expense) continue;
      if (t.date.isBefore(start) || t.date.isAfter(end)) continue;
      map[t.category] = (map[t.category] ?? 0) + t.amount;
    }
    return map;
  }

  double expenseThisMonthForCategory(String category) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.category == category &&
            !t.date.isBefore(start) &&
            !t.date.isAfter(end))
        .fold(0.0, (s, t) => s + t.amount);
  }

  double budgetUsedRatio(String category) {
    final cap = categoryBudgets[category];
    if (cap == null || cap <= 0) return 0;
    return expenseThisMonthForCategory(category) / cap;
  }

  List<String> get categoriesOverBudget80 {
    return categoryBudgets.keys
        .where((c) => budgetUsedRatio(c) >= 0.8)
        .toList();
  }

  /// Daily inflow/outflow for chart: keys are start-of-day DateTime.
  (DateTime start, DateTime end) chartRange(ChartPeriod period) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (period) {
      case ChartPeriod.week:
        return (today.subtract(const Duration(days: 6)), today);
      case ChartPeriod.month:
        return (today.subtract(const Duration(days: 29)), today);
      case ChartPeriod.quarter:
        return (today.subtract(const Duration(days: 89)), today);
    }
  }

  List<({DateTime day, double inflow, double outflow})> chartBars(
    ChartPeriod period,
  ) {
    final range = chartRange(period);
    final map = dailyFlow(range.$1, range.$2);
    final out = <({DateTime day, double inflow, double outflow})>[];
    for (var d = range.$1;
        !d.isAfter(range.$2);
        d = d.add(const Duration(days: 1))) {
      final v = map[d] ?? (inflow: 0.0, outflow: 0.0);
      out.add((day: d, inflow: v.inflow, outflow: v.outflow));
    }
    return out;
  }

  Map<DateTime, ({double inflow, double outflow})> dailyFlow(
    DateTime rangeStart,
    DateTime rangeEnd,
  ) {
    final map = <DateTime, ({double inflow, double outflow})>{};
    for (final t in _transactions) {
      final d = DateTime(t.date.year, t.date.month, t.date.day);
      if (d.isBefore(rangeStart) || d.isAfter(rangeEnd)) continue;
      final cur = map[d] ?? (inflow: 0.0, outflow: 0.0);
      if (t.type == TransactionType.income) {
        map[d] = (
          inflow: cur.inflow + t.amount,
          outflow: cur.outflow,
        );
      } else {
        map[d] = (
          inflow: cur.inflow,
          outflow: cur.outflow + t.amount,
        );
      }
    }
    return map;
  }

  List<CashTransaction> transactionsOnDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _transactions.where((t) {
      final td = DateTime(t.date.year, t.date.month, t.date.day);
      return td == d;
    }).toList();
  }

  List<Receivable> sortedReceivables() {
    final list = List<Receivable>.from(_receivables);
    list.sort((a, b) {
      final aOver = a.isOverdue;
      final bOver = b.isOverdue;
      if (aOver != bOver) return aOver ? -1 : 1;
      if (aOver && bOver) return b.daysPastDue.compareTo(a.daysPastDue);
      return a.dueDate.compareTo(b.dueDate);
    });
    return list;
  }

  List<Payable> sortedPayablesOpen() {
    final list = _payables.where((p) => !p.isPaid).toList();
    list.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return list;
  }

  void updateThemeMode(ThemeMode mode) {
    if (themeMode == mode) return;
    themeMode = mode;
    notifyListeners();
  }

  void updateProfile(BusinessProfile next) {
    profile = next;
    notifyListeners();
  }

  void setBudget(String category, double amount) {
    categoryBudgets[category] = amount;
    notifyListeners();
  }

  void setBiometricLock(bool value) {
    biometricLockEnabled = value;
    notifyListeners();
  }

  void setNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  void addTransaction(CashTransaction t) {
    _transactions.insert(0, t);
    notifyListeners();
  }

  void updateTransaction(String id, CashTransaction next) {
    final idx = _transactions.indexWhere((x) => x.id == id);
    if (idx == -1) return;
    _transactions[idx] = next;
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void addReceivable(Receivable r) {
    _receivables.insert(0, r);
    notifyListeners();
  }

  void updateReceivableStatus(String id, ReceivableStatus status) {
    final idx = _receivables.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    _receivables[idx] = _receivables[idx].copyWith(status: status);
    notifyListeners();
  }

  void addReceivableFollowUp(String id, String note) {
    final idx = _receivables.indexWhere((r) => r.id == id);
    if (idx == -1) return;
    final r = _receivables[idx];
    _receivables[idx] = r.copyWith(followUps: [note, ...r.followUps]);
    notifyListeners();
  }

  void togglePayableReminder(String id) {
    final idx = _payables.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final p = _payables[idx];
    _payables[idx] = p.copyWith(reminderEnabled: !p.reminderEnabled);
    notifyListeners();
  }

  void markPayablePaid(String id) {
    final idx = _payables.indexWhere((p) => p.id == id);
    if (idx == -1) return;
    final p = _payables[idx];
    if (p.isPaid) return;
    _payables[idx] = p.copyWith(isPaid: true);
    addTransaction(
      CashTransaction(
        id: 'tx_${DateTime.now().microsecondsSinceEpoch}',
        type: TransactionType.expense,
        amount: p.amount,
        category: 'Payable',
        contactName: p.vendorName,
        date: DateTime.now(),
        note: 'Payable marked as paid',
      ),
    );
  }

  void _seed() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _transactions.addAll([
      CashTransaction(
        id: 't1',
        type: TransactionType.income,
        amount: 42000,
        category: 'Sales',
        contactName: 'Ahmed Store',
        date: today.subtract(const Duration(days: 1)),
        note: 'Groceries batch',
        hasReceipt: false,
      ),
      CashTransaction(
        id: 't2',
        type: TransactionType.expense,
        amount: 12500,
        category: 'Utilities',
        contactName: 'K-Electric',
        date: today.subtract(const Duration(days: 1)),
        note: 'Electricity bill',
      ),
      CashTransaction(
        id: 't3',
        type: TransactionType.income,
        amount: 18000,
        category: 'Sales',
        contactName: 'Walk-in',
        date: today.subtract(const Duration(days: 2)),
        note: 'Counter sales',
      ),
      CashTransaction(
        id: 't4',
        type: TransactionType.expense,
        amount: 65000,
        category: 'Stock',
        contactName: 'Wholesale Supplier',
        date: today.subtract(const Duration(days: 3)),
        note: 'Restock',
      ),
    ]);

    _receivables.addAll([
      Receivable(
        id: 'r1',
        contactName: 'Ahmed bhai',
        phoneNumber: '923001112233',
        amount: 45000,
        dueDate: today.subtract(const Duration(days: 18)),
        status: ReceivableStatus.pending,
        riskScore: 78,
        followUps: const ['Called on Monday, asked to pay by Friday'],
      ),
      Receivable(
        id: 'r2',
        contactName: 'Shahzad Traders',
        phoneNumber: '923111234567',
        amount: 22000,
        dueDate: today.subtract(const Duration(days: 6)),
        status: ReceivableStatus.promised,
        riskScore: 52,
        followUps: const ['Promised to pay in 2 days'],
      ),
      Receivable(
        id: 'r3',
        contactName: 'Bilal Mart',
        phoneNumber: '923219876543',
        amount: 12000,
        dueDate: today.add(const Duration(days: 4)),
        status: ReceivableStatus.pending,
        riskScore: 25,
        followUps: const [],
      ),
    ]);

    _payables.addAll([
      Payable(
        id: 'p1',
        vendorName: 'Shop Rent',
        amount: 60000,
        dueDate: today.add(const Duration(days: 2)),
        reminderEnabled: true,
        isPaid: false,
      ),
      Payable(
        id: 'p2',
        vendorName: 'Internet',
        amount: 8000,
        dueDate: today,
        reminderEnabled: false,
        isPaid: false,
      ),
      Payable(
        id: 'p3',
        vendorName: 'Supplier Credit',
        amount: 95000,
        dueDate: today.add(const Duration(days: 9)),
        reminderEnabled: true,
        isPaid: false,
      ),
    ]);
  }
}

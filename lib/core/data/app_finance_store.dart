import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/models/budget_model.dart';
import '../../data/models/payable_model.dart';
import '../../data/models/receivable_model.dart';
import '../../data/models/transaction_model.dart';
import '../../services/sme_app_services.dart';
import '../models/finance_models.dart';
import '../services/supabase_service.dart';

/// Live finance data from Supabase (`transactions`, `receivables`, `payables`, `budgets`, `businesses`).
class AppFinanceStore extends ChangeNotifier {
  AppFinanceStore({SmeAppServices? api}) : _api = api ?? SmeAppServices.instance;

  final SmeAppServices _api;

  bool refreshing = false;
  String? lastError;
  String? _businessId;

  ThemeMode themeMode = ThemeMode.light;
  bool biometricLockEnabled = false;
  bool notificationsEnabled = true;

  BusinessProfile profile = const BusinessProfile(
    businessName: 'My business',
    industry: '',
    currency: 'PKR',
  );

  List<CashTransaction> _transactions = [];
  List<Receivable> _receivables = [];
  List<Payable> _payables = [];
  final Map<String, double> _budgetByCategory = {};
  final Map<String, bool> _payableReminderLocal = {};

  static const _defaultBudgetCategories = [
    'Stock',
    'Rent',
    'Salaries',
    'Utilities',
    'Marketing',
  ];

  int _insightIndex = 0;

  List<CashTransaction> get transactions => List.unmodifiable(_transactions);
  List<Receivable> get receivables => List.unmodifiable(_receivables);
  List<Payable> get payables => List.unmodifiable(_payables);
  bool get hasSavedBudgets => _budgetByCategory.isNotEmpty;

  Map<String, double> get categoryBudgets {
    final m = Map<String, double>.from(_budgetByCategory);
    for (final e in expenseByCategoryThisMonth().entries) {
      m.putIfAbsent(e.key, () => 0);
    }
    return Map.unmodifiable(m);
  }

  List<String> get rotatingInsights {
    final overdue = _receivables.where((r) => r.isOverdue).length;
    final openPay = _payables.where((p) => !p.isPaid).length;
    return [
      if (overdue > 0) '$overdue receivable(s) overdue — follow up.',
      if (openPay > 0) '$openPay open payable(s) — watch due dates.',
      'Review this month’s expenses against budgets.',
      'Keep recording every sale and expense in the ledger.',
    ];
  }

  String get currentInsight =>
      rotatingInsights.isEmpty ? 'Add data in the ledger to see insights.' : rotatingInsights[_insightIndex % rotatingInsights.length];

  void nextInsight() {
    _insightIndex++;
    notifyListeners();
  }

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  double get netCash => totalIncome - totalExpense;

  double get totalReceivablesPending =>
      _receivables.where((r) => r.status != ReceivableStatus.paid).fold(0.0, (s, r) => s + r.amount);

  double get totalPayablesOpen =>
      _payables.where((p) => !p.isPaid).fold(0.0, (s, p) => s + p.amount);

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
    return categoryBudgets.keys.where((c) => budgetUsedRatio(c) >= 0.8).toList();
  }

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

  List<({DateTime day, double inflow, double outflow})> chartBars(ChartPeriod period) {
    final range = chartRange(period);
    final map = dailyFlow(range.$1, range.$2);
    final out = <({DateTime day, double inflow, double outflow})>[];
    for (var d = range.$1; !d.isAfter(range.$2); d = d.add(const Duration(days: 1))) {
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
        map[d] = (inflow: cur.inflow + t.amount, outflow: cur.outflow);
      } else {
        map[d] = (inflow: cur.inflow, outflow: cur.outflow + t.amount);
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

  Future<void> refresh() async {
    if (!SupabaseService.isInitialized || SupabaseService.client.auth.currentSession == null) {
      _transactions = [];
      _receivables = [];
      _payables = [];
      _budgetByCategory.clear();
      _businessId = null;
      lastError = SupabaseService.isInitialized ? null : 'Supabase not configured';
      notifyListeners();
      return;
    }

    refreshing = true;
    lastError = null;
    notifyListeners();

    final biz = await _api.business.getOrCreatePrimary();
    if (biz.isFailure) {
      lastError = biz.errorMessage;
      refreshing = false;
      notifyListeners();
      return;
    }
    final b = biz.dataOrNull!;
    _businessId = b.id;
    profile = BusinessProfile(
      businessName: b.name,
      industry: b.industry ?? '',
      currency: b.currency,
    );

    final txs = await _api.transactions.listForBusiness(_businessId!);
    if (txs.isSuccess) {
      _transactions = txs.dataOrNull!.map(_cashFromModel).toList();
    } else {
      _transactions = [];
      lastError ??= txs.errorMessage;
    }

    final rec = await _api.receivables.listForBusiness(_businessId!);
    if (rec.isSuccess) {
      _receivables = rec.dataOrNull!.map(_receivableFromModel).toList();
    } else {
      _receivables = [];
    }

    final pays = await _api.payables.listForBusiness(_businessId!);
    if (pays.isSuccess) {
      _payables = pays.dataOrNull!.map(_payableFromModel).toList();
    } else {
      _payables = [];
      lastError ??= pays.errorMessage;
    }

    _budgetByCategory.clear();
    final monthYear = BudgetModel.monthYearFromDate(DateTime.now());
    final bud = await _api.budgets.listForBusinessAndMonth(_businessId!, monthYear);
    if (bud.isSuccess) {
      for (final row in bud.dataOrNull!) {
        _budgetByCategory[row.category] = row.monthlyLimit;
      }
    }
    for (final cat in _defaultBudgetCategories) {
      _budgetByCategory.putIfAbsent(cat, () => 0);
    }

    refreshing = false;
    notifyListeners();
  }

  Future<String?> _ensureBusiness() async {
    if (_businessId != null) return null;
    await refresh();
    return _businessId == null ? (lastError ?? 'Could not load business.') : null;
  }

  CashTransaction _cashFromModel(TransactionModel m) {
    final desc = m.description ?? '';
    final idx = desc.indexOf('\n');
    final contact = idx >= 0 ? desc.substring(0, idx).trim() : '';
    final note = idx >= 0 ? desc.substring(idx + 1).trim() : desc.trim();
    return CashTransaction(
      id: m.id,
      type: m.type == 'income' ? TransactionType.income : TransactionType.expense,
      amount: m.amount,
      category: m.category,
      contactName: contact,
      date: m.transactionDate,
      note: note,
    );
  }

  String _encodeTxDescription(CashTransaction t) {
    final c = t.contactName.trim();
    final n = t.note.trim();
    if (c.isEmpty) return n;
    if (n.isEmpty) return c;
    return '$c\n$n';
  }

  List<String> _decodeReceivableFollowUps(String? note) {
    if (note == null || note.trim().isEmpty) {
      return <String>[];
    }
    try {
      final dynamic j = jsonDecode(note);
      if (j is Map) {
        final f = j['f'];
        if (f is List) {
          return f.map((e) => e.toString()).toList();
        }
        return <String>[];
      }
    } catch (_) {}
    return note.split('\n').where((e) => e.trim().isNotEmpty).toList();
  }

  String _encodeReceivableNote(List<String> followUps) {
    return jsonEncode({'f': followUps});
  }

  Receivable _receivableFromModel(ReceivableModel m) {
    final followUps = _decodeReceivableFollowUps(m.note);
    final status = switch (m.status) {
      'paid' => ReceivableStatus.paid,
      _ => ReceivableStatus.pending,
    };
    final risk = 1 + (m.id.hashCode.abs() % 99);
    return Receivable(
      id: m.id,
      contactName: (m.contactName?.trim().isNotEmpty ?? false) ? m.contactName!.trim() : 'Customer',
      phoneNumber: (m.contactPhone ?? '').trim(),
      amount: m.amount,
      dueDate: m.dueDate,
      status: status,
      riskScore: risk,
      followUps: followUps,
    );
  }

  Payable _payableFromModel(PayableModel m) {
    final name = (m.description?.trim().isNotEmpty ?? false)
        ? m.description!.trim()
        : (m.category?.trim().isNotEmpty ?? false)
            ? m.category!.trim()
            : 'Vendor';
    return Payable(
      id: m.id,
      vendorName: name,
      amount: m.amount,
      dueDate: m.dueDate,
      reminderEnabled: _payableReminderLocal[m.id] ?? false,
      isPaid: m.status == 'paid',
    );
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

  Future<String?> persistBusinessProfile(String name, String industry) async {
    final err = await _ensureBusiness();
    if (err != null) return err;
    final r = await _api.business.updateBusiness(
      businessId: _businessId!,
      name: name.trim().isEmpty ? 'My business' : name.trim(),
      industry: industry.trim().isEmpty ? null : industry.trim(),
    );
    if (r.isFailure) return r.errorMessage;
    await refresh();
    return null;
  }

  Future<String?> setBudget(String category, double amount) async {
    final err = await _ensureBusiness();
    if (err != null) return err;
    final my = BudgetModel.monthYearFromDate(DateTime.now());
    final r = await _api.budgets.upsert(
      businessId: _businessId!,
      category: category,
      monthlyLimit: amount,
      monthYear: my,
    );
    if (r.isFailure) return r.errorMessage;
    _budgetByCategory[category] = amount;
    notifyListeners();
    return null;
  }

  void setBiometricLock(bool value) {
    biometricLockEnabled = value;
    notifyListeners();
  }

  void setNotifications(bool value) {
    notificationsEnabled = value;
    notifyListeners();
  }

  Future<String?> addTransaction(CashTransaction t) async {
    final err = await _ensureBusiness();
    if (err != null) return err;
    final r = await _api.transactions.create(
      businessId: _businessId!,
      type: t.type == TransactionType.income ? 'income' : 'expense',
      amount: t.amount,
      category: t.category,
      description: _encodeTxDescription(t),
      transactionDate: t.date,
    );
    if (r.isFailure) return r.errorMessage;
    await refresh();
    return null;
  }

  Future<String?> updateTransaction(String id, CashTransaction next) async {
    final err = await _ensureBusiness();
    if (err != null) return err;
    final r = await _api.transactions.update(
      id: id,
      type: next.type == TransactionType.income ? 'income' : 'expense',
      amount: next.amount,
      category: next.category,
      description: _encodeTxDescription(next),
      transactionDate: next.date,
    );
    if (r.isFailure) return r.errorMessage;
    await refresh();
    return null;
  }

  Future<String?> deleteTransaction(String id) async {
    final r = await _api.transactions.delete(id);
    if (r.isFailure) return r.errorMessage;
    await refresh();
    return null;
  }

  Future<String?> addReceivable(Receivable r) async {
    final err = await _ensureBusiness();
    if (err != null) return err;
    // Your receivables table uses contact_id, so we create a customer contact first.
    final c = await _api.contacts.create(
      businessId: _businessId!,
      name: r.contactName.trim().isEmpty ? 'Customer' : r.contactName.trim(),
      phone: r.phoneNumber.trim().isEmpty ? null : r.phoneNumber.trim(),
      type: 'customer',
    );
    if (c.isFailure) return c.errorMessage;

    final note = _encodeReceivableNote(r.followUps);
    final draft = ReceivableModel(
      id: '',
      businessId: _businessId!,
      contactId: c.dataOrNull!.id,
      amount: r.amount,
      amountPaid: 0,
      dueDate: r.dueDate,
      status: 'pending',
      note: note,
    );
    final res = await _api.receivables.create(draft);
    if (res.isFailure) return res.errorMessage;
    await refresh();
    return null;
  }

  Future<String?> addPayable(Payable p) async {
    final err = await _ensureBusiness();
    if (err != null) return err;
    final c = await _api.contacts.create(
      businessId: _businessId!,
      name: p.vendorName.trim().isEmpty ? 'Vendor' : p.vendorName.trim(),
      phone: null,
      type: 'vendor',
    );
    if (c.isFailure) return c.errorMessage;

    final res = await _api.payables.create(
      businessId: _businessId!,
      contactId: c.dataOrNull!.id,
      amount: p.amount,
      dueDate: p.dueDate,
      description: p.vendorName.trim().isEmpty ? 'Vendor' : p.vendorName.trim(),
    );
    if (res.isFailure) return res.errorMessage;
    await refresh();
    return null;
  }

  Future<String?> updateReceivableStatus(String id, ReceivableStatus status) async {
    final db = status == ReceivableStatus.paid ? 'paid' : 'pending';
    final r = await _api.receivables.updateRow(id: id, status: db);
    if (r.isFailure) return r.errorMessage;
    await refresh();
    return null;
  }

  Future<String?> addReceivableFollowUp(String id, String note) async {
    Receivable? current;
    for (final r in _receivables) {
      if (r.id == id) {
        current = r;
        break;
      }
    }
    if (current == null) return 'Receivable not found.';
    final nextFollow = [...current.followUps, note];
    final encoded = _encodeReceivableNote(nextFollow);
    final rr = await _api.receivables.updateRow(id: id, note: encoded);
    if (rr.isFailure) return rr.errorMessage;
    await refresh();
    return null;
  }

  void togglePayableReminder(String id) {
    _payableReminderLocal[id] = !(_payableReminderLocal[id] ?? false);
    _payables = _payables.map((p) {
      if (p.id != id) return p;
      return p.copyWith(reminderEnabled: _payableReminderLocal[id] ?? false);
    }).toList();
    notifyListeners();
  }

  Future<String?> markPayablePaid(String id) async {
    final err = await _ensureBusiness();
    if (err != null) return err;
    Payable? p;
    for (final x in _payables) {
      if (x.id == id) {
        p = x;
        break;
      }
    }
    if (p == null) return 'Payable not found.';
    if (p.isPaid) return null;

    final st = await _api.payables.updateStatus(id: id, status: 'paid');
    if (st.isFailure) return st.errorMessage;

    final tx = await _api.transactions.create(
      businessId: _businessId!,
      type: 'expense',
      amount: p.amount,
      category: 'Payable',
      description: '${p.vendorName}\nPayable marked as paid',
      transactionDate: DateTime.now(),
    );
    if (tx.isFailure) return tx.errorMessage;

    await refresh();
    return null;
  }
}

import '../data/repositories/budget_repository.dart';
import '../data/repositories/business_repository.dart';
import '../data/repositories/cash_flow_repository.dart';
import '../data/repositories/contact_repository.dart';
import '../data/repositories/payable_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/receivable_repository.dart';
import '../data/repositories/storage_repository.dart';
import '../data/repositories/transaction_repository.dart';

/// Single entry for Supabase-backed repositories (service layer).
///
/// Inject a custom instance in tests; otherwise use [instance].
class SmeAppServices {
  SmeAppServices({
    ProfileRepository? profile,
    BusinessRepository? business,
    TransactionRepository? transactions,
    ContactRepository? contacts,
    ReceivableRepository? receivables,
    BudgetRepository? budgets,
    PayableRepository? payables,
    CashFlowRepository? cashFlow,
    StorageRepository? storage,
  })  : profile = profile ?? ProfileRepository(),
        business = business ?? BusinessRepository(),
        transactions = transactions ?? TransactionRepository(),
        contacts = contacts ?? ContactRepository(),
        receivables = receivables ?? ReceivableRepository(),
        budgets = budgets ?? BudgetRepository(),
        payables = payables ?? PayableRepository(),
        cashFlow = cashFlow ?? CashFlowRepository(),
        storage = storage ?? StorageRepository();

  final ProfileRepository profile;
  final BusinessRepository business;
  final TransactionRepository transactions;
  final ContactRepository contacts;
  final ReceivableRepository receivables;
  final BudgetRepository budgets;
  final PayableRepository payables;
  final CashFlowRepository cashFlow;
  final StorageRepository storage;

  static final SmeAppServices instance = SmeAppServices();
}

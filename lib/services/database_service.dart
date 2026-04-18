import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  // Supabase client ka instance le rahe hain
  final _supabase = Supabase.instance.client;

  // Transaction save karne ka function
  Future<bool> saveTransaction({
    required double amount,
    required String type, // 'income' ya 'expense'
    required String category,
    String? description,
  }) async {
    try {
      // 'transactions' table mein data insert kar rahe hain
      await _supabase.from('transactions').insert({
        'amount': amount,
        'type': type,
        'category': category,
        'description': description ?? 'Scanned via FlowSense',
        'transaction_date': DateTime.now().toIso8601String(),
      });
      
      print("Transaction saved successfully!");
      return true; // Success
    } catch (e) {
      // Agar koi error aaye to handle karein
      print("Error saving transaction: $e");
      return false; // Failure
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/cash_flow_bloc.dart';
import '../services/email_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("FlowSense Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A6B4A), // Emerald Green [cite: 12]
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Cash Summary Card [cite: 9]
            _buildCashCard(),
            const SizedBox(height: 30),

            // State-dependent UI
            BlocBuilder<CashFlowBloc, CashFlowState>(
              builder: (context, state) {
                if (state is CashFlowLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CashFlowLoaded) {
                  return _buildResultCard(state.amount);
                }
                return const Text("Ready to process transactions", style: TextStyle(color: Colors.grey));
              },
            ),
            
            const Spacer(),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.read<CashFlowBloc>().add(StartScanning()),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("SCAN BILL"),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(15)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => EmailService.sendFinancialReport("Total Sales: PKR 125,000"),
                    icon: const Icon(Icons.email),
                    label: const Text("EMAIL REPORT"),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A6B4A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Text("Net Cash Balance", style: TextStyle(color: Colors.white70)),
          Text("PKR 125,500", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResultCard(String amount) {
    return Card(
      color: Colors.green.shade50,
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green),
        title: const Text("Bill Scanned Successfully"),
        subtitle: Text("Amount: PKR $amount"),
      ),
    );
  }
}
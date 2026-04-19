import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../controllers/cash_flow_bloc.dart';
import '../services/communication_service.dart';
import '../services/pdf_service.dart'; 

class OldDashboardScreen extends StatelessWidget {
  const OldDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ERROR FIX: Screen ko BlocProvider mein wrap kar diya taakay BlocBuilder ko context mil sakay
    return BlocProvider(
      create: (context) => CashFlowBloc(), 
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("FlowSense Dashboard", 
            style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF1A6B4A), // Emerald Green
          foregroundColor: Colors.white,
          elevation: 0,
          // Naye Dashboard par jane ke liye back button (Agar zaroorat ho)
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 1. Net Cash Balance Card
              _buildCashCard(),
              const SizedBox(height: 30),

              // 2. Result Display Area
              Expanded(
                child: SingleChildScrollView(
                  child: BlocBuilder<CashFlowBloc, CashFlowState>(
                    builder: (context, state) {
                      if (state is CashFlowLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(color: Color(0xFF1A6B4A)),
                          ),
                        );
                      } else if (state is CashFlowLoaded) {
                        return _buildResultCard(state.amount);
                      }
                      return const Center(
                        child: Text(
                          "Ready to process transactions",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // 3. Action Buttons Section
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components (Same as before) ---

  Widget _buildCashCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A6B4A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        children: [
          Text("Net Cash Balance", 
            style: TextStyle(color: Colors.white70, fontSize: 16)),
          SizedBox(height: 8),
          Text("PKR 125,500", 
            style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildResultCard(String amount) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.green.shade50,
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green, size: 30),
        title: const Text("Bill Scanned Successfully", 
          style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Detected Amount: PKR $amount", 
          style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Builder( // Builder use kiya taakay correct context milay
      builder: (newContext) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _customButton(
                    onPressed: () => newContext.read<CashFlowBloc>().add(StartScanning()),
                    icon: Icons.camera_alt,
                    label: "SCAN BILL",
                    color: const Color(0xFF1A6B4A),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _customButton(
                    onPressed: () => CommunicationService.sendEmail("Daily Report: PKR 125,500"),
                    icon: Icons.email,
                    label: "EMAIL",
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _customButton(
                    onPressed: () => CommunicationService.sendWhatsApp("Today's Balance: PKR 125,500"),
                    icon: Icons.chat,
                    label: "WHATSAPP",
                    color: const Color(0xFF25D366),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _customButton(
                    onPressed: () => CommunicationService.sendSMS("Today's Balance: PKR 125,500"),
                    icon: Icons.sms,
                    label: "SMS",
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: _customButton(
                onPressed: () => PdfService.generateAndPrintReport("125,500"),
                icon: Icons.picture_as_pdf,
                label: "GENERATE PDF REPORT",
                color: Colors.redAccent,
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _customButton({required VoidCallback onPressed, required IconData icon, required String label, required Color color}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
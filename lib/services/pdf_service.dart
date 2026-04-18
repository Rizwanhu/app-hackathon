import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAndPrintReport(String amount) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("FlowSense SME Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text("Transaction Details:", style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text("Amount Scanned: PKR $amount"),
              pw.Text("Date: ${DateTime.now().toString()}"),
              pw.SizedBox(height: 50),
              pw.Text("Thank you for using FlowSense!", style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
            ],
          );
        },
      ),
    );

    // Ye line mobile par PDF preview khol de gi jahan se aap print ya save kar sakte hain
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
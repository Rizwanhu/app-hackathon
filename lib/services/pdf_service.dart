import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAndPrintReport(String amount) async {
    final pdf = pw.Document();

    // App ke official colors ko PDF colors mein convert kiya hai
    final primaryColor = PdfColor.fromHex('#1A6B4A'); // Emerald Green
    final greyColor = PdfColor.fromHex('#64748B');    // Text Secondary
    final lightBg = PdfColor.fromHex('#F8F9FA');      // Card Background
    final borderColor = PdfColor.fromHex('#E2E8F0');  // Border Light

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40), // Achhi padding
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "FlowSense",
                    style: pw.TextStyle(
                      color: primaryColor,
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "RECEIPT",
                    style: pw.TextStyle(
                      color: greyColor,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(color: primaryColor, thickness: 2),
              pw.SizedBox(height: 30),

              // --- BODY ---
              pw.Text(
                "Transaction Details",
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 15),

              // Professional Info Box
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
                  border: pw.Border.all(color: borderColor),
                ),
                child: pw.Column(
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text("Date & Time:", style: pw.TextStyle(color: greyColor)),
                        // Date ko thora clean format mein dikhane ke liye split use kiya
                        pw.Text(DateTime.now().toString().split('.')[0]), 
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(color: borderColor),
                    pw.SizedBox(height: 10),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "Amount Scanned:",
                          style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          "PKR $amount",
                          style: pw.TextStyle(
                            color: primaryColor,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.Spacer(),

              // --- FOOTER ---
              pw.Divider(color: borderColor),
              pw.SizedBox(height: 15),
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text(
                      "Thank you for using FlowSense!",
                      style: pw.TextStyle(
                        color: primaryColor,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      "Generated via FlowSense SME Dashboard App",
                      style: pw.TextStyle(
                        color: greyColor,
                        fontSize: 10,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Ye line mobile par PDF preview khol de gi jahan se aap print ya save kar sakte hain
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
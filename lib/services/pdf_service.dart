import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../core/data/app_store_scope.dart';
import '../../../core/extensions/currency_extension.dart';
import 'package:intl/intl.dart';

class PdfService {
  // ─── Colors ───────────────────────────────────────────────────────────────
  static final _primary    = PdfColor.fromHex('#1A6B4A');
  static final _grey       = PdfColor.fromHex('#64748B');
  static final _green      = PdfColor.fromHex('#10B981');
  static final _red        = PdfColor.fromHex('#EF4444');
  static final _amber      = PdfColor.fromHex('#F59E0B');
  static final _blue       = PdfColor.fromHex('#3B82F6');
  static final _lightBg    = PdfColor.fromHex('#F8F9FA');
  static final _headerBg   = PdfColor.fromHex('#E8F5EE');
  static final _sectionBg  = PdfColor.fromHex('#F1F5F9');

  // ─── Entry point ──────────────────────────────────────────────────────────
  static Future<void> generateAndPrintReport() async {
    final pdf = pw.Document();
    final s   = appStore;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        build: (pw.Context context) => [
          _buildHeader(s),
          pw.SizedBox(height: 16),
          pw.Divider(thickness: 1, color: PdfColors.grey300),
          pw.SizedBox(height: 16),

          // 1. Financial Position Cards
          _sectionTitle('Financial Position'),
          pw.SizedBox(height: 8),
          pw.Row(children: [
            _summaryBox('Net Cash',       s.netCash.toPkr(),                   _primary),
            pw.SizedBox(width: 8),
            _summaryBox('Receivables',    s.totalReceivablesPending.toPkr(),   _green),
            pw.SizedBox(width: 8),
            _summaryBox('Payables',       s.totalPayablesOpen.toPkr(),         _red),
          ]),
          pw.SizedBox(height: 20),

          // 2. Income vs Expense Summary
          _sectionTitle('Income & Expense Overview'),
          pw.SizedBox(height: 8),
          _incomeExpenseSummary(s),
          pw.SizedBox(height: 20),

          // 3. Full Transactions Table
          _sectionTitle('All Transactions'),
          pw.SizedBox(height: 8),
          _transactionsTable(s),
          pw.SizedBox(height: 20),

          // 4. Receivables Detail
          _sectionTitle('Receivables Detail'),
          pw.SizedBox(height: 8),
          _receivablesTable(s),
          pw.SizedBox(height: 20),

          // 5. Payables Detail
          _sectionTitle('Payables Detail'),
          pw.SizedBox(height: 8),
          _payablesTable(s),
          pw.SizedBox(height: 20),

          // 6. Overdue Alerts
          _buildOverdueAlerts(s),
          pw.SizedBox(height: 20),

          // 7. AI Insight Box
          _aiInsightBox(s),
          pw.SizedBox(height: 20),

          // 8. Footer Disclaimer
          _disclaimer(),
        ],
        footer: (pw.Context ctx) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 10),
          child: pw.Text(
            'FlowSense • Page ${ctx.pageNumber} of ${ctx.pagesCount} • ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
          ),
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────
  static pw.Widget _buildHeader(dynamic s) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('FlowSense',
                style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: _primary)),
            pw.SizedBox(height: 2),
            pw.Text('Financial Summary Report',
                style: pw.TextStyle(fontSize: 11, color: _grey)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              s.profile.businessName,
              style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _primary),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
              style: pw.TextStyle(fontSize: 9, color: _grey),
            ),
            if ((s.profile.email ?? '').isNotEmpty)
              pw.Text(s.profile.email!, style: pw.TextStyle(fontSize: 9, color: _grey)),
            if ((s.profile.phone ?? '').isNotEmpty)
              pw.Text(s.profile.phone!, style: pw.TextStyle(fontSize: 9, color: _grey)),
          ],
        ),
      ],
    );
  }

  // ─── Income vs Expense summary row ────────────────────────────────────────
  static pw.Widget _incomeExpenseSummary(dynamic s) {
    final transactions = s.transactions as List;
    double totalIncome  = 0;
    double totalExpense = 0;
    for (final tx in transactions) {
      if (tx.amount >= 0) {
        totalIncome += (tx.amount as num).toDouble();
      } else {
        totalExpense += (tx.amount as num).abs().toDouble();
      }
    }
    final net = totalIncome - totalExpense;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _lightBg,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total Income',  totalIncome.toPkr(),  _green),
          _dividerLine(),
          _statItem('Total Expense', totalExpense.toPkr(), _red),
          _dividerLine(),
          _statItem('Net Balance',   net.toPkr(),          net >= 0 ? _primary : _red),
          _dividerLine(),
          _statItem('Transactions',  '${transactions.length}', _blue),
        ],
      ),
    );
  }

  // ─── Transactions Table (all) ──────────────────────────────────────────────
  static pw.Widget _transactionsTable(dynamic s) {
    final transactions = s.transactions as List;
    if (transactions.isEmpty) {
      return _emptyState('No transactions recorded.');
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.4), // Date
        1: const pw.FlexColumnWidth(2.2), // Contact
        2: const pw.FlexColumnWidth(1.6), // Category
        3: const pw.FlexColumnWidth(1.0), // Type
        4: const pw.FlexColumnWidth(1.8), // Amount
        5: const pw.FlexColumnWidth(2.0), // Note
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _headerBg),
          children: [
            _th('Date'),
            _th('Contact / Source'),
            _th('Category'),
            _th('Type'),
            _th('Amount'),
            _th('Note'),
          ],
        ),
        // Rows
        ...transactions.map((tx) {
          final isIncome = (tx.amount as num) >= 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: transactions.indexOf(tx) % 2 == 0 ? PdfColors.white : _sectionBg,
            ),
            children: [
              _td(DateFormat('dd/MM/yy').format(tx.date as DateTime)),
              _td((tx.contactName as String).isEmpty ? '—' : tx.contactName as String),
              _td(tx.category as String),
              _tdColored(isIncome ? 'Income' : 'Expense', isIncome ? _green : _red),
              _tdColored(
                '${isIncome ? '+' : '-'}${(tx.amount as num).abs().toPkr()}',
                isIncome ? _green : _red,
              ),
              _td((tx.note as String?)?.isEmpty ?? true ? '—' : tx.note as String),
            ],
          );
        }),
      ],
    );
  }

  // ─── Receivables Table ────────────────────────────────────────────────────
  static pw.Widget _receivablesTable(dynamic s) {
    final receivables = s.receivables as List;
    if (receivables.isEmpty) {
      return _emptyState('No receivables recorded.');
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5), // Contact
        1: const pw.FlexColumnWidth(2.0), // Amount
        2: const pw.FlexColumnWidth(1.8), // Due Date
        3: const pw.FlexColumnWidth(1.5), // Status
        4: const pw.FlexColumnWidth(1.2), // Overdue
        5: const pw.FlexColumnWidth(1.0), // Risk
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _headerBg),
          children: [
            _th('Customer'),
            _th('Amount Due'),
            _th('Due Date'),
            _th('Status'),
            _th('Overdue'),
            _th('Risk'),
          ],
        ),
        ...receivables.map((r) {
          final overdue   = r.daysPastDue as int;
          final isPastDue = overdue > 0;
          final status    = (r.status?.name ?? 'pending') as String;

          PdfColor statusColor;
          switch (status) {
            case 'paid':     statusColor = _green; break;
            case 'partial':  statusColor = _primary; break;
            case 'promised': statusColor = _blue; break;
            case 'disputed': statusColor = _red; break;
            default:         statusColor = _amber;
          }

          PdfColor riskColor;
          final risk = (r.riskScore as num).toInt();
          if (risk >= 70)      riskColor = _red;
          else if (risk >= 40) riskColor = _amber;
          else                 riskColor = _green;

          return pw.TableRow(
            children: [
              _td(r.contactName as String),
              _tdColored((r.amount as num).toPkr(), _red),
              _td(DateFormat('dd MMM yy').format(r.dueDate as DateTime)),
              _tdColored(status.toUpperCase(), statusColor),
              _tdColored(
                isPastDue ? '${overdue}d' : 'On time',
                isPastDue ? _red : _green,
              ),
              _tdColored('$risk%', riskColor),
            ],
          );
        }),
      ],
    );
  }

  // ─── Payables Table ───────────────────────────────────────────────────────
  static pw.Widget _payablesTable(dynamic s) {
    final payables = s.sortedPayablesOpen() as List;
    if (payables.isEmpty) {
      return _emptyState('No open payables — all clear!');
    }

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey200, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.5), // Vendor
        1: const pw.FlexColumnWidth(2.0), // Amount
        2: const pw.FlexColumnWidth(2.0), // Due Date
        3: const pw.FlexColumnWidth(1.5), // Days to Due
        4: const pw.FlexColumnWidth(1.0), // Reminder
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _headerBg),
          children: [
            _th('Vendor'),
            _th('Amount'),
            _th('Due Date'),
            _th('Urgency'),
            _th('Reminder'),
          ],
        ),
        ...payables.map((p) {
          final days = (p.daysToDue as num).toInt();

          PdfColor urgencyColor;
          String urgencyLabel;
          if (days < 0) {
            urgencyColor = _red;
            urgencyLabel = 'Overdue ${-days}d';
          } else if (days == 0) {
            urgencyColor = _red;
            urgencyLabel = 'Due Today';
          } else if (days <= 7) {
            urgencyColor = _amber;
            urgencyLabel = 'In ${days}d';
          } else {
            urgencyColor = _green;
            urgencyLabel = 'In ${days}d';
          }

          return pw.TableRow(
            children: [
              _td(p.vendorName as String),
              _tdColored((p.amount as num).toPkr(), _red),
              _td(DateFormat('dd MMM yy').format(p.dueDate as DateTime)),
              _tdColored(urgencyLabel, urgencyColor),
              _td((p.reminderEnabled as bool) ? '✓ On' : 'Off'),
            ],
          );
        }),
      ],
    );
  }

  // ─── Overdue Alerts ───────────────────────────────────────────────────────
  static pw.Widget _buildOverdueAlerts(dynamic s) {
    final overdueReceivables = (s.receivables as List)
        .where((r) => (r.daysPastDue as int) > 0 && r.status?.name != 'paid')
        .toList();
    final overduePayables = (s.sortedPayablesOpen() as List)
        .where((p) => (p.daysToDue as int) <= 0)
        .toList();

    if (overdueReceivables.isEmpty && overduePayables.isEmpty) {
      return pw.SizedBox();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _sectionTitle('⚠ Overdue Alerts'),
        pw.SizedBox(height: 8),
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#FFF5F5'),
            border: pw.Border.all(color: _red),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (overdueReceivables.isNotEmpty) ...[
                pw.Text('Overdue Receivables',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _red, fontSize: 11)),
                pw.SizedBox(height: 4),
                ...overdueReceivables.map((r) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Text(
                    '• ${r.contactName}  —  ${(r.amount as num).toPkr()}  —  ${r.daysPastDue} days overdue',
                    style: pw.TextStyle(fontSize: 9, color: _red),
                  ),
                )),
              ],
              if (overdueReceivables.isNotEmpty && overduePayables.isNotEmpty)
                pw.SizedBox(height: 8),
              if (overduePayables.isNotEmpty) ...[
                pw.Text('Overdue Payables',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _amber, fontSize: 11)),
                pw.SizedBox(height: 4),
                ...overduePayables.map((p) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 3),
                  child: pw.Text(
                    '• ${p.vendorName}  —  ${(p.amount as num).toPkr()}  —  due ${DateFormat('dd MMM').format(p.dueDate as DateTime)}',
                    style: pw.TextStyle(fontSize: 9, color: _amber),
                  ),
                )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─── AI Insight ───────────────────────────────────────────────────────────
  static pw.Widget _aiInsightBox(dynamic s) {
    final transactions  = s.transactions as List;
    final receivables   = s.receivables as List;
    final payables      = s.sortedPayablesOpen() as List;

    double totalIncome  = 0;
    double totalExpense = 0;
    for (final tx in transactions) {
      if ((tx.amount as num) >= 0) {
        totalIncome  += (tx.amount as num).toDouble();
      } else {
        totalExpense += (tx.amount as num).abs().toDouble();
      }
    }

    final overdueCount      = receivables.where((r) => (r.daysPastDue as int) > 0).length;
    final urgentPayables    = payables.where((p) => (p.daysToDue as int) <= 7).length;
    final highRiskCount     = receivables.where((r) => (r.riskScore as num) >= 70).length;
    final netCash           = (s.netCash as num).toDouble();
    final savingsRate       = totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome * 100).toStringAsFixed(1) : '0';

    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: _headerBg,
        border: pw.Border.all(color: _primary),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(children: [
            pw.Text('FlowSense AI Insights',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _primary, fontSize: 12)),
          ]),
          pw.SizedBox(height: 8),
          _insightLine('Net cash position is ${netCash >= 0 ? 'positive' : 'negative'} at ${s.netCash.toPkr()}.',
              netCash >= 0 ? _green : _red),
          _insightLine('Savings rate this period: $savingsRate% of total income.', _primary),
          if (overdueCount > 0)
            _insightLine('$overdueCount receivable(s) are overdue — follow up immediately to protect cash flow.', _red),
          if (urgentPayables > 0)
            _insightLine('$urgentPayables payable(s) are due within 7 days — plan cash accordingly.', _amber),
          if (highRiskCount > 0)
            _insightLine('$highRiskCount customer(s) flagged as high risk (risk score ≥ 70%). Consider tighter credit terms.', _red),
          if (overdueCount == 0 && urgentPayables == 0)
            _insightLine('All receivables and payables are on track — excellent financial hygiene!', _green),
        ],
      ),
    );
  }

  // ─── Disclaimer ───────────────────────────────────────────────────────────
  static pw.Widget _disclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(color: _sectionBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6))),
      child: pw.Text(
        'This report is auto-generated by FlowSense and is for internal business use only. '
        'Figures are based on data entered in the app and may not reflect external accounting adjustments.',
        style: pw.TextStyle(fontSize: 8, color: _grey, lineSpacing: 1.4),
      ),
    );
  }

  // ─── Tiny helpers ─────────────────────────────────────────────────────────

  static pw.Widget _sectionTitle(String text) => pw.Text(
        text,
        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: _primary),
      );

  static pw.Widget _summaryBox(String label, String value, PdfColor color) =>
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: pw.BoxDecoration(
            color: _lightBg,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: color.shade(0.3)),
          ),
          child: pw.Column(children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 9, color: _grey)),
            pw.SizedBox(height: 4),
            pw.Text(value,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: color)),
          ]),
        ),
      );

  static pw.Widget _statItem(String label, String value, PdfColor color) =>
      pw.Column(children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 8, color: _grey)),
        pw.SizedBox(height: 3),
        pw.Text(value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
      ]);

  static pw.Widget _dividerLine() => pw.Container(
        height: 30, width: 1, color: PdfColors.grey300,
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
      );

  static pw.Widget _emptyState(String msg) => pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: _sectionBg,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Text(msg, style: pw.TextStyle(fontSize: 10, color: _grey)),
      );

  static pw.Widget _insightLine(String text, PdfColor color) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('• ', style: pw.TextStyle(color: color, fontSize: 9, fontWeight: pw.FontWeight.bold)),
            pw.Expanded(
              child: pw.Text(text, style: pw.TextStyle(fontSize: 9, color: color, lineSpacing: 1.4)),
            ),
          ],
        ),
      );

  // Table header cell
  static pw.Widget _th(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text,
            style: pw.TextStyle(
                fontSize: 9, fontWeight: pw.FontWeight.bold, color: _primary)),
      );

  // Table data cell — plain
  static pw.Widget _td(String text) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
      );

  // Table data cell — coloured
  static pw.Widget _tdColored(String text, PdfColor color) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(text,
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: color)),
      );
}

import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import '../utils/formatters.dart';

class ExportService {
  const ExportService();

  Future<Directory> _exportsDir() async {
    final dir = Directory(p.join((await getApplicationDocumentsDirectory()).path, 'exports'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  String _timestamp() => DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;

  Future<String> exportExpensesCsv(List<Expense> expenses, List<Category> categories) async {
    final byId = {for (final c in categories) c.id: c};
    final rows = <List<dynamic>>[
      ['Date', 'Amount', 'Category', 'Merchant', 'Payment', 'Notes', 'Favorite'],
      for (final e in expenses)
        [
          e.date.toIso8601String(),
          e.amount.toStringAsFixed(2),
          byId[e.categoryId]?.name ?? '',
          e.merchant,
          e.paymentMethod,
          e.notes,
          e.isFavorite ? 'yes' : 'no',
        ],
    ];
    final csv = const ListToCsvConverter().convert(rows);
    final path = p.join((await _exportsDir()).path, 'expenses_${_timestamp()}.csv');
    await File(path).writeAsString(csv);
    return path;
  }

  Future<String> exportExpensesExcel(List<Expense> expenses, List<Category> categories) async {
    final byId = {for (final c in categories) c.id: c};
    final excel = Excel.createExcel();
    final sheet = excel['Expenses'];
    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Amount'),
      TextCellValue('Category'),
      TextCellValue('Merchant'),
      TextCellValue('Payment'),
      TextCellValue('Notes'),
      TextCellValue('Favorite'),
    ]);
    for (final e in expenses) {
      sheet.appendRow([
        TextCellValue(e.date.toIso8601String()),
        DoubleCellValue(e.amount),
        TextCellValue(byId[e.categoryId]?.name ?? ''),
        TextCellValue(e.merchant),
        TextCellValue(e.paymentMethod),
        TextCellValue(e.notes),
        TextCellValue(e.isFavorite ? 'yes' : 'no'),
      ]);
    }
    final bytes = excel.save() ?? <int>[];
    final path = p.join((await _exportsDir()).path, 'expenses_${_timestamp()}.xlsx');
    await File(path).writeAsBytes(bytes);
    return path;
  }

  Future<Uint8List> buildExpensesPdf(
    List<Expense> expenses,
    List<Category> categories, {
    String currencySymbol = '\$',
    String title = 'Expenses',
  }) async {
    final byId = {for (final c in categories) c.id: c};
    final doc = pw.Document();
    final total = expenses.fold<double>(0, (a, e) => a + e.amount);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text('Generated ${formatDate(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellAlignment: pw.Alignment.centerLeft,
            headers: const ['Date', 'Category', 'Merchant', 'Payment', 'Amount'],
            data: expenses
                .map((e) => [
                      formatShortDate(e.date),
                      byId[e.categoryId]?.name ?? '',
                      e.merchant,
                      e.paymentMethod,
                      formatCurrency(e.amount, symbol: currencySymbol),
                    ])
                .toList(),
          ),
          pw.SizedBox(height: 16),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text('Total: ${formatCurrency(total, symbol: currencySymbol)}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          ),
        ],
      ),
    );
    return doc.save();
  }

  Future<Uint8List> buildReportPdf({
    required String title,
    required Map<String, double> categoryTotals,
    required double income,
    required double expenses,
    required double savings,
    String currencySymbol = '\$',
  }) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _summaryBlock('Income', formatCurrency(income, symbol: currencySymbol)),
              _summaryBlock('Expenses', formatCurrency(expenses, symbol: currencySymbol)),
              _summaryBlock('Savings', formatCurrency(savings, symbol: currencySymbol)),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text('By Category', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: const ['Category', 'Amount'],
            data: categoryTotals.entries
                .map((e) => [e.key, formatCurrency(e.value, symbol: currencySymbol)])
                .toList(),
          ),
        ],
      ),
    );
    return doc.save();
  }

  pw.Widget _summaryBlock(String label, String value) => pw.Column(
        children: [
          pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        ],
      );

  Future<void> printOrShare(Uint8List bytes, String filename) async {
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}

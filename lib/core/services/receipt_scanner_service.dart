import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ReceiptLineItem {
  final String name;
  final double price;
  const ReceiptLineItem({required this.name, required this.price});
}

class ScanResult {
  final double? amount;
  final String? merchant;
  final DateTime? date;
  final String? paymentMethod;
  final List<ReceiptLineItem> items;
  final String rawText;

  const ScanResult({
    required this.amount,
    required this.merchant,
    required this.date,
    required this.paymentMethod,
    required this.items,
    required this.rawText,
  });

  bool get hasAnything =>
      amount != null ||
      merchant != null ||
      date != null ||
      paymentMethod != null ||
      items.isNotEmpty;
}

class ReceiptScannerService {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  bool get supported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<ScanResult> scan(String imagePath) async {
    if (!supported) {
      return const ScanResult(
          amount: null, merchant: null, date: null, paymentMethod: null, items: [], rawText: '');
    }
    final file = File(imagePath);
    if (!await file.exists()) {
      return const ScanResult(
          amount: null, merchant: null, date: null, paymentMethod: null, items: [], rawText: '');
    }
    try {
      final input = InputImage.fromFilePath(imagePath);
      final recognized = await _recognizer.processImage(input);
      final text = recognized.text;
      final lines = text
          .split(RegExp(r'[\r\n]+'))
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      final amount = _extractAmount(lines);
      return ScanResult(
        amount: amount,
        merchant: _extractMerchantFromBlocks(recognized.blocks) ?? _extractMerchant(lines),
        date: _extractDate(lines),
        paymentMethod: _extractPaymentMethod(lines),
        items: _extractLineItems(lines, totalAmount: amount),
        rawText: text,
      );
    } catch (e) {
      debugPrint('scan error: $e');
      return const ScanResult(
          amount: null, merchant: null, date: null, paymentMethod: null, items: [], rawText: '');
    }
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }

  double? _extractAmount(List<String> lines) {
    final keywordRe = RegExp(
      r'\b(grand\s*total|total(?:\s+due)?|amount\s*(?:due|paid)?|balance(?:\s+due)?|to\s*pay|subtotal)\b',
      caseSensitive: false,
    );
    final currencyRe = RegExp(r'([€£¥₹\$]?\s*[-]?\s*\d{1,3}(?:[,\s]\d{3})*(?:\.\d{2})|\d+\.\d{2})');
    final candidates = <double>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (keywordRe.hasMatch(line.toLowerCase())) {
        final match = currencyRe.firstMatch(line);
        double? v;
        if (match != null) v = _parseNumber(match.group(0)!);
        if (v == null && i + 1 < lines.length) {
          final m2 = currencyRe.firstMatch(lines[i + 1]);
          if (m2 != null) v = _parseNumber(m2.group(0)!);
        }
        if (v != null && v > 0 && !line.toLowerCase().contains('subtotal')) return v;
        if (v != null) candidates.add(v);
      }
    }

    final all = <double>[];
    for (final line in lines) {
      for (final m in currencyRe.allMatches(line)) {
        final v = _parseNumber(m.group(0)!);
        if (v != null && v > 0 && v < 100000) all.add(v);
      }
    }
    if (all.isEmpty) return candidates.isNotEmpty ? candidates.reduce((a, b) => a > b ? a : b) : null;
    all.sort();
    return all.last;
  }

  double? _parseNumber(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^\d.,-]'), '');
    if (cleaned.isEmpty) return null;
    String norm = cleaned;
    final lastDot = cleaned.lastIndexOf('.');
    final lastComma = cleaned.lastIndexOf(',');
    if (lastDot >= 0 && lastComma >= 0) {
      if (lastComma > lastDot) {
        norm = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        norm = cleaned.replaceAll(',', '');
      }
    } else if (lastComma >= 0 && lastDot < 0) {
      final afterComma = cleaned.length - lastComma - 1;
      if (afterComma == 2) {
        norm = cleaned.replaceAll(',', '.');
      } else {
        norm = cleaned.replaceAll(',', '');
      }
    }
    return double.tryParse(norm);
  }

  /// Merchant via bounding boxes: pick the tallest text in the top third of
  /// the receipt (biggest font at the top = brand name).
  String? _extractMerchantFromBlocks(List<TextBlock> blocks) {
    if (blocks.isEmpty) return null;
    final maxY = blocks
        .map((b) => b.boundingBox.bottom)
        .fold<double>(0, (a, b) => b > a ? b : a);
    final topThird = maxY / 3;

    final skip = RegExp(
      r'^(receipt|invoice|tax\s*invoice|order|welcome|thank\s*you|customer\s*copy|address|tel[:\s]|phone[:\s]|www\.|http)',
      caseSensitive: false,
    );

    TextLine? best;
    double bestHeight = 0;
    for (final block in blocks) {
      for (final line in block.lines) {
        final text = line.text.trim();
        if (text.length < 3 || text.length > 60) continue;
        if (line.boundingBox.top > topThird) continue;
        if (RegExp(r'^[\d\s\-\.,:/]+$').hasMatch(text)) continue;
        if (skip.hasMatch(text)) continue;
        final digits = text.replaceAll(RegExp(r'\D'), '');
        if (digits.length > text.length / 2) continue;
        final height = line.boundingBox.height;
        if (height > bestHeight) {
          bestHeight = height;
          best = line;
        }
      }
    }
    return best?.text.trim();
  }

  String? _extractMerchant(List<String> lines) {
    final skip = RegExp(
      r'^(receipt|invoice|tax\s*invoice|order|welcome|thank\s*you|customer\s*copy|address|tel[:\s]|phone[:\s]|www\.|http)',
      caseSensitive: false,
    );
    for (final raw in lines.take(6)) {
      final line = raw.trim();
      if (line.length < 3) continue;
      if (line.length > 60) continue;
      if (RegExp(r'^[\d\s\-\.,:/]+$').hasMatch(line)) continue;
      if (skip.hasMatch(line)) continue;
      final digits = line.replaceAll(RegExp(r'\D'), '');
      if (digits.length > line.length / 2) continue;
      return line;
    }
    return null;
  }

  DateTime? _extractDate(List<String> lines) {
    final patterns = [
      RegExp(r'(\d{4})[-/\.](\d{1,2})[-/\.](\d{1,2})'),
      RegExp(r'(\d{1,2})[-/\.](\d{1,2})[-/\.](\d{2,4})'),
    ];
    for (final line in lines) {
      for (final re in patterns) {
        final m = re.firstMatch(line);
        if (m == null) continue;
        try {
          final g1 = int.parse(m.group(1)!);
          final g2 = int.parse(m.group(2)!);
          final g3 = int.parse(m.group(3)!);
          if (g1 > 1900 && g1 < 2100) {
            return DateTime(g1, g2, g3);
          }
          var year = g3;
          if (year < 100) year += 2000;
          if (year < 1900 || year > 2100) continue;
          final month = g2;
          final day = g1;
          if (month < 1 || month > 12) continue;
          if (day < 1 || day > 31) continue;
          return DateTime(year, month, day);
        } catch (_) {
          continue;
        }
      }
    }
    return null;
  }

  /// Payment method detection. Maps receipt keywords → app payment methods.
  /// Order matters: check specific tokens (debit, credit) before generic
  /// card brand names, so "VISA DEBIT" is not misread as "Credit Card".
  String? _extractPaymentMethod(List<String> lines) {
    final text = lines.join(' ').toLowerCase();

    if (RegExp(r'\b(apple\s*pay|google\s*pay|g\s*pay|samsung\s*pay|paypal|venmo|zelle|cash\s*app|wallet|contactless|tap\s*to\s*pay|nfc)\b')
        .hasMatch(text)) {
      return 'Digital Wallet';
    }
    if (RegExp(r'\b(bank\s*transfer|wire\s*transfer|ach|eft|direct\s*deposit)\b').hasMatch(text)) {
      return 'Bank Transfer';
    }
    if (RegExp(r'\b(debit|interac|maestro|visa\s*debit|mastercard\s*debit)\b').hasMatch(text)) {
      return 'Debit Card';
    }
    if (RegExp(r'\b(credit\s*card|credit)\b').hasMatch(text) &&
        !RegExp(r'\bstore\s*credit\b').hasMatch(text)) {
      return 'Credit Card';
    }
    if (RegExp(r'\b(visa|mastercard|amex|american\s*express|discover|jcb|diners)\b').hasMatch(text)) {
      // Card brand seen without explicit debit/credit qualifier — Credit is
      // statistically the more common of the two on receipts.
      return 'Credit Card';
    }
    if (RegExp(r'\b(cash|change\s*due|tendered)\b').hasMatch(text)) {
      return 'Cash';
    }
    return null;
  }

  List<ReceiptLineItem> _extractLineItems(List<String> lines, {double? totalAmount}) {
    final results = <ReceiptLineItem>[];
    final skip = RegExp(
      r'^(sub\s*total|total|grand\s*total|tax|vat|change|cash|debit|credit\s*card|balance|amount\s*due|thank|welcome|order\s*#|receipt|invoice|store|register|cashier|tel|phone|www\.|http|address|date|time|item\s*count|customer)\b',
      caseSensitive: false,
    );
    final lineRe = RegExp(
      r'^\s*(.+?)\s{2,}[€£¥₹\$]?\s*(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})\s*$',
    );
    final loose = RegExp(
      r"^\s*([A-Za-z][A-Za-z0-9 \-\.'&/]{2,40}?)\s+[€£¥₹\$]?\s*(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})\s*$",
    );

    for (final raw in lines) {
      final line = raw.trim();
      if (line.length < 4 || line.length > 80) continue;
      if (skip.hasMatch(line)) continue;

      Match? m = lineRe.firstMatch(line);
      m ??= loose.firstMatch(line);
      if (m == null) continue;

      final name = m.group(1)!.trim().replaceAll(RegExp(r'[\.\s]{2,}'), ' ');
      final priceStr = m.group(2)!;
      final price = _parseNumber(priceStr);
      if (price == null || price <= 0 || price > 10000) continue;

      if (totalAmount != null && (price - totalAmount).abs() < 0.01) continue;

      if (RegExp(r'^\d').hasMatch(name)) continue;
      if (name.length < 3) continue;

      results.add(ReceiptLineItem(name: name, price: price));
      if (results.length >= 40) break;
    }
    return results;
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/services/receipt_scanner_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/merchant_categorizer.dart';
import '../../providers/currency_provider.dart';
import '../../providers/repository_providers.dart';

class ScanReceiptScreen extends ConsumerStatefulWidget {
  const ScanReceiptScreen({super.key});

  @override
  ConsumerState<ScanReceiptScreen> createState() => _ScanReceiptScreenState();
}

class _ScanReceiptScreenState extends ConsumerState<ScanReceiptScreen> {
  final _scanner = ReceiptScannerService();
  bool _busy = false;
  String? _imagePath;
  bool _isSample = false; // true when the demo "sample" result is shown
  ScanResult? _result;
  String? _error;

  @override
  void dispose() {
    _scanner.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // In demo builds, land on the sample result immediately so buyers can
    // screenshot the polished "What we found" state without a camera.
    if (AppConfig.demoMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadSample());
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture(fromCamera: true));
  }

  void _loadSample() {
    setState(() {
      _isSample = true;
      _imagePath = null;
      _busy = false;
      _error = null;
      final today = DateTime.now();
      _result = ScanResult(
        amount: 47.83,
        merchant: 'Whole Foods Market',
        date: DateTime(today.year, today.month, today.day)
            .subtract(const Duration(days: 1)),
        paymentMethod: 'Credit Card',
        items: const [
          ReceiptLineItem(name: 'Organic bananas', price: 3.99),
          ReceiptLineItem(name: 'Almond milk', price: 4.29),
          ReceiptLineItem(name: 'Greek yogurt', price: 5.99),
          ReceiptLineItem(name: 'Sourdough loaf', price: 6.50),
          ReceiptLineItem(name: 'Baby spinach', price: 4.49),
          ReceiptLineItem(name: 'Salmon fillet', price: 15.75),
          ReceiptLineItem(name: 'Blueberries', price: 4.99),
        ],
        rawText: '',
      );
    });
  }

  Future<void> _capture({required bool fromCamera}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final imgSvc = ref.read(imageServiceProvider);
      final path = await imgSvc.pickReceipt(fromCamera: fromCamera);
      if (path == null) {
        if (_imagePath == null && mounted) context.pop();
        setState(() => _busy = false);
        return;
      }
      final result = await _scanner.scan(path);
      if (!mounted) return;
      setState(() {
        _imagePath = path;
        _result = result;
        _busy = false;
        if (!result.hasAnything) {
          _error = 'Could not read the receipt clearly. Try again or fill in the details manually.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Scan failed: $e';
        _busy = false;
      });
    }
  }

  Future<void> _useResult() async {
    if (_result == null && _imagePath == null) return;
    final items = _result?.items ?? const <ReceiptLineItem>[];
    final notesText = items.isEmpty
        ? null
        : 'Receipt items:\n${items.map((it) => '• ${it.name} — \$${it.price.toStringAsFixed(2)}').join('\n')}';

    int? categoryId;
    final categoryName = guessCategoryName(_result?.merchant);
    if (categoryName != null) {
      final cats = await ref.read(categoryRepositoryProvider).getAll();
      for (final c in cats) {
        if (c.name.toLowerCase() == categoryName.toLowerCase()) {
          categoryId = c.id;
          break;
        }
      }
    }

    if (!mounted) return;
    context.pushReplacement('/expenses/new', extra: ScanPayload(
      imagePath: _imagePath,
      amount: _result?.amount,
      merchant: _result?.merchant,
      date: _result?.date,
      notes: notesText,
      categoryId: categoryId,
      paymentMethod: _result?.paymentMethod,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final hasResult = _imagePath != null || _isSample;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.scanTitle),
        actions: [
          if (hasResult)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Retake',
              onPressed: () => _capture(fromCamera: true),
            ),
        ],
      ),
      body: SafeArea(
        child: _busy
            ? _buildBusy(theme)
            : !hasResult
                ? _buildIntro(theme)
                : _buildResult(theme, currency),
      ),
    );
  }

  Widget _buildIntro(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.document_scanner_rounded, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(context.l10n.scanPoint,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(context.l10n.scanAutoFill,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.photo_camera_rounded),
              label: Text(context.l10n.scanOpenCamera),
              onPressed: () => _capture(fromCamera: true),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.photo_library_rounded),
              label: Text(context.l10n.scanPickGallery),
              onPressed: () => _capture(fromCamera: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusy(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(context.l10n.scanReading,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildResult(ThemeData theme, String currency) {
    final r = _result;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (_imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(
              File(_imagePath!),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const SizedBox(height: 220, child: Center(child: Icon(Icons.broken_image_rounded))),
            ),
          )
        else if (_isSample)
          const _SampleReceiptCard(),
        const SizedBox(height: 20),
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.onErrorContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_error!,
                    style: TextStyle(color: theme.colorScheme.onErrorContainer)),
              ),
            ]),
          ),
        if (_error != null) const SizedBox(height: 16),
        Text(context.l10n.scanWhatFound,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _resultRow(theme, Icons.attach_money_rounded, 'Amount',
            r?.amount != null ? formatCurrency(r!.amount!, symbol: currency) : '—'),
        _resultRow(theme, Icons.store_rounded, 'Merchant', r?.merchant ?? '—'),
        _resultRow(theme, Icons.calendar_today_rounded, 'Date',
            r?.date != null ? formatDate(r!.date!) : '—'),
        if (r != null && r.items.isNotEmpty) ...[
          const SizedBox(height: 20),
          _ItemsCard(items: r.items, currency: currency),
        ],
        const SizedBox(height: 24),
        FilledButton.icon(
          icon: const Icon(Icons.arrow_forward_rounded),
          label: Text(context.l10n.scanContinueForm),
          onPressed: _useResult,
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.replay_rounded),
          label: Text(context.l10n.scanRetake),
          onPressed: () => _capture(fromCamera: true),
        ),
      ],
    );
  }

  Widget _resultRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondaryContainer,
            ),
            child: Icon(icon, color: theme.colorScheme.onSecondaryContainer, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Text(value,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  final List<ReceiptLineItem> items;
  final String currency;
  const _ItemsCard({required this.items, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtotal = items.fold<double>(0, (a, e) => a + e.price);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surfaceContainerLow,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.list_alt_rounded,
                      size: 14, color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 4),
                  Text('${items.length} items detected',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
            const Spacer(),
            Text(
              formatCurrency(subtotal, symbol: currency),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ]),
          const SizedBox(height: 10),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      it.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatCurrency(it.price, symbol: currency),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Text(
            'Full list will be saved to the expense notes.',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Payload passed from scan screen to the expense form via GoRouter `extra`.
class ScanPayload {
  final String? imagePath;
  final double? amount;
  final String? merchant;
  final DateTime? date;
  final String? notes;
  final int? categoryId;
  final String? paymentMethod;

  const ScanPayload({
    this.imagePath,
    this.amount,
    this.merchant,
    this.date,
    this.notes,
    this.categoryId,
    this.paymentMethod,
  });
}

/// Paper-receipt looking placeholder shown in demo builds instead of a real
/// captured photo. Screenshots great — everything is drawn with widgets.
class _SampleReceiptCard extends StatelessWidget {
  const _SampleReceiptCard();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft background so the paper "sits" on a surface.
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2A2540),
                  const Color(0xFF3E2A7A).withOpacity(0.8),
                ],
              ),
            ),
          ),
          // The paper receipt itself — slight tilt for realism.
          Transform.rotate(
            angle: -0.03,
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF7EC),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'WHOLE FOODS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 2,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'MARKET',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 3,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFF999999), thickness: 0.5, height: 4),
                  const SizedBox(height: 8),
                  _line('Organic bananas', '\$3.99'),
                  _line('Almond milk', '\$4.29'),
                  _line('Greek yogurt', '\$5.99'),
                  _line('Sourdough loaf', '\$6.50'),
                  _line('Baby spinach', '\$4.49'),
                  _line('Salmon fillet', '\$15.75'),
                  _line('Blueberries', '\$4.99'),
                  const SizedBox(height: 6),
                  const Divider(color: Color(0xFF999999), thickness: 0.5, height: 4),
                  _line('SUBTOTAL', '\$45.00', bold: true),
                  _line('TAX', '\$2.83'),
                  const SizedBox(height: 4),
                  _line('TOTAL', '\$47.83', bold: true, big: true),
                  const SizedBox(height: 8),
                  const Text(
                    'Thank you for\nshopping with us',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 8,
                      color: Color(0xFF555555),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Subtle "AI reading" indicator overlay on the top-right of the paper.
          Positioned(
            top: 20,
            right: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Read',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _line(String label, String value, {bool bold = false, bool big = false}) {
    final style = TextStyle(
      fontFamily: 'monospace',
      fontSize: big ? 12 : 10,
      fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
      color: const Color(0xFF1A1A1A),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}

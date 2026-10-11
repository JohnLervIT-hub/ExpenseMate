import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/default_categories.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/category.dart';
import '../../../data/models/expense.dart';
import '../../providers/currency_provider.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/common/field_header.dart';
import '../../widgets/common/loading_indicator.dart';
import 'scan_receipt_screen.dart';

class ExpenseFormScreen extends ConsumerStatefulWidget {
  final int? expenseId;
  final ScanPayload? prefill;
  const ExpenseFormScreen({super.key, this.expenseId, this.prefill});

  @override
  ConsumerState<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends ConsumerState<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _merchantCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int? _categoryId;
  String _paymentMethod = AppConstants.paymentMethods.first;
  DateTime _date = DateTime.now();
  String? _receiptPath;
  bool _isFavorite = false;
  bool _loading = false;
  Expense? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.expenseId != null) {
      _loadExisting();
    } else if (widget.prefill != null) {
      _applyPrefill(widget.prefill!);
    }
  }

  void _applyPrefill(ScanPayload p) {
    if (p.amount != null) _amountCtrl.text = p.amount!.toStringAsFixed(2);
    if (p.merchant != null) _merchantCtrl.text = p.merchant!;
    if (p.date != null) _date = p.date!;
    if (p.imagePath != null) _receiptPath = p.imagePath;
    if (p.notes != null && p.notes!.isNotEmpty) _notesCtrl.text = p.notes!;
    if (p.categoryId != null) _categoryId = p.categoryId;
    if (p.paymentMethod != null &&
        AppConstants.paymentMethods.contains(p.paymentMethod)) {
      _paymentMethod = p.paymentMethod!;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _merchantCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExisting() async {
    setState(() => _loading = true);
    final e = await ref.read(expenseRepositoryProvider).getById(widget.expenseId!);
    if (e != null) {
      _existing = e;
      _amountCtrl.text = e.amount.toStringAsFixed(2);
      _merchantCtrl.text = e.merchant;
      _notesCtrl.text = e.notes;
      _categoryId = e.categoryId;
      _paymentMethod = e.paymentMethod.isEmpty ? _paymentMethod : e.paymentMethod;
      _date = e.date;
      _receiptPath = e.receiptPath;
      _isFavorite = e.isFavorite;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.l10n.expensesPickCategory)));
      return;
    }
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final repo = ref.read(expenseRepositoryProvider);
    if (_existing == null) {
      final e = Expense.create(
        amount: amount,
        categoryId: _categoryId!,
        merchant: _merchantCtrl.text.trim(),
        paymentMethod: _paymentMethod,
        notes: _notesCtrl.text.trim(),
        receiptPath: _receiptPath,
        isFavorite: _isFavorite,
        date: _date,
      );
      await repo.insert(e);
    } else {
      await repo.update(_existing!.copyWith(
        amount: amount,
        categoryId: _categoryId,
        merchant: _merchantCtrl.text.trim(),
        paymentMethod: _paymentMethod,
        notes: _notesCtrl.text.trim(),
        receiptPath: _receiptPath,
        isFavorite: _isFavorite,
        date: _date,
      ));
    }
    ref.invalidate(expensesProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(calendarMonthProvider);
    if (!mounted) return;
    context.pop();
  }

  Future<void> _pickReceipt() async {
    final source = await showModalBottomSheet<ImageSourceChoice>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: Text(context.l10n.scanOpenCamera),
              onTap: () => Navigator.pop(ctx, ImageSourceChoice.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(context.l10n.scanPickGallery),
              onTap: () => Navigator.pop(ctx, ImageSourceChoice.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final path = await ref
        .read(imageServiceProvider)
        .pickReceipt(fromCamera: source == ImageSourceChoice.camera);
    if (path != null) setState(() => _receiptPath = path);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.expensesDeleteConfirmTitle),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.actionCancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.actionDelete)),
            ],
          ),
        ) ??
        false;
    if (!ok || _existing == null) return;
    await ref.read(expenseRepositoryProvider).delete(_existing!.id);
    ref.invalidate(expensesProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(calendarMonthProvider);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencySymbolProvider);
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? l.expensesAdd : l.expensesEdit),
        actions: [
          if (_existing == null)
            IconButton(
              icon: const Icon(Icons.document_scanner_rounded),
              tooltip: context.l10n.expensesScanTooltip,
              onPressed: () => context.push(Routes.expenseScan),
            ),
          if (_existing != null)
            IconButton(icon: const Icon(Icons.delete_rounded), onPressed: _delete),
          IconButton(icon: const Icon(Icons.check_rounded), onPressed: _save),
        ],
      ),
      body: _loading
          ? const AppLoadingIndicator()
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Text(currency,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              )),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _amountCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: theme.textTheme.displaySmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                              decoration: const InputDecoration(
                                filled: false,
                                border: InputBorder.none,
                                hintText: '0.00',
                                contentPadding: EdgeInsets.zero,
                              ),
                              validator: (v) {
                                final d = double.tryParse((v ?? '').trim());
                                if (d == null || d <= 0) return 'Enter an amount';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FieldHeader(label: context.l10n.commonCategory, icon: Icons.category_rounded),
                  categoriesAsync.when(
                    data: (cats) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in cats) _CategoryChip(
                          category: c,
                          selected: _categoryId == c.id,
                          onTap: () => setState(() => _categoryId = c.id),
                        ),
                      ],
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 24),
                  FieldHeader(label: context.l10n.commonDetails, icon: Icons.description_rounded),
                  TextFormField(
                    controller: _merchantCtrl,
                    decoration: InputDecoration(
                      labelText: context.l10n.commonMerchant,
                      prefixIcon: Icon(Icons.store_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    decoration: InputDecoration(
                      labelText: context.l10n.commonPaymentMethod,
                      prefixIcon: Icon(Icons.payment_rounded),
                    ),
                    items: [
                      for (final m in AppConstants.paymentMethods)
                        DropdownMenuItem(value: m, child: Text(m)),
                    ],
                    onChanged: (v) => setState(() => _paymentMethod = v ?? _paymentMethod),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                      labelText: context.l10n.commonDate,
                        prefixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                      child: Text(formatDate(_date)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notesCtrl,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: context.l10n.commonNotes,
                      prefixIcon: Icon(Icons.notes_rounded),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FieldHeader(
                    label: 'Favorite',
                    icon: Icons.star_rounded,
                    trailing: Switch(
                      value: _isFavorite,
                      onChanged: (v) => setState(() => _isFavorite = v),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FieldHeader(label: context.l10n.commonReceipt, icon: Icons.receipt_rounded),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Text(
                              _receiptPath == null ? 'No receipt attached' : 'Attached',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const Spacer(),
                            TextButton.icon(
                              onPressed: _pickReceipt,
                              icon: const Icon(Icons.add_photo_alternate_rounded),
                              label: Text(context.l10n.expensesAttach),
                            ),
                          ]),
                          if (_receiptPath != null) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_receiptPath!),
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                    height: 180, child: Center(child: Icon(Icons.broken_image_rounded))),
                              ),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.close_rounded),
                              label: Text(context.l10n.actionRemove),
                              onPressed: () => setState(() => _receiptPath = null),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    icon: const Icon(Icons.save_rounded),
                    label: Text(_existing == null ? context.l10n.expensesSaveExpense : context.l10n.expensesUpdateExpense),
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}

enum ImageSourceChoice { camera, gallery }

class _CategoryChip extends StatelessWidget {
  final Category category;
  final bool selected;
  final VoidCallback onTap;
  const _CategoryChip({required this.category, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Color(category.colorValue);
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(DefaultCategories.iconFor(category.iconCode), size: 18, color: color),
      label: Text(category.name),
    );
  }
}

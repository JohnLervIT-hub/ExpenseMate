import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/default_categories.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/category.dart';
import '../../../data/models/recurring_expense.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/common/field_header.dart';
import '../../widgets/common/loading_indicator.dart';

class RecurringFormScreen extends ConsumerStatefulWidget {
  final int? recurringId;
  const RecurringFormScreen({super.key, this.recurringId});

  @override
  ConsumerState<RecurringFormScreen> createState() => _RecurringFormScreenState();
}

class _RecurringFormScreenState extends ConsumerState<RecurringFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _merchantCtrl = TextEditingController();

  int? _categoryId;
  String _frequency = 'Monthly';
  DateTime _nextDue = DateTime.now().add(const Duration(days: 7));
  bool _isActive = true;
  bool _loading = false;
  RecurringExpense? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.recurringId != null) _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _merchantCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await ref.read(recurringRepositoryProvider).getById(widget.recurringId!);
    if (r != null) {
      _existing = r;
      _amountCtrl.text = r.amount.toStringAsFixed(2);
      _merchantCtrl.text = r.merchant;
      _categoryId = r.categoryId;
      _frequency = r.frequency;
      _nextDue = r.nextDue;
      _isActive = r.isActive;
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
    final repo = ref.read(recurringRepositoryProvider);
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    final r = RecurringExpense(
      id: _existing?.id ?? 0,
      amount: amount,
      categoryId: _categoryId!,
      merchant: _merchantCtrl.text.trim(),
      frequency: _frequency,
      nextDue: _nextDue,
      isActive: _isActive,
    );
    if (_existing == null) {
      await repo.insert(r);
    } else {
      await repo.update(r);
    }
    ref.invalidate(recurringExpensesProvider);
    ref.invalidate(calendarMonthProvider);
    if (!mounted) return;
    context.pop();
  }

  Future<void> _delete() async {
    if (_existing == null) return;
    final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(context.l10n.recurringDeleteRule),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(context.l10n.actionCancel)),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(context.l10n.actionDelete)),
            ],
          ),
        ) ??
        false;
    if (!ok) return;
    await ref.read(recurringRepositoryProvider).delete(_existing!.id);
    ref.invalidate(recurringExpensesProvider);
    ref.invalidate(calendarMonthProvider);
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_existing == null ? 'New Recurring Rule' : 'Edit Rule'),
        actions: [
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
                      child: Row(children: [
                        Text(currency,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
                            )),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _amountCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w800,
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
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FieldHeader(label: context.l10n.commonMerchant, icon: Icons.store_rounded),
                  TextFormField(
                    controller: _merchantCtrl,
                    decoration: const InputDecoration(hintText: 'Netflix, Rent, State Farm…'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a merchant' : null,
                  ),
                  const SizedBox(height: 24),
                  FieldHeader(label: context.l10n.commonCategory, icon: Icons.category_rounded),
                  categoriesAsync.when(
                    data: (cats) => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in cats)
                          _CategoryChip(
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
                  FieldHeader(label: context.l10n.recurringFrequency, icon: Icons.repeat_rounded),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final f in AppConstants.recurrenceOptions)
                        ChoiceChip(
                          label: Text(f),
                          selected: _frequency == f,
                          onSelected: (_) => setState(() => _frequency = f),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FieldHeader(label: context.l10n.recurringNextDue, icon: Icons.calendar_today_rounded),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _nextDue,
                        firstDate: DateTime.now().subtract(const Duration(days: 30)),
                        lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) setState(() => _nextDue = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.event_rounded),
                      ),
                      child: Text(formatDate(_nextDue)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FieldHeader(
                    label: 'Active',
                    icon: Icons.power_settings_new_rounded,
                    trailing: Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    icon: const Icon(Icons.save_rounded),
                    label: Text(_existing == null ? 'Create Rule' : 'Save Rule'),
                    onPressed: _save,
                  ),
                ],
              ),
            ),
    );
  }
}

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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../core/constants/default_categories.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/budget.dart';
import '../../../data/models/category.dart';
import '../../../data/models/income.dart';
import '../../providers/currency_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/section_header.dart';

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key});

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  Future<_BudgetData> _load() async {
    final budget = await ref.read(budgetRepositoryProvider).forMonth(_month.year, _month.month);
    final categories = await ref.read(categoryRepositoryProvider).getAll();
    final byCat = await ref.read(expenseRepositoryProvider).totalsByCategoryForMonth(_month.year, _month.month);
    final incomeTotal = await ref.read(incomeRepositoryProvider).totalForMonth(_month.year, _month.month);
    final expensesTotal = await ref.read(expenseRepositoryProvider).totalForMonth(_month.year, _month.month);
    return _BudgetData(
      budget: budget ?? Budget.empty(_month.year, _month.month),
      categories: categories,
      byCategory: byCat,
      incomeTotal: incomeTotal,
      expensesTotal: expensesTotal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.budgetTitle)),
      body: FutureBuilder<_BudgetData>(
        future: _load(),
        builder: (context, snap) {
          if (!snap.hasData) return const AppLoadingIndicator();
          final data = snap.data!;
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () => setState(() {
                        _month = DateTime(_month.year, _month.month - 1);
                      }),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(formatMonthYear(_month),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () => setState(() {
                        _month = DateTime(_month.year, _month.month + 1);
                      }),
                    ),
                  ]),
                ),
                _MonthlyBudgetCard(
                  data: data,
                  currency: currency,
                  onSave: (b) async {
                    await ref.read(budgetRepositoryProvider).upsert(b);
                    ref.invalidate(dashboardSummaryProvider);
                    setState(() {});
                  },
                  onLogIncome: (amount, source) async {
                    if (amount <= 0) return;
                    await ref
                        .read(incomeRepositoryProvider)
                        .insert(Income.create(amount: amount, source: source, date: _month));
                    ref.invalidate(dashboardSummaryProvider);
                    setState(() {});
                  },
                ),
                const SectionHeader(title: 'Category Budgets'),
                for (final c in data.categories)
                  _CategoryBudgetRow(
                    category: c,
                    spent: data.byCategory[c.id] ?? 0,
                    currency: currency,
                    onSave: (newBudget) async {
                      await ref
                          .read(categoryRepositoryProvider)
                          .update(c.copyWith(budgetAmount: newBudget));
                      if (mounted) setState(() {});
                    },
                  ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.savings_rounded, color: AppColors.success),
                            const SizedBox(width: 8),
                            Text('Savings progress',
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 12),
                          _SavingsProgress(
                            saved: (data.incomeTotal - data.expensesTotal).clamp(0, double.infinity).toDouble(),
                            goal: data.budget.savingsGoal,
                            currency: currency,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BudgetData {
  final Budget budget;
  final List<Category> categories;
  final Map<int, double> byCategory;
  final double incomeTotal;
  final double expensesTotal;
  const _BudgetData({
    required this.budget,
    required this.categories,
    required this.byCategory,
    required this.incomeTotal,
    required this.expensesTotal,
  });
}

class _MonthlyBudgetCard extends StatefulWidget {
  final _BudgetData data;
  final String currency;
  final Future<void> Function(Budget) onSave;
  final Future<void> Function(double amount, String source) onLogIncome;

  const _MonthlyBudgetCard({
    required this.data,
    required this.currency,
    required this.onSave,
    required this.onLogIncome,
  });

  @override
  State<_MonthlyBudgetCard> createState() => _MonthlyBudgetCardState();
}

class _MonthlyBudgetCardState extends State<_MonthlyBudgetCard> {
  late final TextEditingController _income;
  late final TextEditingController _savings;
  late final TextEditingController _limit;

  @override
  void initState() {
    super.initState();
    _income = TextEditingController(text: widget.data.budget.income.toStringAsFixed(2));
    _savings = TextEditingController(text: widget.data.budget.savingsGoal.toStringAsFixed(2));
    _limit = TextEditingController(text: widget.data.budget.spendingLimit.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _income.dispose();
    _savings.dispose();
    _limit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.data.budget;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Monthly plan',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: _income,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monthly income (plan)',
                  prefixText: widget.currency,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _limit,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Spending limit',
                  prefixText: widget.currency,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _savings,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Savings goal',
                  prefixText: widget.currency,
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_rounded),
                    label: Text(context.l10n.budgetLogIncome),
                    onPressed: _logIncomeDialog,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save_rounded),
                    label: Text(context.l10n.budgetSavePlan),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await widget.onSave(b.copyWith(
                        income: double.tryParse(_income.text) ?? 0,
                        savingsGoal: double.tryParse(_savings.text) ?? 0,
                        spendingLimit: double.tryParse(_limit.text) ?? 0,
                      ));
                      if (mounted) {
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Budget saved')),
                        );
                      }
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Text(
                'Actual income: ${formatCurrency(widget.data.incomeTotal, symbol: widget.currency)} • Spent: ${formatCurrency(widget.data.expensesTotal, symbol: widget.currency)}',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logIncomeDialog() async {
    final amountCtrl = TextEditingController();
    final sourceCtrl = TextEditingController(text: 'Salary');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log income'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Amount', prefixText: widget.currency),
            ),
            const SizedBox(height: 8),
            TextField(controller: sourceCtrl, decoration: const InputDecoration(labelText: 'Source')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.actionCancel)),
          FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await widget.onLogIncome(double.tryParse(amountCtrl.text) ?? 0, sourceCtrl.text.trim());
              },
              child: Text(context.l10n.actionSave)),
        ],
      ),
    );
  }
}

class _CategoryBudgetRow extends StatelessWidget {
  final Category category;
  final double spent;
  final String currency;
  final Future<void> Function(double) onSave;

  const _CategoryBudgetRow({
    required this.category,
    required this.spent,
    required this.currency,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = category.budgetAmount > 0
        ? (spent / category.budgetAmount).clamp(0.0, 1.0)
        : 0.0;
    final over = category.budgetAmount > 0 && spent > category.budgetAmount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _editDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(category.colorValue).withOpacity(0.15),
                  child: Icon(DefaultCategories.iconFor(category.iconCode),
                      color: Color(category.colorValue)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(category.name,
                              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        Text(
                          category.budgetAmount > 0
                              ? '${formatCurrency(spent, symbol: currency)} / ${formatCurrency(category.budgetAmount, symbol: currency)}'
                              : formatCurrency(spent, symbol: currency),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: over ? AppColors.danger : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          color: over ? AppColors.danger : Color(category.colorValue),
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editDialog(BuildContext context) async {
    final ctrl = TextEditingController(text: category.budgetAmount.toStringAsFixed(2));
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${category.name} budget'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(prefixText: currency, labelText: 'Monthly amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.actionCancel)),
          FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await onSave(double.tryParse(ctrl.text) ?? 0);
              },
              child: Text(context.l10n.actionSave)),
        ],
      ),
    );
  }
}

class _SavingsProgress extends StatelessWidget {
  final double saved;
  final double goal;
  final String currency;
  const _SavingsProgress({required this.saved, required this.goal, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratio = goal > 0 ? (saved / goal).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 10,
            color: AppColors.success,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          goal > 0
              ? '${formatCurrency(saved, symbol: currency)} of ${formatCurrency(goal, symbol: currency)} saved'
              : 'Set a savings goal to track progress',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

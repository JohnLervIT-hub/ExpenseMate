import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/utils/date_utils.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/category.dart';
import '../../../data/models/expense.dart';
import '../../providers/currency_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/user_name_provider.dart';
import '../../widgets/cards/summary_card.dart';
import '../../widgets/charts/category_pie_chart.dart';
import '../../widgets/charts/monthly_bar_chart.dart';
import '../../widgets/charts/monthly_trend_chart.dart';
import '../../widgets/common/loading_indicator.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _tab = 0;

  Future<_ReportData> _load() async {
    final now = DateTime.now();
    final expensesRepo = ref.read(expenseRepositoryProvider);
    final incomeRepo = ref.read(incomeRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);

    final cats = await catRepo.getAll();
    final byCat = await expensesRepo.totalsByCategoryForMonth(now.year, now.month);
    final incomeMonth = await incomeRepo.totalForMonth(now.year, now.month);
    final expensesMonth = await expensesRepo.totalForMonth(now.year, now.month);
    final months = lastNMonths(now, 6);
    final ml = monthLabels();
    final trend = <double>[];
    final labels = <String>[];
    for (final (y, m) in months) {
      trend.add(await expensesRepo.totalForMonth(y, m));
      labels.add(ml[m - 1]);
    }

    // Yearly totals per month
    final ytdExpenses = <double>[];
    final ytdIncome = <double>[];
    for (var m = 1; m <= 12; m++) {
      ytdExpenses.add(await expensesRepo.totalForMonth(now.year, m));
      ytdIncome.add(await incomeRepo.totalForMonth(now.year, m));
    }
    final all = await expensesRepo.getAll(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
    return _ReportData(
      categories: cats,
      byCategory: byCat,
      incomeThisMonth: incomeMonth,
      expensesThisMonth: expensesMonth,
      last6: trend,
      last6Labels: labels,
      ytdExpenses: ytdExpenses,
      ytdIncome: ytdIncome,
      thisMonthExpenses: all,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.reportsTitle)),
      body: FutureBuilder<_ReportData>(
        future: _load(),
        builder: (context, snap) {
          if (!snap.hasData) return const AppLoadingIndicator();
          final d = snap.data!;
          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(children: [
                  for (var i = 0; i < _tabs.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_tabs[i]),
                        selected: _tab == i,
                        onSelected: (_) => setState(() => _tab = i),
                      ),
                    ),
                ]),
              ),
              Expanded(
                child: IndexedStack(
                  index: _tab,
                  children: [
                    _monthlyTab(d, currency),
                    _yearlyTab(d, currency),
                    _categoryTab(d, currency),
                    _incomeVsExpenseTab(d, currency),
                    _savingsTab(d, currency),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(children: [
                  Expanded(child: _exportButton('CSV', Icons.description_rounded, () => _exportCsv(d))),
                  const SizedBox(width: 8),
                  Expanded(child: _exportButton('Excel', Icons.table_chart_rounded, () => _exportExcel(d))),
                  const SizedBox(width: 8),
                  Expanded(child: _exportButton('PDF', Icons.picture_as_pdf_rounded, () => _exportPdf(d))),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  static const _tabs = ['Monthly', 'Yearly', 'Category', 'Income vs Expense', 'Savings'];

  Widget _exportButton(String label, IconData icon, VoidCallback onTap) => OutlinedButton.icon(
        icon: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onTap,
      );

  Widget _monthlyTab(_ReportData d, String currency) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(children: [
          Expanded(
            child: SummaryCard(
              title: 'Income (mo)',
              value: formatCurrency(d.incomeThisMonth, symbol: currency),
              icon: Icons.trending_up_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SummaryCard(
              title: 'Expenses (mo)',
              value: formatCurrency(d.expensesThisMonth, symbol: currency),
              icon: Icons.trending_down_rounded,
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Last 6 months', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 12),
              MonthlyBarChart(values: d.last6, labels: d.last6Labels),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _yearlyTab(_ReportData d, String currency) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Expenses by month', style: TextStyle(fontWeight: FontWeight.w700))),
              const SizedBox(height: 12),
              MonthlyBarChart(
                values: d.ytdExpenses,
                labels: monthLabels(),
                barColor: AppColors.danger,
              ),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Income by month', style: TextStyle(fontWeight: FontWeight.w700))),
              const SizedBox(height: 12),
              MonthlyTrendChart(
                values: d.ytdIncome,
                labels: monthLabels(),
                lineColor: AppColors.success,
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _categoryTab(_ReportData d, String currency) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CategoryPieChart(
              totals: d.byCategory,
              categories: d.categories,
              currencySymbol: currency,
            ),
          ),
        ),
      ],
    );
  }

  Widget _incomeVsExpenseTab(_ReportData d, String currency) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Income vs Expense (this year)',
                      style: TextStyle(fontWeight: FontWeight.w700))),
              const SizedBox(height: 12),
              SizedBox(
                height: 240,
                child: _IncomeExpenseChart(income: d.ytdIncome, expense: d.ytdExpenses),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _savingsTab(_ReportData d, String currency) {
    final savings = [
      for (var i = 0; i < 12; i++)
        (d.ytdIncome[i] - d.ytdExpenses[i]).clamp(0, double.infinity).toDouble(),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Savings per month', style: TextStyle(fontWeight: FontWeight.w700))),
              const SizedBox(height: 12),
              MonthlyBarChart(values: savings, labels: monthLabels()),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _exportCsv(_ReportData d) async {
    final svc = ref.read(exportServiceProvider);
    final path = await svc.exportExpensesCsv(d.thisMonthExpenses, d.categories);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: $path')));
    }
  }

  Future<void> _exportExcel(_ReportData d) async {
    final svc = ref.read(exportServiceProvider);
    final path = await svc.exportExpensesExcel(d.thisMonthExpenses, d.categories);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: $path')));
    }
  }

  Future<void> _exportPdf(_ReportData d) async {
    final svc = ref.read(exportServiceProvider);
    final currency = ref.read(currencySymbolProvider);
    final catById = {for (final c in d.categories) c.id: c.name};
    final name = ref.read(userNameProvider);
    final preparedFor =
        name.isEmpty ? null : context.l10n.backupPdfPreparedFor(name);
    final bytes = await svc.buildReportPdf(
      title: 'ExpenseMate Report',
      categoryTotals: {
        for (final e in d.byCategory.entries)
          catById[e.key] ?? 'Unknown': e.value,
      },
      income: d.incomeThisMonth,
      expenses: d.expensesThisMonth,
      savings: (d.incomeThisMonth - d.expensesThisMonth).clamp(0, double.infinity).toDouble(),
      currencySymbol: currency,
      preparedFor: preparedFor,
    );
    await svc.printOrShare(bytes, 'report_${DateTime.now().toIso8601String()}.pdf');
  }
}

class _ReportData {
  final List<Category> categories;
  final Map<int, double> byCategory;
  final double incomeThisMonth;
  final double expensesThisMonth;
  final List<double> last6;
  final List<String> last6Labels;
  final List<double> ytdExpenses;
  final List<double> ytdIncome;
  final List<Expense> thisMonthExpenses;

  const _ReportData({
    required this.categories,
    required this.byCategory,
    required this.incomeThisMonth,
    required this.expensesThisMonth,
    required this.last6,
    required this.last6Labels,
    required this.ytdExpenses,
    required this.ytdIncome,
    required this.thisMonthExpenses,
  });
}

class _IncomeExpenseChart extends StatelessWidget {
  final List<double> income;
  final List<double> expense;
  const _IncomeExpenseChart({required this.income, required this.expense});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 12; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(child: _bar(context, income[i], _maxOf(income, expense), Theme.of(context).colorScheme.primary)),
                        const SizedBox(width: 2),
                        Expanded(child: _bar(context, expense[i], _maxOf(income, expense), Theme.of(context).colorScheme.error)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(monthLabels()[i], style: const TextStyle(fontSize: 8)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  double _maxOf(List<double> a, List<double> b) {
    final combined = [...a, ...b];
    if (combined.isEmpty) return 100;
    final m = combined.reduce((x, y) => x > y ? x : y);
    return m <= 0 ? 100 : m;
  }

  Widget _bar(BuildContext context, double value, double max, Color color) {
    final ratio = (value / max).clamp(0.0, 1.0);
    return FractionallySizedBox(
      heightFactor: ratio,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }
}

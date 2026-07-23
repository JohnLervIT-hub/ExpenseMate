import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../data/models/category.dart';
import '../../data/models/expense.dart';
import 'repository_providers.dart';

class OverBudgetItem {
  final Category category;
  final double spent;
  final double overAmount;
  const OverBudgetItem({
    required this.category,
    required this.spent,
    required this.overAmount,
  });
}

class DashboardSummary {
  final double monthlyIncome;
  final double monthlyExpenses;
  final double remainingBudget;
  final double savings;
  final double groceries;
  final double budgetLimit;
  final double savingsGoal;
  final List<Expense> recent;
  final Map<int, double> byCategory;
  final List<double> last6MonthsExpenses;
  final List<String> last6MonthsLabels;
  final List<OverBudgetItem> overBudget;

  const DashboardSummary({
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.remainingBudget,
    required this.savings,
    required this.groceries,
    required this.budgetLimit,
    required this.savingsGoal,
    required this.recent,
    required this.byCategory,
    required this.last6MonthsExpenses,
    required this.last6MonthsLabels,
    required this.overBudget,
  });
}

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final incomeRepo = ref.watch(incomeRepositoryProvider);
  final budgetRepo = ref.watch(budgetRepositoryProvider);
  final categoryRepo = ref.watch(categoryRepositoryProvider);

  final now = DateTime.now();
  final year = now.year;
  final month = now.month;

  final income = await incomeRepo.totalForMonth(year, month);
  final expenses = await expenseRepo.totalForMonth(year, month);
  final byCategory = await expenseRepo.totalsByCategoryForMonth(year, month);
  final budget = await budgetRepo.forMonth(year, month);
  final recent = await expenseRepo.recent(limit: 5);
  final categories = await categoryRepo.getAll();

  final grocery = categories.firstWhere(
    (c) => c.name.toLowerCase() == 'groceries',
    orElse: () => categories.isNotEmpty
        ? categories.first
        : throw StateError('No categories'),
  );
  final groceriesTotal = byCategory[grocery.id] ?? 0;

  final budgetLimit = budget?.spendingLimit ?? 0;
  final savingsGoal = budget?.savingsGoal ?? 0;
  final remaining = budgetLimit > 0 ? (budgetLimit - expenses) : (income - expenses);
  final savings = income - expenses;

  final months = lastNMonths(now, 6);
  final trendValues = <double>[];
  final trendLabels = <String>[];
  final ml = monthLabels();
  for (final (y, m) in months) {
    trendValues.add(await expenseRepo.totalForMonth(y, m));
    trendLabels.add(ml[m - 1]);
  }

  final overBudget = <OverBudgetItem>[];
  for (final c in categories) {
    if (c.budgetAmount <= 0) continue;
    final spent = byCategory[c.id] ?? 0;
    if (spent > c.budgetAmount) {
      overBudget.add(OverBudgetItem(
        category: c,
        spent: spent,
        overAmount: spent - c.budgetAmount,
      ));
    }
  }
  overBudget.sort((a, b) => b.overAmount.compareTo(a.overAmount));

  return DashboardSummary(
    monthlyIncome: income,
    monthlyExpenses: expenses,
    remainingBudget: remaining,
    savings: savings,
    groceries: groceriesTotal,
    budgetLimit: budgetLimit,
    savingsGoal: savingsGoal,
    recent: recent,
    byCategory: byCategory,
    last6MonthsExpenses: trendValues,
    last6MonthsLabels: trendLabels,
    overBudget: overBudget,
  );
});

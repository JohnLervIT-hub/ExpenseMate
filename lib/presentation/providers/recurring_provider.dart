import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/recurring_expense.dart';
import 'repository_providers.dart';

final recurringExpensesProvider = FutureProvider<List<RecurringExpense>>((ref) async {
  return ref.watch(recurringRepositoryProvider).getAll();
});

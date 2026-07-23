import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/expense.dart';
import 'repository_providers.dart';

@immutable
class ExpenseFilter {
  final DateTime? start;
  final DateTime? end;
  final int? categoryId;
  final String? query;
  final bool favoritesOnly;

  const ExpenseFilter({
    this.start,
    this.end,
    this.categoryId,
    this.query,
    this.favoritesOnly = false,
  });

  @override
  bool operator ==(Object other) =>
      other is ExpenseFilter &&
      other.start == start &&
      other.end == end &&
      other.categoryId == categoryId &&
      other.query == query &&
      other.favoritesOnly == favoritesOnly;

  @override
  int get hashCode => Object.hash(start, end, categoryId, query, favoritesOnly);
}

final expensesProvider = FutureProvider.family<List<Expense>, ExpenseFilter>((ref, filter) async {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getAll(
    start: filter.start,
    end: filter.end,
    categoryId: filter.categoryId,
    query: filter.query,
    favoritesOnly: filter.favoritesOnly ? true : null,
  );
});

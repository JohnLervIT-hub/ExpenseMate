import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/date_utils.dart';
import '../../data/models/expense.dart';
import '../../data/models/recurring_expense.dart';
import 'repository_providers.dart';

@immutable
class CalendarMonthData {
  final DateTime month; // first-day-of-month anchor
  final Map<DateTime, List<Expense>> byDay; // key = midnight local
  final Map<DateTime, List<RecurringExpense>> upcomingByDay;
  final double monthTotal;
  final int transactionCount;

  const CalendarMonthData({
    required this.month,
    required this.byDay,
    required this.upcomingByDay,
    required this.monthTotal,
    required this.transactionCount,
  });

  List<Expense> forDay(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return byDay[key] ?? const [];
  }

  List<RecurringExpense> upcomingFor(DateTime day) {
    final key = DateTime(day.year, day.month, day.day);
    return upcomingByDay[key] ?? const [];
  }
}

final calendarMonthProvider =
    FutureProvider.family<CalendarMonthData, DateTime>((ref, month) async {
  final expenseRepo = ref.watch(expenseRepositoryProvider);
  final recurringRepo = ref.watch(recurringRepositoryProvider);

  final anchor = DateTime(month.year, month.month, 1);
  final start = firstDayOfMonth(anchor);
  final end = lastDayOfMonth(anchor);

  final expenses = await expenseRepo.getAll(start: start, end: end);
  final byDay = <DateTime, List<Expense>>{};
  var total = 0.0;
  for (final e in expenses) {
    final key = DateTime(e.date.year, e.date.month, e.date.day);
    (byDay[key] ??= []).add(e);
    total += e.amount;
  }

  final rules = await recurringRepo.getAll(activeOnly: true);
  final upcomingByDay = <DateTime, List<RecurringExpense>>{};
  for (final r in rules) {
    // Show a marker on the day it will next materialize, only if in this month.
    if (r.nextDue.year == anchor.year && r.nextDue.month == anchor.month) {
      final key = DateTime(r.nextDue.year, r.nextDue.month, r.nextDue.day);
      (upcomingByDay[key] ??= []).add(r);
    }
  }

  return CalendarMonthData(
    month: anchor,
    byDay: byDay,
    upcomingByDay: upcomingByDay,
    monthTotal: total,
    transactionCount: expenses.length,
  );
});

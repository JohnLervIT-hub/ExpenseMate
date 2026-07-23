import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/expense.dart';
import '../../../data/models/recurring_expense.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/format_prefs_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/cards/expense_tile.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = ref.watch(currencySymbolProvider);
    final firstDay = ref.watch(firstDayOfWeekProvider);
    final monthAnchor = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final async = ref.watch(calendarMonthProvider(monthAnchor));
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.calendarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: context.l10n.commonToday,
            onPressed: () => setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            }),
          ),
        ],
      ),
      body: async.when(
        loading: () => const AppLoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) {
          final daySelected = data.forDay(_selectedDay);
          final dayUpcoming = data.upcomingFor(_selectedDay);
          final dayTotal = daySelected.fold<double>(0, (a, e) => a + e.amount);
          return Column(
            children: [
              _MonthHeader(data: data, currency: currency),
              Container(
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TableCalendar<Expense>(
                  firstDay: DateTime(2020, 1, 1),
                  lastDay: DateTime.now().add(const Duration(days: 365 * 5)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                  calendarFormat: _format,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                    CalendarFormat.twoWeeks: '2 wks',
                    CalendarFormat.week: 'Week',
                  },
                  eventLoader: (d) => data.forDay(d),
                  startingDayOfWeek: firstDay == 1
                      ? StartingDayOfWeek.monday
                      : StartingDayOfWeek.sunday,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    titleTextStyle: theme.textTheme.titleMedium!
                        .copyWith(fontWeight: FontWeight.w700),
                    formatButtonDecoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    formatButtonTextStyle: theme.textTheme.labelMedium!
                        .copyWith(color: theme.colorScheme.onSecondaryContainer),
                    leftChevronIcon: Icon(Icons.chevron_left_rounded,
                        color: theme.colorScheme.primary),
                    rightChevronIcon: Icon(Icons.chevron_right_rounded,
                        color: theme.colorScheme.primary),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: theme.textTheme.labelSmall!,
                    weekendStyle: theme.textTheme.labelSmall!
                        .copyWith(color: theme.colorScheme.error),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: theme.textTheme.bodyMedium!
                        .copyWith(color: theme.colorScheme.error),
                    selectedDecoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                    markersAlignment: Alignment.bottomCenter,
                    markerSize: 0, // we draw our own dots
                    cellMargin: const EdgeInsets.all(4),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty && data.upcomingFor(day).isEmpty) {
                        return const SizedBox();
                      }
                      final total = events.fold<double>(0, (a, e) => a + e.amount);
                      final hasUpcoming = data.upcomingFor(day).isNotEmpty;
                      final dotSize = total > 0
                          ? (3.5 + (total / 100).clamp(0, 4)).toDouble()
                          : 4.0;
                      return Positioned(
                        bottom: 4,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (events.isNotEmpty)
                              Container(
                                width: dotSize,
                                height: dotSize,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (events.isNotEmpty && hasUpcoming)
                              const SizedBox(width: 3),
                            if (hasUpcoming)
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  onFormatChanged: (fmt) => setState(() => _format = fmt),
                  onPageChanged: (focused) => setState(() => _focusedDay = focused),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: _DayPanel(
                  day: _selectedDay,
                  expenses: daySelected,
                  upcoming: dayUpcoming,
                  dayTotal: dayTotal,
                  currency: currency,
                  categoriesAsync: categoriesAsync,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final CalendarMonthData data;
  final String currency;
  const _MonthHeader({required this.data, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final upcoming = data.upcomingByDay.values.expand((e) => e).toList()
      ..sort((a, b) => a.nextDue.compareTo(b.nextDue));
    final firstBill = upcoming.isNotEmpty ? upcoming.first : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.7),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatMonthYear(data.month),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.75),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatCurrency(data.monthTotal, symbol: currency),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${data.transactionCount} transactions',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          if (firstBill != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Next bill',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer.withOpacity(0.8),
                    ),
                  ),
                  Text(
                    firstBill.merchant,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${formatCurrency(firstBill.amount, symbol: currency)} · ${formatShortDate(firstBill.nextDue)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DayPanel extends StatelessWidget {
  final DateTime day;
  final List<Expense> expenses;
  final List<RecurringExpense> upcoming;
  final double dayTotal;
  final String currency;
  final AsyncValue categoriesAsync;

  const _DayPanel({
    required this.day,
    required this.expenses,
    required this.upcoming,
    required this.dayTotal,
    required this.currency,
    required this.categoriesAsync,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
          child: Row(
            children: [
              Text(
                formatDate(day),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (dayTotal > 0)
                Text(
                  formatCurrency(dayTotal, symbol: currency),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: expenses.isEmpty && upcoming.isEmpty
              ? const Center(
                  child: EmptyState(
                    icon: Icons.calendar_today_rounded,
                    title: 'Nothing on this day',
                    subtitle: 'Tap a day with a dot to see transactions.',
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    if (upcoming.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                        child: Text(context.l10n.calendarUpcomingBills,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      for (final r in upcoming)
                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: theme.colorScheme.tertiaryContainer,
                            ),
                            child: Icon(Icons.autorenew_rounded,
                                color: theme.colorScheme.onTertiaryContainer),
                          ),
                          title: Text(r.merchant,
                              style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: Text('${r.frequency} · ${context.l10n.calendarAutoLog}'),
                          trailing: Text(
                            formatCurrency(r.amount, symbol: currency),
                            style:
                                const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ),
                      const Divider(height: 24),
                    ],
                    if (expenses.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                        child: Text(context.l10n.calendarTransactionsHeader,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                      categoriesAsync.when(
                        data: (cats) {
                          final byId = {for (final c in cats) c.id: c};
                          return Column(
                            children: [
                              for (final e in expenses)
                                ExpenseTile(
                                  expense: e,
                                  category: byId[e.categoryId],
                                  currencySymbol: currency,
                                  onTap: () =>
                                      context.push('/expenses/edit/${e.id}'),
                                ),
                            ],
                          );
                        },
                        loading: () => const AppLoadingIndicator(),
                        error: (e, _) => Text('Error: $e'),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

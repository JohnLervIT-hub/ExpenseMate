import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/category.dart';
import '../../../data/models/expense.dart';
import '../../providers/calendar_provider.dart';
import '../../providers/currency_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/cards/expense_tile.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

enum _QuickRange { thisMonth, thisYear, allTime, custom }

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  ExpenseFilter _filter = _monthToDate();
  _QuickRange _quickRange = _QuickRange.thisMonth;

  static ExpenseFilter _monthToDate() {
    final now = DateTime.now();
    return ExpenseFilter(
      start: DateTime(now.year, now.month, 1),
      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
    );
  }

  void _applyQuickRange(_QuickRange r) {
    final now = DateTime.now();
    setState(() {
      _quickRange = r;
      switch (r) {
        case _QuickRange.thisMonth:
          _filter = ExpenseFilter(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
            categoryId: _filter.categoryId,
            query: _filter.query,
            favoritesOnly: _filter.favoritesOnly,
          );
          break;
        case _QuickRange.thisYear:
          _filter = ExpenseFilter(
            start: DateTime(now.year, 1, 1),
            end: DateTime(now.year, 12, 31, 23, 59, 59),
            categoryId: _filter.categoryId,
            query: _filter.query,
            favoritesOnly: _filter.favoritesOnly,
          );
          break;
        case _QuickRange.allTime:
          _filter = ExpenseFilter(
            start: null,
            end: null,
            categoryId: _filter.categoryId,
            query: _filter.query,
            favoritesOnly: _filter.favoritesOnly,
          );
          break;
        case _QuickRange.custom:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider(_filter));
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.expensesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(Routes.search),
          ),
          IconButton(
            icon: Icon(_filter.favoritesOnly ? Icons.star_rounded : Icons.star_border_rounded),
            tooltip: context.l10n.expensesFavorites,
            onPressed: () => setState(() {
              _filter = ExpenseFilter(
                start: _filter.start,
                end: _filter.end,
                categoryId: _filter.categoryId,
                query: _filter.query,
                favoritesOnly: !_filter.favoritesOnly,
              );
            }),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: _openFilterSheet,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.expenseNew),
        child: const Icon(Icons.add_rounded),
      ),
      body: Column(
        children: [
          _buildQuickChips(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(expensesProvider);
                ref.invalidate(calendarMonthProvider);
                await ref.read(expensesProvider(_filter).future);
              },
              child: expensesAsync.when(
                loading: () => const AppLoadingIndicator(),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (expenses) {
                  if (expenses.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 100),
                        EmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: context.l10n.expensesEmptyTitle,
                          subtitle: context.l10n.expensesEmptySubtitle,
                        ),
                      ],
                    );
                  }
                  return categoriesAsync.when(
                    loading: () => const AppLoadingIndicator(),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (cats) => _buildList(expenses, cats, currency),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChips(BuildContext context) {
    final l = context.l10n;
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [
          _chip(l.filterThisMonth, _QuickRange.thisMonth),
          _chip(l.filterThisYear, _QuickRange.thisYear),
          _chip(l.filterAllTime, _QuickRange.allTime),
          _chip(l.filterCustom, _QuickRange.custom, onTap: _openFilterSheet),
        ],
      ),
    );
  }

  Widget _chip(String label, _QuickRange range, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: _quickRange == range,
        onSelected: (_) {
          if (onTap != null) {
            setState(() => _quickRange = range);
            onTap();
          } else {
            _applyQuickRange(range);
          }
        },
      ),
    );
  }

  Widget _buildList(List<Expense> expenses, List<Category> cats, String currency) {
    final byId = {for (final c in cats) c.id: c};
    // Group by date (day)
    final grouped = <String, List<Expense>>{};
    for (final e in expenses) {
      final key = formatDate(e.date);
      grouped.putIfAbsent(key, () => []).add(e);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: grouped.length,
      itemBuilder: (context, i) {
        final key = grouped.keys.elementAt(i);
        final items = grouped[key]!;
        final dayTotal = items.fold<double>(0, (a, e) => a + e.amount);
        final theme = Theme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                children: [
                  Text(key,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Text(formatCurrency(dayTotal, symbol: currency),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            for (final e in items)
              Dismissible(
                key: ValueKey('exp-${e.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: theme.colorScheme.errorContainer,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: Icon(Icons.delete_rounded, color: theme.colorScheme.onErrorContainer),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(context.l10n.expensesDeleteConfirmTitle),
                          content: Text(context.l10n.expensesDeleteConfirmBody),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(context.l10n.actionCancel)),
                            FilledButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(context.l10n.actionDelete)),
                          ],
                        ),
                      ) ??
                      false;
                },
                onDismissed: (_) async {
                  final repo = ref.read(expenseRepositoryProvider);
                  final messenger = ScaffoldMessenger.of(context);
                  await repo.delete(e.id);
                  ref.invalidate(expensesProvider);
                  ref.invalidate(dashboardSummaryProvider);
                  ref.invalidate(calendarMonthProvider);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.expensesDeleted),
                      action: SnackBarAction(
                        label: context.l10n.actionUndo,
                        onPressed: () async {
                          await repo.insert(e.copyWith(id: 0));
                          ref.invalidate(expensesProvider);
                          ref.invalidate(dashboardSummaryProvider);
                          ref.invalidate(calendarMonthProvider);
                        },
                      ),
                    ),
                  );
                },
                child: ExpenseTile(
                  expense: e,
                  category: byId[e.categoryId],
                  currencySymbol: currency,
                  onTap: () => context.push('/expenses/edit/${e.id}'),
                  onLongPress: () => _showItemMenu(e),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showItemMenu(Expense e) async {
    final repo = ref.read(expenseRepositoryProvider);
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: Text(context.l10n.actionEdit),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/expenses/edit/${e.id}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: Text(context.l10n.expensesDuplicate),
              onTap: () async {
                Navigator.pop(ctx);
                await repo.duplicate(e.id);
                ref.invalidate(expensesProvider);
                ref.invalidate(dashboardSummaryProvider);
                ref.invalidate(calendarMonthProvider);
              },
            ),
            ListTile(
              leading: Icon(e.isFavorite ? Icons.star_rounded : Icons.star_border_rounded),
              title: Text(e.isFavorite ? 'Unfavorite' : 'Favorite'),
              onTap: () async {
                Navigator.pop(ctx);
                await repo.toggleFavorite(e.id);
                ref.invalidate(expensesProvider);
                ref.invalidate(calendarMonthProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded),
              title: Text(context.l10n.actionDelete),
              onTap: () async {
                Navigator.pop(ctx);
                await repo.delete(e.id);
                ref.invalidate(expensesProvider);
                ref.invalidate(dashboardSummaryProvider);
                ref.invalidate(calendarMonthProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    final categoriesAsync = ref.read(categoriesProvider);
    if (!categoriesAsync.hasValue) return;
    final cats = categoriesAsync.value!;
    int? selectedCat = _filter.categoryId;
    DateTimeRange? range = _filter.start != null && _filter.end != null
        ? DateTimeRange(start: _filter.start!, end: _filter.end!)
        : null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 8,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(context.l10n.expensesFilter, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                Text(context.l10n.commonCategory, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(context.l10n.commonAll),
                      selected: selectedCat == null,
                      onSelected: (_) => setSheet(() => selectedCat = null),
                    ),
                    for (final c in cats)
                      ChoiceChip(
                        label: Text(c.name),
                        selected: selectedCat == c.id,
                        onSelected: (_) => setSheet(() => selectedCat = c.id),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Text(context.l10n.expensesFilterDateRange, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDateRangePicker(
                        context: ctx,
                        firstDate: DateTime(now.year - 5),
                        lastDate: DateTime(now.year + 1),
                        initialDateRange: range,
                      );
                      if (picked != null) setSheet(() => range = picked);
                    },
                    child: Text(range == null
                        ? 'Any'
                        : '${formatShortDate(range!.start)} → ${formatShortDate(range!.end)}'),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _applyQuickRange(_QuickRange.thisMonth);
                        Navigator.pop(ctx);
                      },
                      child: Text(context.l10n.actionClear),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        setState(() {
                          _quickRange = _QuickRange.custom;
                          _filter = ExpenseFilter(
                            categoryId: selectedCat,
                            start: range?.start,
                            end: range?.end,
                            query: _filter.query,
                            favoritesOnly: _filter.favoritesOnly,
                          );
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text(context.l10n.actionApply),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../data/models/category.dart';
import '../../../data/models/expense.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/shopping_provider.dart';
import '../../widgets/cards/expense_tile.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  int? _categoryFilter;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final currency = ref.watch(currencySymbolProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final hasFilter = _query.isNotEmpty || _categoryFilter != null;
    final AsyncValue<List<Expense>> expensesAsync = !hasFilter
        ? const AsyncValue.data(<Expense>[])
        : ref.watch(expensesProvider(ExpenseFilter(
            query: _query.isEmpty ? null : _query,
            categoryId: _categoryFilter,
          )));
    final listsAsync = ref.watch(shoppingListsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          onChanged: (v) => setState(() => _query = v.trim()),
          decoration: InputDecoration(
            filled: false,
            border: InputBorder.none,
            hintText: l.searchHint,
          ),
        ),
        actions: [
          if (_ctrl.text.isNotEmpty || _categoryFilter != null)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () {
                _ctrl.clear();
                setState(() {
                  _query = '';
                  _categoryFilter = null;
                });
              },
            ),
        ],
      ),
      body: !hasFilter
          ? EmptyState(
              icon: Icons.search_rounded,
              title: l.searchTitleFallback,
              subtitle: l.searchSubtitleFallback,
            )
          : ListView(
              children: [
                if (_categoryFilter != null)
                  _buildCategoryFilterChip(categoriesAsync),
                _section(l.expensesTitle),
                expensesAsync.when(
                  loading: () => const AppLoadingIndicator(),
                  error: (e, _) => Padding(padding: const EdgeInsets.all(20), child: Text('$e')),
                  data: (list) {
                    if (list.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(l.searchNoExpenses),
                      );
                    }
                    return categoriesAsync.when(
                      loading: () => const AppLoadingIndicator(),
                      error: (e, _) => Padding(padding: const EdgeInsets.all(20), child: Text('$e')),
                      data: (cats) {
                        final byId = {for (final c in cats) c.id: c};
                        return Column(
                          children: [
                            for (final e in list.take(20))
                              ExpenseTile(
                                expense: e,
                                category: byId[e.categoryId],
                                currencySymbol: currency,
                                onTap: () => context.push('/expenses/edit/${e.id}'),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
                _section(l.searchShoppingLists),
                listsAsync.when(
                  loading: () => const AppLoadingIndicator(),
                  error: (e, _) => Padding(padding: const EdgeInsets.all(20), child: Text('$e')),
                  data: (lists) {
                    final filtered = _query.isEmpty
                        ? lists.take(0).toList()
                        : lists
                            .where((li) => li.name.toLowerCase().contains(_query.toLowerCase()))
                            .toList();
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(l.searchNoLists),
                      );
                    }
                    return Column(
                      children: [
                        for (final li in filtered)
                          ListTile(
                            leading: const Icon(Icons.shopping_cart_rounded),
                            title: Text(li.name),
                            onTap: () => context.push('/grocery/list/${li.id}'),
                          ),
                      ],
                    );
                  },
                ),
                _section(l.searchCategories),
                categoriesAsync.when(
                  loading: () => const AppLoadingIndicator(),
                  error: (e, _) => Padding(padding: const EdgeInsets.all(20), child: Text('$e')),
                  data: (cats) {
                    final filtered = _query.isEmpty
                        ? cats
                        : cats
                            .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
                            .toList();
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(l.searchNoCategories),
                      );
                    }
                    return Column(
                      children: [
                        for (final c in filtered)
                          ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(c.colorValue).withOpacity(0.2),
                              child: Icon(IconData(c.iconCode, fontFamily: 'MaterialIcons'),
                                  color: Color(c.colorValue)),
                            ),
                            title: Text(c.name),
                            trailing: _categoryFilter == c.id
                                ? const Icon(Icons.check_rounded)
                                : null,
                            onTap: () => setState(() {
                              _categoryFilter = _categoryFilter == c.id ? null : c.id;
                            }),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }

  Widget _buildCategoryFilterChip(AsyncValue<List<Category>> categoriesAsync) {
    return categoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (cats) {
        Category? cat;
        for (final c in cats) {
          if (c.id == _categoryFilter) {
            cat = c;
            break;
          }
        }
        if (cat == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Chip(
            avatar: CircleAvatar(
              backgroundColor: Color(cat.colorValue).withOpacity(0.2),
              child: Icon(
                IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
                size: 18,
                color: Color(cat.colorValue),
              ),
            ),
            label: Text(cat.name),
            deleteIcon: const Icon(Icons.close_rounded, size: 18),
            onDeleted: () => setState(() => _categoryFilter = null),
          ),
        );
      },
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
      );
}

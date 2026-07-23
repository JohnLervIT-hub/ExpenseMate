import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/currency_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/shopping_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/section_header.dart';

class GroceryScreen extends ConsumerWidget {
  const GroceryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListsProvider);
    final currency = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.groceryTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.groceryNew),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.groceryNewList),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(shoppingListsProvider);
          await ref.read(shoppingListsProvider.future);
        },
        child: listsAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (lists) {
            if (lists.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.shopping_cart_rounded,
                    title: 'No shopping lists',
                    subtitle: 'Create your first list to start tracking groceries.',
                  ),
                ],
              );
            }
            return ListView(
              padding: const EdgeInsets.only(bottom: 100),
              children: [
                const SectionHeader(title: 'Your lists'),
                for (final list in lists)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.push('/grocery/list/${list.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: theme.colorScheme.primaryContainer,
                                    ),
                                    child: Icon(Icons.shopping_cart_rounded,
                                        color: theme.colorScheme.onPrimaryContainer),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                list.name,
                                                style: theme.textTheme.titleMedium
                                                    ?.copyWith(fontWeight: FontWeight.w700),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (list.isFavorite)
                                              Icon(Icons.star_rounded,
                                                  size: 18, color: theme.colorScheme.tertiary),
                                          ],
                                        ),
                                        Text(
                                          'Updated ${formatDate(list.updatedAt)}',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert_rounded),
                                    onPressed: () => _showMenu(context, ref, list.id, list.isFavorite),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _ListStatsRow(listId: list.id, currency: currency),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, WidgetRef ref, int listId, bool isFav) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: Text(context.l10n.expensesDuplicate),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(shoppingRepositoryProvider).duplicateList(listId);
                ref.invalidate(shoppingListsProvider);
              },
            ),
            ListTile(
              leading: Icon(isFav ? Icons.star_rounded : Icons.star_border_rounded),
              title: Text(isFav ? 'Unfavorite' : 'Favorite'),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(shoppingRepositoryProvider).toggleFavoriteList(listId);
                ref.invalidate(shoppingListsProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_rounded),
              title: Text(context.l10n.groceryArchive),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(shoppingRepositoryProvider).archiveList(listId, true);
                ref.invalidate(shoppingListsProvider);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded),
              title: Text(context.l10n.actionDelete),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(shoppingRepositoryProvider).deleteList(listId);
                ref.invalidate(shoppingListsProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ListStatsRow extends ConsumerWidget {
  final int listId;
  final String currency;
  const _ListStatsRow({required this.listId, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final repo = ref.watch(shoppingRepositoryProvider);
    return FutureBuilder<List<double>>(
      future: Future.wait([
        repo.totalEstimatedForList(listId),
        repo.totalActualForList(listId),
        repo.purchasedCount(listId).then((v) => v.toDouble()),
        repo.totalCount(listId).then((v) => v.toDouble()),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const LinearProgressIndicator(minHeight: 4);
        }
        final [est, act, done, total] = snap.data!;
        final progress = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              _statLabel(theme, 'Estimated', formatCurrency(est, symbol: currency)),
              const SizedBox(width: 16),
              _statLabel(theme, 'Actual', formatCurrency(act, symbol: currency)),
              const Spacer(),
              Text('${done.toInt()}/${total.toInt()}',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: progress, minHeight: 6),
            ),
          ],
        );
      },
    );
  }

  Widget _statLabel(ThemeData t, String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          Text(value, style: t.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        ],
      );
}

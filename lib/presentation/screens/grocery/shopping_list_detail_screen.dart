import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/shopping_item.dart';
import '../../providers/currency_provider.dart';
import '../../providers/repository_providers.dart';
import '../../providers/shopping_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class ShoppingListDetailScreen extends ConsumerWidget {
  final int listId;
  const ShoppingListDetailScreen({super.key, required this.listId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(shoppingListDetailProvider(listId));
    final itemsAsync = ref.watch(shoppingItemsProvider(listId));
    final currency = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(
        title: listAsync.maybeWhen(
          data: (l) => Text(l?.name ?? 'List'),
          orElse: () => Text(context.l10n.groceryDetailFallbackTitle),
        ),
        actions: [
          IconButton(
            icon: listAsync.maybeWhen(
              data: (l) => Icon(l?.isFavorite == true ? Icons.star_rounded : Icons.star_border_rounded),
              orElse: () => const Icon(Icons.star_border_rounded),
            ),
            onPressed: () async {
              await ref.read(shoppingRepositoryProvider).toggleFavoriteList(listId);
              ref.invalidate(shoppingListDetailProvider(listId));
              ref.invalidate(shoppingListsProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showListMenu(context, ref),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showItemForm(context, ref, null),
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        top: false,
        child: itemsAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (items) {
            if (items.isEmpty) {
              return const EmptyState(
                icon: Icons.checklist_rounded,
                title: 'No items yet',
                subtitle: 'Tap + to add your first item.',
              );
            }
            return Column(
              children: [
                _SummaryHeader(items: items, currency: currency),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      for (final it in items)
                        _ItemRow(
                          key: ValueKey('item-${it.id}'),
                          item: it,
                          currency: currency,
                          onCheck: (v) async {
                            await ref
                                .read(shoppingRepositoryProvider)
                                .updateItem(it.copyWith(isPurchased: v));
                            ref.invalidate(shoppingItemsProvider(listId));
                          },
                          onTap: () => _showItemForm(context, ref, it),
                          onDelete: () async {
                            await ref.read(shoppingRepositoryProvider).deleteItem(it.id);
                            ref.invalidate(shoppingItemsProvider(listId));
                          },
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showListMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy_rounded),
              title: Text(context.l10n.groceryDuplicateList),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(shoppingRepositoryProvider).duplicateList(listId);
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
                if (context.mounted) context.pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded),
              title: Text(context.l10n.groceryDeleteList),
              onTap: () async {
                Navigator.pop(ctx);
                await ref.read(shoppingRepositoryProvider).deleteList(listId);
                ref.invalidate(shoppingListsProvider);
                if (context.mounted) context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showItemForm(BuildContext context, WidgetRef ref, ShoppingItem? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final qtyCtrl = TextEditingController(text: (existing?.quantity ?? 1).toString());
    final unitCtrl = TextEditingController(text: existing?.unit ?? '');
    final estCtrl = TextEditingController(text: (existing?.estimatedPrice ?? 0).toString());
    final actCtrl = TextEditingController(text: (existing?.actualPrice ?? 0).toString());
    final storeCtrl = TextEditingController(text: existing?.store ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          top: 8,
          left: 16,
          right: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(existing == null ? 'Add Item' : 'Edit Item',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: context.l10n.groceryItemName), autofocus: true),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: context.l10n.groceryQty),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(controller: unitCtrl, decoration: InputDecoration(labelText: context.l10n.groceryUnit)),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: estCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: context.l10n.commonEstimated),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: actCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: context.l10n.commonActual),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              TextField(controller: storeCtrl, decoration: InputDecoration(labelText: context.l10n.groceryStore)),
              const SizedBox(height: 12),
              TextField(controller: notesCtrl, decoration: InputDecoration(labelText: context.l10n.commonNotes)),
              const SizedBox(height: 20),
              Row(children: [
                if (existing != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_rounded),
                      label: Text(context.l10n.actionDelete),
                      onPressed: () async {
                        await ref.read(shoppingRepositoryProvider).deleteItem(existing.id);
                        ref.invalidate(shoppingItemsProvider(listId));
                        if (context.mounted) Navigator.pop(ctx);
                      },
                    ),
                  ),
                if (existing != null) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_rounded),
                    label: Text(context.l10n.actionSave),
                    onPressed: () async {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) return;
                      final repo = ref.read(shoppingRepositoryProvider);
                      final base = existing ??
                          ShoppingItem(
                            id: 0,
                            listId: listId,
                            name: name,
                            quantity: 1,
                            unit: '',
                            estimatedPrice: 0,
                            actualPrice: 0,
                            store: '',
                            isPurchased: false,
                            notes: '',
                            sortOrder: 0,
                          );
                      final updated = base.copyWith(
                        name: name,
                        quantity: double.tryParse(qtyCtrl.text) ?? 1,
                        unit: unitCtrl.text.trim(),
                        estimatedPrice: double.tryParse(estCtrl.text) ?? 0,
                        actualPrice: double.tryParse(actCtrl.text) ?? 0,
                        store: storeCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                      );
                      if (existing == null) {
                        await repo.insertItem(updated);
                      } else {
                        await repo.updateItem(updated);
                      }
                      ref.invalidate(shoppingItemsProvider(listId));
                      if (context.mounted) Navigator.pop(ctx);
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final List<ShoppingItem> items;
  final String currency;
  const _SummaryHeader({required this.items, required this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final est = items.fold<double>(0, (a, e) => a + e.estimatedPrice * e.quantity);
    final act = items.fold<double>(
        0, (a, e) => a + (e.actualPrice > 0 ? e.actualPrice : e.estimatedPrice) * e.quantity);
    final purchased = items.where((e) => e.isPurchased).length;
    final progress = items.isEmpty ? 0.0 : (purchased / items.length).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withOpacity(0.75),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _label(theme, 'Estimated', formatCurrency(est, symbol: currency))),
              const SizedBox(width: 12),
              Expanded(child: _label(theme, 'Total', formatCurrency(act, symbol: currency))),
              const SizedBox(width: 12),
              _label(theme, 'Purchased', '$purchased/${items.length}'),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.onPrimaryContainer.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(ThemeData t, String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: t.textTheme.labelSmall?.copyWith(color: t.colorScheme.onSurfaceVariant)),
          Text(value, style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        ],
      );
}

class _ItemRow extends StatelessWidget {
  final ShoppingItem item;
  final String currency;
  final ValueChanged<bool> onCheck;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ItemRow({
    super.key,
    required this.item,
    required this.currency,
    required this.onCheck,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qtyStr = item.quantity.truncateToDouble() == item.quantity
        ? item.quantity.toInt().toString()
        : item.quantity.toStringAsFixed(2);
    final subtitleParts = <String>[
      '$qtyStr${item.unit.isNotEmpty ? ' ${item.unit}' : ''}',
      if (item.store.isNotEmpty) item.store,
      if (item.notes.isNotEmpty) item.notes,
    ];
    final displayPrice =
        (item.actualPrice > 0 ? item.actualPrice : item.estimatedPrice) *
            item.quantity;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHigh
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.4),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          onLongPress: onDelete,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Checkbox(
                    value: item.isPurchased,
                    onChanged: (v) => onCheck(v ?? false),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          decoration: item.isPurchased
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isPurchased
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitleParts.join(' • '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatCurrency(displayPrice, symbol: currency),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.actualPrice > 0 ? 'Actual' : 'Est.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

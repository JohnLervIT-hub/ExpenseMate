import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/extensions/l10n_extension.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/default_categories.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/currency_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/recurring_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(recurringExpensesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final currency = ref.watch(currencySymbolProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.recurringTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.recurringNew),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.recurringNewRule),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recurringExpensesProvider);
          await ref.read(recurringExpensesProvider.future);
        },
        child: async.when(
          loading: () => const AppLoadingIndicator(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (rules) {
            if (rules.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 80),
                  EmptyState(
                    icon: Icons.autorenew_rounded,
                    title: 'No recurring rules yet',
                    subtitle:
                        'Add subscriptions like Netflix, rent, or insurance. They\'ll auto-log on their due date.',
                  ),
                ],
              );
            }
            return categoriesAsync.when(
              loading: () => const AppLoadingIndicator(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (cats) {
                final byId = {for (final c in cats) c.id: c};
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: rules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, i) {
                    final r = rules[i];
                    final cat = byId[r.categoryId];
                    final catColor = cat != null ? Color(cat.colorValue) : theme.colorScheme.primary;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.lerp(catColor, Colors.white, 0.12)!,
                                  catColor,
                                  Color.lerp(catColor, Colors.black, 0.25)!,
                                ],
                                stops: const [0, 0.55, 1],
                              ),
                            ),
                            child: Icon(
                              cat != null
                                  ? DefaultCategories.iconFor(cat.iconCode)
                                  : Icons.autorenew_rounded,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            r.merchant,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            '${r.frequency} · Next ${formatShortDate(r.nextDue)} · ${cat?.name ?? ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatCurrency(r.amount, symbol: currency),
                                style: theme.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 2),
                              Transform.scale(
                                scale: 0.7,
                                alignment: Alignment.centerRight,
                                child: Switch(
                                  value: r.isActive,
                                  onChanged: (_) async {
                                    await ref
                                        .read(recurringRepositoryProvider)
                                        .toggleActive(r.id);
                                    ref.invalidate(recurringExpensesProvider);
                                  },
                                ),
                              ),
                            ],
                          ),
                          onTap: () => context.push('/recurring/edit/${r.id}'),
                          onLongPress: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete recurring rule?'),
                                content: Text(
                                    'This won\'t remove past expenses. ${r.merchant} will just stop auto-logging.'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: Text(context.l10n.actionCancel)),
                                  FilledButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text(context.l10n.actionDelete)),
                                ],
                              ),
                            );
                            if (ok == true) {
                              await ref
                                  .read(recurringRepositoryProvider)
                                  .delete(r.id);
                              ref.invalidate(recurringExpensesProvider);
                              ref.invalidate(expensesProvider);
                              ref.invalidate(dashboardSummaryProvider);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

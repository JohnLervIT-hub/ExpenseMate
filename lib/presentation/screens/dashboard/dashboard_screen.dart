import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/currency_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/user_name_provider.dart';
import '../../providers/repository_providers.dart';
import '../../widgets/cards/expense_tile.dart';
import '../../widgets/cards/overspending_banner.dart';
import '../../widgets/cards/summary_card.dart';
import '../../widgets/charts/category_pie_chart.dart';
import '../../widgets/charts/monthly_trend_chart.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/section_header.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final currency = ref.watch(currencySymbolProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => context.push(Routes.calendar),
            tooltip: 'Calendar',
          ),
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.push(Routes.search),
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.assessment_rounded),
            onPressed: () => context.push(Routes.reports),
            tooltip: 'Reports',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAdd(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.dashboardQuickAdd),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardSummaryProvider);
          await ref.read(dashboardSummaryProvider.future);
        },
        child: summaryAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (s) => ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              if (AppConfig.demoMode) const _DemoBanner(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Builder(builder: (context) {
                  final userName = ref.watch(userNameProvider);
                  final headline = userName.isEmpty
                      ? l.dashboardOverview
                      : l.dashboardGreeting(userName);
                  return Text(
                    headline,
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  );
                }),
              ),
              OverspendingBanner(items: s.overBudget, currency: currency),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    SummaryCard(
                      title: l.dashboardMonthlyIncome,
                      value: formatCurrency(s.monthlyIncome, symbol: currency),
                      icon: Icons.trending_up_rounded,
                      color: AppColors.success,
                    ),
                    SummaryCard(
                      title: l.dashboardMonthlyExpenses,
                      value: formatCurrency(s.monthlyExpenses, symbol: currency),
                      icon: Icons.trending_down_rounded,
                      color: AppColors.danger,
                    ),
                    SummaryCard(
                      title: l.dashboardRemainingBudget,
                      value: formatCurrency(s.remainingBudget, symbol: currency),
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.info,
                    ),
                    SummaryCard(
                      title: l.dashboardSavings,
                      value: formatCurrency(s.savings, symbol: currency),
                      icon: Icons.savings_rounded,
                      color: theme.colorScheme.tertiary,
                    ),
                  ],
                ),
              ),
              if (s.budgetLimit > 0) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(l.dashboardBudgetUtilization,
                                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Text(
                                '${((s.monthlyExpenses / s.budgetLimit).clamp(0, 1) * 100).toStringAsFixed(0)}%',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: s.monthlyExpenses > s.budgetLimit
                                      ? AppColors.danger
                                      : theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: (s.monthlyExpenses / s.budgetLimit).clamp(0, 1).toDouble(),
                              minHeight: 10,
                              color: s.monthlyExpenses > s.budgetLimit
                                  ? AppColors.danger
                                  : theme.colorScheme.primary,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${formatCurrency(s.monthlyExpenses, symbol: currency)} of ${formatCurrency(s.budgetLimit, symbol: currency)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (s.monthlyExpenses > s.budgetLimit) ...[
                            const SizedBox(height: 8),
                            Row(children: [
                              const Icon(Icons.warning_amber_rounded,
                                  size: 16, color: AppColors.danger),
                              const SizedBox(width: 4),
                              Text(l.commonOverspending,
                                  style: theme.textTheme.labelSmall?.copyWith(color: AppColors.danger)),
                            ]),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              SectionHeader(
                title: l.dashboardSpendingByCategory,
                trailing: Text(
                  'This month',
                  style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: categoriesAsync.when(
                      data: (cats) => CategoryPieChart(
                        totals: s.byCategory,
                        categories: cats,
                        currencySymbol: currency,
                      ),
                      loading: () => const AppLoadingIndicator(),
                      error: (e, _) => Text('Error: $e'),
                    ),
                  ),
                ),
              ),
              SectionHeader(title: l.dashboardMonthlyTrend),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: MonthlyTrendChart(
                      values: s.last6MonthsExpenses,
                      labels: s.last6MonthsLabels,
                    ),
                  ),
                ),
              ),
              SectionHeader(
                title: l.commonRecentTransactions,
                trailing: TextButton(
                  onPressed: () => context.go(Routes.expenses),
                  child: Text(l.commonViewAll),
                ),
              ),
              if (s.recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: l.dashboardEmptyTitle,
                    subtitle: l.dashboardEmptySubtitle,
                  ),
                )
              else
                categoriesAsync.when(
                  data: (cats) {
                    final byId = {for (final c in cats) c.id: c};
                    return Column(
                      children: [
                        for (final e in s.recent)
                          ExpenseTile(
                            expense: e,
                            category: byId[e.categoryId],
                            currencySymbol: currency,
                            onTap: () => context.push('/expenses/edit/${e.id}'),
                          ),
                      ],
                    );
                  },
                  loading: () => const AppLoadingIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuickAdd(BuildContext context) {
    final l = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(ctx).colorScheme.primaryContainer,
                ),
                child: Icon(Icons.document_scanner_rounded,
                    color: Theme.of(ctx).colorScheme.onPrimaryContainer),
              ),
              title: Text(l.dashboardScanReceipt,
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(l.dashboardScanReceiptSubtitle),
              onTap: () {
                Navigator.pop(ctx);
                context.push(Routes.expenseScan);
              },
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(ctx).colorScheme.secondaryContainer,
                ),
                child: Icon(Icons.edit_rounded,
                    color: Theme.of(ctx).colorScheme.onSecondaryContainer),
              ),
              title: Text(l.dashboardEnterManually,
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(l.dashboardEnterManuallySubtitle),
              onTap: () {
                Navigator.pop(ctx);
                context.push(Routes.expenseNew);
              },
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

class _DemoBanner extends StatelessWidget {
  const _DemoBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.tertiaryContainer,
              theme.colorScheme.tertiaryContainer.withOpacity(0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.tertiary.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 6),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.play_circle_rounded,
                size: 20, color: theme.colorScheme.onTertiaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Demo — sample data',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Every transaction here is seeded. Buy the full source to make it yours.',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onTertiaryContainer.withOpacity(0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

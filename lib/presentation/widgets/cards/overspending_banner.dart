import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/default_categories.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/dashboard_provider.dart';

class OverspendingBanner extends StatelessWidget {
  final List<OverBudgetItem> items;
  final String currency;

  const OverspendingBanner({
    super.key,
    required this.items,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final l = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Card(
        color: AppColors.danger.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.danger, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.dashboardOverspendingTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              for (final it in items.take(4))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            Color(it.category.colorValue).withValues(alpha: 0.2),
                        child: Icon(
                          DefaultCategories.iconFor(it.category.iconCode),
                          size: 14,
                          color: Color(it.category.colorValue),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          it.category.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '+${formatCurrency(it.overAmount, symbol: currency)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => context.push(Routes.budget),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(l.dashboardOverspendingViewBudget),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/default_categories.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/category.dart';
import '../../../data/models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final Category? category;
  final String currencySymbol;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavorite;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.category,
    this.currencySymbol = '\$',
    this.onTap,
    this.onLongPress,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cat = category;
    final catColor = cat != null ? Color(cat.colorValue) : theme.colorScheme.primary;
    final title = expense.merchant.isNotEmpty ? expense.merchant : (cat?.name ?? 'Expense');
    final subtitleParts = <String>[
      formatShortDate(expense.date),
      if (expense.paymentMethod.isNotEmpty) expense.paymentMethod,
      if (cat != null) cat.name,
    ];
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
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
          boxShadow: [
            BoxShadow(
              color: catColor.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      Colors.white.withOpacity(0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Icon(
                cat != null ? DefaultCategories.iconFor(cat.iconCode) : Icons.receipt_long_rounded,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.35),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        subtitleParts.join(' • '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            formatCurrency(expense.amount, symbol: currencySymbol),
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          if (expense.isFavorite) const SizedBox(height: 4),
          if (expense.isFavorite)
            Icon(Icons.star_rounded, size: 16, color: theme.colorScheme.tertiary),
        ],
      ),
    );
  }
}

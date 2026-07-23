import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/category.dart';

class CategoryPieChart extends StatefulWidget {
  final Map<int, double> totals;
  final List<Category> categories;
  final String currencySymbol;

  const CategoryPieChart({
    super.key,
    required this.totals,
    required this.categories,
    this.currencySymbol = '\$',
  });

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = widget.totals.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline_rounded,
                  size: 48, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(height: 8),
              Text('No expenses yet this month',
                  style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    final catById = {for (final c in widget.categories) c.id: c};
    final total = entries.fold<double>(0, (a, e) => a + e.value);
    final topEntries = entries.take(6).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  setState(() {
                    _touchedIndex = response?.touchedSection?.touchedSectionIndex;
                  });
                },
              ),
              sections: [
                for (var i = 0; i < topEntries.length; i++)
                  PieChartSectionData(
                    value: topEntries[i].value,
                    color: catById[topEntries[i].key] != null
                        ? Color(catById[topEntries[i].key]!.colorValue)
                        : theme.colorScheme.primary,
                    title: _touchedIndex == i
                        ? '${((topEntries[i].value / total) * 100).toStringAsFixed(0)}%'
                        : '',
                    radius: _touchedIndex == i ? 62 : 52,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final e in topEntries)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: catById[e.key] != null
                          ? Color(catById[e.key]!.colorValue)
                          : theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(catById[e.key]?.name ?? 'Unknown',
                      style: theme.textTheme.labelSmall),
                  const SizedBox(width: 4),
                  Text(
                    formatCurrency(e.value, symbol: widget.currencySymbol),
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/extensions/l10n_extension.dart';

class MonthlyTrendChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color? lineColor;

  const MonthlyTrendChart({
    super.key,
    required this.values,
    this.labels = const [],
    this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxV = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);
    if (values.isEmpty || maxV <= 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.show_chart_rounded,
                size: 40,
                color: theme.colorScheme.outlineVariant,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.commonNoData,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    final ceiling = maxV * 1.2;
    final color = lineColor ?? theme.colorScheme.primary;
    final spots = <FlSpot>[
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: ceiling,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: ceiling / 4,
            getDrawingHorizontalLine: (v) => FlLine(
              color: theme.colorScheme.outlineVariant,
              strokeWidth: 0.5,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: labels.isNotEmpty,
                reservedSize: 26,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(labels[i],
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              barWidth: 3,
              color: color,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 4,
                  color: color,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

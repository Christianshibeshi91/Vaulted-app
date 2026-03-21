import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Revenue area chart with gold gradient fill.
class AdminRevenueChart extends StatelessWidget {
  final List<double> dataPoints;
  final List<String> labels;
  final String title;
  final double height;

  const AdminRevenueChart({
    super.key,
    required this.dataPoints,
    this.labels = const [],
    this.title = 'Revenue',
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return _emptyState();
    }

    final spots = dataPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    final maxY = dataPoints.reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      padding: VaultedSpacing.cardInner,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: VaultedTypography.gold(VaultedTypography.labelSmall)
                .copyWith(letterSpacing: 1.5),
          ),
          VaultedSpacing.gapLg,
          SizedBox(
            height: height,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: VaultedColors.border,
                    strokeWidth: 0.5,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: labels.isNotEmpty,
                      reservedSize: 22,
                      interval: (dataPoints.length / 5).ceilToDouble(),
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[idx],
                            style: VaultedTypography.labelMicro,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (dataPoints.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: VaultedColors.accentGold,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          VaultedColors.accentGold.withValues(alpha: 0.25),
                          VaultedColors.accentGold.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => VaultedColors.bgSecondary,
                    tooltipBorder:
                        const BorderSide(color: VaultedColors.borderStrong),
                    tooltipRoundedRadius: VaultedRadii.badge,
                    getTooltipItems: (spots) => spots.map((spot) {
                      return LineTooltipItem(
                        '\$${spot.y.toStringAsFixed(0)}',
                        VaultedTypography.gold(VaultedTypography.monoSmall),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      height: height + 60,
      padding: VaultedSpacing.cardInner,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      child: Center(
        child: Text(
          'No data available',
          style: VaultedTypography.muted(VaultedTypography.bodyMedium),
        ),
      ),
    );
  }
}

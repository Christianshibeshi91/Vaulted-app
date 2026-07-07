import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Revenue area chart with "ANALYTICS OVERVIEW" section header
/// and MONTHLY / QUARTERLY period toggle.
class AdminRevenueChart extends StatefulWidget {
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
  State<AdminRevenueChart> createState() => _AdminRevenueChartState();
}

class _AdminRevenueChartState extends State<AdminRevenueChart> {
  int _selectedPeriod = 0; // 0 = Monthly, 1 = Quarterly

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ────────────────────────────────
        Text(
          'ANALYTICS OVERVIEW',
          style: VaultedTypography.muted(VaultedTypography.labelSmall).copyWith(
            letterSpacing: 2.0,
          ),
        ),

        VaultedSpacing.gapLg,

        // ── Title + Period toggle ──────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Revenue Trend',
              style: VaultedTypography.headlineLarge,
            ),
            Row(
              children: [
                _PeriodTab(
                  label: 'MONTHLY',
                  isActive: _selectedPeriod == 0,
                  onTap: () => setState(() => _selectedPeriod = 0),
                ),
                const SizedBox(width: 12),
                _PeriodTab(
                  label: 'QUARTERLY',
                  isActive: _selectedPeriod == 1,
                  onTap: () => setState(() => _selectedPeriod = 1),
                ),
              ],
            ),
          ],
        ),

        VaultedSpacing.gapXl,

        // ── Chart ──────────────────────────────────────────
        if (widget.dataPoints.isEmpty)
          _emptyState()
        else
          _buildChart(),

        VaultedSpacing.gapMd,

        // ── X-axis labels ──────────────────────────────────
        if (widget.labels.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildXLabels(),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildXLabels() {
    if (widget.labels.length >= 6) {
      final step = (widget.labels.length / 6).floor().clamp(1, widget.labels.length);
      return List.generate(6, (i) {
        final idx = (i * step).clamp(0, widget.labels.length - 1);
        return Text(
          widget.labels[idx].toUpperCase(),
          style: VaultedTypography.muted(VaultedTypography.labelMicro),
        );
      });
    }
    final months = ['SEP', 'OCT', 'NOV', 'DEC', 'JAN', 'FEB'];
    return months
        .map((m) => Text(
              m,
              style: VaultedTypography.muted(VaultedTypography.labelMicro),
            ))
        .toList();
  }

  Widget _buildChart() {
    final spots = widget.dataPoints.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    final maxY = widget.dataPoints.reduce((a, b) => a > b ? a : b) * 1.2;

    return Container(
      padding: VaultedSpacing.cardInner,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      child: SizedBox(
        height: widget.height,
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
            titlesData: const FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: (widget.dataPoints.length - 1).toDouble(),
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
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, lineData, index) {
                    if (spot.x > widget.dataPoints.length - 3) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: VaultedColors.accentGold,
                        strokeWidth: 2,
                        strokeColor: VaultedColors.bgCard,
                      );
                    }
                    return FlDotCirclePainter(
                      radius: 0,
                      color: Colors.transparent,
                      strokeWidth: 0,
                      strokeColor: Colors.transparent,
                    );
                  },
                ),
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
                tooltipBorder: const BorderSide(color: VaultedColors.borderStrong),
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
    );
  }

  Widget _emptyState() {
    return Container(
      height: widget.height + 60,
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

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _PeriodTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            label,
            style: (isActive
                    ? VaultedTypography.bodyMedium.copyWith(
                        color: VaultedColors.accentGold,
                        fontWeight: FontWeight.w600,
                      )
                    : VaultedTypography.muted(VaultedTypography.bodyMedium))
                .copyWith(letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 40,
            color: isActive ? VaultedColors.accentGold : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

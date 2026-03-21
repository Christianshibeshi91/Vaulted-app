import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/admin/admin_kpi_cards.dart';

/// Admin revenue analytics screen.
class AdminRevenueScreen extends ConsumerWidget {
  const AdminRevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyAsync = ref.watch(dailyStatsProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: dailyAsync.when(
        data: (days) {
          // Aggregate totals
          var totalConversion = 0.0;
          var totalInterchange = 0.0;
          var totalPremium = 0.0;
          var totalAffiliate = 0.0;

          for (final d in days) {
            totalConversion += d.conversionRevenue;
            totalInterchange += d.interchangeRevenue;
            totalPremium += d.premiumRevenue;
            totalAffiliate += d.affiliateRevenue;
          }

          return ListView(
            padding: VaultedSpacing.screenH.copyWith(
              top: VaultedSpacing.xl,
              bottom: VaultedSpacing.section,
            ),
            children: [
              // ── Per-stream KPI cards ───────────────────────
              AdminKpiGrid(
                cards: [
                  AdminKpiCard(
                    icon: Icons.currency_exchange,
                    label: 'Conversion',
                    value: Formatters.currencyCompact(totalConversion),
                    useGoldAccent: true,
                  ),
                  AdminKpiCard(
                    icon: Icons.swap_horiz,
                    label: 'Interchange',
                    value: Formatters.currencyCompact(totalInterchange),
                  ),
                  AdminKpiCard(
                    icon: Icons.star_outline,
                    label: 'Premium',
                    value: Formatters.currencyCompact(totalPremium),
                    useGoldAccent: true,
                  ),
                  AdminKpiCard(
                    icon: Icons.handshake_outlined,
                    label: 'Affiliate',
                    value: Formatters.currencyCompact(totalAffiliate),
                  ),
                ],
              ),

              VaultedSpacing.gapXl,

              // ── Stacked bar chart ──────────────────────────
              _StackedRevenueChart(days: days),

              VaultedSpacing.gapXl,

              // ── User growth line chart ─────────────────────
              _UserGrowthChart(days: days),

              VaultedSpacing.gapXl,

              // ── Daily table ────────────────────────────────
              Text(
                'DAILY BREAKDOWN',
                style: VaultedTypography.gold(VaultedTypography.labelSmall)
                    .copyWith(letterSpacing: 1.5),
              ),
              VaultedSpacing.gapMd,
              _DailyTable(days: days),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: VaultedColors.accentGold,
            strokeWidth: 2,
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            'Failed to load revenue data',
            style: VaultedTypography.muted(VaultedTypography.bodyLarge),
          ),
        ),
      ),
    );
  }
}

// ── Stacked bar chart ────────────────────────────────────────────

class _StackedRevenueChart extends StatelessWidget {
  final List<dynamic> days;

  const _StackedRevenueChart({required this.days});

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

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
            'REVENUE BY STREAM',
            style: VaultedTypography.gold(VaultedTypography.labelSmall)
                .copyWith(letterSpacing: 1.5),
          ),
          VaultedSpacing.gapSm,
          // Legend
          Wrap(
            spacing: 16,
            children: [
              _LegendDot(color: VaultedColors.accentGold, label: 'Conversion'),
              _LegendDot(color: VaultedColors.info, label: 'Interchange'),
              _LegendDot(color: VaultedColors.success, label: 'Premium'),
              _LegendDot(color: VaultedColors.warning, label: 'Affiliate'),
            ],
          ),
          VaultedSpacing.gapLg,
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barTouchData: BarTouchData(enabled: false),
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
                      showTitles: true,
                      reservedSize: 22,
                      interval: (days.length / 6).ceilToDouble(),
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final date = (days[idx] as dynamic).date as String;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            date.length >= 5 ? date.substring(5) : date,
                            style: VaultedTypography.labelMicro,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: days.asMap().entries.map((e) {
                  final d = e.value as dynamic;
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: (d.conversionRevenue as double) +
                            (d.interchangeRevenue as double) +
                            (d.premiumRevenue as double) +
                            (d.affiliateRevenue as double),
                        width: 8,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(3),
                        ),
                        rodStackItems: [
                          BarChartRodStackItem(
                            0,
                            d.conversionRevenue as double,
                            VaultedColors.accentGold,
                          ),
                          BarChartRodStackItem(
                            d.conversionRevenue as double,
                            (d.conversionRevenue as double) +
                                (d.interchangeRevenue as double),
                            VaultedColors.info,
                          ),
                          BarChartRodStackItem(
                            (d.conversionRevenue as double) +
                                (d.interchangeRevenue as double),
                            (d.conversionRevenue as double) +
                                (d.interchangeRevenue as double) +
                                (d.premiumRevenue as double),
                            VaultedColors.success,
                          ),
                          BarChartRodStackItem(
                            (d.conversionRevenue as double) +
                                (d.interchangeRevenue as double) +
                                (d.premiumRevenue as double),
                            (d.conversionRevenue as double) +
                                (d.interchangeRevenue as double) +
                                (d.premiumRevenue as double) +
                                (d.affiliateRevenue as double),
                            VaultedColors.warning,
                          ),
                        ],
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: VaultedTypography.labelMicro),
      ],
    );
  }
}

// ── User growth chart ────────────────────────────────────────────

class _UserGrowthChart extends StatelessWidget {
  final List<dynamic> days;

  const _UserGrowthChart({required this.days});

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    final spots = days.asMap().entries.map((e) {
      return FlSpot(
        e.key.toDouble(),
        ((e.value as dynamic).newUsers as int).toDouble(),
      );
    }).toList();

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.3;

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
            'USER GROWTH',
            style: VaultedTypography.gold(VaultedTypography.labelSmall)
                .copyWith(letterSpacing: 1.5),
          ),
          VaultedSpacing.gapLg,
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (days.length - 1).toDouble(),
                minY: 0,
                maxY: maxY > 0 ? maxY : 10,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: VaultedColors.success,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          VaultedColors.success.withValues(alpha: 0.2),
                          VaultedColors.success.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily breakdown table ────────────────────────────────────────

class _DailyTable extends StatelessWidget {
  final List<dynamic> days;

  const _DailyTable({required this.days});

  @override
  Widget build(BuildContext context) {
    final reversed = days.reversed.toList();

    return Container(
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: VaultedColors.bgInput,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Date',
                      style: VaultedTypography.muted(
                          VaultedTypography.labelMicro)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Revenue',
                      style: VaultedTypography.muted(
                          VaultedTypography.labelMicro),
                      textAlign: TextAlign.right),
                ),
                Expanded(
                  child: Text('Txns',
                      style: VaultedTypography.muted(
                          VaultedTypography.labelMicro),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
          ...reversed.take(14).map((day) {
            final d = day as dynamic;
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(
                  bottom:
                      BorderSide(color: VaultedColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      d.date as String,
                      style: VaultedTypography.monoSmall,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      Formatters.currency(d.totalRevenue as double),
                      style: VaultedTypography.gold(
                          VaultedTypography.monoSmall),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${d.totalTransactions as int}',
                      style: VaultedTypography.monoSmall,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../widgets/admin/admin_kpi_cards.dart';

/// Admin cards overview with KPIs, retailer breakdown, and distribution chart.
class AdminCardsScreen extends StatelessWidget {
  const AdminCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collectionGroup('cards').snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: VaultedColors.accentGold,
                strokeWidth: 2,
              ),
            );
          }

          final docs = snap.data!.docs;
          final allCards = docs.map((d) => d.data() as Map<String, dynamic>).toList();

          // ── Compute KPIs ───────────────────────────────────
          final total = allCards.length;
          final active = allCards.where((c) => c['status'] == 'active').length;
          final depleted = allCards.where((c) => c['status'] == 'depleted').length;
          final expired = allCards.where((c) => c['status'] == 'expired').length;

          // ── Retailer breakdown ─────────────────────────────
          final retailerMap = <String, _RetailerStats>{};
          for (final card in allCards) {
            final name = card['retailer'] as String? ?? 'Unknown';
            final balance = (card['balance'] as num?)?.toDouble() ?? 0;
            final stats = retailerMap.putIfAbsent(
              name,
              () => _RetailerStats(name: name),
            );
            stats.count++;
            stats.totalValue += balance;
          }
          final retailers = retailerMap.values.toList()
            ..sort((a, b) => b.totalValue.compareTo(a.totalValue));

          return ListView(
            padding: VaultedSpacing.screenH.copyWith(
              top: VaultedSpacing.xl,
              bottom: VaultedSpacing.section,
            ),
            children: [
              // ── KPI Row ────────────────────────────────────
              AdminKpiGrid(
                cards: [
                  AdminKpiCard(
                    icon: Icons.credit_card,
                    label: 'Total Cards',
                    value: '$total',
                    useGoldAccent: true,
                  ),
                  AdminKpiCard(
                    icon: Icons.check_circle_outline,
                    label: 'Active',
                    value: '$active',
                  ),
                  AdminKpiCard(
                    icon: Icons.remove_circle_outline,
                    label: 'Depleted',
                    value: '$depleted',
                  ),
                  AdminKpiCard(
                    icon: Icons.timer_off_outlined,
                    label: 'Expired',
                    value: '$expired',
                  ),
                ],
              ),

              VaultedSpacing.gapXl,

              // ── Distribution chart ─────────────────────────
              _DistributionChart(retailers: retailers.take(8).toList()),

              VaultedSpacing.gapXl,

              // ── Retailer table ─────────────────────────────
              Text(
                'RETAILER BREAKDOWN',
                style: VaultedTypography.gold(VaultedTypography.labelSmall)
                    .copyWith(letterSpacing: 1.5),
              ),
              VaultedSpacing.gapMd,
              _RetailerTable(retailers: retailers),
            ],
          );
        },
      ),
    );
  }
}

// ── Mutable stats accumulator (local to this file) ───────────────

class _RetailerStats {
  final String name;
  int count = 0;
  double totalValue = 0;

  _RetailerStats({required this.name});

  double get avgBalance => count > 0 ? totalValue / count : 0;
}

// ── Distribution bar chart ───────────────────────────────────────

class _DistributionChart extends StatelessWidget {
  final List<_RetailerStats> retailers;

  const _DistributionChart({required this.retailers});

  @override
  Widget build(BuildContext context) {
    if (retailers.isEmpty) return const SizedBox.shrink();

    final maxVal = retailers
        .map((r) => r.totalValue)
        .reduce((a, b) => a > b ? a : b);

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
            'CARD DISTRIBUTION',
            style: VaultedTypography.gold(VaultedTypography.labelSmall)
                .copyWith(letterSpacing: 1.5),
          ),
          VaultedSpacing.gapLg,
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => VaultedColors.bgSecondary,
                    tooltipBorder:
                        const BorderSide(color: VaultedColors.borderStrong),
                    tooltipRoundedRadius: VaultedRadii.badge,
                    getTooltipItem: (group, gIdx, rod, rIdx) {
                      final r = retailers[group.x.toInt()];
                      return BarTooltipItem(
                        '${r.name}\n${Formatters.currencyCompact(r.totalValue)}',
                        VaultedTypography.gold(VaultedTypography.labelMicro),
                      );
                    },
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
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= retailers.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            retailers[idx].name.length > 6
                                ? '${retailers[idx].name.substring(0, 5)}..'
                                : retailers[idx].name,
                            style: VaultedTypography.labelMicro,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: retailers.asMap().entries.map((e) {
                  return BarChartGroupData(
                    x: e.key,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.totalValue,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            VaultedColors.accentGold.withValues(alpha: 0.4),
                            VaultedColors.accentGold,
                          ],
                        ),
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

// ── Retailer table ───────────────────────────────────────────────

class _RetailerTable extends StatelessWidget {
  final List<_RetailerStats> retailers;

  const _RetailerTable({required this.retailers});

  @override
  Widget build(BuildContext context) {
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
                  flex: 3,
                  child: Text('Retailer',
                      style: VaultedTypography.muted(
                          VaultedTypography.labelMicro)),
                ),
                Expanded(
                  child: Text('Count',
                      style: VaultedTypography.muted(
                          VaultedTypography.labelMicro),
                      textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Total Value',
                      style: VaultedTypography.muted(
                          VaultedTypography.labelMicro),
                      textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Avg Balance',
                      style: VaultedTypography.muted(
                          VaultedTypography.labelMicro),
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
          // Rows
          ...retailers.map((r) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: VaultedColors.border, width: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        r.name,
                        style: VaultedTypography.bodyMedium
                            .copyWith(color: VaultedColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${r.count}',
                        style: VaultedTypography.monoSmall,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        Formatters.currency(r.totalValue),
                        style: VaultedTypography.monoSmall,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        Formatters.currency(r.avgBalance),
                        style: VaultedTypography.monoSmall,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

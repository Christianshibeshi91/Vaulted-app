import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/admin_providers.dart';
import '../../widgets/admin/admin_activity_feed.dart';
import '../../widgets/admin/admin_kpi_cards.dart';
import '../../widgets/admin/admin_revenue_chart.dart';

/// Main admin dashboard with KPIs, revenue chart, live feed, and alerts.
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final alertsAsync = ref.watch(adminAlertsProvider);
    final dailyAsync = ref.watch(dailyStatsProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: RefreshIndicator(
        color: VaultedColors.accentGold,
        backgroundColor: VaultedColors.bgCard,
        onRefresh: () async {
          ref.invalidate(adminStatsProvider);
          ref.invalidate(dailyStatsProvider);
        },
        child: ListView(
          padding: VaultedSpacing.screenH.copyWith(
            top: VaultedSpacing.xl,
            bottom: VaultedSpacing.section,
          ),
          children: [
            // ── Alerts banner ────────────────────────────────────
            alertsAsync.when(
              data: (alerts) {
                final critical = alerts
                    .where((a) => a.severity == 'critical' && !a.isResolved)
                    .toList();
                if (critical.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: VaultedSpacing.lg),
                  child: Container(
                    padding: VaultedSpacing.cardInner,
                    decoration: BoxDecoration(
                      color: VaultedColors.danger.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: VaultedColors.danger.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: VaultedColors.danger,
                          size: 22,
                        ),
                        VaultedSpacing.gapHMd,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${critical.length} Critical Alert${critical.length > 1 ? 's' : ''}',
                                style: VaultedTypography.bodyLarge.copyWith(
                                  color: VaultedColors.danger,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              VaultedSpacing.gapXs,
                              Text(
                                critical.first.title,
                                style: VaultedTypography.bodyMedium.copyWith(
                                  color: VaultedColors.danger
                                      .withValues(alpha: 0.8),
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
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // ── KPI Grid ─────────────────────────────────────────
            statsAsync.when(
              data: (stats) => AdminKpiGrid(
                cards: [
                  AdminKpiCard(
                    icon: Icons.people_outline,
                    label: 'Total Users',
                    value: '${stats['totalUsers'] ?? 0}',
                    delta: '+12%',
                    useGoldAccent: true,
                  ),
                  AdminKpiCard(
                    icon: Icons.credit_card_outlined,
                    label: 'Total Cards',
                    value: '${stats['totalCards'] ?? 0}',
                    delta: '+8%',
                  ),
                  AdminKpiCard(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Total Value',
                    value: Formatters.currencyCompact(
                      (stats['totalValue'] as num?)?.toDouble() ?? 0,
                    ),
                    delta: '+15%',
                    useGoldAccent: true,
                  ),
                  AdminKpiCard(
                    icon: Icons.trending_up,
                    label: 'Revenue',
                    value: Formatters.currencyCompact(
                      (stats['revenue'] as num?)?.toDouble() ?? 0,
                    ),
                    delta: '+22%',
                  ),
                ],
              ),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: VaultedColors.accentGold,
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (e, _) => _errorCard('Failed to load stats'),
            ),

            VaultedSpacing.gapXl,

            // ── Revenue Chart ────────────────────────────────────
            dailyAsync.when(
              data: (days) {
                final revenues =
                    days.map((d) => d.totalRevenue).toList();
                final labels = days
                    .map((d) => d.date.length >= 5
                        ? d.date.substring(5) // MM-DD
                        : d.date)
                    .toList();
                return AdminRevenueChart(
                  dataPoints: revenues,
                  labels: labels,
                  title: 'REVENUE (30 DAYS)',
                );
              },
              loading: () => const AdminRevenueChart(
                dataPoints: [],
                title: 'REVENUE (30 DAYS)',
              ),
              error: (_, _) => _errorCard('Chart unavailable'),
            ),

            VaultedSpacing.gapXl,

            // ── Live Feed ────────────────────────────────────────
            const AdminActivityFeed(),
          ],
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      padding: VaultedSpacing.cardInner,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VaultedColors.border),
      ),
      child: Center(
        child: Text(
          message,
          style: VaultedTypography.muted(VaultedTypography.bodyMedium),
        ),
      ),
    );
  }
}

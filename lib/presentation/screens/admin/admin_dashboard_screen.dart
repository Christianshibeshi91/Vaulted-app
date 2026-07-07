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
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _alertDismissed = false;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);
    final alertsAsync = ref.watch(adminAlertsProvider);
    final dailyAsync = ref.watch(dailyStatsProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: Column(
        children: [
          // ── Alert banner (amber, dismissible) ─────────────
          if (!_alertDismissed)
            alertsAsync.when(
              data: (alerts) {
                final flagged = alerts
                    .where((a) =>
                        a.severity == 'critical' && !a.isResolved)
                    .toList();
                if (flagged.isEmpty) return const SizedBox.shrink();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: VaultedColors.warning.withValues(alpha: 0.15),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: VaultedColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text:
                                '${flagged.length} flagged transactions require review  ',
                            style: VaultedTypography.bodyMedium.copyWith(
                              color: VaultedColors.textPrimary,
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: 'Review',
                                style: TextStyle(
                                  color: VaultedColors.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _alertDismissed = true),
                        child: Icon(
                          Icons.close,
                          color: VaultedColors.textSecondary,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

          // ── Scrollable body ───────────────────────────────
          Expanded(
            child: RefreshIndicator(
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
                  // ── KPI Grid ────────────────────────────────
                  statsAsync.when(
                    data: (stats) => AdminKpiGrid(
                      cards: [
                        AdminKpiCard(
                          icon: Icons.people_outline,
                          label: 'TOTAL USERS',
                          value: Formatters.compactNumber(
                            (stats['totalUsers'] as num?)?.toInt() ?? 0,
                          ),
                          delta: '+3.2%',
                          useGoldAccent: true,
                        ),
                        AdminKpiCard(
                          icon: Icons.credit_card_outlined,
                          label: 'ACTIVE CARDS',
                          value: Formatters.compactNumber(
                            (stats['totalCards'] as num?)?.toInt() ?? 0,
                          ),
                          delta: '+5.8%',
                        ),
                        AdminKpiCard(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'REVENUE',
                          value: Formatters.currencyCompact(
                            (stats['revenue'] as num?)?.toDouble() ?? 0,
                          ),
                          delta: '+12.1%',
                          useGoldAccent: true,
                        ),
                        AdminKpiCard(
                          icon: Icons.flag_outlined,
                          label: 'FLAGGED TXNS',
                          value: '${stats['flaggedCount'] ?? 0}',
                          statusText: 'NEEDS ATTENTION',
                          statusIcon: Icons.warning_amber_rounded,
                          isPositiveDelta: false,
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

                  // ── Revenue Chart ────────────────────────────
                  dailyAsync.when(
                    data: (days) {
                      final revenues =
                          days.map((d) => d.totalRevenue).toList();
                      final labels = days
                          .map((d) => d.date.length >= 5
                              ? d.date.substring(5)
                              : d.date)
                          .toList();
                      return AdminRevenueChart(
                        dataPoints: revenues,
                        labels: labels,
                      );
                    },
                    loading: () => const AdminRevenueChart(
                      dataPoints: [],
                    ),
                    error: (_, _) => _errorCard('Chart unavailable'),
                  ),

                  VaultedSpacing.gapXl,

                  // ── Live Activity Feed ────────────────────────
                  const AdminActivityFeed(),
                ],
              ),
            ),
          ),
        ],
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

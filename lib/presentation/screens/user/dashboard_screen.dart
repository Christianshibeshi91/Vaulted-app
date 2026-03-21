import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/card_providers.dart';
import '../../widgets/cards/add_card_sheet.dart';
import '../../widgets/dashboard/balance_card.dart';
import '../../widgets/dashboard/cards_carousel.dart';
import '../../widgets/dashboard/expiration_alert.dart';
import '../../widgets/dashboard/quick_actions.dart';
import '../../widgets/dashboard/recent_activity.dart';

/// Main dashboard screen -- first tab of the user shell.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: RefreshIndicator(
        color: VaultedColors.accentGold,
        backgroundColor: VaultedColors.bgCard,
        onRefresh: () async {
          ref.invalidate(cardsProvider);
          ref.invalidate(recentTransactionsProvider);
          await Haptics.lightTap();
          // Allow streams to re-emit.
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Collapsing App Bar ──────────────────────────────
            SliverAppBar(
              expandedHeight: 100,
              floating: false,
              pinned: true,
              backgroundColor: VaultedColors.bgPrimary,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(
                  left: VaultedSpacing.xl,
                  bottom: VaultedSpacing.lg,
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_greeting,',
                      style: VaultedTypography.bodyMedium.copyWith(
                        fontSize: 11,
                        color: VaultedColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Your Vault',
                      style: VaultedTypography.headlineMedium.copyWith(
                        fontSize: 16,
                        color: VaultedColors.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding:
                      const EdgeInsets.only(right: VaultedSpacing.lg),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_outlined,
                          size: 24,
                        ),
                        onPressed: () {
                          Haptics.lightTap();
                          context.go('/notifications');
                        },
                        tooltip: 'Notifications',
                      ),
                      // Badge
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: VaultedColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ── Body ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: VaultedSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VaultedSpacing.gapMd,

                    // Balance hero
                    const BalanceCard(),
                    VaultedSpacing.gapXxl,

                    // Expiration alert
                    const ExpirationAlert(),
                    VaultedSpacing.gapXxl,

                    // Quick actions
                    QuickActions(
                      onAddCard: () => AddCardSheet.show(context),
                      onCheckAll: () => Haptics.mediumTap(),
                      onActivity: () => context.go('/activity'),
                      onShare: () => Haptics.lightTap(),
                    ),
                    VaultedSpacing.gapXxl,

                    // Section label
                    Text(
                      'Your Cards',
                      style: VaultedTypography.headlineMedium,
                    ),
                    VaultedSpacing.gapMd,
                  ],
                ),
              ),
            ),

            // Cards carousel (full-width, horizontal scroll)
            SliverToBoxAdapter(
              child: CardsCarousel(
                onCardTap: (cardId) {
                  Haptics.lightTap();
                  context.go('/cards/detail/$cardId');
                },
              ),
            ),

            // ── Balance Trend Chart ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                  vertical: VaultedSpacing.xxl,
                ),
                child: const _BalanceTrendChart(),
              ),
            ),

            // ── Recent Activity ──────────────────────────────────
            const SliverToBoxAdapter(
              child: RecentActivity(),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Balance trend line chart ─────────────────────────────────────

class _BalanceTrendChart extends StatelessWidget {
  const _BalanceTrendChart();

  @override
  Widget build(BuildContext context) {
    // Sample data -- will be replaced by real data from provider.
    final spots = [
      const FlSpot(0, 320),
      const FlSpot(1, 380),
      const FlSpot(2, 360),
      const FlSpot(3, 420),
      const FlSpot(4, 400),
      const FlSpot(5, 480),
      const FlSpot(6, 460),
    ];

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
          Text('Balance Trend', style: VaultedTypography.headlineMedium),
          VaultedSpacing.gapSm,
          Text(
            'Last 7 days',
            style: VaultedTypography.secondary(VaultedTypography.bodyMedium),
          ),
          VaultedSpacing.gapLg,
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => VaultedColors.bgCard,
                    tooltipRoundedRadius: VaultedRadii.badge,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          '\$${spot.y.toStringAsFixed(0)}',
                          VaultedTypography.monoSmall.copyWith(
                            color: VaultedColors.accentGold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
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
                          VaultedColors.accentGold.withValues(alpha: 0.15),
                          VaultedColors.accentGold.withValues(alpha: 0.0),
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
    )
        .animate()
        .fadeIn(duration: 500.ms, delay: 200.ms, curve: Curves.easeOut)
        .slideY(
            begin: 0.05, end: 0, duration: 500.ms, delay: 200.ms, curve: Curves.easeOut);
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../providers/auth_providers.dart';
import '../../providers/card_providers.dart';
import '../../providers/notification_providers.dart';
import '../../widgets/cards/add_card_sheet.dart';
import '../../widgets/dashboard/balance_card.dart';
import '../../widgets/dashboard/cards_carousel.dart';
import '../../widgets/dashboard/expiration_alert.dart';
import '../../widgets/dashboard/quick_actions.dart';
import '../../widgets/dashboard/recent_activity.dart';

/// Main dashboard screen -- first tab of the user shell.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _shareText =
      'Check out Vaulted — the smart way to manage your gift cards! https://vaulted.app';

  Future<void> _handleShare(BuildContext context) async {
    if (kIsWeb) {
      await Clipboard.setData(const ClipboardData(text: _shareText));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link copied to clipboard')),
        );
      }
    } else {
      await Share.share(_shareText, subject: 'Try Vaulted');
    }
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadCountProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;
    final displayName = user?.displayName?.split(' ').first ?? 'there';

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: RefreshIndicator(
        color: VaultedColors.accentGold,
        backgroundColor: VaultedColors.bgCard,
        onRefresh: () async {
          ref.invalidate(cardsProvider);
          ref.invalidate(recentTransactionsProvider);
          await Haptics.lightTap();
          await Future<void>.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            // ── Top Bar ──────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 60,
              floating: false,
              pinned: true,
              backgroundColor: VaultedColors.bgPrimary,
              leading: IconButton(
                icon: const Icon(Icons.menu, size: 24),
                onPressed: () {
                  Haptics.lightTap();
                  Scaffold.of(context).openDrawer();
                },
              ),
              title: Text(
                '$_greeting, $displayName',
                style: VaultedTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
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
                      // Badge — only show when there are unread notifications
                      if (unreadCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: VaultedColors.accentGold,
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
                    VaultedSpacing.gapXl,

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
                      onShare: () {
                        Haptics.lightTap();
                        _handleShare(context);
                      },
                    ),
                    VaultedSpacing.gapXxl,

                    // My Cards section header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Cards',
                          style: VaultedTypography.headlineMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            Haptics.lightTap();
                            context.go('/cards');
                          },
                          child: Text(
                            'SEE ALL →',
                            style: VaultedTypography.labelSmall.copyWith(
                              color: VaultedColors.accentGold,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
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

            VaultedSpacing.gapXxl.toSliver,

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

// ── SizedBox to sliver extension ──────────────────────────────────

extension on SizedBox {
  SliverToBoxAdapter get toSliver => SliverToBoxAdapter(child: this);
}

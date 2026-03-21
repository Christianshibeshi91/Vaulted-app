import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/constants/retailers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/card_model.dart';
import '../../providers/card_providers.dart';
import '../../widgets/cards/add_card_sheet.dart';
import '../../widgets/cards/card_grid_item.dart';

/// Cards list screen -- second tab of the user shell.
class CardsListScreen extends ConsumerWidget {
  const CardsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);
    final filteredCards = ref.watch(filteredCardsProvider);
    final filter = ref.watch(cardsFilterProvider);
    final search = ref.watch(cardsSearchProvider);
    final sortMode = ref.watch(cardsSortProvider);
    final viewMode = ref.watch(cardsViewModeProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      floatingActionButton: (cardsAsync.valueOrNull ?? []).isNotEmpty
          ? FloatingActionButton(
              onPressed: () => AddCardSheet.show(context),
              backgroundColor: VaultedColors.accentGold,
              foregroundColor: VaultedColors.bgPrimary,
              elevation: 4,
              tooltip: 'Add Card',
              child: const Icon(Icons.add),
            )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms, curve: Curves.easeOut)
              .scale(
                begin: const Offset(0.0, 0.0),
                end: const Offset(1.0, 1.0),
                delay: 300.ms,
                duration: 400.ms,
                curve: Curves.easeOut,
              )
          : null,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 60,
            floating: true,
            pinned: true,
            backgroundColor: VaultedColors.bgPrimary,
            title: Text(
              'My Cards',
              style: VaultedTypography.gold(
                  VaultedTypography.headlineLarge),
            ),
            actions: [
              // View toggle
              IconButton(
                icon: Icon(
                  viewMode == CardsViewMode.grid
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  size: 22,
                ),
                onPressed: () {
                  Haptics.lightTap();
                  ref.read(cardsViewModeProvider.notifier).state =
                      viewMode == CardsViewMode.grid
                          ? CardsViewMode.list
                          : CardsViewMode.grid;
                },
                tooltip: viewMode == CardsViewMode.grid
                    ? 'List view'
                    : 'Grid view',
              ),

              // Sort
              PopupMenuButton<CardSortMode>(
                icon: const Icon(Icons.sort_rounded, size: 22),
                tooltip: 'Sort',
                color: VaultedColors.bgSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: VaultedRadii.brCard,
                  side: const BorderSide(color: VaultedColors.border),
                ),
                onSelected: (mode) {
                  Haptics.lightTap();
                  ref.read(cardsSortProvider.notifier).state = mode;
                },
                itemBuilder: (_) => CardSortMode.values
                    .map(
                      (mode) => PopupMenuItem(
                        value: mode,
                        child: Row(
                          children: [
                            if (mode == sortMode)
                              const Icon(
                                Icons.check,
                                size: 16,
                                color: VaultedColors.accentGold,
                              )
                            else
                              const SizedBox(width: 16),
                            VaultedSpacing.gapHSm,
                            Text(
                              mode.label,
                              style: VaultedTypography.bodyMedium.copyWith(
                                color: mode == sortMode
                                    ? VaultedColors.accentGold
                                    : VaultedColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),

          // ── Search Bar ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VaultedSpacing.xl,
                vertical: VaultedSpacing.sm,
              ),
              child: TextField(
                onChanged: (v) =>
                    ref.read(cardsSearchProvider.notifier).state = v,
                style: VaultedTypography.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search cards...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => ref
                              .read(cardsSearchProvider.notifier)
                              .state = '',
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── Filter Chips ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: filter == 'all',
                      onTap: () => ref
                          .read(cardsFilterProvider.notifier)
                          .state = 'all',
                    ),
                    for (final status in CardStatus.all)
                      _FilterChip(
                        label: CardStatus.label(status),
                        isSelected: filter == status,
                        onTap: () => ref
                            .read(cardsFilterProvider.notifier)
                            .state = status,
                      ),
                  ],
                ),
              ),
            ),
          ),

          VaultedSpacing.gapMd.toSliver,

          // ── Cards Content ────────────────────────────────────
          cardsAsync.when(
            loading: () => _buildSkeleton(viewMode),
            error: (_, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: VaultedColors.danger, size: 40),
                    VaultedSpacing.gapMd,
                    Text(
                      'Could not load cards',
                      style: VaultedTypography.bodyLarge.copyWith(
                        color: VaultedColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (_) {
              if (filteredCards.isEmpty) {
                return SliverFillRemaining(
                  child: _EmptyState(
                    hasFilter: filter != 'all' || search.isNotEmpty,
                    onAddCard: () => AddCardSheet.show(context),
                  ),
                );
              }

              if (viewMode == CardsViewMode.grid) {
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: VaultedSpacing.xl),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) {
                        final card = filteredCards[index];
                        return Dismissible(
                          key: ValueKey(card.id),
                          direction: DismissDirection.endToStart,
                          background: _DismissBackground(),
                          confirmDismiss: (_) =>
                              _confirmArchive(context, card),
                          child: CardGridItem(
                            card: card,
                            index: index,
                            onTap: () {
                              Haptics.lightTap();
                              context.go('/cards/detail/${card.id}');
                            },
                          ),
                        );
                      },
                      childCount: filteredCards.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: VaultedSpacing.md,
                      crossAxisSpacing: VaultedSpacing.md,
                      childAspectRatio: 0.82,
                    ),
                  ),
                );
              }

              // List view
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: VaultedSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) {
                      final card = filteredCards[index];
                      return Dismissible(
                        key: ValueKey(card.id),
                        direction: DismissDirection.endToStart,
                        background: _DismissBackground(),
                        confirmDismiss: (_) =>
                            _confirmArchive(context, card),
                        child: _ListTileCard(
                          card: card,
                          index: index,
                          onTap: () {
                            Haptics.lightTap();
                            context.go('/cards/detail/${card.id}');
                          },
                        ),
                      );
                    },
                    childCount: filteredCards.length,
                  ),
                ),
              );
            },
          ),

          // Bottom padding for FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  SliverPadding _buildSkeleton(CardsViewMode viewMode) {
    if (viewMode == CardsViewMode.grid) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, i) => Container(
              decoration: BoxDecoration(
                color: VaultedColors.bgCard,
                borderRadius: VaultedRadii.brCard,
                border: Border.all(color: VaultedColors.border),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: 1200.ms,
                  delay: (100 * i).ms,
                  color: VaultedColors.shimmerHighlight,
                ),
            childCount: 4,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: VaultedSpacing.md,
            crossAxisSpacing: VaultedSpacing.md,
            childAspectRatio: 0.82,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Container(
            height: 72,
            margin: const EdgeInsets.only(bottom: VaultedSpacing.sm),
            decoration: BoxDecoration(
              color: VaultedColors.bgCard,
              borderRadius: VaultedRadii.brCard,
              border: Border.all(color: VaultedColors.border),
            ),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                delay: (100 * i).ms,
                color: VaultedColors.shimmerHighlight,
              ),
          childCount: 4,
        ),
      ),
    );
  }

  Future<bool?> _confirmArchive(
      BuildContext context, CardModel card) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Card?'),
        content: Text(
            'Archive your ${card.retailer} card? You can restore it later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Haptics.mediumTap();
              Navigator.pop(ctx, true);
            },
            child: const Text('Archive'),
          ),
        ],
      ),
    );
  }
}

// ── Filter Chip ──────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.selection();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(right: VaultedSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: VaultedSpacing.lg,
          vertical: VaultedSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? VaultedColors.accentGoldDim
              : VaultedColors.bgCard,
          borderRadius: VaultedRadii.brPill,
          border: Border.all(
            color: isSelected
                ? VaultedColors.accentGold.withValues(alpha: 0.4)
                : VaultedColors.border,
          ),
        ),
        child: Text(
          label,
          style: VaultedTypography.bodyMedium.copyWith(
            color: isSelected
                ? VaultedColors.accentGold
                : VaultedColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ── Dismiss Background ───────────────────────────────────────────

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: VaultedSpacing.xxl),
      decoration: BoxDecoration(
        color: VaultedColors.warning.withValues(alpha: 0.1),
        borderRadius: VaultedRadii.brCard,
      ),
      child: const Icon(
        Icons.archive_outlined,
        color: VaultedColors.warning,
        size: 24,
      ),
    );
  }
}

// ── Empty State ──────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  final VoidCallback? onAddCard;

  const _EmptyState({required this.hasFilter, this.onAddCard});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: VaultedSpacing.insetsXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating icon with gold ring
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: VaultedColors.accentGoldDim,
                border: Border.all(
                  color: VaultedColors.accentGold.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                hasFilter
                    ? Icons.filter_list_off_rounded
                    : Icons.account_balance_wallet_outlined,
                color: VaultedColors.accentGold.withValues(alpha: 0.6),
                size: 40,
              ),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .moveY(
                  begin: 0,
                  end: -6,
                  duration: 2000.ms,
                  curve: Curves.easeInOut,
                ),
            VaultedSpacing.gapXxl,
            Text(
              hasFilter ? 'No cards match your filter' : 'Your vault is empty',
              style: VaultedTypography.headlineMedium.copyWith(
                color: VaultedColors.textPrimary,
              ),
            ),
            VaultedSpacing.gapSm,
            Text(
              hasFilter
                  ? 'Try adjusting your search or filters'
                  : 'Add your first gift card to get started',
              style: VaultedTypography.secondary(VaultedTypography.bodyMedium),
              textAlign: TextAlign.center,
            ),
            if (!hasFilter) ...[
              VaultedSpacing.gapXxxl,
              SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Haptics.mediumTap();
                    onAddCard?.call();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add a Card'),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .then(delay: 600.ms)
                  .shimmer(
                    duration: 1800.ms,
                    color: VaultedColors.accentGoldLight.withValues(alpha: 0.3),
                  ),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

// ── List tile card ───────────────────────────────────────────────

class _ListTileCard extends StatelessWidget {
  final CardModel card;
  final int index;
  final VoidCallback? onTap;

  const _ListTileCard({
    required this.card,
    required this.index,
    this.onTap,
  });

  Color get _retailerColor {
    final retailer =
        Retailers.byName(card.retailer);
    if (retailer != null) return retailer.color;
    final hex = card.retailerColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: VaultedSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: VaultedSpacing.lg,
          vertical: VaultedSpacing.md,
        ),
        decoration: BoxDecoration(
          color: VaultedColors.bgCard,
          borderRadius: VaultedRadii.brCard,
          border: Border.all(color: VaultedColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _retailerColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  card.retailer.isNotEmpty
                      ? card.retailer[0].toUpperCase()
                      : '?',
                  style: VaultedTypography.headlineMedium.copyWith(
                    color: _retailerColor,
                  ),
                ),
              ),
            ),
            VaultedSpacing.gapHMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.retailer,
                    style: VaultedTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CardStatus.label(card.status),
                    style: VaultedTypography.labelSmall,
                  ),
                ],
              ),
            ),
            Text(
              Formatters.currency(card.balance),
              style: VaultedTypography.monoMedium.copyWith(
                color: VaultedColors.accentGold,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 250.ms,
          delay: (40 * index).ms,
          curve: Curves.easeOut,
        )
        .slideX(
          begin: 0.03,
          end: 0,
          duration: 250.ms,
          delay: (40 * index).ms,
          curve: Curves.easeOut,
        );
  }
}

// ── SizedBox to sliver extension ──────────────────────────────────

extension on SizedBox {
  SliverToBoxAdapter get toSliver => SliverToBoxAdapter(child: this);
}

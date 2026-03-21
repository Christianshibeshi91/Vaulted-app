import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/retailers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/card_model.dart';
import '../../providers/card_providers.dart';

/// Horizontal scrolling carousel of gift cards on the dashboard.
class CardsCarousel extends ConsumerWidget {
  final void Function(String cardId)? onCardTap;

  const CardsCarousel({super.key, this.onCardTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);

    return cardsAsync.when(
      loading: () => const _CarouselSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (cards) {
        if (cards.isEmpty) return const _CarouselEmpty();

        final activeCards =
            cards.where((c) => c.status == CardStatus.active).toList();
        if (activeCards.isEmpty) return const _CarouselEmpty();

        return SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding:
                const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
            itemCount: activeCards.length,
            itemBuilder: (context, index) {
              final card = activeCards[index];
              return _CarouselCard(
                card: card,
                index: index,
                onTap: () => onCardTap?.call(card.id),
              );
            },
          ),
        );
      },
    );
  }
}

class _CarouselCard extends StatelessWidget {
  final CardModel card;
  final int index;
  final VoidCallback? onTap;

  const _CarouselCard({
    required this.card,
    required this.index,
    this.onTap,
  });

  Color get _retailerColor {
    final retailer = Retailers.byName(card.retailer);
    if (retailer != null) return retailer.color;
    // Parse hex from model if no match.
    final hex = card.retailerColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: VaultedSpacing.md),
        padding: VaultedSpacing.cardInner,
        decoration: BoxDecoration(
          color: VaultedColors.bgCard,
          borderRadius: VaultedRadii.brCard,
          border: Border.all(color: VaultedColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _retailerColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      card.retailer.isNotEmpty
                          ? card.retailer[0].toUpperCase()
                          : '?',
                      style: VaultedTypography.bodyLarge.copyWith(
                        color: _retailerColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                VaultedSpacing.gapHSm,
                Expanded(
                  child: Text(
                    card.retailer,
                    style: VaultedTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              Formatters.currency(card.balance),
              style: VaultedTypography.monoLarge.copyWith(
                color: VaultedColors.accentGold,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: (60 * index).ms,
          curve: Curves.easeOut,
        )
        .slideX(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
          delay: (60 * index).ms,
          curve: Curves.easeOut,
        );
  }
}

class _CarouselSkeleton extends StatelessWidget {
  const _CarouselSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
        itemCount: 3,
        itemBuilder: (_, index) => Container(
          width: 200,
          margin: const EdgeInsets.only(right: VaultedSpacing.md),
          decoration: BoxDecoration(
            color: VaultedColors.bgCard,
            borderRadius: VaultedRadii.brCard,
            border: Border.all(color: VaultedColors.border),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
              duration: 1200.ms,
              delay: (100 * index).ms,
              color: VaultedColors.shimmerHighlight,
            ),
      ),
    );
  }
}

class _CarouselEmpty extends StatelessWidget {
  const _CarouselEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(
          color: VaultedColors.border,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          'No active cards yet',
          style: VaultedTypography.secondary(VaultedTypography.bodyMedium),
        ),
      ),
    );
  }
}

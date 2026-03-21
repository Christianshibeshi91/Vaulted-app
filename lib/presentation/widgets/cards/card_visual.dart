import 'package:flutter/material.dart';

import '../../../core/constants/retailers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/card_model.dart';

/// Stylised physical-card visual with retailer gradient.
///
/// Used in [CardDetailScreen] and as a standalone preview.
class CardVisual extends StatelessWidget {
  final CardModel card;
  final bool showFullNumber;
  final double? width;

  const CardVisual({
    super.key,
    required this.card,
    this.showFullNumber = false,
    this.width,
  });

  Color get _retailerColor {
    final retailer = Retailers.byName(card.retailer);
    if (retailer != null) return retailer.color;
    final hex = card.retailerColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? MediaQuery.sizeOf(context).width - 40;
    final cardHeight = cardWidth * 0.6;

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.all(VaultedSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: VaultedRadii.brCard,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _retailerColor.withValues(alpha: 0.85),
            _retailerColor.withValues(alpha: 0.45),
            VaultedColors.bgCard,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: _retailerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row: retailer name + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  card.retailer,
                  style: VaultedTypography.headlineLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _StatusChip(status: card.status),
            ],
          ),

          // Card number
          if (card.cardNumberEncrypted != null)
            Text(
              showFullNumber
                  ? Formatters.groupCardDigits(
                      card.cardNumberEncrypted!)
                  : Formatters.maskCardNumber(
                      card.cardNumberEncrypted ?? ''),
              style: VaultedTypography.monoMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
                letterSpacing: 2.0,
              ),
            ),

          // Bottom row: balance + expiration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BALANCE',
                    style: VaultedTypography.labelMicro.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.currency(card.balance),
                    style: VaultedTypography.monoHero.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (card.expirationDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'EXPIRES',
                      style: VaultedTypography.labelMicro.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.dateShort(card.expirationDate!),
                      style: VaultedTypography.monoSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  Color get _color => switch (status) {
        'active' => VaultedColors.success,
        'depleted' => VaultedColors.textMuted,
        'expired' => VaultedColors.danger,
        'archived' => VaultedColors.textSecondary,
        _ => VaultedColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VaultedSpacing.sm,
        vertical: VaultedSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: VaultedRadii.brBadge,
      ),
      child: Text(
        CardStatus.label(status),
        style: VaultedTypography.labelMicro.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

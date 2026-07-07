import 'package:flutter/material.dart';

import '../../../core/constants/retailers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/card_model.dart';

/// Full-width card visual with retailer gradient, card details,
/// masked number with eye toggle, expiry, and status badge.
///
/// Used in [CardDetailScreen] as the hero element.
class CardVisual extends StatelessWidget {
  final CardModel card;
  final bool showFullNumber;
  final VoidCallback? onToggleNumber;
  final double? width;

  const CardVisual({
    super.key,
    required this.card,
    this.showFullNumber = false,
    this.onToggleNumber,
    this.width,
  });

  Color get _retailerColor {
    final retailer = Retailers.byName(card.retailer);
    if (retailer != null) return retailer.color;
    final hex = card.retailerColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String get _retailerInitial {
    if (card.retailer.isEmpty) return '?';
    return card.retailer[0].toUpperCase();
  }

  Color get _statusColor => switch (card.status) {
        'active' => VaultedColors.success,
        'depleted' => VaultedColors.textMuted,
        'expired' => VaultedColors.danger,
        'archived' => VaultedColors.textSecondary,
        _ => VaultedColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final cardWidth = width ?? MediaQuery.sizeOf(context).width;
    final cardHeight = cardWidth * 0.58;

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
            _retailerColor.withValues(alpha: 0.9),
            _retailerColor.withValues(alpha: 0.5),
            VaultedColors.bgCard.withValues(alpha: 0.95),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: _retailerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: _retailerColor.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Top row: retailer icon + VAULTED PREMIUM label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Retailer initial badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _retailerInitial,
                  style: VaultedTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              // VAULTED PREMIUM label
              Text(
                'VAULTED PREMIUM',
                style: VaultedTypography.labelMicro.copyWith(
                  color: VaultedColors.accentGoldLight,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          const Spacer(),

          // -- Card name
          Text(
            '${card.retailer} Card',
            style: VaultedTypography.headlineLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // -- Masked card number with eye toggle
          if (card.cardNumberEncrypted != null)
            Row(
              children: [
                Text(
                  showFullNumber
                      ? Formatters.groupCardDigits(card.cardNumberEncrypted!)
                      : Formatters.maskCardNumber(card.cardNumberEncrypted ?? ''),
                  style: VaultedTypography.monoSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    letterSpacing: 2.0,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                if (onToggleNumber != null)
                  GestureDetector(
                    onTap: onToggleNumber,
                    child: Icon(
                      showFullNumber
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ),
              ],
            ),

          const Spacer(),

          // -- Bottom row: expiry date + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Expiry date
              if (card.expirationDate != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EXPIRY DATE',
                      style: VaultedTypography.labelMicro.copyWith(
                        color: Colors.white.withValues(alpha: 0.55),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.monthYear(card.expirationDate!),
                      style: VaultedTypography.monoSmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),

              // Status badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'STATUS',
                    style: VaultedTypography.labelMicro.copyWith(
                      color: Colors.white.withValues(alpha: 0.55),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    CardStatus.label(card.status).toUpperCase(),
                    style: VaultedTypography.monoSmall.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
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

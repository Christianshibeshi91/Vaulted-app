import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/retailers.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/card_model.dart';

/// Grid item widget for the 2-column cards grid.
class CardGridItem extends StatelessWidget {
  final CardModel card;
  final int index;
  final VoidCallback? onTap;

  const CardGridItem({
    super.key,
    required this.card,
    required this.index,
    this.onTap,
  });

  Color get _retailerColor {
    final retailer = Retailers.byName(card.retailer);
    if (retailer != null) return retailer.color;
    final hex = card.retailerColor.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: VaultedSpacing.cardInner,
        decoration: BoxDecoration(
          color: VaultedColors.bgCard,
          borderRadius: VaultedRadii.brCard,
          border: Border.all(color: VaultedColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Retailer circle + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            VaultedSpacing.gapMd,

            // Retailer name
            Text(
              card.retailer,
              style: VaultedTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            VaultedSpacing.gapXs,

            // Balance
            Text(
              Formatters.currency(card.balance),
              style: VaultedTypography.monoMedium.copyWith(
                color: VaultedColors.accentGold,
              ),
            ),

            const Spacer(),

            // Expiration or status label
            if (card.expirationDate != null)
              Text(
                'Exp ${Formatters.dateShort(card.expirationDate!)}',
                style: VaultedTypography.labelSmall,
              )
            else
              Text(
                CardStatus.label(card.status),
                style: VaultedTypography.labelSmall.copyWith(
                  color: _statusColor,
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: (50 * index).ms,
          curve: Curves.easeOut,
        )
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
          delay: (50 * index).ms,
          curve: Curves.easeOut,
        );
  }
}

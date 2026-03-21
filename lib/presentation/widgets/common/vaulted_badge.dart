import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Size variants for [VaultedBadge].
enum VaultedBadgeSize { small, medium }

/// Semantic color presets for [VaultedBadge].
enum VaultedBadgeColor { success, warning, danger, info, gold }

/// Small status badge / tag used throughout the Vaulted app.
///
/// Renders a pill-shaped label with a tinted background derived from
/// the chosen [VaultedBadgeColor].
class VaultedBadge extends StatelessWidget {
  const VaultedBadge(
    this.label, {
    this.color = VaultedBadgeColor.gold,
    this.size = VaultedBadgeSize.small,
    super.key,
  });

  final String label;
  final VaultedBadgeColor color;
  final VaultedBadgeSize size;

  Color get _foreground => switch (color) {
        VaultedBadgeColor.success => VaultedColors.success,
        VaultedBadgeColor.warning => VaultedColors.warning,
        VaultedBadgeColor.danger => VaultedColors.danger,
        VaultedBadgeColor.info => VaultedColors.info,
        VaultedBadgeColor.gold => VaultedColors.accentGold,
      };

  Color get _background => _foreground.withValues(alpha: 0.12);

  @override
  Widget build(BuildContext context) {
    final isSmall = size == VaultedBadgeSize.small;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? VaultedSpacing.sm : VaultedSpacing.md,
        vertical: isSmall ? VaultedSpacing.xs : VaultedSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(VaultedRadii.badge),
      ),
      child: Text(
        label,
        style: (isSmall
                ? VaultedTypography.labelMicro
                : VaultedTypography.labelSmall)
            .copyWith(
          color: _foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

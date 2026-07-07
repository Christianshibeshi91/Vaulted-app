import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// A single KPI metric card for admin dashboards.
///
/// Layout order: label (top) -> value (middle) -> delta/status (bottom).
class AdminKpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? delta;
  final bool isPositiveDelta;
  final bool useGoldAccent;

  /// Optional status text shown instead of [delta] (e.g. "NEEDS ATTENTION").
  final String? statusText;

  /// Optional icon shown alongside [statusText].
  final IconData? statusIcon;

  const AdminKpiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.delta,
    this.isPositiveDelta = true,
    this.useGoldAccent = false,
    this.statusText,
    this.statusIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: VaultedSpacing.cardInner,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(
          color: useGoldAccent
              ? VaultedColors.borderStrong
              : VaultedColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // -- TOP: uppercase label --
          Text(
            label.toUpperCase(),
            style: VaultedTypography.muted(VaultedTypography.labelSmall)
                .copyWith(letterSpacing: 1.2),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // -- MIDDLE: big value --
          Text(
            value,
            style: useGoldAccent
                ? VaultedTypography.gold(VaultedTypography.monoLarge)
                : VaultedTypography.monoLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // -- BOTTOM: delta badge or status text --
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    // Status text takes priority over delta.
    if (statusText != null) {
      return _StatusRow(
        icon: statusIcon ?? Icons.warning_amber_rounded,
        text: statusText!,
        color: VaultedColors.warning,
      );
    }

    if (delta != null) {
      final color =
          isPositiveDelta ? VaultedColors.success : VaultedColors.danger;
      return _DeltaBadge(
        delta: delta!,
        color: color,
        isPositive: isPositiveDelta,
      );
    }

    // No footer content -- render empty to keep layout stable.
    return const SizedBox.shrink();
  }
}

/// Compact delta badge with an up/down arrow prefix.
class _DeltaBadge extends StatelessWidget {
  final String delta;
  final Color color;
  final bool isPositive;

  const _DeltaBadge({
    required this.delta,
    required this.color,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: VaultedRadii.brBadge,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            delta,
            style: VaultedTypography.labelMicro.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status row with icon + warning/info text for non-delta cards.
class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: VaultedTypography.labelMicro.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// 2x2 grid of KPI cards.
class AdminKpiGrid extends StatelessWidget {
  final List<AdminKpiCard> cards;

  const AdminKpiGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: VaultedSpacing.md,
      crossAxisSpacing: VaultedSpacing.md,
      childAspectRatio: 1.35,
      children: cards,
    );
  }
}

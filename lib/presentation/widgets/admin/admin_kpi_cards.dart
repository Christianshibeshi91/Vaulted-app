import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// A single KPI metric card for admin dashboards.
class AdminKpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? delta;
  final bool isPositiveDelta;
  final bool useGoldAccent;

  const AdminKpiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.delta,
    this.isPositiveDelta = true,
    this.useGoldAccent = false,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: useGoldAccent
                      ? VaultedColors.accentGoldDim
                      : VaultedColors.bgInput,
                  borderRadius: VaultedRadii.brBadge,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: useGoldAccent
                      ? VaultedColors.accentGold
                      : VaultedColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (delta != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: (isPositiveDelta
                            ? VaultedColors.success
                            : VaultedColors.danger)
                        .withValues(alpha: 0.12),
                    borderRadius: VaultedRadii.brBadge,
                  ),
                  child: Text(
                    delta!,
                    style: VaultedTypography.labelMicro.copyWith(
                      color: isPositiveDelta
                          ? VaultedColors.success
                          : VaultedColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          VaultedSpacing.gapMd,
          Text(
            value,
            style: useGoldAccent
                ? VaultedTypography.gold(VaultedTypography.monoLarge)
                : VaultedTypography.monoLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          VaultedSpacing.gapXs,
          Text(
            label,
            style: VaultedTypography.muted(VaultedTypography.labelSmall),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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

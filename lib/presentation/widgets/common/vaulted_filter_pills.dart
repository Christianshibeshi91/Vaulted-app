import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Horizontally scrolling row of filter chips (pills).
///
/// The active pill uses [VaultedColors.accentGold] background with dark text;
/// inactive pills use [VaultedColors.bgCard] with secondary text.
class VaultedFilterPills extends StatelessWidget {
  const VaultedFilterPills({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
        itemCount: labels.length,
        separatorBuilder: (_, _) =>
            const SizedBox(width: VaultedSpacing.sm),
        itemBuilder: (_, index) {
          final isActive = index == selectedIndex;
          return _Pill(
            label: labels[index],
            isActive: isActive,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(index);
            },
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? VaultedColors.accentGold : VaultedColors.bgCard,
      borderRadius: VaultedRadii.brPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: VaultedRadii.brPill,
        splashColor: VaultedColors.accentGoldDim,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: VaultedRadii.brPill,
            border: isActive
                ? null
                : Border.all(color: VaultedColors.border),
          ),
          child: Text(
            label,
            style: VaultedTypography.bodyMedium.copyWith(
              color:
                  isActive ? VaultedColors.bgPrimary : VaultedColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

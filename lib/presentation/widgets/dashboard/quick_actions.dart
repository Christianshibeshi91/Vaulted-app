import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Row of 4 quick-action buttons on the dashboard.
class QuickActions extends StatelessWidget {
  final VoidCallback? onAddCard;
  final VoidCallback? onCheckAll;
  final VoidCallback? onActivity;
  final VoidCallback? onShare;

  const QuickActions({
    super.key,
    this.onAddCard,
    this.onCheckAll,
    this.onActivity,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.add_card,
        label: 'Add Card',
        onTap: onAddCard,
      ),
      _QuickAction(
        icon: Icons.refresh_rounded,
        label: 'Check All',
        onTap: onCheckAll,
      ),
      _QuickAction(
        icon: Icons.receipt_long_outlined,
        label: 'Activity',
        onTap: onActivity,
      ),
      _QuickAction(
        icon: Icons.ios_share_rounded,
        label: 'Share',
        onTap: onShare,
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < actions.length; i++)
          Expanded(
            child: actions[i]
                .animate()
                .fadeIn(
                  duration: 300.ms,
                  delay: (80 * i).ms,
                  curve: Curves.easeOut,
                )
                .slideY(
                  begin: 0.15,
                  end: 0,
                  duration: 300.ms,
                  delay: (80 * i).ms,
                  curve: Curves.easeOut,
                ),
          ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Haptics.lightTap();
        onTap?.call();
      },
      borderRadius: VaultedRadii.brCard,
      splashColor: VaultedColors.accentGoldDim,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: VaultedSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: VaultedColors.bgCard,
                shape: BoxShape.circle,
                border: Border.all(color: VaultedColors.border),
              ),
              child: Icon(
                icon,
                color: VaultedColors.accentGold,
                size: 22,
              ),
            ),
            VaultedSpacing.gapSm,
            Text(
              label,
              style: VaultedTypography.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

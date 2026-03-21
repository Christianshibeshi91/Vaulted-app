import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';

/// Section header row with a title and an optional trailing action link.
///
/// Renders the title in Outfit SemiBold and the action in gold with an
/// appended arrow character.
class VaultedSectionHeader extends StatelessWidget {
  const VaultedSectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: VaultedTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '$actionLabel \u2192',
                style: VaultedTypography.bodyMedium.copyWith(
                  color: VaultedColors.accentGold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

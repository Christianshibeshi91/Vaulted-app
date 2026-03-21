import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Styled switch toggle with an optional label and description.
///
/// Uses gold thumb/track when active and muted tones when inactive,
/// consistent with the Vaulted dark-luxury aesthetic.
class VaultedToggle extends StatelessWidget {
  const VaultedToggle({
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    super.key,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final toggle = SizedBox(
      height: 44,
      child: FittedBox(
        child: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: VaultedColors.bgPrimary,
          activeTrackColor: VaultedColors.accentGold,
          inactiveThumbColor: VaultedColors.textMuted,
          inactiveTrackColor: VaultedColors.bgInput,
          trackOutlineColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return VaultedColors.accentGold;
            }
            return VaultedColors.borderStrong;
          }),
        ),
      ),
    );

    if (label == null) return toggle;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label!, style: VaultedTypography.bodyLarge),
              if (description != null) ...[
                const SizedBox(height: VaultedSpacing.xs),
                Text(
                  description!,
                  style: VaultedTypography.bodyMedium
                      .copyWith(color: VaultedColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: VaultedSpacing.md),
        toggle,
      ],
    );
  }
}

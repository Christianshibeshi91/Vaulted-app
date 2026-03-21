import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Collapsible settings section using ExpansionTile with Vaulted styling.
class AdminSettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;

  const AdminSettingsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: VaultedSpacing.cardInner,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        collapsedIconColor: VaultedColors.textMuted,
        iconColor: VaultedColors.accentGold,
        backgroundColor: VaultedColors.bgCard,
        collapsedBackgroundColor: VaultedColors.bgCard,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon, color: VaultedColors.accentGold, size: 20),
        title: Text(
          title,
          style: VaultedTypography.bodyLarge
              .copyWith(fontWeight: FontWeight.w600),
        ),
        children: children,
      ),
    );
  }
}

/// Labeled text field for settings.
class SettingsTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? suffix;

  const SettingsTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VaultedSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: VaultedTypography.bodyMedium),
          ),
          VaultedSpacing.gapHMd,
          Expanded(
            flex: 3,
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: VaultedTypography.monoSmall,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                suffixText: suffix,
                suffixStyle: VaultedTypography.muted(
                    VaultedTypography.labelMicro),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Labeled switch for settings.
class SettingsSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VaultedSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: VaultedTypography.bodyMedium),
          ),
          SizedBox(
            height: 44,
            child: Switch(
              value: value,
              onChanged: (val) {
                Haptics.toggle();
                onChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }
}

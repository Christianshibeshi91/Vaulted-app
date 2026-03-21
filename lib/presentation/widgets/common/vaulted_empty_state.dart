import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import 'vaulted_button.dart';

/// Full-width empty-state placeholder with icon, title, description,
/// and an optional call-to-action.
///
/// Designed for zero-data screens (empty lists, no search results, etc.).
class VaultedEmptyState extends StatelessWidget {
  const VaultedEmptyState({
    this.icon,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData? icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: VaultedSpacing.insetsXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 56,
                color: VaultedColors.accentGold.withValues(alpha: 0.6),
              ),
              const SizedBox(height: VaultedSpacing.xl),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: VaultedTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: VaultedSpacing.sm),
            ],
            if (message != null)
              Text(
                message!,
                style: VaultedTypography.bodyMedium
                    .copyWith(color: VaultedColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: VaultedSpacing.xxl),
              SizedBox(
                width: 220,
                child: VaultedButton.primary(
                  actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

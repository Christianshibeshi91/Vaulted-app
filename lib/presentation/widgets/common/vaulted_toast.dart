import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Convenience helper for showing styled snack-bar toasts.
///
/// Each variant uses a semantic colour and icon to communicate intent.
class VaultedToast {
  VaultedToast._();

  /// Green check toast for success feedback.
  static void success(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.check_circle_rounded,
      accentColor: VaultedColors.success,
    );
  }

  /// Red alert toast for error feedback.
  static void error(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.error_rounded,
      accentColor: VaultedColors.danger,
    );
  }

  /// Blue info toast for neutral notifications.
  static void info(BuildContext context, String message) {
    _show(
      context,
      message: message,
      icon: Icons.info_rounded,
      accentColor: VaultedColors.info,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color accentColor,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: VaultedColors.bgCard,
          shape: RoundedRectangleBorder(
            borderRadius: VaultedRadii.brButton,
            side: BorderSide(color: accentColor.withValues(alpha: 0.3)),
          ),
          elevation: 4,
          margin: const EdgeInsets.symmetric(
            horizontal: VaultedSpacing.xl,
            vertical: VaultedSpacing.md,
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: VaultedSpacing.md),
              Expanded(
                child: Text(
                  message,
                  style: VaultedTypography.bodyMedium
                      .copyWith(color: VaultedColors.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
  }
}

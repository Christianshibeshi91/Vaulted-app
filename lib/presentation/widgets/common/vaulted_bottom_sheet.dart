import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Styled modal bottom sheet consistent with the Vaulted design system.
///
/// Uses [VaultedColors.bgCard] background, 24 px top radius, a drag handle,
/// and an optional title row with a close button.
class VaultedBottomSheet {
  VaultedBottomSheet._();

  /// Shows a modal bottom sheet with Vaulted styling.
  ///
  /// [actions] are placed at the bottom of the sheet separated from
  /// [child] by a divider.
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    List<Widget>? actions,
    bool isDismissible = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      barrierColor: VaultedColors.overlay,
      builder: (_) => _Sheet(
        title: title,
        actions: actions,
        child: child,
      ),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({
    this.title,
    required this.child,
    this.actions,
  });

  final String? title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brBottomSheet,
        border: const Border(
          top: BorderSide(color: VaultedColors.border),
          left: BorderSide(color: VaultedColors.border),
          right: BorderSide(color: VaultedColors.border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: VaultedSpacing.md),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: VaultedColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title row
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VaultedSpacing.xl,
                VaultedSpacing.lg,
                VaultedSpacing.sm,
                VaultedSpacing.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(title!, style: VaultedTypography.headlineMedium),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: VaultedColors.textSecondary,
                      size: 22,
                    ),
                    splashRadius: 22,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: VaultedSpacing.bottomSheet,
              child: child,
            ),
          ),

          // Actions
          if (actions != null && actions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                VaultedSpacing.xl,
                0,
                VaultedSpacing.xl,
                VaultedSpacing.xxxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Divider(color: VaultedColors.border, height: 1),
                  const SizedBox(height: VaultedSpacing.lg),
                  ...actions!,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

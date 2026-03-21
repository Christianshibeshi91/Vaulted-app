import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

enum _Variant { primary, secondary, text, danger }

/// Button variants used across the Vaulted app.
///
/// All variants enforce a 52px minimum height (meets the 44px touch-target
/// rule) and use [VaultedColors] / [VaultedRadii] for visual consistency.
class VaultedButton extends StatelessWidget {
  const VaultedButton._({
    required this.label,
    required this.onPressed,
    required _Variant variant,
    this.isLoading = false,
    this.icon,
    super.key,
  }) : _variant = variant;

  // ── Named constructors ───────────────────────────────────────

  /// Gold background, dark text. Primary call-to-action.
  factory VaultedButton.primary(
    String label, {
    required VoidCallback? onPressed,
    bool isLoading = false,
    IconData? icon,
    Key? key,
  }) =>
      VaultedButton._(
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        icon: icon,
        key: key,
        variant: _Variant.primary,
      );

  /// Transparent background, gold border (20 % opacity), gold text.
  factory VaultedButton.secondary(
    String label, {
    required VoidCallback? onPressed,
    IconData? icon,
    Key? key,
  }) =>
      VaultedButton._(
        label: label,
        onPressed: onPressed,
        icon: icon,
        key: key,
        variant: _Variant.secondary,
      );

  /// Text-only button. No border, no background.
  factory VaultedButton.text(
    String label, {
    required VoidCallback? onPressed,
    Key? key,
  }) =>
      VaultedButton._(
        label: label,
        onPressed: onPressed,
        key: key,
        variant: _Variant.text,
      );

  /// Danger action -- red background with loading support.
  factory VaultedButton.danger(
    String label, {
    required VoidCallback? onPressed,
    bool isLoading = false,
    Key? key,
  }) =>
      VaultedButton._(
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        key: key,
        variant: _Variant.danger,
      );

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final _Variant _variant;

  // ── Helpers ──────────────────────────────────────────────────

  bool get _isDisabled => onPressed == null || isLoading;

  void _handlePress() {
    if (_isDisabled) return;
    HapticFeedback.lightImpact();
    onPressed?.call();
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _Variant.primary => _buildElevated(
          bg: VaultedColors.accentGold,
          fg: VaultedColors.bgPrimary,
        ),
      _Variant.secondary => _buildOutlined(),
      _Variant.text => _buildText(),
      _Variant.danger => _buildElevated(
          bg: VaultedColors.danger,
          fg: Colors.white,
        ),
    };
  }

  Widget _buildElevated({required Color bg, required Color fg}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isDisabled ? null : _handlePress,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          disabledBackgroundColor: bg.withValues(alpha: 0.35),
          disabledForegroundColor: fg.withValues(alpha: 0.5),
          elevation: 0,
          shape: VaultedRadii.shapeButton,
          padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xxl),
          textStyle: VaultedTypography.buttonLabel(),
        ),
        child: _innerContent(fg),
      ),
    );
  }

  Widget _buildOutlined() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _isDisabled ? null : _handlePress,
        style: OutlinedButton.styleFrom(
          foregroundColor: VaultedColors.accentGold,
          backgroundColor: Colors.transparent,
          disabledForegroundColor: VaultedColors.textMuted,
          elevation: 0,
          side: const BorderSide(color: VaultedColors.borderStrong),
          shape: VaultedRadii.shapeButton,
          padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xxl),
          textStyle: VaultedTypography.buttonLabel(),
        ),
        child: _innerContent(VaultedColors.accentGold),
      ),
    );
  }

  Widget _buildText() {
    return SizedBox(
      height: 52,
      child: TextButton(
        onPressed: _isDisabled ? null : _handlePress,
        style: TextButton.styleFrom(
          foregroundColor: VaultedColors.accentGold,
          textStyle: VaultedTypography.buttonLabel(),
          shape: VaultedRadii.shapeButton,
          padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.lg),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _innerContent(Color indicatorColor) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: indicatorColor,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: VaultedSpacing.sm),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}

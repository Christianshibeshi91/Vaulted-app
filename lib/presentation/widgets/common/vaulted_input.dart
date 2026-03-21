import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Styled text field for the Vaulted design system.
///
/// Uses [VaultedColors.bgInput] fill, gold focus border, and danger border
/// on validation errors. Supports obscure text, prefix/suffix icons,
/// multi-line, and all standard [TextFormField] validation.
class VaultedInput extends StatelessWidget {
  const VaultedInput({
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
    this.autofillHints,
    this.textInputAction,
    this.focusNode,
    this.enabled = true,
    super.key,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: VaultedTypography.bodyMedium
                .copyWith(color: VaultedColors.textSecondary),
          ),
          const SizedBox(height: VaultedSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          autofillHints: autofillHints,
          textInputAction: textInputAction,
          focusNode: focusNode,
          enabled: enabled,
          style: VaultedTypography.bodyLarge,
          cursorColor: VaultedColors.accentGold,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: VaultedTypography.bodyLarge
                .copyWith(color: VaultedColors.textMuted),
            filled: true,
            fillColor: VaultedColors.bgInput,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: VaultedSpacing.lg,
              vertical: VaultedSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: VaultedRadii.brInput,
              borderSide: const BorderSide(color: VaultedColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: VaultedRadii.brInput,
              borderSide: const BorderSide(color: VaultedColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: VaultedRadii.brInput,
              borderSide: const BorderSide(
                color: VaultedColors.accentGold,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: VaultedRadii.brInput,
              borderSide: const BorderSide(color: VaultedColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: VaultedRadii.brInput,
              borderSide: const BorderSide(
                color: VaultedColors.danger,
                width: 1.5,
              ),
            ),
            errorStyle: VaultedTypography.labelSmall
                .copyWith(color: VaultedColors.danger),
          ),
        ),
      ],
    );
  }
}

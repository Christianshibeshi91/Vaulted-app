import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import 'vaulted_bottom_sheet.dart';
import 'vaulted_button.dart';
import 'vaulted_input.dart';

/// Pre-built confirmation bottom sheet for destructive or important actions.
///
/// Supports a standard confirm/cancel flow and a "type DELETE" variant
/// for high-risk destructive operations.
class ConfirmationSheet {
  ConfirmationSheet._();

  /// Shows a confirmation sheet with confirm and cancel actions.
  ///
  /// When [isDanger] is true the confirm button uses the danger variant.
  /// When [requiresTypedConfirmation] is true the user must type "DELETE"
  /// before the confirm button becomes enabled.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    bool isDanger = false,
    bool requiresTypedConfirmation = false,
    VoidCallback? onConfirm,
  }) {
    return VaultedBottomSheet.show<bool>(
      context,
      title: title,
      child: _ConfirmationContent(
        message: message,
        confirmLabel: confirmLabel,
        isDanger: isDanger,
        requiresTypedConfirmation: requiresTypedConfirmation,
        onConfirm: onConfirm,
      ),
    );
  }
}

class _ConfirmationContent extends StatefulWidget {
  const _ConfirmationContent({
    this.message,
    required this.confirmLabel,
    required this.isDanger,
    required this.requiresTypedConfirmation,
    this.onConfirm,
  });

  final String? message;
  final String confirmLabel;
  final bool isDanger;
  final bool requiresTypedConfirmation;
  final VoidCallback? onConfirm;

  @override
  State<_ConfirmationContent> createState() => _ConfirmationContentState();
}

class _ConfirmationContentState extends State<_ConfirmationContent> {
  final _deleteController = TextEditingController();
  bool _canConfirm = false;

  @override
  void initState() {
    super.initState();
    _canConfirm = !widget.requiresTypedConfirmation;
    if (widget.requiresTypedConfirmation) {
      _deleteController.addListener(_onDeleteTextChanged);
    }
  }

  void _onDeleteTextChanged() {
    final matches =
        _deleteController.text.trim().toUpperCase() == 'DELETE';
    if (matches != _canConfirm) {
      setState(() => _canConfirm = matches);
    }
  }

  void _handleConfirm() {
    widget.onConfirm?.call();
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _deleteController.removeListener(_onDeleteTextChanged);
    _deleteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.message != null) ...[
          Text(
            widget.message!,
            style: VaultedTypography.bodyLarge
                .copyWith(color: VaultedColors.textSecondary),
          ),
          const SizedBox(height: VaultedSpacing.xl),
        ],

        if (widget.requiresTypedConfirmation) ...[
          Text(
            'Type DELETE to confirm this action',
            style: VaultedTypography.bodyMedium
                .copyWith(color: VaultedColors.danger),
          ),
          const SizedBox(height: VaultedSpacing.sm),
          VaultedInput(
            controller: _deleteController,
            hint: 'DELETE',
            keyboardType: TextInputType.text,
          ),
          const SizedBox(height: VaultedSpacing.xl),
        ],

        // Confirm button
        if (widget.isDanger)
          VaultedButton.danger(
            widget.confirmLabel,
            onPressed: _canConfirm ? _handleConfirm : null,
          )
        else
          VaultedButton.primary(
            widget.confirmLabel,
            onPressed: _canConfirm ? _handleConfirm : null,
          ),

        const SizedBox(height: VaultedSpacing.md),

        // Cancel button
        VaultedButton.secondary(
          'Cancel',
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }
}

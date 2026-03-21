import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Search input field styled for the Vaulted design system.
///
/// Features a search icon prefix and an animated clear button suffix
/// that appears when the field contains text.
class VaultedSearchBar extends StatefulWidget {
  const VaultedSearchBar({
    this.controller,
    this.onChanged,
    this.hint = 'Search...',
    this.onClear,
    super.key,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hint;
  final VoidCallback? onClear;

  @override
  State<VaultedSearchBar> createState() => _VaultedSearchBarState();
}

class _VaultedSearchBarState extends State<VaultedSearchBar> {
  late final TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        style: VaultedTypography.bodyLarge,
        cursorColor: VaultedColors.accentGold,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: VaultedTypography.bodyLarge
              .copyWith(color: VaultedColors.textMuted),
          filled: true,
          fillColor: VaultedColors.bgInput,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 8),
            child: Icon(
              Icons.search_rounded,
              color: VaultedColors.textSecondary,
              size: 20,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: 44,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  onPressed: _handleClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: VaultedColors.textSecondary,
                    size: 18,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                )
              : null,
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
        ),
      ),
    );
  }
}

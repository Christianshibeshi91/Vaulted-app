import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';

/// Six-digit MFA / OTP code input with auto-advance and auto-submit.
///
/// Each cell is a 48 x 56 [TextField] using JetBrains Mono 24 pt.
/// On the 6th digit the [onCompleted] callback fires automatically.
class MfaCodeInput extends StatefulWidget {
  const MfaCodeInput({
    required this.onCompleted,
    super.key,
  });

  final ValueChanged<String> onCompleted;

  @override
  State<MfaCodeInput> createState() => _MfaCodeInputState();
}

class _MfaCodeInputState extends State<MfaCodeInput> {
  static const _length = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Paste handling: distribute digits across cells.
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < _length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final nextIndex = digits.length.clamp(0, _length - 1);
      _focusNodes[nextIndex].requestFocus();
      if (digits.length >= _length) _submit();
      return;
    }

    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isNotEmpty && index == _length - 1) {
      _submit();
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _submit() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length == _length) {
      HapticFeedback.mediumImpact();
      widget.onCompleted(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_length, (i) {
        return Padding(
          padding: EdgeInsets.only(
            right: i < _length - 1 ? VaultedSpacing.sm : 0,
          ),
          child: SizedBox(
            width: 48,
            height: 56,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) => _onKeyEvent(i, event),
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                onChanged: (v) => _onChanged(i, v),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: VaultedTypography.monoHero,
                cursorColor: VaultedColors.accentGold,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: VaultedColors.bgInput,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: VaultedRadii.brInput,
                    borderSide:
                        const BorderSide(color: VaultedColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: VaultedRadii.brInput,
                    borderSide:
                        const BorderSide(color: VaultedColors.border),
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
            ),
          ),
        );
      }),
    );
  }
}

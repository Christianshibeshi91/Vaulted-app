import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';

/// Visual indicator of password strength with four animated segments.
///
/// [strength] ranges from 0 (empty) to 4 (strong). Segment colours
/// follow semantic mapping: danger -> warning -> accentGoldLight -> success.
class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({
    required this.strength,
    super.key,
  }) : assert(strength >= 0 && strength <= 4);

  /// 0 = empty, 1 = weak, 2 = fair, 3 = good, 4 = strong.
  final int strength;

  static const _labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];

  Color _segmentColor(int index) {
    if (index >= strength) return VaultedColors.bgInput;
    return switch (strength) {
      1 => VaultedColors.danger,
      2 => VaultedColors.warning,
      3 => VaultedColors.accentGoldLight,
      4 => VaultedColors.success,
      _ => VaultedColors.bgInput,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < 3 ? VaultedSpacing.xs : 0,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _segmentColor(i),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }),
        ),
        if (strength > 0) ...[
          const SizedBox(height: VaultedSpacing.xs),
          Text(
            _labels[strength],
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _segmentColor(0),
            ),
          ),
        ],
      ],
    );
  }
}

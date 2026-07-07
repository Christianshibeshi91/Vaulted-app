import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/typography.dart';

/// Inline manual balance entry widget — no redirects.
///
/// Shows a balance input field directly in the app for the user
/// to type their known balance. Used as fallback when auto-check
/// isn't available or fails.
class ManualBalanceEntry extends StatefulWidget {
  const ManualBalanceEntry({
    super.key,
    required this.onBalanceEntered,
    this.message,
  });

  final ValueChanged<double> onBalanceEntered;
  final String? message;

  @override
  State<ManualBalanceEntry> createState() => _ManualBalanceEntryState();
}

class _ManualBalanceEntryState extends State<ManualBalanceEntry> {
  final _balanceController = TextEditingController();

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() {
    final balance = double.tryParse(_balanceController.text.trim());
    if (balance != null && balance >= 0) {
      widget.onBalanceEntered(balance);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: VaultedSpacing.cardInner,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_rounded,
                color: VaultedColors.accentGold,
                size: 20,
              ),
              VaultedSpacing.gapHSm,
              Expanded(
                child: Text(
                  widget.message ?? 'Enter your card balance below.',
                  style: VaultedTypography.bodyMedium.copyWith(
                    color: VaultedColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          VaultedSpacing.gapLg,
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _balanceController,
                  style: VaultedTypography.gold(VaultedTypography.monoLarge),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money, size: 20),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
              VaultedSpacing.gapMd,
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(
                    'Save',
                    style: VaultedTypography.buttonLabel(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.05, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}

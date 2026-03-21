import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// MFA setup flow: QR display, 6-digit verification, recovery codes.
class MfaSetupScreen extends StatefulWidget {
  const MfaSetupScreen({super.key});

  @override
  State<MfaSetupScreen> createState() => _MfaSetupScreenState();
}

class _MfaSetupScreenState extends State<MfaSetupScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _MfaStep _step = _MfaStep.qr;
  bool _isVerifying = false;

  // Placeholder values -- in production these come from the server.
  final String _totpSecret = 'JBSWY3DPEHPK3PXP';
  final String _totpUri =
      'otpauth://totp/Vaulted:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Vaulted';

  late final List<String> _recoveryCodes = _generateRecoveryCodes();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  List<String> _generateRecoveryCodes() {
    final rng = Random.secure();
    return List.generate(10, (_) {
      final code = List.generate(8, (_) => rng.nextInt(10)).join();
      return '${code.substring(0, 4)}-${code.substring(4)}';
    });
  }

  Future<void> _verifyCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isVerifying = true);
    Haptics.mediumTap();

    // Simulate verification delay.
    await Future<void>.delayed(const Duration(seconds: 1));

    // In production, verify the TOTP code against the server.
    setState(() {
      _isVerifying = false;
      _step = _MfaStep.recovery;
    });
    Haptics.success();
  }

  void _copyRecoveryCodes() {
    final text = _recoveryCodes.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    Haptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recovery codes copied')),
    );
  }

  void _finishSetup() {
    Haptics.success();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Set Up 2FA'),
      ),
      body: SafeArea(
        child: switch (_step) {
          _MfaStep.qr => _buildQrStep(),
          _MfaStep.verify => _buildVerifyStep(),
          _MfaStep.recovery => _buildRecoveryStep(),
        },
      ),
    );
  }

  // -- Step 1: QR Code ---------------------------------------------------

  Widget _buildQrStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(VaultedSpacing.xl),
      child: Column(
        children: [
          VaultedSpacing.gapXl,
          Text(
            'Scan this QR code',
            style: VaultedTypography.headlineLarge,
          ),
          VaultedSpacing.gapSm,
          Text(
            'Open your authenticator app and scan the code below.',
            style: VaultedTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          VaultedSpacing.gapXxl,

          // QR code
          Container(
            padding: const EdgeInsets.all(VaultedSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: VaultedRadii.brCard,
            ),
            child: QrImageView(
              data: _totpUri,
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
            ),
          ),
          VaultedSpacing.gapXl,

          // Manual key
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(VaultedSpacing.lg),
            decoration: BoxDecoration(
              color: VaultedColors.bgCard,
              borderRadius: VaultedRadii.brCard,
              border: Border.all(color: VaultedColors.border),
            ),
            child: Column(
              children: [
                Text(
                  'Or enter this key manually:',
                  style: VaultedTypography.bodyMedium,
                ),
                VaultedSpacing.gapSm,
                SelectableText(
                  _totpSecret,
                  style: VaultedTypography.monoMedium.copyWith(
                    color: VaultedColors.accentGold,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          VaultedSpacing.gapXxl,

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Haptics.mediumTap();
                setState(() => _step = _MfaStep.verify);
              },
              child: const Text('Next: Verify Code'),
            ),
          ),
        ],
      ),
    );
  }

  // -- Step 2: Verify code -----------------------------------------------

  Widget _buildVerifyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(VaultedSpacing.xl),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            VaultedSpacing.gapXl,
            Text(
              'Enter verification code',
              style: VaultedTypography.headlineLarge,
            ),
            VaultedSpacing.gapSm,
            Text(
              'Enter the 6-digit code from your authenticator app.',
              style: VaultedTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            VaultedSpacing.gapXxl,

            TextFormField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: VaultedTypography.monoLarge.copyWith(
                letterSpacing: 8,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
              validator: (v) {
                if (v == null || v.length != 6) {
                  return 'Enter the 6-digit code';
                }
                return null;
              },
              decoration: const InputDecoration(
                counterText: '',
                hintText: '000000',
              ),
            ),
            VaultedSpacing.gapXxl,

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyCode,
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: VaultedColors.bgPrimary,
                        ),
                      )
                    : const Text('Verify'),
              ),
            ),
            VaultedSpacing.gapMd,

            TextButton(
              onPressed: () {
                setState(() => _step = _MfaStep.qr);
              },
              child: const Text('Back to QR Code'),
            ),
          ],
        ),
      ),
    );
  }

  // -- Step 3: Recovery codes --------------------------------------------

  Widget _buildRecoveryStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(VaultedSpacing.xl),
      child: Column(
        children: [
          VaultedSpacing.gapXl,
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: VaultedColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: VaultedColors.success,
              size: 32,
            ),
          ),
          VaultedSpacing.gapLg,
          Text(
            'Save your recovery codes',
            style: VaultedTypography.headlineLarge,
          ),
          VaultedSpacing.gapSm,
          Text(
            'Store these codes in a safe place. Each code can only be used once. These will not be shown again.',
            style: VaultedTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
          VaultedSpacing.gapXxl,

          // Recovery codes grid
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(VaultedSpacing.lg),
            decoration: BoxDecoration(
              color: VaultedColors.bgCard,
              borderRadius: VaultedRadii.brCard,
              border: Border.all(color: VaultedColors.border),
            ),
            child: Wrap(
              spacing: VaultedSpacing.md,
              runSpacing: VaultedSpacing.sm,
              children: _recoveryCodes
                  .asMap()
                  .entries
                  .map(
                    (e) => SizedBox(
                      width: 130,
                      child: Row(
                        children: [
                          Text(
                            '${e.key + 1}.',
                            style: VaultedTypography.labelSmall,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            e.value,
                            style: VaultedTypography.monoSmall.copyWith(
                              color: VaultedColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          VaultedSpacing.gapXl,

          // Copy button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _copyRecoveryCodes,
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Copy Codes'),
            ),
          ),
          VaultedSpacing.gapLg,

          // Done button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finishSetup,
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MfaStep { qr, verify, recovery }

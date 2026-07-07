import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Lock screen shown when biometric unlock is enabled.
///
/// Displays the Vaulted logo, a fingerprint/Face ID icon, and a fallback
/// to password-based authentication.
class BiometricLockScreen extends StatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Trigger biometric prompt shortly after screen builds.
    Future.delayed(600.ms, _authenticate);
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;
    setState(() => _isAuthenticating = true);
    Haptics.mediumTap();

    try {
      final localAuth = LocalAuthentication();

      final canCheck = await localAuth.canCheckBiometrics;
      final isSupported = await localAuth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        // Device doesn't support biometrics — require password instead
        if (mounted) {
          Haptics.warning();
          context.goNamed(RouteNames.authLogin);
        }
        return;
      }

      final didAuth = await localAuth.authenticate(
        localizedReason: 'Unlock your vault',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuth && mounted) {
        Haptics.success();
        context.goNamed(RouteNames.home);
      }
    } catch (_) {
      Haptics.error();
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  /// Returns the appropriate biometric icon for the platform.
  IconData get _biometricIcon {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Icons.face_unlock_rounded;
    }
    return Icons.fingerprint_rounded;
  }

  String get _biometricLabel {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Tap to unlock with Face ID';
    }
    return 'Tap to unlock with fingerprint';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: VaultedSpacing.screenH,
          child: Column(
            children: [
              const Spacer(flex: 3),

              // -- Logo --
              Text(
                'VAULTED',
                style: VaultedTypography.displayLarge.copyWith(
                  color: VaultedColors.accentGold,
                  letterSpacing: 6,
                ),
              ).animate().fadeIn(duration: 600.ms),

              const Spacer(flex: 2),

              // -- Biometric icon --
              GestureDetector(
                onTap: _authenticate,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: VaultedColors.accentGold,
                      width: 2,
                    ),
                    color: VaultedColors.accentGoldDim,
                  ),
                  child: Icon(
                    _biometricIcon,
                    size: 44,
                    color: VaultedColors.accentGold,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.05, 1.05),
                    duration: 1500.ms,
                    curve: Curves.easeInOut,
                  ),

              VaultedSpacing.gapXxl,

              // -- Label --
              Text(
                _biometricLabel,
                textAlign: TextAlign.center,
                style: VaultedTypography.bodyLarge.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms),

              if (_isAuthenticating) ...[
                VaultedSpacing.gapXxl,
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: VaultedColors.accentGold,
                  ),
                ),
              ],

              const Spacer(flex: 3),

              // -- Use Password Instead --
              TextButton(
                onPressed: () {
                  Haptics.lightTap();
                  context.goNamed(RouteNames.authLogin);
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: Text(
                  'Use Password Instead',
                  style: VaultedTypography.bodyLarge.copyWith(
                    color: VaultedColors.accentGold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              VaultedSpacing.gapLg,
            ],
          ),
        ),
      ),
    );
  }
}

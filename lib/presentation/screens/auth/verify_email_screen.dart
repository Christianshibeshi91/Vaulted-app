import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Email verification screen shown after registration.
///
/// Displays a pulsing mail icon, the target email, and an "Open Email App"
/// button. Includes a resend-with-cooldown and a placeholder for auto-polling
/// verification status.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  int _resendCooldown = 0;
  Timer? _resendTimer;
  bool _isResending = false;

  // TODO: Replace with actual user email from auth state.
  final String _userEmail = 'user@example.com';

  // Auto-poll placeholder:
  // Timer.periodic(const Duration(seconds: 3), (timer) async {
  //   await FirebaseAuth.instance.currentUser?.reload();
  //   if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
  //     timer.cancel();
  //     if (mounted) context.goNamed(RouteNames.onboarding);
  //   }
  // });

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) timer.cancel();
      });
    });
  }

  Future<void> _handleResend() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);
    Haptics.mediumTap();

    try {
      // TODO: Replace with FirebaseAuth.currentUser.sendEmailVerification
      await Future<void>.delayed(const Duration(seconds: 1));

      Haptics.success();
      _startCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email resent.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _openEmailApp() async {
    Haptics.mediumTap();
    final uri = Uri.parse('mailto:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
              VaultedSpacing.gapLg,

              // -- Back --
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Haptics.lightTap();
                    context.pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: VaultedColors.accentGold,
                  ),
                  style:
                      IconButton.styleFrom(minimumSize: const Size(44, 44)),
                ),
              ),

              const Spacer(),

              // -- Pulsing mail icon --
              Icon(
                Icons.mark_email_unread_outlined,
                size: 72,
                color: VaultedColors.accentGold,
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.08, 1.08),
                    duration: 1200.ms,
                    curve: Curves.easeInOut,
                  )
                  .fadeIn(duration: 500.ms),

              VaultedSpacing.gapXxl,

              Text(
                'Verify Your Email',
                style: VaultedTypography.gold(VaultedTypography.headlineLarge),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              VaultedSpacing.gapMd,

              Text(
                'We sent a verification link to',
                textAlign: TextAlign.center,
                style: VaultedTypography.bodyLarge.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

              VaultedSpacing.gapXs,

              Text(
                _userEmail,
                textAlign: TextAlign.center,
                style: VaultedTypography.bodyLarge.copyWith(
                  color: VaultedColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

              VaultedSpacing.gapXxxl,

              // -- Open Email App --
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _openEmailApp,
                  icon: const Icon(Icons.open_in_new_rounded, size: 20),
                  label: const Text('Open Email App'),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

              VaultedSpacing.gapLg,

              // -- Resend --
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: (_resendCooldown > 0 || _isResending)
                      ? null
                      : _handleResend,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VaultedColors.accentGold,
                    side: const BorderSide(color: VaultedColors.accentGold),
                    disabledForegroundColor: VaultedColors.textMuted,
                  ),
                  child: Text(
                    _resendCooldown > 0
                        ? 'Resend in $_resendCooldown s'
                        : 'Resend Verification Email',
                  ),
                ),
              ),

              const Spacer(flex: 2),

              Text(
                'Didn\'t receive the email? Check your spam folder\nor try a different email address.',
                textAlign: TextAlign.center,
                style: VaultedTypography.labelSmall.copyWith(
                  color: VaultedColors.textMuted,
                  height: 1.6,
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

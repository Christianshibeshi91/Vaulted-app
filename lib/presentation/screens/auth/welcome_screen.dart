import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/theme/radii.dart';
import '../../../core/utils/haptics.dart';

/// Landing screen with Sign In / Create Account / Social options.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
              )
                  .animate()
                  .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.easeOut,
                  ),

              VaultedSpacing.gapMd,

              // -- Tagline --
              Text(
                'Your gift cards. One vault.',
                style: VaultedTypography.bodyLarge.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

              const Spacer(flex: 3),

              // -- Sign In --
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Haptics.mediumTap();
                    context.goNamed(RouteNames.authLogin);
                  },
                  child: const Text('Sign In'),
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms).slideY(
                    begin: 0.15,
                    end: 0,
                    delay: 600.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              VaultedSpacing.gapMd,

              // -- Create Account --
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VaultedColors.accentGold,
                    side: const BorderSide(color: VaultedColors.accentGold),
                  ),
                  onPressed: () {
                    Haptics.mediumTap();
                    context.goNamed(RouteNames.authRegister);
                  },
                  child: const Text('Create Account'),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 500.ms).slideY(
                    begin: 0.15,
                    end: 0,
                    delay: 700.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              VaultedSpacing.gapXxl,

              // -- Divider --
              _OrDivider().animate().fadeIn(delay: 800.ms, duration: 500.ms),

              VaultedSpacing.gapXxl,

              // -- Social buttons --
              _SocialButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                onTap: () {
                  Haptics.mediumTap();
                  // TODO: Google sign-in
                },
              ).animate().fadeIn(delay: 900.ms, duration: 500.ms),

              VaultedSpacing.gapMd,

              _SocialButton(
                label: 'Continue with Apple',
                icon: Icons.apple_rounded,
                onTap: () {
                  Haptics.mediumTap();
                  // TODO: Apple sign-in
                },
              ).animate().fadeIn(delay: 1000.ms, duration: 500.ms),

              const Spacer(),

              // -- Terms / Privacy --
              Text(
                'By continuing, you agree to our Terms of Service\nand Privacy Policy.',
                textAlign: TextAlign.center,
                style: VaultedTypography.labelSmall.copyWith(
                  color: VaultedColors.textMuted,
                  height: 1.6,
                ),
              ).animate().fadeIn(delay: 1100.ms, duration: 500.ms),

              VaultedSpacing.gapLg,
            ],
          ),
        ),
      ),
    );
  }
}

// ── "or continue with" divider ───────────────────────────────────────
class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: VaultedColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.lg),
          child: Text(
            'or continue with',
            style: VaultedTypography.labelSmall.copyWith(
              color: VaultedColors.textMuted,
            ),
          ),
        ),
        const Expanded(child: Divider(color: VaultedColors.border)),
      ],
    );
  }
}

// ── Social sign-in button ────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: VaultedColors.textPrimary,
          backgroundColor: VaultedColors.bgInput,
          side: const BorderSide(color: VaultedColors.border),
          shape: VaultedRadii.shapeButton,
        ),
      ),
    );
  }
}

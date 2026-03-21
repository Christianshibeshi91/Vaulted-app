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
      body: Stack(
        children: [
          // -- Radial gold glow behind logo area --
          Positioned(
            top: -80,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    VaultedColors.accentGold.withValues(alpha: 0.06),
                    VaultedColors.bgPrimary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 1200.ms, curve: Curves.easeOut),
          ),

          SafeArea(
            child: Padding(
              padding: VaultedSpacing.screenH,
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // -- Logo with shimmer --
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        VaultedColors.accentGold,
                        VaultedColors.accentGoldLight,
                        VaultedColors.accentGold,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ).createShader(bounds),
                    child: Text(
                      'VAULTED',
                      style: VaultedTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontSize: 40,
                        letterSpacing: 8,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 800.ms,
                        curve: Curves.easeOut,
                      )
                      .then(delay: 400.ms)
                      .shimmer(
                        duration: 2400.ms,
                        color: VaultedColors.accentGoldLight.withValues(alpha: 0.3),
                      ),

                  VaultedSpacing.gapSm,

                  // -- Gold accent line under logo --
                  Container(
                    width: 48,
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          VaultedColors.accentGold.withValues(alpha: 0.0),
                          VaultedColors.accentGold,
                          VaultedColors.accentGold.withValues(alpha: 0.0),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 500.ms, duration: 600.ms)
                      .scaleX(
                        begin: 0.0,
                        end: 1.0,
                        delay: 500.ms,
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),

                  VaultedSpacing.gapLg,

                  // -- Tagline --
                  Text(
                    'Your gift cards. One vault.',
                    style: VaultedTypography.bodyLarge.copyWith(
                      color: VaultedColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

                  const Spacer(flex: 3),

                  // -- Sign In (gold filled, primary CTA) --
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

                  // -- Create Account (outlined, secondary CTA) --
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: VaultedColors.accentGold,
                        side: const BorderSide(
                          color: VaultedColors.borderStrong,
                        ),
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
                  _OrDivider()
                      .animate()
                      .fadeIn(delay: 800.ms, duration: 500.ms),

                  VaultedSpacing.gapXxl,

                  // -- Social buttons --
                  _SocialButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata_rounded,
                    onTap: () {
                      Haptics.mediumTap();
                      // TODO: Google sign-in
                    },
                  ).animate().fadeIn(delay: 900.ms, duration: 500.ms).slideY(
                        begin: 0.08,
                        end: 0,
                        delay: 900.ms,
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),

                  VaultedSpacing.gapMd,

                  _SocialButton(
                    label: 'Continue with Apple',
                    icon: Icons.apple_rounded,
                    onTap: () {
                      Haptics.mediumTap();
                      // TODO: Apple sign-in
                    },
                  ).animate().fadeIn(delay: 1000.ms, duration: 500.ms).slideY(
                        begin: 0.08,
                        end: 0,
                        delay: 1000.ms,
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      ),

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
        ],
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

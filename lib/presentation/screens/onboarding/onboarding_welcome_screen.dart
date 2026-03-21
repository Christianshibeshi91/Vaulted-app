import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Onboarding step 1: animated logo welcome with "Get Started" CTA.
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

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

              // -- Animated logo --
              Text(
                'VAULTED',
                style: VaultedTypography.displayLarge.copyWith(
                  color: VaultedColors.accentGold,
                  fontSize: 42,
                  letterSpacing: 8,
                ),
              )
                  .animate()
                  .fadeIn(duration: 800.ms, curve: Curves.easeOut)
                  .scale(
                    begin: const Offset(0.6, 0.6),
                    end: const Offset(1, 1),
                    duration: 800.ms,
                    curve: Curves.easeOut,
                  ),

              VaultedSpacing.gapXxl,

              // -- Tagline --
              Text(
                'Welcome to Vaulted',
                style: VaultedTypography.headlineLarge.copyWith(
                  color: VaultedColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),

              VaultedSpacing.gapMd,

              Text(
                'The safest place for your gift cards.\nOrganize, track, and redeem\u2014all in one place.',
                textAlign: TextAlign.center,
                style: VaultedTypography.bodyLarge.copyWith(
                  color: VaultedColors.textSecondary,
                  height: 1.6,
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),

              const Spacer(flex: 2),

              // -- Dot indicator (step 1 of 4) --
              _DotIndicator(current: 0, total: 4),

              VaultedSpacing.gapXxl,

              // -- Get Started --
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Haptics.mediumTap();
                    context.goNamed(RouteNames.onboardingProfile);
                  },
                  child: const Text('Get Started'),
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms).slideY(
                    begin: 0.15,
                    end: 0,
                    delay: 800.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              VaultedSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Dot indicator ────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _DotIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: isActive ? 24 : 8,
          height: 8,
          margin: EdgeInsets.only(right: i < total - 1 ? VaultedSpacing.sm : 0),
          decoration: BoxDecoration(
            color: isActive ? VaultedColors.accentGold : VaultedColors.bgInput,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

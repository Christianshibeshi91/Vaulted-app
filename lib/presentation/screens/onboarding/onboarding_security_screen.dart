import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';

/// Onboarding step 3: biometric toggle and MFA setup prompt.
class OnboardingSecurityScreen extends StatefulWidget {
  const OnboardingSecurityScreen({super.key});

  @override
  State<OnboardingSecurityScreen> createState() =>
      _OnboardingSecurityScreenState();
}

class _OnboardingSecurityScreenState extends State<OnboardingSecurityScreen> {
  bool _biometricEnabled = false;
  bool _mfaEnabled = false;

  void _handleContinue() {
    Haptics.mediumTap();
    // TODO: Persist security preferences to Firestore
    context.goNamed(RouteNames.onboardingFirstCard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: VaultedSpacing.screenH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VaultedSpacing.gapLg,

              // -- Back --
              IconButton(
                onPressed: () {
                  Haptics.lightTap();
                  context.pop();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: VaultedColors.accentGold,
                ),
                style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
              ),

              VaultedSpacing.gapXxl,

              // -- Header --
              Text(
                'Secure Your Vault',
                style: VaultedTypography.gold(VaultedTypography.displayMedium),
              ).animate().fadeIn(duration: 500.ms),

              VaultedSpacing.gapSm,

              Text(
                'Add extra layers of protection',
                style: VaultedTypography.bodyLarge.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 500.ms),

              VaultedSpacing.gapXxxl,

              // -- Biometric card --
              _SecurityOptionCard(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Unlock',
                subtitle: 'Use fingerprint or Face ID to open the app',
                value: _biometricEnabled,
                onChanged: (v) {
                  Haptics.toggle();
                  setState(() => _biometricEnabled = v);
                },
              ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideX(
                    begin: -0.05,
                    end: 0,
                    delay: 300.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              VaultedSpacing.gapLg,

              // -- MFA card --
              _SecurityOptionCard(
                icon: Icons.security_rounded,
                title: 'Two-Factor Authentication',
                subtitle: 'Require a code from your authenticator app',
                value: _mfaEnabled,
                onChanged: (v) {
                  Haptics.toggle();
                  setState(() => _mfaEnabled = v);
                },
              ).animate().fadeIn(delay: 450.ms, duration: 500.ms).slideX(
                    begin: -0.05,
                    end: 0,
                    delay: 450.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              VaultedSpacing.gapXxl,

              // -- Info text --
              Container(
                padding: VaultedSpacing.insetsLg,
                decoration: BoxDecoration(
                  color: VaultedColors.accentGoldDim,
                  borderRadius: VaultedRadii.brCard,
                  border: Border.all(color: VaultedColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 20,
                      color: VaultedColors.accentGold,
                    ),
                    VaultedSpacing.gapHMd,
                    Expanded(
                      child: Text(
                        'You can always change these settings later in your profile.',
                        style: VaultedTypography.bodyMedium.copyWith(
                          color: VaultedColors.accentGoldLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

              const Spacer(),

              // -- Dot indicator (step 3 of 4) --
              _DotIndicator(current: 2, total: 4),

              VaultedSpacing.gapXxl,

              // -- Continue --
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  child: const Text('Continue'),
                ),
              ),

              VaultedSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Security option card ─────────────────────────────────────────────

class _SecurityOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SecurityOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: VaultedSpacing.insetsLg,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(
          color: value ? VaultedColors.accentGold : VaultedColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: VaultedColors.accentGoldDim,
              borderRadius: VaultedRadii.brButton,
            ),
            child: Icon(icon, color: VaultedColors.accentGold, size: 22),
          ),
          VaultedSpacing.gapHLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: VaultedTypography.bodyLarge),
                VaultedSpacing.gapXs,
                Text(
                  subtitle,
                  style: VaultedTypography.bodyMedium.copyWith(
                    color: VaultedColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          VaultedSpacing.gapHMd,
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
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

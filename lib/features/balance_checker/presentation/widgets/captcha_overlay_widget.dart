import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/radii.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/theme/typography.dart';

/// Slide-up overlay that reveals the WebView when a CAPTCHA is detected.
///
/// The overlay appears with a dark scrim and a header saying
/// "Quick verification needed". After the user solves the CAPTCHA,
/// the parent dismisses this overlay.
class CaptchaOverlayWidget extends StatelessWidget {
  const CaptchaOverlayWidget({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onDismiss,
  });

  final WebViewController? controller;
  final bool isVisible;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    if (!isVisible || controller == null) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        color: const Color(0xD9000000), // 85% opacity black
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                  vertical: VaultedSpacing.md,
                ),
                decoration: const BoxDecoration(
                  color: VaultedColors.bgSecondary,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(VaultedRadii.bottomSheet),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_user_outlined,
                          color: VaultedColors.accentGold,
                          size: 20,
                        ),
                        VaultedSpacing.gapHSm,
                        Text(
                          'Quick verification needed',
                          style: VaultedTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: VaultedColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: onDismiss,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: VaultedColors.bgCard,
                          shape: BoxShape.circle,
                          border: Border.all(color: VaultedColors.border),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: VaultedColors.textSecondary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // WebView container
              Container(
                height: 420,
                color: Colors.white, // CAPTCHA pages expect white bg
                child: WebViewWidget(controller: controller!),
              ),

              // Bottom hint
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                  vertical: VaultedSpacing.md,
                ),
                color: VaultedColors.bgSecondary,
                child: Text(
                  'Complete the verification to check your balance',
                  style: VaultedTypography.labelSmall.copyWith(
                    color: VaultedColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(
          begin: 1,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 200.ms);
  }
}

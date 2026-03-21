import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import 'vaulted_button.dart';

/// Enhanced empty-state widget with subtle floating animation on the
/// icon and a gold pulse effect on the CTA button.
///
/// Drop-in replacement for [VaultedEmptyState] when you want more
/// visual life on zero-data screens.
class AnimatedEmptyState extends StatelessWidget {
  const AnimatedEmptyState({
    this.icon,
    this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData? icon;
  final String? title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: VaultedSpacing.insetsXxl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Floating icon ──────────────────────────────────
            if (icon != null) ...[
              Icon(
                icon,
                size: 56,
                color: VaultedColors.accentGold.withValues(alpha: 0.6),
              )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .moveY(
                    begin: 0,
                    end: -8,
                    duration: 2000.ms,
                    curve: Curves.easeInOut,
                  )
                  .fadeIn(duration: 500.ms, curve: Curves.easeOut),
              const SizedBox(height: VaultedSpacing.xl),
            ],

            // ── Title ──────────────────────────────────────────
            if (title != null) ...[
              Text(
                title!,
                style: VaultedTypography.headlineMedium,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 100.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 100.ms),
              const SizedBox(height: VaultedSpacing.sm),
            ],

            // ── Message ────────────────────────────────────────
            if (message != null)
              Text(
                message!,
                style: VaultedTypography.bodyMedium
                    .copyWith(color: VaultedColors.textSecondary),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 200.ms),

            // ── CTA with gold pulse ────────────────────────────
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: VaultedSpacing.xxl),
              SizedBox(
                width: 220,
                child: VaultedButton.primary(
                  actionLabel!,
                  onPressed: onAction,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 300.ms, curve: Curves.easeOut)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms, delay: 300.ms)
                  .then(delay: 600.ms)
                  .shimmer(
                    duration: 1800.ms,
                    color: VaultedColors.accentGoldLight.withValues(alpha: 0.3),
                    delay: 0.ms,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

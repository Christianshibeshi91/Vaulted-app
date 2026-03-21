import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/card_providers.dart';

/// Hero balance display with gold radial gradient and shimmer effect.
class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);
    final totalBalance = ref.watch(totalBalanceProvider);
    final activeCount = ref.watch(activeCardsCountProvider);

    return cardsAsync.when(
      loading: () => const _BalanceSkeleton(),
      error: (_, _) => const _BalanceError(),
      data: (_) => _BalanceContent(
        totalBalance: totalBalance,
        activeCount: activeCount,
      ),
    );
  }
}

class _BalanceContent extends StatelessWidget {
  final double totalBalance;
  final int activeCount;

  const _BalanceContent({
    required this.totalBalance,
    required this.activeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: VaultedSpacing.xxl,
        vertical: VaultedSpacing.xxxl,
      ),
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.8,
          colors: [
            VaultedColors.accentGold.withValues(alpha: 0.08),
            VaultedColors.bgCard,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: VaultedTypography.secondary(VaultedTypography.bodyMedium),
          ),
          VaultedSpacing.gapSm,
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
              Formatters.currency(totalBalance),
              style: VaultedTypography.displayLarge.copyWith(
                color: Colors.white,
                fontSize: 36,
              ),
            ),
          )
              .animate(
                onPlay: (c) => c.repeat(reverse: true),
              )
              .shimmer(
                duration: 3000.ms,
                color: VaultedColors.accentGoldLight.withValues(alpha: 0.3),
              ),
          VaultedSpacing.gapSm,
          Text(
            '$activeCount card${activeCount == 1 ? '' : 's'}',
            style: VaultedTypography.bodyMedium.copyWith(
              color: VaultedColors.textSecondary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

class _BalanceSkeleton extends StatelessWidget {
  const _BalanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: VaultedSpacing.xxl,
          vertical: VaultedSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 14,
              decoration: BoxDecoration(
                color: VaultedColors.shimmerBase,
                borderRadius: VaultedRadii.brBadge,
              ),
            ),
            VaultedSpacing.gapMd,
            Container(
              width: 180,
              height: 36,
              decoration: BoxDecoration(
                color: VaultedColors.shimmerBase,
                borderRadius: VaultedRadii.brBadge,
              ),
            ),
            VaultedSpacing.gapMd,
            Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: VaultedColors.shimmerBase,
                borderRadius: VaultedRadii.brBadge,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(
          duration: 1200.ms,
          color: VaultedColors.shimmerHighlight,
        );
  }
}

class _BalanceError extends StatelessWidget {
  const _BalanceError();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: VaultedSpacing.insetsXxl,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: VaultedColors.danger, size: 20),
          VaultedSpacing.gapHMd,
          Expanded(
            child: Text(
              'Could not load balance',
              style: VaultedTypography.bodyMedium.copyWith(
                color: VaultedColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

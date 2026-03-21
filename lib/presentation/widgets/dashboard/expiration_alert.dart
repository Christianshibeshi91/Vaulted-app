import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../providers/card_providers.dart';

/// Conditional alert banner shown when cards are expiring within 30 days.
class ExpirationAlert extends ConsumerWidget {
  const ExpirationAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardsProvider);

    return cardsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (cards) {
        final now = DateTime.now();
        final threshold = now.add(const Duration(days: 30));
        final expiring = cards.where((c) {
          if (c.status != 'active') return false;
          if (c.expirationDate == null) return false;
          return c.expirationDate!.isBefore(threshold) &&
              c.expirationDate!.isAfter(now);
        }).toList();

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: expiring.isEmpty
              ? const SizedBox.shrink()
              : _AlertBanner(count: expiring.length),
        );
      },
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final int count;

  const _AlertBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
      padding: const EdgeInsets.symmetric(
        horizontal: VaultedSpacing.lg,
        vertical: VaultedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: VaultedColors.warning.withValues(alpha: 0.08),
        borderRadius: VaultedRadii.brCard,
        border: Border.all(
          color: VaultedColors.warning.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            color: VaultedColors.warning,
            size: 20,
          ),
          VaultedSpacing.gapHMd,
          Expanded(
            child: Text(
              '$count card${count == 1 ? '' : 's'} expiring within 30 days',
              style: VaultedTypography.bodyMedium.copyWith(
                color: VaultedColors.warning,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: VaultedColors.warning.withValues(alpha: 0.6),
            size: 20,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: -0.1, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

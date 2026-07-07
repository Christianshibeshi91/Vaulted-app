import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/card_providers.dart';

/// Shows the 5 most recent transactions on the dashboard.
class RecentActivity extends ConsumerWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(recentTransactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: VaultedTypography.headlineMedium,
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'See All',
                  style: VaultedTypography.bodyMedium.copyWith(
                    color: VaultedColors.accentGold,
                  ),
                ),
              ),
            ],
          ),
        ),
        VaultedSpacing.gapSm,
        txAsync.when(
          loading: () => const _ActivitySkeleton(),
          error: (_, _) => Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: VaultedSpacing.xl),
            child: Text(
              'Could not load activity',
              style: VaultedTypography.bodyMedium.copyWith(
                color: VaultedColors.danger,
              ),
            ),
          ),
          data: (transactions) {
            if (transactions.isEmpty) return const _ActivityEmpty();

            final recent = transactions.take(5).toList();
            return Column(
              children: [
                for (var i = 0; i < recent.length; i++)
                  _TransactionTile(tx: recent[i], index: i),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel tx;
  final int index;

  const _TransactionTile({required this.tx, required this.index});

  IconData get _icon => switch (tx.type) {
        TransactionType.purchase => Icons.shopping_bag_outlined,
        TransactionType.refund => Icons.replay_rounded,
        TransactionType.balanceCheck => Icons.account_balance_outlined,
        TransactionType.adjustment => Icons.tune_rounded,
        TransactionType.transfer => Icons.swap_horiz_rounded,
        _ => Icons.receipt_long_outlined,
      };

  Color get _amountColor {
    if (tx.type == TransactionType.refund || tx.amount > 0) {
      return VaultedColors.accentGold;
    }
    return VaultedColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: VaultedSpacing.xl,
        vertical: VaultedSpacing.xs,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: VaultedSpacing.lg,
        vertical: VaultedSpacing.md,
      ),
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: VaultedColors.accentGoldDim,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: VaultedColors.accentGold, size: 18),
          ),
          VaultedSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ?? tx.retailer,
                  style: VaultedTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  Formatters.relativeTime(tx.createdAt),
                  style: VaultedTypography.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          VaultedSpacing.gapHSm,
          Text(
            Formatters.currencySigned(tx.amount),
            style: VaultedTypography.monoSmall.copyWith(color: _amountColor),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: 250.ms,
          delay: (50 * index).ms,
          curve: Curves.easeOut,
        )
        .slideX(
          begin: 0.03,
          end: 0,
          duration: 250.ms,
          delay: (50 * index).ms,
          curve: Curves.easeOut,
        );
  }
}

class _ActivitySkeleton extends StatelessWidget {
  const _ActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (i) => Container(
          height: 64,
          margin: const EdgeInsets.symmetric(
            horizontal: VaultedSpacing.xl,
            vertical: VaultedSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: VaultedColors.bgCard,
            borderRadius: VaultedRadii.brCard,
            border: Border.all(color: VaultedColors.border),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
              duration: 1200.ms,
              delay: (100 * i).ms,
              color: VaultedColors.shimmerHighlight,
            ),
      ),
    );
  }
}

class _ActivityEmpty extends StatelessWidget {
  const _ActivityEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: VaultedSpacing.xl,
        vertical: VaultedSpacing.xxl,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: VaultedColors.textMuted,
              size: 32,
            ),
            VaultedSpacing.gapSm,
            Text(
              'No recent activity',
              style:
                  VaultedTypography.secondary(VaultedTypography.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

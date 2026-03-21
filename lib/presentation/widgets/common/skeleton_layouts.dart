import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import 'vaulted_skeleton.dart';

/// Pre-built skeleton screens that mirror real screen layouts.
///
/// Each skeleton uses [VaultedSkeleton] primitives with
/// [VaultedColors.shimmerBase] (#0E0E18) and
/// [VaultedColors.shimmerHighlight] (#1A1A2E).

// ── Dashboard skeleton ──────────────────────────────────────────

/// Matches the dashboard layout: balance card, 3 quick-action buttons,
/// section label, and 3 card carousel placeholders.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar placeholder
            const SizedBox(height: VaultedSpacing.xxl),
            VaultedSkeleton.box(width: 100, height: 12, borderRadius: 4),
            const SizedBox(height: VaultedSpacing.xs),
            VaultedSkeleton.box(width: 140, height: 18, borderRadius: 4),
            const SizedBox(height: VaultedSpacing.xxl),

            // Balance card shimmer
            VaultedSkeleton.box(height: 160, borderRadius: VaultedRadii.card),
            const SizedBox(height: VaultedSpacing.xxl),

            // Quick actions row (3 buttons)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                3,
                (_) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: VaultedSpacing.xs),
                    child: VaultedSkeleton.box(
                      height: 56,
                      borderRadius: VaultedRadii.button,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: VaultedSpacing.xxl),

            // Section header
            VaultedSkeleton.box(width: 90, height: 16, borderRadius: 4),
            const SizedBox(height: VaultedSpacing.md),

            // Card carousel (3 items, horizontal)
            SizedBox(
              height: 180,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: VaultedSpacing.md),
                itemBuilder: (_, _) => SizedBox(
                  width: 260,
                  child: VaultedSkeleton.box(
                    height: 180,
                    borderRadius: VaultedRadii.card,
                  ),
                ),
              ),
            ),
            const SizedBox(height: VaultedSpacing.xxl),

            // Balance trend chart placeholder
            VaultedSkeleton.box(height: 200, borderRadius: VaultedRadii.card),
            const SizedBox(height: VaultedSpacing.xxl),

            // Recent activity header
            VaultedSkeleton.box(width: 120, height: 16, borderRadius: 4),
            const SizedBox(height: VaultedSpacing.md),

            // 3 recent transaction rows
            ...List.generate(3, (_) => const _TransactionRowSkeleton()),
          ],
        ),
      ),
    );
  }
}

// ── Cards list skeleton ──────────────────────────────────────────

/// Grid of 6 card shimmer items arranged in a 2-column grid.
class CardsListSkeleton extends StatelessWidget {
  const CardsListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: VaultedSpacing.xl),

            // Title placeholder
            VaultedSkeleton.box(width: 110, height: 22, borderRadius: 4),
            const SizedBox(height: VaultedSpacing.lg),

            // Search bar
            VaultedSkeleton.box(height: 44, borderRadius: VaultedRadii.input),
            const SizedBox(height: VaultedSpacing.md),

            // Filter chips row
            SizedBox(
              height: 36,
              child: Row(
                children: List.generate(
                  3,
                  (_) => Padding(
                    padding:
                        const EdgeInsets.only(right: VaultedSpacing.sm),
                    child: VaultedSkeleton.box(
                      width: 72,
                      height: 36,
                      borderRadius: VaultedRadii.pill,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: VaultedSpacing.lg),

            // 2x3 grid
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: VaultedSpacing.md,
                  crossAxisSpacing: VaultedSpacing.md,
                  childAspectRatio: 0.82,
                ),
                itemCount: 6,
                itemBuilder: (_, _) => VaultedSkeleton.box(
                  height: double.infinity,
                  borderRadius: VaultedRadii.card,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Activity list skeleton ───────────────────────────────────────

/// 8 transaction item shimmers mimicking the grouped transaction list.
class ActivityListSkeleton extends StatelessWidget {
  const ActivityListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: VaultedSpacing.xl,
        vertical: VaultedSpacing.lg,
      ),
      itemCount: 8,
      itemBuilder: (_, index) {
        // Insert a date-group header at indices 0 and 4.
        if (index == 0 || index == 4) {
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : VaultedSpacing.xl,
              bottom: VaultedSpacing.md,
            ),
            child: VaultedSkeleton.box(
              width: 80,
              height: 10,
              borderRadius: 4,
            ),
          );
        }
        return const _TransactionRowSkeleton();
      },
    );
  }
}

// ── Profile skeleton ─────────────────────────────────────────────

/// Avatar circle at top + 4 settings-row shimmers.
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(VaultedSpacing.xl),
        child: Column(
          children: [
            const SizedBox(height: VaultedSpacing.xxl),

            // Avatar
            VaultedSkeleton.circle(size: 88),
            const SizedBox(height: VaultedSpacing.lg),

            // Name
            VaultedSkeleton.box(width: 150, height: 20, borderRadius: 4),
            const SizedBox(height: VaultedSpacing.sm),

            // Email
            VaultedSkeleton.box(width: 200, height: 14, borderRadius: 4),
            const SizedBox(height: VaultedSpacing.xxl),

            // Plan badge
            VaultedSkeleton.box(width: 80, height: 24, borderRadius: 12),
            const SizedBox(height: VaultedSpacing.section),

            // Section header
            Align(
              alignment: Alignment.centerLeft,
              child: VaultedSkeleton.box(
                  width: 70, height: 10, borderRadius: 4),
            ),
            const SizedBox(height: VaultedSpacing.md),

            // 4 settings rows
            ...List.generate(
              4,
              (_) => Padding(
                padding:
                    const EdgeInsets.only(bottom: VaultedSpacing.lg),
                child: Row(
                  children: [
                    VaultedSkeleton.circle(size: 22),
                    const SizedBox(width: VaultedSpacing.lg),
                    Expanded(
                      child: VaultedSkeleton.box(
                        height: 14,
                        borderRadius: 4,
                      ),
                    ),
                    const SizedBox(width: VaultedSpacing.xxxl),
                    VaultedSkeleton.box(
                      width: 20,
                      height: 14,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared: single transaction row skeleton ──────────────────────

class _TransactionRowSkeleton extends StatelessWidget {
  const _TransactionRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VaultedSpacing.lg),
      child: Row(
        children: [
          VaultedSkeleton.circle(size: 44),
          const SizedBox(width: VaultedSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VaultedSkeleton.box(
                    width: 140, height: 14, borderRadius: 4),
                const SizedBox(height: 6),
                VaultedSkeleton.box(
                    width: 80, height: 10, borderRadius: 4),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              VaultedSkeleton.box(width: 60, height: 14, borderRadius: 4),
              const SizedBox(height: 6),
              VaultedSkeleton.box(width: 40, height: 10, borderRadius: 4),
            ],
          ),
        ],
      ),
    );
  }
}

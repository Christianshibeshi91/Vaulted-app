import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/card_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/card_providers.dart';
import '../../widgets/cards/card_visual.dart';

/// Detail screen for a single gift card.
class CardDetailScreen extends ConsumerStatefulWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  ConsumerState<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends ConsumerState<CardDetailScreen> {
  bool _showCardNumber = false;
  bool _showPin = false;

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(cardByIdProvider(widget.cardId));
    final txAsync = ref.watch(cardTransactionsProvider(widget.cardId));

    if (card == null) {
      return Scaffold(
        backgroundColor: VaultedColors.bgPrimary,
        appBar: AppBar(backgroundColor: VaultedColors.bgPrimary),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.credit_card_off,
                  color: VaultedColors.textMuted, size: 48),
              VaultedSpacing.gapMd,
              Text(
                'Card not found',
                style: VaultedTypography.headlineMedium.copyWith(
                  color: VaultedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 60,
            pinned: true,
            backgroundColor: VaultedColors.bgPrimary,
            title: Text(
              card.retailer,
              style: VaultedTypography.headlineLarge,
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 22),
                color: VaultedColors.bgSecondary,
                shape: RoundedRectangleBorder(
                  borderRadius: VaultedRadii.brCard,
                  side: const BorderSide(color: VaultedColors.border),
                ),
                onSelected: (action) => _handleAction(action, card),
                itemBuilder: (_) => [
                  _menuItem('edit', Icons.edit_outlined, 'Edit Card'),
                  _menuItem(
                      'archive', Icons.archive_outlined, 'Archive'),
                  _menuItem(
                      'delete', Icons.delete_outline, 'Delete',
                      isDanger: true),
                ],
              ),
            ],
          ),

          // ── Card Visual ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl),
              child: CardVisual(card: card, showFullNumber: _showCardNumber)
                  .animate()
                  .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                  .slideY(
                    begin: 0.05,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOut,
                  ),
            ),
          ),

          // ── Balance Display ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VaultedSpacing.xl,
                vertical: VaultedSpacing.xxl,
              ),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Current Balance',
                      style: VaultedTypography.secondary(
                          VaultedTypography.bodyMedium),
                    ),
                    VaultedSpacing.gapXs,
                    Text(
                      Formatters.currency(card.balance),
                      style: VaultedTypography.displayLarge.copyWith(
                        color: VaultedColors.accentGold,
                        fontSize: 36,
                      ),
                    ),
                    if (card.originalBalance != card.balance) ...[
                      VaultedSpacing.gapXs,
                      Text(
                        'of ${Formatters.currency(card.originalBalance)} original',
                        style: VaultedTypography.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // ── Info Section ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl),
              child: Container(
                padding: VaultedSpacing.cardInner,
                decoration: BoxDecoration(
                  color: VaultedColors.bgCard,
                  borderRadius: VaultedRadii.brCard,
                  border: Border.all(color: VaultedColors.border),
                ),
                child: Column(
                  children: [
                    // Card Number
                    if (card.cardNumberEncrypted != null)
                      _InfoRow(
                        label: 'Card Number',
                        value: _showCardNumber
                            ? Formatters.groupCardDigits(
                                card.cardNumberEncrypted!)
                            : Formatters.maskCardNumber(
                                card.cardNumberEncrypted!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionIcon(
                              icon: _showCardNumber
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              onTap: () {
                                Haptics.lightTap();
                                setState(
                                    () => _showCardNumber = !_showCardNumber);
                              },
                              tooltip: _showCardNumber ? 'Hide' : 'Reveal',
                            ),
                            const SizedBox(width: 4),
                            _ActionIcon(
                              icon: Icons.copy,
                              onTap: () {
                                Clipboard.setData(ClipboardData(
                                    text: card.cardNumberEncrypted!));
                                Haptics.lightTap();
                                _showCopiedSnackbar(context);
                              },
                              tooltip: 'Copy',
                            ),
                          ],
                        ),
                        mono: true,
                      ),

                    // PIN
                    if (card.pinEncrypted != null) ...[
                      const Divider(color: VaultedColors.border),
                      _InfoRow(
                        label: 'PIN',
                        value: _showPin ? card.pinEncrypted! : '****',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionIcon(
                              icon: _showPin
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              onTap: () {
                                Haptics.lightTap();
                                setState(() => _showPin = !_showPin);
                              },
                              tooltip: _showPin ? 'Hide' : 'Reveal',
                            ),
                            const SizedBox(width: 4),
                            _ActionIcon(
                              icon: Icons.copy,
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: card.pinEncrypted!));
                                Haptics.lightTap();
                                _showCopiedSnackbar(context);
                              },
                              tooltip: 'Copy',
                            ),
                          ],
                        ),
                        mono: true,
                      ),
                    ],

                    // Expiration
                    if (card.expirationDate != null) ...[
                      const Divider(color: VaultedColors.border),
                      _InfoRow(
                        label: 'Expires',
                        value: Formatters.dateFull(card.expirationDate!),
                      ),
                    ],

                    // Last Balance Check
                    if (card.lastBalanceCheck != null) ...[
                      const Divider(color: VaultedColors.border),
                      _InfoRow(
                        label: 'Last Checked',
                        value: Formatters.relativeTime(
                            card.lastBalanceCheck!),
                      ),
                    ],

                    // Added date
                    const Divider(color: VaultedColors.border),
                    _InfoRow(
                      label: 'Added',
                      value: Formatters.dateFull(card.createdAt),
                    ),

                    // Notes
                    if (card.notes != null &&
                        card.notes!.isNotEmpty) ...[
                      const Divider(color: VaultedColors.border),
                      _InfoRow(
                        label: 'Notes',
                        value: card.notes!,
                      ),
                    ],
                  ],
                ),
              )
                  .animate()
                  .fadeIn(
                    duration: 400.ms,
                    delay: 100.ms,
                    curve: Curves.easeOut,
                  ),
            ),
          ),

          VaultedSpacing.gapXxl.toSliver,

          // ── Balance History Chart ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl),
              child: _BalanceHistoryChart(cardId: widget.cardId),
            ),
          ),

          VaultedSpacing.gapXxl.toSliver,

          // ── Transaction History ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl),
              child: Text(
                'Transaction History',
                style: VaultedTypography.headlineMedium,
              ),
            ),
          ),

          VaultedSpacing.gapMd.toSliver,

          txAsync.when(
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: VaultedSpacing.xl),
                child: Column(
                  children: List.generate(
                    3,
                    (i) => Container(
                      height: 60,
                      margin: const EdgeInsets.only(
                          bottom: VaultedSpacing.sm),
                      decoration: BoxDecoration(
                        color: VaultedColors.bgCard,
                        borderRadius: VaultedRadii.brCard,
                        border:
                            Border.all(color: VaultedColors.border),
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .shimmer(
                          duration: 1200.ms,
                          delay: (100 * i).ms,
                          color: VaultedColors.shimmerHighlight,
                        ),
                  ),
                ),
              ),
            ),
            error: (_, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: VaultedSpacing.xl),
                child: Text(
                  'Could not load transactions',
                  style: VaultedTypography.bodyMedium.copyWith(
                    color: VaultedColors.danger,
                  ),
                ),
              ),
            ),
            data: (transactions) {
              if (transactions.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
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
                            'No transactions yet',
                            style: VaultedTypography.secondary(
                                VaultedTypography.bodyMedium),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: VaultedSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => _TransactionRow(
                      tx: transactions[index],
                      index: index,
                    ),
                    childCount: transactions.length,
                  ),
                ),
              );
            },
          ),

          // ── Actions ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(VaultedSpacing.xl),
              child: Column(
                children: [
                  VaultedSpacing.gapLg,
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Haptics.mediumTap();
                        // TODO: Update balance flow
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Update Balance'),
                    ),
                  ),
                  VaultedSpacing.gapMd,
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Haptics.lightTap();
                        // TODO: Edit card flow
                      },
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit Card'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _handleAction(String action, CardModel card) {
    switch (action) {
      case 'edit':
        Haptics.lightTap();
        // TODO: Navigate to edit
        break;
      case 'archive':
        Haptics.mediumTap();
        // TODO: Archive card
        break;
      case 'delete':
        Haptics.warning();
        _showDeleteDialog(card);
        break;
    }
  }

  void _showDeleteDialog(CardModel card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Card?'),
        content: Text(
          'Permanently delete your ${card.retailer} card? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultedColors.danger,
            ),
            onPressed: () {
              Haptics.heavyTap();
              Navigator.pop(ctx);
              context.pop();
              // TODO: Delete from Firestore
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCopiedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Copied to clipboard',
          style: VaultedTypography.bodyMedium.copyWith(
            color: VaultedColors.textPrimary,
          ),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: VaultedColors.bgCard,
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label, {
    bool isDanger = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isDanger
                ? VaultedColors.danger
                : VaultedColors.textSecondary,
          ),
          VaultedSpacing.gapHSm,
          Text(
            label,
            style: VaultedTypography.bodyMedium.copyWith(
              color: isDanger
                  ? VaultedColors.danger
                  : VaultedColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info row ─────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  final bool mono;

  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VaultedSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: VaultedTypography.labelSmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? VaultedTypography.monoSmall
                  : VaultedTypography.bodyLarge,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

// ── Action icon button ───────────────────────────────────────────

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionIcon({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            icon,
            size: 16,
            color: VaultedColors.accentGold,
          ),
        ),
      ),
    );
  }
}

// ── Balance history chart ────────────────────────────────────────

class _BalanceHistoryChart extends ConsumerWidget {
  final String cardId;

  const _BalanceHistoryChart({required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(cardTransactionsProvider(cardId));

    return Container(
      padding: VaultedSpacing.cardInner,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance History',
            style: VaultedTypography.headlineMedium,
          ),
          VaultedSpacing.gapLg,
          SizedBox(
            height: 140,
            child: txAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: VaultedColors.accentGold,
                  strokeWidth: 2,
                ),
              ),
              error: (_, _) => Center(
                child: Text(
                  'No data',
                  style: VaultedTypography.secondary(
                      VaultedTypography.bodyMedium),
                ),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No balance history',
                      style: VaultedTypography.secondary(
                          VaultedTypography.bodyMedium),
                    ),
                  );
                }

                final reversed = transactions.reversed.toList();
                final spots = <FlSpot>[];
                for (var i = 0; i < reversed.length; i++) {
                  spots.add(FlSpot(
                    i.toDouble(),
                    reversed[i].balanceAfter,
                  ));
                }

                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (_) => VaultedColors.bgCard,
                        tooltipRoundedRadius: VaultedRadii.badge,
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              '\$${spot.y.toStringAsFixed(2)}',
                              VaultedTypography.monoSmall.copyWith(
                                color: VaultedColors.accentGold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.3,
                        color: VaultedColors.accentGold,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              VaultedColors.accentGold
                                  .withValues(alpha: 0.15),
                              VaultedColors.accentGold
                                  .withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 150.ms, curve: Curves.easeOut);
  }
}

// ── Transaction row ──────────────────────────────────────────────

class _TransactionRow extends StatelessWidget {
  final TransactionModel tx;
  final int index;

  const _TransactionRow({required this.tx, required this.index});

  IconData get _icon => switch (tx.type) {
        TransactionType.purchase => Icons.shopping_bag_outlined,
        TransactionType.refund => Icons.replay_rounded,
        TransactionType.balanceCheck => Icons.account_balance_outlined,
        TransactionType.adjustment => Icons.tune_rounded,
        TransactionType.transfer => Icons.swap_horiz_rounded,
        _ => Icons.receipt_long_outlined,
      };

  Color get _amountColor {
    if (tx.type == TransactionType.refund) return VaultedColors.success;
    if (tx.amount < 0) return VaultedColors.danger;
    return VaultedColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: VaultedSpacing.sm),
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
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: VaultedColors.accentGoldDim,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: VaultedColors.accentGold, size: 16),
          ),
          VaultedSpacing.gapHMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description ?? TransactionType.label(tx.type),
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
                ),
              ],
            ),
          ),
          Text(
            Formatters.currencySigned(tx.amount),
            style: VaultedTypography.monoSmall.copyWith(color: _amountColor),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: 200.ms,
          delay: (40 * index).ms,
          curve: Curves.easeOut,
        )
        .slideX(
          begin: 0.03,
          end: 0,
          duration: 200.ms,
          delay: (40 * index).ms,
          curve: Curves.easeOut,
        );
  }
}

// ── SizedBox to sliver extension ──────────────────────────────────

extension on SizedBox {
  SliverToBoxAdapter get toSliver => SliverToBoxAdapter(child: this);
}

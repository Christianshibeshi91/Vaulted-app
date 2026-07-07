import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/encryption.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/screenshot_prevention.dart';
import '../../../core/utils/secure_storage.dart';
import '../../../data/models/card_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../../features/balance_checker/data/retailer_configs.dart';
import '../../../features/balance_checker/presentation/screens/balance_check_screen.dart';
import '../../providers/card_providers.dart';
import '../../widgets/cards/card_visual.dart';

/// Detail screen for a single gift card.
class CardDetailScreen extends ConsumerStatefulWidget {
  final String cardId;

  const CardDetailScreen({super.key, required this.cardId});

  @override
  ConsumerState<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends ConsumerState<CardDetailScreen>
    with ScreenshotPreventionMixin {
  bool _showCardNumber = false;
  final bool _showPin = false;
  String? _decryptedCardNumber;
  String? _decryptedPin;
  bool _decryptionFailed = false;

  @override
  void initState() {
    super.initState();
    _decryptFields();
  }

  Future<void> _decryptFields() async {
    try {
      final card = ref.read(cardByIdProvider(widget.cardId));
      if (card == null) return;
      final enc = EncryptionService(SecureStorageService.instance);
      await enc.initialise();
      if (card.cardNumberEncrypted != null) {
        _decryptedCardNumber = enc.decrypt(card.cardNumberEncrypted!);
      }
      if (card.pinEncrypted != null) {
        _decryptedPin = enc.decrypt(card.pinEncrypted!);
      }
    } catch (_) {
      _decryptionFailed = true;
    }
    if (mounted) setState(() {});
  }

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
              const Icon(
                Icons.credit_card_off,
                color: VaultedColors.textMuted,
                size: 48,
              ),
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
            pinned: true,
            backgroundColor: VaultedColors.bgPrimary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 22),
              onPressed: () => context.pop(),
            ),
            centerTitle: true,
            title: Text(
              'CARD DETAILS',
              style: VaultedTypography.labelSmall.copyWith(
                color: VaultedColors.textPrimary,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
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
                  _menuItem('archive', Icons.archive_outlined, 'Archive'),
                  _menuItem(
                    'delete',
                    Icons.delete_outline,
                    'Delete',
                    isDanger: true,
                  ),
                ],
              ),
            ],
          ),

          // ── Card Visual (full width) ─────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VaultedSpacing.xl,
              ),
              child:
                  CardVisual(
                        card: _decryptedCardNumber != null
                            ? card.copyWith(
                                cardNumberEncrypted: _showCardNumber
                                    ? _decryptedCardNumber
                                    : card.cardNumberEncrypted,
                              )
                            : card,
                        showFullNumber: _showCardNumber,
                        onToggleNumber: _decryptedCardNumber != null
                            ? () {
                                Haptics.lightTap();
                                setState(
                                  () => _showCardNumber = !_showCardNumber,
                                );
                              }
                            : null,
                      )
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

          // ── Balance Section ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                VaultedSpacing.xl,
                VaultedSpacing.xxl,
                VaultedSpacing.xl,
                VaultedSpacing.lg,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BALANCE',
                        style: VaultedTypography.labelMicro.copyWith(
                          letterSpacing: 1.5,
                          color: VaultedColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.currency(card.balance),
                        style: VaultedTypography.displayLarge.copyWith(
                          color: VaultedColors.accentGold,
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      'PRECISION VAULT v2.04',
                      style: VaultedTypography.labelMicro.copyWith(
                        color: VaultedColors.textMuted,
                        letterSpacing: 0.8,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Action Buttons Row ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VaultedSpacing.xl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.refresh_rounded,
                      label: 'REFRESH',
                      onTap: () {
                        Haptics.lightTap();
                        final config = RetailerConfigs.byName(card.retailer);
                        if (config != null) {
                          Navigator.of(context).push(
                            MaterialPageRoute<bool>(
                              builder: (_) =>
                                  BalanceCheckScreen(config: config),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: VaultedSpacing.sm),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.share_outlined,
                      label: 'SHARE',
                      onTap: () {
                        Haptics.lightTap();
                        _shareCard(card);
                      },
                    ),
                  ),
                  const SizedBox(width: VaultedSpacing.sm),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.archive_outlined,
                      label: 'ARCHIVE',
                      onTap: () {
                        Haptics.mediumTap();
                        // TODO: Archive card
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          VaultedSpacing.gapXxl.toSliver,

          // ── Balance History Chart ─────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VaultedSpacing.xl,
              ),
              child: _BalanceHistoryChart(cardId: widget.cardId),
            ),
          ),

          VaultedSpacing.gapXxl.toSliver,

          // ── Recent Transactions Header ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: VaultedSpacing.xl,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Transactions',
                    style: VaultedTypography.headlineMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Haptics.lightTap();
                      // TODO: Navigate to all transactions
                    },
                    child: Text(
                      'VIEW ALL',
                      style: VaultedTypography.labelSmall.copyWith(
                        color: VaultedColors.accentGold,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          VaultedSpacing.gapMd.toSliver,

          // ── Transaction List ──────────────────────────────────
          txAsync.when(
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                ),
                child: Column(
                  children: List.generate(
                    3,
                    (i) =>
                        Container(
                              height: 68,
                              margin: const EdgeInsets.only(
                                bottom: VaultedSpacing.sm,
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
                ),
              ),
            ),
            error: (_, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                ),
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
                          const Icon(
                            Icons.receipt_long_outlined,
                            color: VaultedColors.textMuted,
                            size: 32,
                          ),
                          VaultedSpacing.gapSm,
                          Text(
                            'No transactions yet',
                            style: VaultedTypography.secondary(
                              VaultedTypography.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Show max 5 recent transactions
              final visible = transactions.take(5).toList();
              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, index) =>
                        _TransactionRow(tx: visible[index], index: index),
                    childCount: visible.length,
                  ),
                ),
              );
            },
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  void _shareCard(CardModel card) {
    final text = StringBuffer()
      ..writeln('${card.retailer} Gift Card')
      ..writeln('Balance: ${Formatters.currency(card.balance)}');
    if (card.expirationDate != null) {
      text.writeln('Expires: ${Formatters.monthYear(card.expirationDate!)}');
    }
    text.writeln('\nShared from Vaulted');
    Share.share(text.toString(), subject: '${card.retailer} Gift Card');
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
        backgroundColor: VaultedColors.bgSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: VaultedRadii.brCard,
          side: const BorderSide(color: VaultedColors.border),
        ),
        title: Text('Delete Card?', style: VaultedTypography.headlineMedium),
        content: Text(
          'Permanently delete your ${card.retailer} card? '
          'This cannot be undone.',
          style: VaultedTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: VaultedTypography.bodyLarge.copyWith(
                color: VaultedColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultedColors.danger,
              shape: VaultedRadii.shapeButton,
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

// ── Action button ──────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: VaultedRadii.brButton,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: VaultedSpacing.md),
          decoration: BoxDecoration(
            color: VaultedColors.bgCard,
            borderRadius: VaultedRadii.brButton,
            border: Border.all(color: VaultedColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: VaultedColors.accentGold),
              const SizedBox(height: 6),
              Text(
                label,
                style: VaultedTypography.labelMicro.copyWith(
                  color: VaultedColors.accentGold,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
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

  static const _monthLabels = ['JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV'];

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
          Text('Balance History', style: VaultedTypography.headlineMedium),
          VaultedSpacing.gapLg,
          SizedBox(
            height: 160,
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
                    VaultedTypography.bodyMedium,
                  ),
                ),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No balance history',
                      style: VaultedTypography.secondary(
                        VaultedTypography.bodyMedium,
                      ),
                    ),
                  );
                }

                final reversed = transactions.reversed.toList();
                final spots = <FlSpot>[];
                for (var i = 0; i < reversed.length; i++) {
                  spots.add(FlSpot(i.toDouble(), reversed[i].balanceAfter));
                }

                return LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 24,
                          interval: 1,
                          getTitlesWidget: (value, _) {
                            final idx = value.toInt();
                            if (idx < 0 || idx >= _monthLabels.length) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _monthLabels[idx],
                                style: VaultedTypography.labelMicro.copyWith(
                                  color: VaultedColors.textMuted,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
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
                              VaultedColors.accentGold.withValues(alpha: 0.2),
                              VaultedColors.accentGold.withValues(alpha: 0.0),
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
    ).animate().fadeIn(duration: 400.ms, delay: 150.ms, curve: Curves.easeOut);
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

  Color get _iconBgColor => switch (tx.type) {
    TransactionType.purchase => VaultedColors.accentGoldDim,
    TransactionType.refund => VaultedColors.success.withValues(alpha: 0.12),
    TransactionType.balanceCheck => VaultedColors.info.withValues(alpha: 0.12),
    TransactionType.adjustment => VaultedColors.warning.withValues(alpha: 0.12),
    TransactionType.transfer => VaultedColors.accentGoldDim,
    _ => VaultedColors.accentGoldDim,
  };

  Color get _iconColor => switch (tx.type) {
    TransactionType.purchase => VaultedColors.accentGold,
    TransactionType.refund => VaultedColors.success,
    TransactionType.balanceCheck => VaultedColors.info,
    TransactionType.adjustment => VaultedColors.warning,
    TransactionType.transfer => VaultedColors.accentGold,
    _ => VaultedColors.accentGold,
  };

  Color get _amountColor {
    if (tx.type == TransactionType.refund) return VaultedColors.success;
    if (tx.amount < 0) return VaultedColors.danger;
    return VaultedColors.accentGold;
  }

  String get _typeLabel {
    if (tx.amount < 0) return 'DEBIT';
    return 'CREDIT';
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
              // Category icon in circle
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _iconColor, size: 18),
              ),
              const SizedBox(width: VaultedSpacing.md),

              // Merchant name + date/time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.merchant ??
                          tx.description ??
                          TransactionType.label(tx.type),
                      style: VaultedTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                        color: VaultedColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.dateTime(tx.createdAt),
                      style: VaultedTypography.labelSmall.copyWith(
                        color: VaultedColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount + DEBIT/CREDIT label
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currencySigned(tx.amount),
                    style: VaultedTypography.monoSmall.copyWith(
                      color: _amountColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _typeLabel,
                    style: VaultedTypography.labelMicro.copyWith(
                      color: VaultedColors.textMuted,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 200.ms, delay: (40 * index).ms, curve: Curves.easeOut)
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

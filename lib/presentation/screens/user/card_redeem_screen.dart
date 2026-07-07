import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/clipboard_manager.dart';
import '../../../core/utils/encryption.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../core/utils/screenshot_prevention.dart';
import '../../../core/utils/secure_storage.dart';
import '../../../data/models/card_model.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/card_providers.dart';
import '../../widgets/cards/card_visual.dart';

/// Screen for using / redeeming a gift card at checkout.
///
/// Displays card details prominently with copy actions and
/// a "Mark as Used" flow that records a purchase transaction.
class CardRedeemScreen extends ConsumerStatefulWidget {
  final String cardId;

  const CardRedeemScreen({super.key, required this.cardId});

  @override
  ConsumerState<CardRedeemScreen> createState() => _CardRedeemScreenState();
}

class _CardRedeemScreenState extends ConsumerState<CardRedeemScreen>
    with ScreenshotPreventionMixin {
  bool _showCardNumber = false;
  bool _showPin = false;
  String? _decryptedCardNumber;
  String? _decryptedPin;

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
      // Decryption failed — fields will remain null
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final card = ref.watch(cardByIdProvider(widget.cardId));

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
          // ── App Bar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 60,
            pinned: true,
            backgroundColor: VaultedColors.bgPrimary,
            title: Text(
              '${card.retailer} \u2014 Use Card',
              style: VaultedTypography.headlineLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // ── Card Visual ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: VaultedSpacing.xl),
              child:
                  CardVisual(card: card, showFullNumber: _showCardNumber)
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

          VaultedSpacing.gapXxl.toSliver,

          // ── Card Details (number + PIN) ────────────────────────
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
                    // Card Number (decrypted)
                    if (_decryptedCardNumber != null)
                      _InfoRow(
                        label: 'Card Number',
                        value: _showCardNumber
                            ? Formatters.groupCardDigits(
                                _decryptedCardNumber!)
                            : Formatters.maskCardNumber(
                                _decryptedCardNumber!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ActionIcon(
                              icon: _showCardNumber
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              onTap: () {
                                Haptics.lightTap();
                                setState(() =>
                                    _showCardNumber = !_showCardNumber);
                              },
                              tooltip:
                                  _showCardNumber ? 'Hide' : 'Reveal',
                            ),
                            const SizedBox(width: 4),
                            _ActionIcon(
                              icon: Icons.copy,
                              onTap: () {
                                VaultedClipboard.copyAndClear(
                                  context,
                                  _decryptedCardNumber!,
                                  label: 'Card number',
                                  timeout:
                                      const Duration(seconds: 30),
                                );
                              },
                              tooltip: 'Copy',
                            ),
                          ],
                        ),
                        mono: true,
                      )
                    else if (card.cardNumberEncrypted != null)
                      _InfoRow(
                        label: 'Card Number',
                        value: 'Decrypting...',
                        mono: true,
                      ),

                    // PIN (decrypted)
                    if (_decryptedPin != null) ...[
                      const Divider(color: VaultedColors.border),
                      _InfoRow(
                        label: 'PIN',
                        value: _showPin
                            ? _decryptedPin!
                            : '\u2022\u2022\u2022\u2022',
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
                                VaultedClipboard.copyAndClear(
                                  context,
                                  _decryptedPin!,
                                  label: 'PIN',
                                  timeout:
                                      const Duration(seconds: 30),
                                );
                              },
                              tooltip: 'Copy',
                            ),
                          ],
                        ),
                        mono: true,
                      ),
                    ] else if (card.pinEncrypted != null) ...[
                      const Divider(color: VaultedColors.border),
                      _InfoRow(
                        label: 'PIN',
                        value: 'Decrypting...',
                        mono: true,
                      ),
                    ],

                    // Balance
                    const Divider(color: VaultedColors.border),
                    _InfoRow(
                      label: 'Balance',
                      value: Formatters.currency(card.balance),
                      mono: true,
                    ),

                    // Status
                    const Divider(color: VaultedColors.border),
                    _InfoRow(
                      label: 'Status',
                      value: CardStatus.label(card.status),
                    ),
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

          // ── Mark as Used Button ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(VaultedSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: card.status == CardStatus.depleted
                      ? null
                      : () {
                          Haptics.mediumTap();
                          _showRecordPurchaseSheet(card);
                        },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18),
                  label: Text(
                    card.status == CardStatus.depleted
                        ? 'Card Depleted'
                        : 'Mark as Used',
                  ),
                ),
              )
                  .animate()
                  .fadeIn(
                    duration: 400.ms,
                    delay: 200.ms,
                    curve: Curves.easeOut,
                  ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  // ── Record Purchase Bottom Sheet ─────────────────────────────────

  void _showRecordPurchaseSheet(CardModel card) {
    final amountController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: VaultedColors.bgSecondary,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: VaultedRadii.brBottomSheet,
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            VaultedSpacing.xl,
            VaultedSpacing.md,
            VaultedSpacing.xl,
            MediaQuery.of(ctx).viewInsets.bottom + VaultedSpacing.xxxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: VaultedColors.accentGoldDim,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: VaultedColors.accentGold,
                  size: 28,
                ),
              ),
              VaultedSpacing.gapLg,
              Text(
                'Record Purchase',
                style: VaultedTypography.headlineMedium,
              ),
              VaultedSpacing.gapSm,
              Text(
                'How much did you spend on ${card.retailer}?',
                style: VaultedTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              VaultedSpacing.gapXl,
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: VaultedTypography.monoLarge.copyWith(
                  color: VaultedColors.accentGold,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: VaultedTypography.monoLarge.copyWith(
                    color: VaultedColors.textMuted,
                  ),
                  prefixText: '\$ ',
                  prefixStyle: VaultedTypography.monoLarge.copyWith(
                    color: VaultedColors.accentGold,
                  ),
                ),
              ),
              VaultedSpacing.gapSm,
              Text(
                'Available: ${Formatters.currency(card.balance)}',
                style: VaultedTypography.labelSmall,
              ),
              VaultedSpacing.gapXxl,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final amountText =
                              amountController.text.trim();
                          final amount =
                              double.tryParse(amountText);

                          if (amount == null || amount <= 0) {
                            Haptics.error();
                            return;
                          }

                          if (amount > card.balance) {
                            Haptics.error();
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx)
                                ..clearSnackBars()
                                ..showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Amount exceeds balance'),
                                  ),
                                );
                            }
                            return;
                          }

                          setSheetState(
                              () => isSubmitting = true);
                          await _recordPurchase(
                              card, amount);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: VaultedColors.bgPrimary,
                          ),
                        )
                      : const Text('Record Purchase'),
                ),
              ),
              VaultedSpacing.gapMd,
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Firestore write ──────────────────────────────────────────────

  Future<void> _recordPurchase(CardModel card, double amount) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final firestore = FirebaseFirestore.instance;
      final cardRef = firestore
          .collection('users')
          .doc(uid)
          .collection('cards')
          .doc(card.id);

      // Use a Firestore transaction to prevent race conditions on balance
      await firestore.runTransaction((transaction) async {
        final cardSnap = await transaction.get(cardRef);
        if (!cardSnap.exists) {
          throw Exception('Card not found');
        }

        final currentBalance =
            (cardSnap.data()?['balance'] as num?)?.toDouble() ?? 0.0;
        if (amount > currentBalance) {
          throw Exception('Insufficient balance');
        }

        final newBalance = currentBalance - amount;
        final isDepleted = newBalance <= 0;

        // Create transaction doc
        final txRef = firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .doc();

        transaction.set(txRef, {
          'cardId': card.id,
          'retailer': card.retailer,
          'type': TransactionType.purchase,
          'amount': -amount,
          'balanceAfter': isDepleted ? 0.0 : newBalance,
          'description': 'Purchase at ${card.retailer}',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Update card balance atomically
        transaction.update(cardRef, {
          'balance': isDepleted ? 0.0 : newBalance,
          'status': isDepleted
              ? CardStatus.depleted
              : cardSnap.data()?['status'] ?? card.status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      final newBalance = card.balance - amount;
      final isDepleted = newBalance <= 0;

      Haptics.success();

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(
                isDepleted
                    ? 'Card depleted \u2014 ${Formatters.currency(amount)} spent'
                    : '${Formatters.currency(amount)} recorded \u2014 ${Formatters.currency(newBalance)} remaining',
              ),
            ),
          );
        context.pop();
      }
    } catch (e) {
      Haptics.error();
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Failed to record purchase. Please try again.'),
            ),
          );
      }
    }
  }
}

// ── Info row ────────────────────────────────────────────────────────

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

// ── Action icon button ──────────────────────────────────────────────

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

// ── SizedBox to sliver extension ────────────────────────────────────

extension on SizedBox {
  SliverToBoxAdapter get toSliver => SliverToBoxAdapter(child: this);
}

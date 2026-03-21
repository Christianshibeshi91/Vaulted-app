import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/transaction_model.dart';

/// Full detail view for a single transaction.
class TransactionDetailScreen extends ConsumerWidget {
  final String txId;

  const TransactionDetailScreen({super.key, required this.txId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return _buildError('Not authenticated');
    }

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .doc(txId)
            .get(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }

          // Error state
          if (snapshot.hasError) {
            return _buildError('Failed to load transaction');
          }

          // Not found state
          final doc = snapshot.data;
          if (doc == null || !doc.exists || doc.data() == null) {
            return _buildNotFound(context);
          }

          final data = doc.data()!;
          data['id'] = doc.id;
          final tx = TransactionModel.fromJson(data);

          return _buildContent(context, tx);
        },
      ),
    );
  }

  // ── Content ──────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context, TransactionModel tx) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 60,
          pinned: true,
          backgroundColor: VaultedColors.bgPrimary,
          title: Text('Transaction', style: VaultedTypography.headlineLarge),
        ),

        // ── Amount display ─────────────────────────────────────────
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
                    Formatters.currencySigned(tx.amount),
                    style: VaultedTypography.displayLarge.copyWith(
                      fontSize: 42,
                      color: _amountColor(tx),
                    ),
                  ),
                  VaultedSpacing.gapSm,
                  _TypeBadge(type: tx.type),
                ],
              ),
            ),
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

        // ── Info card ──────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: VaultedSpacing.xl),
            child: Container(
              padding: VaultedSpacing.cardInner,
              decoration: BoxDecoration(
                color: VaultedColors.bgCard,
                borderRadius: VaultedRadii.brCard,
                border: Border.all(color: VaultedColors.border),
              ),
              child: Column(
                children: [
                  _InfoRow(
                    label: 'Type',
                    value: TransactionType.label(tx.type),
                  ),
                  const Divider(color: VaultedColors.border),
                  _InfoRow(
                    label: 'Amount',
                    value: Formatters.currencySigned(tx.amount),
                    mono: true,
                  ),
                  const Divider(color: VaultedColors.border),
                  _InfoRow(
                    label: 'Balance After',
                    value: Formatters.currency(tx.balanceAfter),
                    mono: true,
                  ),
                  const Divider(color: VaultedColors.border),
                  _InfoRow(
                    label: 'Card / Retailer',
                    value: tx.retailer,
                  ),
                  if (tx.merchant != null && tx.merchant!.isNotEmpty) ...[
                    const Divider(color: VaultedColors.border),
                    _InfoRow(
                      label: 'Merchant',
                      value: tx.merchant!,
                    ),
                  ],
                  if (tx.description != null &&
                      tx.description!.isNotEmpty) ...[
                    const Divider(color: VaultedColors.border),
                    _InfoRow(
                      label: 'Description',
                      value: tx.description!,
                    ),
                  ],
                  const Divider(color: VaultedColors.border),
                  _InfoRow(
                    label: 'Date',
                    value: Formatters.dateTime(tx.createdAt),
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

        // Bottom padding
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  // ── States ───────────────────────────────────────────────────────

  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: VaultedColors.bgPrimary,
        title: Text('Transaction', style: VaultedTypography.headlineLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(VaultedSpacing.xl),
        child: Column(
          children: List.generate(
            4,
            (i) => Container(
              height: 56,
              margin: const EdgeInsets.only(bottom: VaultedSpacing.sm),
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
    );
  }

  Widget _buildError(String message) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(backgroundColor: VaultedColors.bgPrimary),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: VaultedColors.danger, size: 48),
            VaultedSpacing.gapMd,
            Text(
              message,
              style: VaultedTypography.headlineMedium.copyWith(
                color: VaultedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(backgroundColor: VaultedColors.bgPrimary),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined,
                color: VaultedColors.textMuted, size: 48),
            VaultedSpacing.gapMd,
            Text(
              'Transaction not found',
              style: VaultedTypography.headlineMedium.copyWith(
                color: VaultedColors.textSecondary,
              ),
            ),
            VaultedSpacing.gapLg,
            TextButton(
              onPressed: () {
                Haptics.lightTap();
                Navigator.of(context).pop();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────

  Color _amountColor(TransactionModel tx) {
    if (tx.type == TransactionType.refund || tx.amount > 0) {
      return VaultedColors.success;
    }
    if (tx.amount < 0) return VaultedColors.danger;
    return VaultedColors.textPrimary;
  }
}

// ── Type badge ──────────────────────────────────────────────────────

class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({required this.type});

  Color get _color => switch (type) {
        TransactionType.purchase => VaultedColors.danger,
        TransactionType.refund => VaultedColors.success,
        TransactionType.balanceCheck => VaultedColors.info,
        TransactionType.adjustment => VaultedColors.warning,
        TransactionType.transfer => VaultedColors.accentGold,
        _ => VaultedColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VaultedSpacing.md,
        vertical: VaultedSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: VaultedRadii.brPill,
        border: Border.all(color: _color.withValues(alpha: 0.25)),
      ),
      child: Text(
        TransactionType.label(type),
        style: VaultedTypography.labelSmall.copyWith(
          color: _color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Info row ────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool mono;

  const _InfoRow({
    required this.label,
    required this.value,
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
        ],
      ),
    );
  }
}

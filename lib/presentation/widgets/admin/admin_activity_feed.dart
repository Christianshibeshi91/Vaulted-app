import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';

/// Live activity feed streaming from Firestore audit log.
///
/// Renders a flat list of activity rows with colored icons, titles,
/// subtitles, and relative timestamps. No card wrapper -- the parent
/// controls the container.
class AdminActivityFeed extends StatelessWidget {
  final int limit;

  const AdminActivityFeed({
    super.key,
    this.limit = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        VaultedSpacing.gapMd,
        _buildStream(),
        VaultedSpacing.gapLg,
        _buildAuditLogButton(context),
      ],
    );
  }

  // ── Header ───────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          'Live Activity',
          style: VaultedTypography.headlineLarge,
        ),
        const SizedBox(width: 10),
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: VaultedColors.success,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  // ── Stream ───────────────────────────────────────────────────

  Widget _buildStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('admin')
          .doc('auditLog')
          .collection('entries')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildEmpty(
            icon: Icons.error_outline,
            label: 'Feed unavailable',
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmpty(
            icon: Icons.rss_feed,
            label: 'No recent activity',
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: docs.length,
          separatorBuilder: (_, _) => Divider(
            color: VaultedColors.border,
            height: 1,
            thickness: 1,
          ),
          itemBuilder: (_, index) => _buildActivityRow(docs[index]),
        );
      },
    );
  }

  // ── Single Activity Row ──────────────────────────────────────

  Widget _buildActivityRow(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final type = _resolveType(data);
    final meta = _metaForType(type);

    final title = data['title'] as String? ?? meta.fallbackTitle;
    final subtitle = data['subtitle'] as String? ?? meta.fallbackSubtitle;
    final timestamp = data['timestamp'] as Timestamp?;
    final time = timestamp != null
        ? Formatters.relativeTime(timestamp.toDate())
        : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VaultedSpacing.md),
      child: Row(
        children: [
          // Colored circle icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              meta.icon,
              size: 20,
              color: meta.color,
            ),
          ),
          VaultedSpacing.gapHMd,

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: VaultedTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle.toUpperCase(),
                  style: VaultedTypography.labelMicro.copyWith(
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          VaultedSpacing.gapHSm,

          // Relative time
          Text(
            time,
            style: VaultedTypography.labelSmall.copyWith(
              color: VaultedColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty State ──────────────────────────────────────────────

  Widget _buildEmpty({required IconData icon, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: VaultedSpacing.xxl),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: VaultedColors.textMuted, size: 28),
            VaultedSpacing.gapSm,
            Text(
              label,
              style: VaultedTypography.muted(VaultedTypography.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }

  // ── Audit Log Button ─────────────────────────────────────────

  Widget _buildAuditLogButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: () => context.go('/admin/audit-log'),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: VaultedColors.accentGold, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'VIEW COMPLETE AUDIT LOG',
          style: VaultedTypography.buttonLabel(uppercase: true).copyWith(
            color: VaultedColors.accentGold,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  // ── Activity Type Resolution ─────────────────────────────────

  _ActivityType _resolveType(Map<String, dynamic> data) {
    final action = (data['action'] as String? ?? '').toLowerCase();
    final type = (data['type'] as String? ?? '').toLowerCase();

    if (type.contains('register') || action.contains('register')) {
      return _ActivityType.userRegistered;
    }
    if (type.contains('card') || action.contains('card')) {
      return _ActivityType.cardActivated;
    }
    if (type.contains('deposit') ||
        type.contains('transfer') ||
        action.contains('deposit') ||
        action.contains('transfer')) {
      return _ActivityType.deposit;
    }
    if (type.contains('flag') ||
        type.contains('fraud') ||
        action.contains('flag') ||
        action.contains('fraud') ||
        action.contains('suspicious')) {
      return _ActivityType.flagged;
    }
    return _ActivityType.userRegistered;
  }

  _ActivityMeta _metaForType(_ActivityType type) {
    return switch (type) {
      _ActivityType.userRegistered => const _ActivityMeta(
          icon: Icons.people,
          color: Color(0xFF3B82F6),
          fallbackTitle: 'New user registered',
          fallbackSubtitle: 'Verification pending',
        ),
      _ActivityType.cardActivated => const _ActivityMeta(
          icon: Icons.credit_card,
          color: Color(0xFFF59E0B),
          fallbackTitle: 'Card activated',
          fallbackSubtitle: 'Virtual card issued',
        ),
      _ActivityType.deposit => const _ActivityMeta(
          icon: Icons.account_balance_wallet,
          color: Color(0xFF22C55E),
          fallbackTitle: 'Deposit received',
          fallbackSubtitle: 'Direct bank transfer',
        ),
      _ActivityType.flagged => const _ActivityMeta(
          icon: Icons.warning,
          color: Color(0xFFEF4444),
          fallbackTitle: 'Flagged transaction',
          fallbackSubtitle: 'Review required',
        ),
    };
  }
}

// ── Private Types ────────────────────────────────────────────────

enum _ActivityType {
  userRegistered,
  cardActivated,
  deposit,
  flagged,
}

class _ActivityMeta {
  final IconData icon;
  final Color color;
  final String fallbackTitle;
  final String fallbackSubtitle;

  const _ActivityMeta({
    required this.icon,
    required this.color,
    required this.fallbackTitle,
    required this.fallbackSubtitle,
  });
}

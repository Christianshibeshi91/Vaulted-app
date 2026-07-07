import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/audit_entry_model.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';

/// Detailed admin view of a single user.
class AdminUserDetailScreen extends ConsumerWidget {
  final String uid;

  const AdminUserDetailScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userByUidProvider(uid));
    final currentAdmin = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Text(
                'User not found',
                style: VaultedTypography.muted(VaultedTypography.bodyLarge),
              ),
            );
          }

          return ListView(
            padding: VaultedSpacing.screenH.copyWith(
              top: VaultedSpacing.xl,
              bottom: VaultedSpacing.section,
            ),
            children: [
              // ── Profile card ─────────────────────────────────
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: VaultedColors.bgCard,
                  borderRadius: VaultedRadii.brCard,
                  border: Border.all(color: VaultedColors.borderStrong),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: VaultedColors.accentGoldDim,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? Text(
                              (user.displayName ?? user.email)
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: VaultedTypography.gold(
                                  VaultedTypography.displayMedium),
                            )
                          : null,
                    ),
                    VaultedSpacing.gapMd,
                    Text(
                      user.displayName ?? 'No Name',
                      style: VaultedTypography.headlineLarge,
                    ),
                    VaultedSpacing.gapXs,
                    Text(
                      user.email,
                      style: VaultedTypography.secondary(
                          VaultedTypography.bodyMedium),
                    ),
                    VaultedSpacing.gapMd,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _InfoChip(
                          label: user.role.toUpperCase(),
                          color: VaultedColors.info,
                        ),
                        VaultedSpacing.gapHSm,
                        _InfoChip(
                          label: user.plan.toUpperCase(),
                          color: user.plan == 'premium'
                              ? VaultedColors.accentGold
                              : VaultedColors.textMuted,
                        ),
                        if (user.isSuspended) ...[
                          VaultedSpacing.gapHSm,
                          _InfoChip(
                            label: 'SUSPENDED',
                            color: VaultedColors.danger,
                          ),
                        ],
                      ],
                    ),
                    if (user.createdAt != null) ...[
                      VaultedSpacing.gapMd,
                      Text(
                        'Member since ${Formatters.dateFull(user.createdAt!)}',
                        style: VaultedTypography.muted(
                            VaultedTypography.labelSmall),
                      ),
                    ],
                  ],
                ),
              ),

              VaultedSpacing.gapLg,

              // ── Stats row ────────────────────────────────────
              _StatsRow(uid: uid),

              VaultedSpacing.gapLg,

              // ── User cards (collapsible) ─────────────────────
              _CollapsibleSection(
                title: 'Gift Cards',
                icon: Icons.credit_card_outlined,
                child: _UserCardsSection(uid: uid),
              ),

              VaultedSpacing.gapMd,

              // ── Transactions (collapsible) ──────────────────
              _CollapsibleSection(
                title: 'Transactions',
                icon: Icons.receipt_long_outlined,
                child: _UserTransactionsSection(uid: uid),
              ),

              VaultedSpacing.gapXl,

              // ── Action buttons ──────────────────────────────
              Text(
                'ADMIN ACTIONS',
                style: VaultedTypography.gold(VaultedTypography.labelSmall)
                    .copyWith(letterSpacing: 1.5),
              ),
              VaultedSpacing.gapMd,

              _ActionButton(
                icon: user.isSuspended
                    ? Icons.play_arrow_outlined
                    : Icons.block_outlined,
                label: user.isSuspended ? 'Unsuspend User' : 'Suspend User',
                color: user.isSuspended
                    ? VaultedColors.success
                    : VaultedColors.warning,
                onTap: () => _toggleSuspend(
                  context,
                  ref,
                  user.isSuspended,
                  currentAdmin.valueOrNull,
                ),
              ),
              VaultedSpacing.gapSm,
              _ActionButton(
                icon: Icons.flag_outlined,
                label: 'Flag for Review',
                color: VaultedColors.warning,
                onTap: () => _performAction(
                  context,
                  ref,
                  AuditAction.flagUser,
                  'User flagged for review',
                  currentAdmin.valueOrNull,
                ),
              ),
              VaultedSpacing.gapSm,
              _ActionButton(
                icon: Icons.lock_reset_outlined,
                label: 'Reset Password',
                color: VaultedColors.info,
                onTap: () => _performAction(
                  context,
                  ref,
                  AuditAction.resetPassword,
                  'Password reset email sent',
                  currentAdmin.valueOrNull,
                ),
              ),
              VaultedSpacing.gapSm,
              _ActionButton(
                icon: user.plan == 'premium'
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                label: user.plan == 'premium'
                    ? 'Downgrade to Free'
                    : 'Upgrade to Premium',
                color: VaultedColors.accentGold,
                onTap: () => _togglePlan(
                  context,
                  ref,
                  user.plan,
                  currentAdmin.valueOrNull,
                ),
              ),
              VaultedSpacing.gapSm,
              _ActionButton(
                icon: Icons.note_add_outlined,
                label: 'Add Admin Note',
                color: VaultedColors.textSecondary,
                onTap: () => _addNote(context, ref, currentAdmin.valueOrNull),
              ),
              VaultedSpacing.gapLg,
              _ActionButton(
                icon: Icons.delete_outline,
                label: 'Delete User',
                color: VaultedColors.danger,
                onTap: () => _deleteUser(
                  context,
                  ref,
                  currentAdmin.valueOrNull,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: VaultedColors.accentGold,
            strokeWidth: 2,
          ),
        ),
        error: (e, _) => Center(
          child: Text(
            'Error loading user',
            style: VaultedTypography.muted(VaultedTypography.bodyLarge),
          ),
        ),
      ),
    );
  }

  // ── Admin actions ─────────────────────────────────────────────

  Future<void> _logAction(
    WidgetRef ref,
    String action,
    dynamic admin,
  ) async {
    final entry = AuditEntryModel(
      id: const Uuid().v4(),
      adminUid: admin?.uid ?? 'unknown',
      adminEmail: admin?.email ?? 'unknown',
      adminDisplayName: admin?.displayName,
      action: action,
      targetType: 'user',
      targetId: uid,
      timestamp: DateTime.now(),
    );
    await writeAuditLog(entry);
  }

  void _showConfirmation(BuildContext context, String message) {
    Haptics.success();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: VaultedColors.success, size: 18),
            VaultedSpacing.gapHSm,
            Expanded(child: Text(message)),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _toggleSuspend(
    BuildContext context,
    WidgetRef ref,
    bool currentlySuspended,
    dynamic admin,
  ) async {
    final action = currentlySuspended
        ? AuditAction.unsuspendUser
        : AuditAction.suspendUser;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'isSuspended': !currentlySuspended});
    await _logAction(ref, action, admin);
    if (context.mounted) {
      _showConfirmation(
        context,
        currentlySuspended ? 'User unsuspended' : 'User suspended',
      );
    }
  }

  Future<void> _togglePlan(
    BuildContext context,
    WidgetRef ref,
    String currentPlan,
    dynamic admin,
  ) async {
    final newPlan = currentPlan == 'premium' ? 'free' : 'premium';
    final action = currentPlan == 'premium'
        ? AuditAction.downgradePlan
        : AuditAction.upgradePlan;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'plan': newPlan});
    await _logAction(ref, action, admin);
    if (context.mounted) {
      _showConfirmation(context, 'Plan changed to $newPlan');
    }
  }

  Future<void> _performAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    String message,
    dynamic admin,
  ) async {
    await _logAction(ref, action, admin);
    if (context.mounted) {
      _showConfirmation(context, message);
    }
  }

  Future<void> _addNote(
    BuildContext context,
    WidgetRef ref,
    dynamic admin,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Admin Note'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: VaultedTypography.bodyLarge,
          decoration: const InputDecoration(
            hintText: 'Enter note...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result != null && result.trim().isNotEmpty && context.mounted) {
      await _logAction(ref, AuditAction.addAdminNote, admin);
      if (context.mounted) {
        _showConfirmation(context, 'Note added to audit log');
      }
    }
  }

  Future<void> _deleteUser(
    BuildContext context,
    WidgetRef ref,
    dynamic admin,
  ) async {
    Haptics.warning();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'This action is irreversible. Are you sure?',
          style: VaultedTypography.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultedColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Call the deleteUserCascade cloud function for proper cleanup
        final functions = FirebaseFunctions.instance;
        await functions.httpsCallable('deleteUserCascade').call({
          'targetUid': uid,
        });
        await _logAction(ref, AuditAction.deleteUser, admin);
        if (context.mounted) {
          Haptics.heavyTap();
          _showConfirmation(context, 'User deleted successfully');
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (context.mounted) {
          Haptics.error();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete user: $e')),
          );
        }
      }
    }
  }
}

// ── Supporting widgets ────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: VaultedRadii.brBadge,
      ),
      child: Text(
        label,
        style: VaultedTypography.labelMicro.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String uid;

  const _StatsRow({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users/$uid/cards')
          .snapshots(),
      builder: (context, snap) {
        final cardCount = snap.data?.size ?? 0;
        var totalBalance = 0.0;
        if (snap.hasData) {
          for (final doc in snap.data!.docs) {
            totalBalance +=
                ((doc.data() as Map<String, dynamic>?)?['balance'] as num?)
                    ?.toDouble() ??
                0.0;
          }
        }

        return Row(
          children: [
            _StatTile(
              label: 'Cards',
              value: '$cardCount',
              icon: Icons.credit_card,
            ),
            VaultedSpacing.gapHSm,
            _StatTile(
              label: 'Balance',
              value: Formatters.currencyCompact(totalBalance),
              icon: Icons.account_balance_wallet,
            ),
            VaultedSpacing.gapHSm,
            _StatTile(
              label: 'Logins',
              value: '--',
              icon: Icons.login,
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: VaultedColors.bgCard,
          borderRadius: VaultedRadii.brCard,
          border: Border.all(color: VaultedColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: VaultedColors.textMuted),
            VaultedSpacing.gapSm,
            Text(value, style: VaultedTypography.monoMedium),
            VaultedSpacing.gapXs,
            Text(
              label,
              style: VaultedTypography.muted(VaultedTypography.labelMicro),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsibleSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _CollapsibleSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        tilePadding: VaultedSpacing.cardInner,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        collapsedIconColor: VaultedColors.textMuted,
        iconColor: VaultedColors.accentGold,
        backgroundColor: VaultedColors.bgCard,
        collapsedBackgroundColor: VaultedColors.bgCard,
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon, color: VaultedColors.accentGold, size: 20),
        title: Text(
          title,
          style: VaultedTypography.bodyLarge
              .copyWith(fontWeight: FontWeight.w600),
        ),
        children: [child],
      ),
    );
  }
}

class _UserCardsSection extends StatelessWidget {
  final String uid;

  const _UserCardsSection({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users/$uid/cards')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No cards found',
              style: VaultedTypography.muted(VaultedTypography.bodyMedium),
            ),
          );
        }

        return Column(
          children: snap.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: VaultedColors.bgInput,
                  borderRadius: VaultedRadii.brBadge,
                ),
                child: const Icon(
                  Icons.credit_card,
                  size: 16,
                  color: VaultedColors.textMuted,
                ),
              ),
              title: Text(
                d['retailer'] as String? ?? 'Unknown',
                style: VaultedTypography.bodyMedium
                    .copyWith(color: VaultedColors.textPrimary),
              ),
              subtitle: Text(
                d['status'] as String? ?? '',
                style: VaultedTypography.labelMicro,
              ),
              trailing: Text(
                Formatters.currency(
                    (d['balance'] as num?)?.toDouble() ?? 0),
                style: VaultedTypography.monoSmall,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _UserTransactionsSection extends StatelessWidget {
  final String uid;

  const _UserTransactionsSection({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users/$uid/transactions')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No transactions collection',
              style: VaultedTypography.muted(VaultedTypography.bodyMedium),
            ),
          );
        }

        if (!snap.hasData || snap.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No transactions found',
              style: VaultedTypography.muted(VaultedTypography.bodyMedium),
            ),
          );
        }

        return Column(
          children: snap.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            final amount = (d['amount'] as num?)?.toDouble() ?? 0;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                amount >= 0 ? Icons.add_circle_outline : Icons.remove_circle_outline,
                size: 18,
                color: amount >= 0 ? VaultedColors.success : VaultedColors.danger,
              ),
              title: Text(
                d['description'] as String? ?? 'Transaction',
                style: VaultedTypography.bodyMedium
                    .copyWith(color: VaultedColors.textPrimary),
              ),
              trailing: Text(
                Formatters.currencySigned(amount),
                style: VaultedTypography.monoSmall.copyWith(
                  color: amount >= 0
                      ? VaultedColors.success
                      : VaultedColors.danger,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: VaultedRadii.brButton,
        splashColor: color.withValues(alpha: 0.1),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: VaultedColors.bgCard,
            borderRadius: VaultedRadii.brButton,
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              VaultedSpacing.gapHMd,
              Expanded(
                child: Text(
                  label,
                  style: VaultedTypography.bodyLarge.copyWith(color: color),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

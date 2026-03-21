import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/audit_entry_model.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/admin/admin_transaction_item.dart';

/// Filter state for transactions.
final _txFilterProvider = StateProvider<String>((_) => 'all');

/// Admin transactions screen with filter and inline actions.
class AdminTransactionsScreen extends ConsumerWidget {
  const AdminTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_txFilterProvider);
    final admin = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: Column(
        children: [
          // ── Filter pills ────────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              children: [
                for (final f in ['all', 'pending', 'completed', 'flagged'])
                  _FilterChip(
                    label: f[0].toUpperCase() + f.substring(1),
                    isActive: filter == f,
                    onTap: () =>
                        ref.read(_txFilterProvider.notifier).state = f,
                  ),
              ],
            ),
          ),

          VaultedSpacing.gapSm,

          // ── Transaction list ────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery(filter),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: VaultedColors.accentGold,
                      strokeWidth: 2,
                    ),
                  );
                }

                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          color: VaultedColors.textMuted,
                          size: 40,
                        ),
                        VaultedSpacing.gapMd,
                        Text(
                          'No transactions found',
                          style: VaultedTypography.muted(
                              VaultedTypography.bodyLarge),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => VaultedSpacing.gapSm,
                  itemBuilder: (_, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>;
                    final docId = docs[index].id;
                    final status = data['status'] as String? ?? 'pending';

                    return AdminTransactionItem(
                      id: docId,
                      userDisplayName:
                          data['userDisplayName'] as String? ?? 'Unknown',
                      userAvatarUrl: data['userAvatarUrl'] as String?,
                      description:
                          data['description'] as String? ?? 'Transaction',
                      amount:
                          (data['amount'] as num?)?.toDouble() ?? 0,
                      status: status,
                      timestamp: (data['timestamp'] as Timestamp?)
                              ?.toDate() ??
                          DateTime.now(),
                      onApprove: status == 'flagged'
                          ? () => _handleAction(
                                context,
                                ref,
                                docId,
                                'completed',
                                AuditAction.approveTransaction,
                                'Transaction approved',
                                admin,
                              )
                          : null,
                      onReject: status == 'flagged'
                          ? () => _handleAction(
                                context,
                                ref,
                                docId,
                                'rejected',
                                AuditAction.rejectTransaction,
                                'Transaction rejected',
                                admin,
                              )
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _buildQuery(String filter) {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('admin')
        .doc('transactions')
        .collection('items')
        .orderBy('timestamp', descending: true)
        .limit(100);

    if (filter != 'all') {
      query = query.where('status', isEqualTo: filter);
    }

    return query.snapshots();
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    String txId,
    String newStatus,
    String action,
    String message,
    dynamic admin,
  ) async {
    await FirebaseFirestore.instance
        .collection('admin')
        .doc('transactions')
        .collection('items')
        .doc(txId)
        .update({'status': newStatus});

    final entry = AuditEntryModel(
      id: const Uuid().v4(),
      adminUid: admin?.uid ?? 'unknown',
      adminEmail: admin?.email ?? 'unknown',
      action: action,
      targetType: 'transaction',
      targetId: txId,
      timestamp: DateTime.now(),
    );
    await writeAuditLog(entry);

    if (context.mounted) {
      Haptics.success();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: VaultedColors.success, size: 18),
              VaultedSpacing.gapHSm,
              Text(message),
            ],
          ),
        ),
      );
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: VaultedSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: VaultedRadii.brPill,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive
                  ? VaultedColors.accentGoldDim
                  : VaultedColors.bgInput,
              borderRadius: VaultedRadii.brPill,
              border: Border.all(
                color: isActive
                    ? VaultedColors.accentGold
                    : VaultedColors.border,
              ),
            ),
            child: Text(
              label,
              style: VaultedTypography.bodyMedium.copyWith(
                color: isActive
                    ? VaultedColors.accentGold
                    : VaultedColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

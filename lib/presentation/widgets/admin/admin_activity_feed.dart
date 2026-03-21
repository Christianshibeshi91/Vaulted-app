import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';

/// Live activity feed streaming from Firestore audit log.
class AdminActivityFeed extends StatelessWidget {
  final int limit;
  final double height;

  const AdminActivityFeed({
    super.key,
    this.limit = 15,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(color: VaultedColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: VaultedColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                VaultedSpacing.gapHSm,
                Text(
                  'LIVE FEED',
                  style:
                      VaultedTypography.gold(VaultedTypography.labelSmall)
                          .copyWith(letterSpacing: 1.5),
                ),
              ],
            ),
          ),
          VaultedSpacing.gapSm,
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('admin')
                  .doc('auditLog')
                  .collection('entries')
                  .orderBy('timestamp', descending: true)
                  .limit(limit)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Feed unavailable',
                      style: VaultedTypography.muted(
                          VaultedTypography.bodyMedium),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.rss_feed,
                          color: VaultedColors.textMuted,
                          size: 28,
                        ),
                        VaultedSpacing.gapSm,
                        Text(
                          'No recent activity',
                          style: VaultedTypography.muted(
                              VaultedTypography.bodyMedium),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const Divider(
                    color: VaultedColors.border,
                    height: 1,
                  ),
                  itemBuilder: (_, index) {
                    final data =
                        docs[index].data() as Map<String, dynamic>? ?? {};
                    final action = data['action'] as String? ?? '';
                    final admin =
                        data['adminEmail'] as String? ?? 'System';
                    final timestamp = data['timestamp'] as Timestamp?;
                    final time = timestamp != null
                        ? Formatters.relativeTime(timestamp.toDate())
                        : '';

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            _iconForAction(action),
                            size: 16,
                            color: VaultedColors.textMuted,
                          ),
                          VaultedSpacing.gapHSm,
                          Expanded(
                            child: Text(
                              '$admin: $action',
                              style: VaultedTypography.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            time,
                            style: VaultedTypography.labelMicro,
                          ),
                        ],
                      ),
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

  IconData _iconForAction(String action) {
    if (action.contains('suspend')) return Icons.block;
    if (action.contains('flag')) return Icons.flag_outlined;
    if (action.contains('delete')) return Icons.delete_outline;
    if (action.contains('approve')) return Icons.check_circle_outline;
    if (action.contains('reject')) return Icons.cancel_outlined;
    if (action.contains('toggle')) return Icons.toggle_on_outlined;
    if (action.contains('setting')) return Icons.settings_outlined;
    if (action.contains('upgrade')) return Icons.arrow_upward;
    if (action.contains('downgrade')) return Icons.arrow_downward;
    return Icons.history;
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';

/// Transaction list item with optional inline Approve/Reject actions.
class AdminTransactionItem extends StatelessWidget {
  final String id;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String description;
  final double amount;
  final String status; // pending, completed, flagged, rejected
  final DateTime timestamp;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const AdminTransactionItem({
    super.key,
    required this.id,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.description,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.onApprove,
    this.onReject,
  });

  bool get _isFlagged => status == 'flagged';

  Color get _statusColor => switch (status) {
        'completed' => VaultedColors.success,
        'pending' => VaultedColors.warning,
        'flagged' => VaultedColors.danger,
        'rejected' => VaultedColors.textMuted,
        _ => VaultedColors.textSecondary,
      };

  String get _statusLabel => switch (status) {
        'completed' => 'Completed',
        'pending' => 'Pending',
        'flagged' => 'Flagged',
        'rejected' => 'Rejected',
        _ => status,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: VaultedSpacing.cardInner,
      decoration: BoxDecoration(
        color: VaultedColors.bgCard,
        borderRadius: VaultedRadii.brCard,
        border: Border.all(
          color: _isFlagged ? VaultedColors.danger.withValues(alpha: 0.3) : VaultedColors.border,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: VaultedColors.accentGoldDim,
                backgroundImage: userAvatarUrl != null
                    ? NetworkImage(userAvatarUrl!)
                    : null,
                child: userAvatarUrl == null
                    ? Text(
                        userDisplayName.isNotEmpty
                            ? userDisplayName[0].toUpperCase()
                            : '?',
                        style: VaultedTypography.gold(
                            VaultedTypography.labelSmall),
                      )
                    : null,
              ),

              VaultedSpacing.gapHMd,

              // Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      description,
                      style: VaultedTypography.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    VaultedSpacing.gapXs,
                    Text(
                      '$userDisplayName  ${Formatters.relativeTime(timestamp)}',
                      style: VaultedTypography.labelMicro,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              VaultedSpacing.gapHSm,

              // Amount + status
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.currency(amount),
                    style: VaultedTypography.monoMedium,
                  ),
                  VaultedSpacing.gapXs,
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.12),
                      borderRadius: VaultedRadii.brBadge,
                    ),
                    child: Text(
                      _statusLabel,
                      style: VaultedTypography.labelMicro.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Inline actions for flagged transactions
          if (_isFlagged && (onApprove != null || onReject != null)) ...[
            VaultedSpacing.gapMd,
            const Divider(color: VaultedColors.border, height: 1),
            VaultedSpacing.gapSm,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onReject != null)
                  SizedBox(
                    height: 44,
                    child: TextButton.icon(
                      onPressed: () {
                        Haptics.warning();
                        onReject!();
                      },
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: TextButton.styleFrom(
                        foregroundColor: VaultedColors.danger,
                      ),
                    ),
                  ),
                VaultedSpacing.gapHMd,
                if (onApprove != null)
                  SizedBox(
                    height: 44,
                    child: TextButton.icon(
                      onPressed: () {
                        Haptics.success();
                        onApprove!();
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: TextButton.styleFrom(
                        foregroundColor: VaultedColors.success,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../data/models/user_model.dart';

/// List tile for a user in the admin users screen.
class AdminUserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const AdminUserListItem({
    super.key,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: VaultedRadii.brCard,
        splashColor: VaultedColors.accentGoldDim,
        child: Container(
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
              // Avatar
              CircleAvatar(
                radius: 22,
                backgroundColor: VaultedColors.accentGoldDim,
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        _initials,
                        style: VaultedTypography.gold(
                            VaultedTypography.labelSmall),
                      )
                    : null,
              ),

              VaultedSpacing.gapHMd,

              // Name + email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'No Name',
                      style: VaultedTypography.bodyLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    VaultedSpacing.gapXs,
                    Text(
                      user.email,
                      style: VaultedTypography.muted(
                          VaultedTypography.labelSmall),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              VaultedSpacing.gapHSm,

              // Status + plan badges
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusBadge(
                    label: user.isSuspended ? 'Suspended' : 'Active',
                    color: user.isSuspended
                        ? VaultedColors.danger
                        : VaultedColors.success,
                  ),
                  VaultedSpacing.gapXs,
                  _StatusBadge(
                    label: user.plan.toUpperCase(),
                    color: user.plan == 'premium'
                        ? VaultedColors.accentGold
                        : VaultedColors.textMuted,
                  ),
                ],
              ),

              VaultedSpacing.gapHSm,

              Icon(
                Icons.chevron_right,
                color: VaultedColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _initials {
    final name = user.displayName ?? user.email;
    final parts = name.split(RegExp(r'[\s@.]'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

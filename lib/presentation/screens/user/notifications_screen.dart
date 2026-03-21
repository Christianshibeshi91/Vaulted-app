import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/notification_model.dart';
import '../../providers/notification_providers.dart';

/// Notifications screen with swipe-to-delete, mark-all-read, and tap routing.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final unreadCount = ref.watch(unreadCountProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () async {
                Haptics.success();
                await markAllNotificationsRead();
              },
              child: const Text('Mark All Read'),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const _NotificationSkeleton(),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: VaultedColors.danger,
                size: 40,
              ),
              VaultedSpacing.gapLg,
              Text('Failed to load notifications',
                  style: VaultedTypography.bodyLarge),
            ],
          ),
        ),
        data: (notifications) {
          if (notifications.isEmpty) return const _EmptyState();

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _DismissibleNotificationTile(
                notification: notification,
                onTap: () => _onNotificationTap(context, notification),
              );
            },
          );
        },
      ),
    );
  }

  void _onNotificationTap(
    BuildContext context,
    NotificationModel notification,
  ) {
    Haptics.lightTap();

    if (!notification.read) {
      markNotificationRead(notification.id);
    }

    if (notification.actionRoute != null) {
      context.go(notification.actionRoute!);
    }
  }
}

// -- Dismissible notification tile ---------------------------------------

class _DismissibleNotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _DismissibleNotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        Haptics.mediumTap();
        deleteNotification(notification.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: VaultedSpacing.xxl),
        color: VaultedColors.danger.withValues(alpha: 0.15),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: VaultedColors.danger,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: VaultedColors.accentGoldDim,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: VaultedSpacing.xl,
              vertical: VaultedSpacing.lg,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: VaultedColors.border,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Type icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_typeIcon, color: _typeColor, size: 20),
                ),
                const SizedBox(width: VaultedSpacing.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: VaultedTypography.bodyLarge.copyWith(
                          fontWeight: notification.read
                              ? FontWeight.w400
                              : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: VaultedTypography.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        Formatters.relativeTime(notification.createdAt),
                        style: VaultedTypography.labelSmall.copyWith(
                          color: VaultedColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                // Unread dot
                if (!notification.read)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: VaultedSpacing.sm,
                      top: VaultedSpacing.xs,
                    ),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: VaultedColors.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData get _typeIcon => switch (notification.type) {
        NotificationType.success => Icons.check_circle_outline_rounded,
        NotificationType.warning => Icons.warning_amber_rounded,
        NotificationType.danger => Icons.shield_outlined,
        NotificationType.system => Icons.settings_outlined,
        _ => Icons.info_outline_rounded,
      };

  Color get _typeColor => switch (notification.type) {
        NotificationType.success => VaultedColors.success,
        NotificationType.warning => VaultedColors.warning,
        NotificationType.danger => VaultedColors.danger,
        NotificationType.system => VaultedColors.accentGold,
        _ => VaultedColors.info,
      };
}

// -- Empty state ---------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: VaultedColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: VaultedColors.success,
              size: 32,
            ),
          ),
          VaultedSpacing.gapXl,
          Text('All caught up!', style: VaultedTypography.headlineMedium),
          VaultedSpacing.gapSm,
          Text(
            'No new notifications',
            style: VaultedTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// -- Skeleton loading ----------------------------------------------------

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: VaultedColors.shimmerBase,
      highlightColor: VaultedColors.shimmerHighlight,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: VaultedSpacing.xl,
          vertical: VaultedSpacing.lg,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => Padding(
          padding: const EdgeInsets.only(bottom: VaultedSpacing.xl),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: VaultedColors.bgCard,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: VaultedSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 180,
                      height: 14,
                      decoration: BoxDecoration(
                        color: VaultedColors.bgCard,
                        borderRadius: VaultedRadii.brBadge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 10,
                      decoration: BoxDecoration(
                        color: VaultedColors.bgCard,
                        borderRadius: VaultedRadii.brBadge,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 120,
                      height: 10,
                      decoration: BoxDecoration(
                        color: VaultedColors.bgCard,
                        borderRadius: VaultedRadii.brBadge,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

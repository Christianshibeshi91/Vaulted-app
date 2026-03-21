import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/alert_model.dart';
import '../../../data/models/audit_entry_model.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';

/// Tab filter state.
final _alertTabProvider = StateProvider<String>((_) => 'all');

/// Admin alerts screen with category tabs and severity styling.
class AdminAlertsScreen extends ConsumerWidget {
  const AdminAlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(adminAlertsProvider);
    final activeTab = ref.watch(_alertTabProvider);
    final admin = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: Column(
        children: [
          // ── Category tabs ───────────────────────────────────
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              children: [
                for (final tab in ['all', 'security', 'fraud', 'system', 'users'])
                  _TabChip(
                    label: tab[0].toUpperCase() + tab.substring(1),
                    isActive: activeTab == tab,
                    onTap: () =>
                        ref.read(_alertTabProvider.notifier).state = tab,
                  ),
              ],
            ),
          ),

          VaultedSpacing.gapSm,

          // ── Alert list ──────────────────────────────────────
          Expanded(
            child: alertsAsync.when(
              data: (alerts) {
                var filtered = alerts;
                if (activeTab != 'all') {
                  filtered = alerts
                      .where((a) => a.category == activeTab)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          color: VaultedColors.textMuted,
                          size: 40,
                        ),
                        VaultedSpacing.gapMd,
                        Text(
                          'No alerts',
                          style: VaultedTypography.muted(
                              VaultedTypography.bodyLarge),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => VaultedSpacing.gapSm,
                  itemBuilder: (_, index) {
                    final alert = filtered[index];
                    return Dismissible(
                      key: ValueKey(alert.id),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          color: VaultedColors.success.withValues(alpha: 0.15),
                          borderRadius: VaultedRadii.brCard,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: VaultedColors.success,
                        ),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: VaultedColors.info.withValues(alpha: 0.15),
                          borderRadius: VaultedRadii.brCard,
                        ),
                        child: const Icon(
                          Icons.done_all,
                          color: VaultedColors.info,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          await _acknowledge(context, ref, alert, admin);
                        } else {
                          await _resolve(context, ref, alert, admin);
                        }
                        return false; // don't remove from list
                      },
                      child: _AlertCard(
                        alert: alert,
                        onTap: () =>
                            _showDetail(context, ref, alert, admin),
                      ),
                    );
                  },
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
                  'Failed to load alerts',
                  style: VaultedTypography.muted(VaultedTypography.bodyLarge),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acknowledge(
    BuildContext context,
    WidgetRef ref,
    AlertModel alert,
    dynamic admin,
  ) async {
    Haptics.lightTap();
    await updateAlertStatus(
      alert.id,
      isAcknowledged: true,
      adminUid: admin?.uid,
    );
    await _auditLog(AuditAction.acknowledgeAlert, alert.id, admin);
    if (context.mounted) {
      _toast(context, 'Alert acknowledged');
    }
  }

  Future<void> _resolve(
    BuildContext context,
    WidgetRef ref,
    AlertModel alert,
    dynamic admin,
  ) async {
    Haptics.success();
    await updateAlertStatus(
      alert.id,
      isResolved: true,
      adminUid: admin?.uid,
    );
    await _auditLog(AuditAction.resolveAlert, alert.id, admin);
    if (context.mounted) {
      _toast(context, 'Alert resolved');
    }
  }

  void _showDetail(
    BuildContext context,
    WidgetRef ref,
    AlertModel alert,
    dynamic admin,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: VaultedColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: VaultedSpacing.bottomSheet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _severityIcon(alert.severity),
                  color: _severityColor(alert.severity),
                  size: 24,
                ),
                VaultedSpacing.gapHMd,
                Expanded(
                  child: Text(
                    alert.title,
                    style: VaultedTypography.headlineMedium,
                  ),
                ),
              ],
            ),
            VaultedSpacing.gapMd,
            Text(alert.message, style: VaultedTypography.bodyLarge),
            VaultedSpacing.gapSm,
            Text(
              '${AlertCategory.label(alert.category)} / ${AlertSeverity.label(alert.severity)}',
              style: VaultedTypography.muted(VaultedTypography.labelSmall),
            ),
            VaultedSpacing.gapXs,
            Text(
              Formatters.dateTime(alert.createdAt),
              style: VaultedTypography.muted(VaultedTypography.labelMicro),
            ),
            VaultedSpacing.gapXl,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: alert.isAcknowledged
                        ? null
                        : () {
                            _acknowledge(context, ref, alert, admin);
                            Navigator.pop(ctx);
                          },
                    icon: const Icon(Icons.check, size: 18),
                    label: Text(
                      alert.isAcknowledged ? 'Acknowledged' : 'Acknowledge',
                    ),
                  ),
                ),
                VaultedSpacing.gapHMd,
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: alert.isResolved
                        ? null
                        : () {
                            _resolve(context, ref, alert, admin);
                            Navigator.pop(ctx);
                          },
                    icon: const Icon(Icons.done_all, size: 18),
                    label: Text(
                      alert.isResolved ? 'Resolved' : 'Resolve',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _auditLog(String action, String targetId, dynamic admin) async {
    final entry = AuditEntryModel(
      id: const Uuid().v4(),
      adminUid: admin?.uid ?? 'unknown',
      adminEmail: admin?.email ?? 'unknown',
      action: action,
      targetType: 'alert',
      targetId: targetId,
      timestamp: DateTime.now(),
    );
    await writeAuditLog(entry);
  }

  void _toast(BuildContext context, String message) {
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

// ── Alert card ───────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onTap;

  const _AlertCard({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(alert.severity);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: VaultedRadii.brCard,
        child: Container(
          padding: VaultedSpacing.cardInner,
          decoration: BoxDecoration(
            color: VaultedColors.bgCard,
            borderRadius: VaultedRadii.brCard,
            border: Border.all(
              color: alert.isResolved
                  ? VaultedColors.border
                  : color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _severityIcon(alert.severity),
                color: alert.isResolved
                    ? VaultedColors.textMuted
                    : color,
                size: 22,
              ),
              VaultedSpacing.gapHMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: VaultedTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: alert.isResolved
                            ? VaultedColors.textMuted
                            : VaultedColors.textPrimary,
                        decoration: alert.isResolved
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    VaultedSpacing.gapXs,
                    Text(
                      alert.message,
                      style: VaultedTypography.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    VaultedSpacing.gapXs,
                    Text(
                      Formatters.relativeTime(alert.createdAt),
                      style: VaultedTypography.labelMicro,
                    ),
                  ],
                ),
              ),
              if (alert.isAcknowledged && !alert.isResolved)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.visibility,
                    size: 14,
                    color: VaultedColors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────

IconData _severityIcon(String severity) => switch (severity) {
      'critical' => Icons.error_outline,
      'warning' => Icons.warning_amber_rounded,
      _ => Icons.info_outline,
    };

Color _severityColor(String severity) => switch (severity) {
      'critical' => VaultedColors.danger,
      'warning' => VaultedColors.warning,
      _ => VaultedColors.info,
    };

class _TabChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabChip({
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

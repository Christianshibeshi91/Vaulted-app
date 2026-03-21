import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/radii.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/audit_entry_model.dart';
import '../../providers/admin_providers.dart';

/// Filter state providers.
final _auditFilterAdminProvider = StateProvider<String?>((_) => null);
final _auditFilterActionProvider = StateProvider<String?>((_) => null);

/// Admin audit log screen with grouped list and export.
class AdminAuditLogScreen extends ConsumerWidget {
  const AdminAuditLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logAsync = ref.watch(auditLogProvider);
    final filterAdmin = ref.watch(_auditFilterAdminProvider);
    final filterAction = ref.watch(_auditFilterActionProvider);

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      floatingActionButton: FloatingActionButton.small(
        onPressed: () => _exportLog(context, ref),
        backgroundColor: VaultedColors.accentGold,
        foregroundColor: VaultedColors.bgPrimary,
        tooltip: 'Export as JSON',
        child: const Icon(Icons.ios_share, size: 20),
      ),
      body: Column(
        children: [
          // ── Filters ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              children: [
                Expanded(
                  child: _FilterDropdown(
                    hint: 'Admin',
                    value: filterAdmin,
                    items: const ['All', 'admin@vaulted.app'],
                    onChanged: (val) => ref
                        .read(_auditFilterAdminProvider.notifier)
                        .state = val == 'All' ? null : val,
                  ),
                ),
                VaultedSpacing.gapHSm,
                Expanded(
                  child: _FilterDropdown(
                    hint: 'Action',
                    value: filterAction,
                    items: const [
                      'All',
                      'suspend_user',
                      'toggle_feature_flag',
                      'update_settings',
                      'approve_transaction',
                      'reject_transaction',
                    ],
                    onChanged: (val) => ref
                        .read(_auditFilterActionProvider.notifier)
                        .state = val == 'All' ? null : val,
                  ),
                ),
              ],
            ),
          ),

          // ── Grouped list ───────────────────────────────────
          Expanded(
            child: logAsync.when(
              data: (entries) {
                var filtered = entries;
                if (filterAdmin != null) {
                  filtered = filtered
                      .where((e) => e.adminEmail == filterAdmin)
                      .toList();
                }
                if (filterAction != null) {
                  filtered = filtered
                      .where((e) => e.action == filterAction)
                      .toList();
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          color: VaultedColors.textMuted,
                          size: 40,
                        ),
                        VaultedSpacing.gapMd,
                        Text(
                          'No audit entries',
                          style: VaultedTypography.muted(
                              VaultedTypography.bodyLarge),
                        ),
                      ],
                    ),
                  );
                }

                return GroupedListView<AuditEntryModel, String>(
                  elements: filtered,
                  groupBy: (entry) =>
                      Formatters.iso(entry.timestamp),
                  groupSeparatorBuilder: (date) => Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Text(
                      date,
                      style: VaultedTypography.gold(
                              VaultedTypography.labelSmall)
                          .copyWith(letterSpacing: 1.0),
                    ),
                  ),
                  itemBuilder: (_, entry) => _AuditEntryTile(entry: entry),
                  itemComparator: (a, b) =>
                      b.timestamp.compareTo(a.timestamp),
                  order: GroupedListOrder.DESC,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
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
                  'Failed to load audit log',
                  style: VaultedTypography.muted(VaultedTypography.bodyLarge),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportLog(BuildContext context, WidgetRef ref) async {
    Haptics.mediumTap();
    final entries = ref.read(auditLogProvider).valueOrNull ?? [];

    final jsonList = entries.map((e) => {
          'id': e.id,
          'adminEmail': e.adminEmail,
          'action': e.action,
          'targetType': e.targetType,
          'targetId': e.targetId,
          'timestamp': e.timestamp.toIso8601String(),
          'details': e.details,
        }).toList();

    final jsonString =
        const JsonEncoder.withIndent('  ').convert(jsonList);

    await Share.share(jsonString, subject: 'Vaulted Audit Log Export');
  }
}

// ── Audit entry tile ─────────────────────────────────────────────

class _AuditEntryTile extends StatelessWidget {
  final AuditEntryModel entry;

  const _AuditEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VaultedSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: VaultedColors.bgCard,
          borderRadius: VaultedRadii.brCard,
          border: Border.all(color: VaultedColors.border),
        ),
        child: Row(
          children: [
            // Admin avatar
            CircleAvatar(
              radius: 16,
              backgroundColor: VaultedColors.accentGoldDim,
              child: Text(
                (entry.adminEmail.isNotEmpty
                        ? entry.adminEmail[0]
                        : '?')
                    .toUpperCase(),
                style:
                    VaultedTypography.gold(VaultedTypography.labelMicro),
              ),
            ),

            VaultedSpacing.gapHMd,

            // Action details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AuditAction.label(entry.action),
                    style: VaultedTypography.bodyMedium.copyWith(
                      color: VaultedColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  VaultedSpacing.gapXs,
                  Text(
                    '${entry.adminEmail} ${entry.targetId != null ? "on ${entry.targetType}:${entry.targetId}" : ""}',
                    style: VaultedTypography.labelMicro,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Timestamp
            Text(
              Formatters.time(entry.timestamp),
              style: VaultedTypography.muted(VaultedTypography.labelMicro),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter dropdown ──────────────────────────────────────────────

class _FilterDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: VaultedColors.bgInput,
        borderRadius: VaultedRadii.brInput,
        border: Border.all(color: VaultedColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Text(hint, style: VaultedTypography.muted(VaultedTypography.bodyMedium)),
          dropdownColor: VaultedColors.bgSecondary,
          icon: const Icon(Icons.expand_more, size: 18, color: VaultedColors.textMuted),
          style: VaultedTypography.bodyMedium.copyWith(color: VaultedColors.textPrimary),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

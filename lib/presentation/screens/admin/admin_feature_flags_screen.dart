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

/// Feature flags management screen.
class AdminFeatureFlagsScreen extends ConsumerWidget {
  const AdminFeatureFlagsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flagsAsync = ref.watch(featureFlagsProvider);
    final admin = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: flagsAsync.when(
        data: (flags) {
          if (flags.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: VaultedColors.textMuted,
                    size: 40,
                  ),
                  VaultedSpacing.gapMd,
                  Text(
                    'No feature flags configured',
                    style:
                        VaultedTypography.muted(VaultedTypography.bodyLarge),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: VaultedSpacing.screenH.copyWith(
              top: VaultedSpacing.xl,
              bottom: VaultedSpacing.section,
            ),
            itemCount: flags.length,
            separatorBuilder: (_, _) => VaultedSpacing.gapSm,
            itemBuilder: (_, index) {
              final flag = flags[index];

              return Container(
                padding: VaultedSpacing.cardInner,
                decoration: BoxDecoration(
                  color: VaultedColors.bgCard,
                  borderRadius: VaultedRadii.brCard,
                  border: Border.all(
                    color: flag.isEnabled
                        ? VaultedColors.success.withValues(alpha: 0.2)
                        : VaultedColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    // Toggle
                    SizedBox(
                      width: 52,
                      height: 44,
                      child: Switch(
                        value: flag.isEnabled,
                        onChanged: (val) async {
                          Haptics.toggle();
                          await toggleFeatureFlag(flag.id, val);

                          // Audit log
                          final entry = AuditEntryModel(
                            id: const Uuid().v4(),
                            adminUid: admin?.uid ?? 'unknown',
                            adminEmail: admin?.email ?? 'unknown',
                            action: AuditAction.toggleFeatureFlag,
                            targetType: 'feature_flag',
                            targetId: flag.id,
                            targetLabel: flag.name,
                            details:
                                '${flag.name} ${val ? "enabled" : "disabled"}',
                            timestamp: DateTime.now(),
                          );
                          await writeAuditLog(entry);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      val
                                          ? Icons.toggle_on
                                          : Icons.toggle_off,
                                      color: val
                                          ? VaultedColors.success
                                          : VaultedColors.textMuted,
                                      size: 18,
                                    ),
                                    VaultedSpacing.gapHSm,
                                    Text(
                                      '${flag.name} ${val ? "enabled" : "disabled"}',
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),

                    VaultedSpacing.gapHMd,

                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  flag.name,
                                  style: VaultedTypography.bodyLarge
                                      .copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              VaultedSpacing.gapHSm,
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: (flag.isEnabled
                                          ? VaultedColors.success
                                          : VaultedColors.textMuted)
                                      .withValues(alpha: 0.12),
                                  borderRadius: VaultedRadii.brBadge,
                                ),
                                child: Text(
                                  flag.isEnabled ? 'ON' : 'OFF',
                                  style:
                                      VaultedTypography.labelMicro.copyWith(
                                    color: flag.isEnabled
                                        ? VaultedColors.success
                                        : VaultedColors.textMuted,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          VaultedSpacing.gapXs,
                          Text(
                            flag.description,
                            style: VaultedTypography.muted(
                                VaultedTypography.bodyMedium),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          VaultedSpacing.gapSm,
                          Row(
                            children: [
                              Text(
                                'Rollout: ${flag.rolloutPercentage}%',
                                style: VaultedTypography.monoSmall.copyWith(
                                  color: VaultedColors.accentGold,
                                ),
                              ),
                              VaultedSpacing.gapHLg,
                              Text(
                                'ID: ${flag.id}',
                                style: VaultedTypography.muted(
                                    VaultedTypography.labelMicro),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
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
            'Failed to load feature flags',
            style: VaultedTypography.muted(VaultedTypography.bodyLarge),
          ),
        ),
      ),
    );
  }
}

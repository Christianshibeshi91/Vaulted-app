import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/colors.dart';
import '../../../core/theme/spacing.dart';
import '../../../core/theme/typography.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/models/app_settings_model.dart';
import '../../../data/models/audit_entry_model.dart';
import '../../providers/admin_providers.dart';
import '../../providers/auth_providers.dart';
import '../../widgets/admin/admin_settings_section.dart';

/// Admin settings screen with collapsible sections.
class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  // ── Fee controllers ────────────────────────────────────────────
  final _defaultFee = TextEditingController();
  final _premiumFee = TextEditingController();
  final _minFee = TextEditingController();
  final _maxFee = TextEditingController();

  // ── Fraud controllers ──────────────────────────────────────────
  final _autoFlagThreshold = TextEditingController();
  final _velocityLimit = TextEditingController();
  final _newUserDelay = TextEditingController();
  final _kycThreshold = TextEditingController();

  // ── Maintenance ────────────────────────────────────────────────
  final _maintenanceMessage = TextEditingController();

  // ── Toggle states ──────────────────────────────────────────────
  bool _notifyFlagged = true;
  bool _notifyRevenue = true;
  bool _notifySignups = true;
  bool _notifyDigest = false;
  bool _maintenanceEnabled = false;

  bool _initialized = false;
  bool _saving = false;

  @override
  void dispose() {
    _defaultFee.dispose();
    _premiumFee.dispose();
    _minFee.dispose();
    _maxFee.dispose();
    _autoFlagThreshold.dispose();
    _velocityLimit.dispose();
    _newUserDelay.dispose();
    _kycThreshold.dispose();
    _maintenanceMessage.dispose();
    super.dispose();
  }

  void _populateFrom(AppSettingsModel s) {
    if (_initialized) return;
    _initialized = true;

    _defaultFee.text = s.defaultFeePercent.toString();
    _premiumFee.text = s.premiumFeePercent.toString();
    _minFee.text = s.minFeeAmount.toString();
    _maxFee.text = s.maxFeeAmount.toString();
    _autoFlagThreshold.text = s.autoFlagThreshold.toString();
    _velocityLimit.text = s.velocityLimit.toString();
    _newUserDelay.text = s.newUserDelayHours.toString();
    _kycThreshold.text = s.kycThreshold.toString();
    _notifyFlagged = s.notifyFlaggedTransactions;
    _notifyRevenue = s.notifyDailyRevenue;
    _notifySignups = s.notifyNewSignups;
    _notifyDigest = s.notifyWeeklyDigest;
    _maintenanceEnabled = s.maintenanceEnabled;
    _maintenanceMessage.text = s.maintenanceMessage;
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final admin = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      backgroundColor: VaultedColors.bgPrimary,
      body: settingsAsync.when(
        data: (settings) {
          _populateFrom(settings);

          return ListView(
            padding: VaultedSpacing.screenH.copyWith(
              top: VaultedSpacing.xl,
              bottom: 100,
            ),
            children: [
              // ── Fees ───────────────────────────────────────
              AdminSettingsSection(
                title: 'Fees',
                icon: Icons.percent,
                initiallyExpanded: true,
                children: [
                  SettingsTextField(
                    label: 'Default Fee',
                    controller: _defaultFee,
                    keyboardType: TextInputType.number,
                    suffix: '%',
                  ),
                  SettingsTextField(
                    label: 'Premium Fee',
                    controller: _premiumFee,
                    keyboardType: TextInputType.number,
                    suffix: '%',
                  ),
                  SettingsTextField(
                    label: 'Min Amount',
                    controller: _minFee,
                    keyboardType: TextInputType.number,
                    suffix: '\$',
                  ),
                  SettingsTextField(
                    label: 'Max Amount',
                    controller: _maxFee,
                    keyboardType: TextInputType.number,
                    suffix: '\$',
                  ),
                ],
              ),

              VaultedSpacing.gapMd,

              // ── Fraud ──────────────────────────────────────
              AdminSettingsSection(
                title: 'Fraud Detection',
                icon: Icons.shield_outlined,
                children: [
                  SettingsTextField(
                    label: 'Auto-Flag Threshold',
                    controller: _autoFlagThreshold,
                    keyboardType: TextInputType.number,
                    suffix: '\$',
                  ),
                  SettingsTextField(
                    label: 'Velocity Limit',
                    controller: _velocityLimit,
                    keyboardType: TextInputType.number,
                    suffix: '/hr',
                  ),
                  SettingsTextField(
                    label: 'New User Delay',
                    controller: _newUserDelay,
                    keyboardType: TextInputType.number,
                    suffix: 'hrs',
                  ),
                  SettingsTextField(
                    label: 'KYC Threshold',
                    controller: _kycThreshold,
                    keyboardType: TextInputType.number,
                    suffix: '\$',
                  ),
                ],
              ),

              VaultedSpacing.gapMd,

              // ── Notifications ──────────────────────────────
              AdminSettingsSection(
                title: 'Notifications',
                icon: Icons.notifications_outlined,
                children: [
                  SettingsSwitch(
                    label: 'Flagged Transactions',
                    value: _notifyFlagged,
                    onChanged: (val) =>
                        setState(() => _notifyFlagged = val),
                  ),
                  SettingsSwitch(
                    label: 'Daily Revenue',
                    value: _notifyRevenue,
                    onChanged: (val) =>
                        setState(() => _notifyRevenue = val),
                  ),
                  SettingsSwitch(
                    label: 'New Signups',
                    value: _notifySignups,
                    onChanged: (val) =>
                        setState(() => _notifySignups = val),
                  ),
                  SettingsSwitch(
                    label: 'Weekly Digest',
                    value: _notifyDigest,
                    onChanged: (val) =>
                        setState(() => _notifyDigest = val),
                  ),
                ],
              ),

              VaultedSpacing.gapMd,

              // ── Maintenance ────────────────────────────────
              AdminSettingsSection(
                title: 'Maintenance Mode',
                icon: Icons.construction_outlined,
                children: [
                  SettingsSwitch(
                    label: 'Maintenance Enabled',
                    value: _maintenanceEnabled,
                    onChanged: (val) =>
                        setState(() => _maintenanceEnabled = val),
                  ),
                  SettingsTextField(
                    label: 'Message',
                    controller: _maintenanceMessage,
                  ),
                ],
              ),

              VaultedSpacing.gapXl,

              // ── Save button ────────────────────────────────
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : () => _saveAll(admin),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: VaultedColors.bgPrimary,
                          ),
                        )
                      : const Text('Save All Settings'),
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
            'Failed to load settings',
            style: VaultedTypography.muted(VaultedTypography.bodyLarge),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAll(dynamic admin) async {
    setState(() => _saving = true);

    try {
      final updated = AppSettingsModel(
        defaultFeePercent: double.tryParse(_defaultFee.text) ?? 2.5,
        premiumFeePercent: double.tryParse(_premiumFee.text) ?? 1.5,
        minFeeAmount: double.tryParse(_minFee.text) ?? 1.0,
        maxFeeAmount: double.tryParse(_maxFee.text) ?? 50.0,
        autoFlagThreshold:
            double.tryParse(_autoFlagThreshold.text) ?? 1000,
        velocityLimit: int.tryParse(_velocityLimit.text) ?? 5,
        newUserDelayHours: int.tryParse(_newUserDelay.text) ?? 24,
        kycThreshold: double.tryParse(_kycThreshold.text) ?? 500,
        notifyFlaggedTransactions: _notifyFlagged,
        notifyDailyRevenue: _notifyRevenue,
        notifyNewSignups: _notifySignups,
        notifyWeeklyDigest: _notifyDigest,
        maintenanceEnabled: _maintenanceEnabled,
        maintenanceMessage: _maintenanceMessage.text,
      );

      await updateAppSettings(updated);

      // Audit log
      final entry = AuditEntryModel(
        id: const Uuid().v4(),
        adminUid: admin?.uid ?? 'unknown',
        adminEmail: admin?.email ?? 'unknown',
        action: AuditAction.updateSettings,
        targetType: 'setting',
        details: 'Updated all app settings',
        timestamp: DateTime.now(),
      );
      await writeAuditLog(entry);

      if (mounted) {
        Haptics.success();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle,
                    color: VaultedColors.success, size: 18),
                VaultedSpacing.gapHSm,
                const Text('Settings saved and audit logged'),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Haptics.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: VaultedColors.danger, size: 18),
                VaultedSpacing.gapHSm,
                const Text('Failed to save settings'),
              ],
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

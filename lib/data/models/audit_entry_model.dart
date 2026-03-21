import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_entry_model.freezed.dart';
part 'audit_entry_model.g.dart';

/// Audit log entry stored in Firestore `/admin/auditLog/{id}`.
@freezed
class AuditEntryModel with _$AuditEntryModel {
  const factory AuditEntryModel({
    required String id,
    required String adminUid,
    required String adminEmail,
    String? adminDisplayName,
    required String action,
    required String targetType, // user, card, transaction, setting, feature_flag
    String? targetId,
    String? targetLabel,
    String? details,
    Map<String, dynamic>? previousValue,
    Map<String, dynamic>? newValue,
    required DateTime timestamp,
    String? ipAddress,
  }) = _AuditEntryModel;

  factory AuditEntryModel.fromJson(Map<String, dynamic> json) =>
      _$AuditEntryModelFromJson(json);
}

/// Common admin action types.
abstract final class AuditAction {
  static const suspendUser = 'suspend_user';
  static const unsuspendUser = 'unsuspend_user';
  static const flagUser = 'flag_user';
  static const deleteUser = 'delete_user';
  static const resetPassword = 'reset_password';
  static const upgradePlan = 'upgrade_plan';
  static const downgradePlan = 'downgrade_plan';
  static const approveTransaction = 'approve_transaction';
  static const rejectTransaction = 'reject_transaction';
  static const toggleFeatureFlag = 'toggle_feature_flag';
  static const updateSettings = 'update_settings';
  static const acknowledgeAlert = 'acknowledge_alert';
  static const resolveAlert = 'resolve_alert';
  static const addAdminNote = 'add_admin_note';

  static String label(String action) => switch (action) {
        suspendUser => 'Suspended User',
        unsuspendUser => 'Unsuspended User',
        flagUser => 'Flagged User',
        deleteUser => 'Deleted User',
        resetPassword => 'Reset Password',
        upgradePlan => 'Upgraded Plan',
        downgradePlan => 'Downgraded Plan',
        approveTransaction => 'Approved Transaction',
        rejectTransaction => 'Rejected Transaction',
        toggleFeatureFlag => 'Toggled Feature Flag',
        updateSettings => 'Updated Settings',
        acknowledgeAlert => 'Acknowledged Alert',
        resolveAlert => 'Resolved Alert',
        addAdminNote => 'Added Admin Note',
        _ => action,
      };
}

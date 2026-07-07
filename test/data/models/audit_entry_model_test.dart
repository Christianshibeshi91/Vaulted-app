import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/data/models/audit_entry_model.dart';

void main() {
  final now = DateTime(2025, 3, 15, 10, 30);

  AuditEntryModel createEntry({
    String id = 'audit-1',
    String adminUid = 'admin-uid-1',
    String adminEmail = 'admin@vaulted.app',
    String? adminDisplayName = 'Admin User',
    String action = 'suspend_user',
    String targetType = 'user',
    String? targetId = 'user-99',
    String? targetLabel = 'john@example.com',
    String? details = 'Violated TOS',
    Map<String, dynamic>? previousValue,
    Map<String, dynamic>? newValue,
    DateTime? timestamp,
    String? ipAddress,
  }) {
    return AuditEntryModel(
      id: id,
      adminUid: adminUid,
      adminEmail: adminEmail,
      adminDisplayName: adminDisplayName,
      action: action,
      targetType: targetType,
      targetId: targetId,
      targetLabel: targetLabel,
      details: details,
      previousValue: previousValue,
      newValue: newValue,
      timestamp: timestamp ?? now,
      ipAddress: ipAddress,
    );
  }

  group('AuditEntryModel', () {
    test('creates with required fields and nullable defaults', () {
      final entry = AuditEntryModel(
        id: 'a1',
        adminUid: 'uid-1',
        adminEmail: 'test@vaulted.app',
        action: 'update_settings',
        targetType: 'setting',
        timestamp: now,
      );

      expect(entry.id, 'a1');
      expect(entry.adminUid, 'uid-1');
      expect(entry.adminEmail, 'test@vaulted.app');
      expect(entry.action, 'update_settings');
      expect(entry.targetType, 'setting');
      // Nullable fields default to null
      expect(entry.adminDisplayName, isNull);
      expect(entry.targetId, isNull);
      expect(entry.targetLabel, isNull);
      expect(entry.details, isNull);
      expect(entry.previousValue, isNull);
      expect(entry.newValue, isNull);
      expect(entry.ipAddress, isNull);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'audit-42',
        'adminUid': 'uid-admin',
        'adminEmail': 'admin@vaulted.app',
        'adminDisplayName': 'Super Admin',
        'action': 'suspend_user',
        'targetType': 'user',
        'targetId': 'user-7',
        'targetLabel': 'jane@example.com',
        'details': 'Fraudulent activity',
        'previousValue': {'status': 'active'},
        'newValue': {'status': 'suspended'},
        'timestamp': '2025-03-15T10:30:00.000',
        'ipAddress': '192.168.1.1',
      };

      final entry = AuditEntryModel.fromJson(json);

      expect(entry.id, 'audit-42');
      expect(entry.adminUid, 'uid-admin');
      expect(entry.adminEmail, 'admin@vaulted.app');
      expect(entry.adminDisplayName, 'Super Admin');
      expect(entry.action, 'suspend_user');
      expect(entry.targetType, 'user');
      expect(entry.targetId, 'user-7');
      expect(entry.targetLabel, 'jane@example.com');
      expect(entry.details, 'Fraudulent activity');
      expect(entry.previousValue, {'status': 'active'});
      expect(entry.newValue, {'status': 'suspended'});
      expect(entry.ipAddress, '192.168.1.1');
    });

    test('fromJson leaves nullable fields null when absent', () {
      final json = {
        'id': 'a2',
        'adminUid': 'uid-2',
        'adminEmail': 'admin2@vaulted.app',
        'action': 'toggle_feature_flag',
        'targetType': 'feature_flag',
        'timestamp': '2025-01-01T00:00:00.000',
      };

      final entry = AuditEntryModel.fromJson(json);

      expect(entry.adminDisplayName, isNull);
      expect(entry.targetId, isNull);
      expect(entry.targetLabel, isNull);
      expect(entry.details, isNull);
      expect(entry.previousValue, isNull);
      expect(entry.newValue, isNull);
      expect(entry.ipAddress, isNull);
    });

    test('toJson then fromJson roundtrip preserves data', () {
      final original = createEntry(
        id: 'rt-1',
        previousValue: {'enabled': false},
        newValue: {'enabled': true},
        ipAddress: '10.0.0.1',
      );

      final json = original.toJson();
      final restored = AuditEntryModel.fromJson(json);

      expect(restored, original);
    });

    test('equality works for identical data (freezed ==)', () {
      final a = createEntry();
      final b = createEntry();
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      final a = createEntry(action: 'suspend_user');
      final b = createEntry(action: 'delete_user');
      expect(a, isNot(equals(b)));
    });

    test('hashCode is equal for equal objects', () {
      final a = createEntry();
      final b = createEntry();
      expect(a.hashCode, b.hashCode);
    });
  });

  // -- AuditAction Constants -----------------------------------------------

  group('AuditAction', () {
    test('has correct constant values', () {
      expect(AuditAction.suspendUser, 'suspend_user');
      expect(AuditAction.unsuspendUser, 'unsuspend_user');
      expect(AuditAction.flagUser, 'flag_user');
      expect(AuditAction.deleteUser, 'delete_user');
      expect(AuditAction.resetPassword, 'reset_password');
      expect(AuditAction.upgradePlan, 'upgrade_plan');
      expect(AuditAction.downgradePlan, 'downgrade_plan');
      expect(AuditAction.approveTransaction, 'approve_transaction');
      expect(AuditAction.rejectTransaction, 'reject_transaction');
      expect(AuditAction.toggleFeatureFlag, 'toggle_feature_flag');
      expect(AuditAction.updateSettings, 'update_settings');
      expect(AuditAction.acknowledgeAlert, 'acknowledge_alert');
      expect(AuditAction.resolveAlert, 'resolve_alert');
      expect(AuditAction.addAdminNote, 'add_admin_note');
    });

    test('label returns human-readable string for all actions', () {
      expect(AuditAction.label('suspend_user'), 'Suspended User');
      expect(AuditAction.label('unsuspend_user'), 'Unsuspended User');
      expect(AuditAction.label('flag_user'), 'Flagged User');
      expect(AuditAction.label('delete_user'), 'Deleted User');
      expect(AuditAction.label('reset_password'), 'Reset Password');
      expect(AuditAction.label('upgrade_plan'), 'Upgraded Plan');
      expect(AuditAction.label('downgrade_plan'), 'Downgraded Plan');
      expect(AuditAction.label('approve_transaction'), 'Approved Transaction');
      expect(AuditAction.label('reject_transaction'), 'Rejected Transaction');
      expect(AuditAction.label('toggle_feature_flag'), 'Toggled Feature Flag');
      expect(AuditAction.label('update_settings'), 'Updated Settings');
      expect(AuditAction.label('acknowledge_alert'), 'Acknowledged Alert');
      expect(AuditAction.label('resolve_alert'), 'Resolved Alert');
      expect(AuditAction.label('add_admin_note'), 'Added Admin Note');
    });

    test('label returns raw value for unknown action', () {
      expect(AuditAction.label('some_custom_action'), 'some_custom_action');
    });
  });
}

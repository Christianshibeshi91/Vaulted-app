import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/data/models/alert_model.dart';

void main() {
  final now = DateTime(2025, 3, 15, 10, 30);

  AlertModel createAlert({
    String id = 'alert-1',
    String title = 'Suspicious Activity',
    String message = 'Multiple failed login attempts detected',
    String severity = 'critical',
    String category = 'security',
    bool isAcknowledged = false,
    bool isResolved = false,
    String? acknowledgedBy,
    String? resolvedBy,
    DateTime? acknowledgedAt,
    DateTime? resolvedAt,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return AlertModel(
      id: id,
      title: title,
      message: message,
      severity: severity,
      category: category,
      isAcknowledged: isAcknowledged,
      isResolved: isResolved,
      acknowledgedBy: acknowledgedBy,
      resolvedBy: resolvedBy,
      acknowledgedAt: acknowledgedAt,
      resolvedAt: resolvedAt,
      createdAt: createdAt ?? now,
      metadata: metadata,
    );
  }

  group('AlertModel', () {
    test('creates with required fields and correct defaults', () {
      final alert = AlertModel(
        id: 'a1',
        title: 'Test Alert',
        message: 'Something happened',
        severity: 'warning',
        category: 'system',
        createdAt: now,
      );

      expect(alert.id, 'a1');
      expect(alert.title, 'Test Alert');
      expect(alert.message, 'Something happened');
      expect(alert.severity, 'warning');
      expect(alert.category, 'system');
      // Defaults
      expect(alert.isAcknowledged, false);
      expect(alert.isResolved, false);
      // Nullable fields default to null
      expect(alert.acknowledgedBy, isNull);
      expect(alert.resolvedBy, isNull);
      expect(alert.acknowledgedAt, isNull);
      expect(alert.resolvedAt, isNull);
      expect(alert.metadata, isNull);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'alert-42',
        'title': 'Fraud Detected',
        'message': 'Unusual transaction pattern',
        'severity': 'critical',
        'category': 'fraud',
        'isAcknowledged': true,
        'isResolved': true,
        'acknowledgedBy': 'admin-1',
        'resolvedBy': 'admin-2',
        'acknowledgedAt': '2025-03-15T11:00:00.000',
        'resolvedAt': '2025-03-15T12:00:00.000',
        'createdAt': '2025-03-15T10:30:00.000',
        'metadata': {'userId': 'u-99', 'amount': 5000},
      };

      final alert = AlertModel.fromJson(json);

      expect(alert.id, 'alert-42');
      expect(alert.title, 'Fraud Detected');
      expect(alert.message, 'Unusual transaction pattern');
      expect(alert.severity, 'critical');
      expect(alert.category, 'fraud');
      expect(alert.isAcknowledged, true);
      expect(alert.isResolved, true);
      expect(alert.acknowledgedBy, 'admin-1');
      expect(alert.resolvedBy, 'admin-2');
      expect(alert.metadata, {'userId': 'u-99', 'amount': 5000});
    });

    test('fromJson applies defaults when optional fields are absent', () {
      final json = {
        'id': 'a2',
        'title': 'Info',
        'message': 'Routine check',
        'severity': 'info',
        'category': 'system',
        'createdAt': '2025-01-01T00:00:00.000',
      };

      final alert = AlertModel.fromJson(json);

      expect(alert.isAcknowledged, false);
      expect(alert.isResolved, false);
      expect(alert.acknowledgedBy, isNull);
      expect(alert.resolvedBy, isNull);
      expect(alert.acknowledgedAt, isNull);
      expect(alert.resolvedAt, isNull);
      expect(alert.metadata, isNull);
    });

    test('toJson then fromJson roundtrip preserves data', () {
      final original = createAlert(
        id: 'rt-1',
        title: 'Roundtrip Alert',
        message: 'Testing roundtrip',
        severity: 'warning',
        category: 'users',
        isAcknowledged: true,
        acknowledgedBy: 'admin-5',
        acknowledgedAt: DateTime(2025, 3, 15, 11, 0),
        metadata: {'key': 'value'},
      );

      final json = original.toJson();
      final restored = AlertModel.fromJson(json);

      expect(restored, original);
    });

    test('equality works for identical data (freezed ==)', () {
      final a = createAlert();
      final b = createAlert();
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      final a = createAlert(isAcknowledged: false);
      final b = createAlert(isAcknowledged: true);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      final original = createAlert(isResolved: false);
      final updated = original.copyWith(
        isResolved: true,
        resolvedBy: 'admin-3',
      );

      expect(updated.isResolved, true);
      expect(updated.resolvedBy, 'admin-3');
      // Unchanged fields remain
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.severity, original.severity);
    });

    test('hashCode is equal for equal objects', () {
      final a = createAlert();
      final b = createAlert();
      expect(a.hashCode, b.hashCode);
    });
  });

  // -- AlertSeverity Constants ---------------------------------------------

  group('AlertSeverity', () {
    test('has correct constant values', () {
      expect(AlertSeverity.critical, 'critical');
      expect(AlertSeverity.warning, 'warning');
      expect(AlertSeverity.info, 'info');
    });

    test('all list contains all severities', () {
      expect(AlertSeverity.all, hasLength(3));
      expect(AlertSeverity.all, contains(AlertSeverity.critical));
      expect(AlertSeverity.all, contains(AlertSeverity.warning));
      expect(AlertSeverity.all, contains(AlertSeverity.info));
    });

    test('label returns human-readable string for all severities', () {
      expect(AlertSeverity.label('critical'), 'Critical');
      expect(AlertSeverity.label('warning'), 'Warning');
      expect(AlertSeverity.label('info'), 'Info');
    });

    test('label returns raw value for unknown severity', () {
      expect(AlertSeverity.label('unknown'), 'unknown');
    });
  });

  // -- AlertCategory Constants ---------------------------------------------

  group('AlertCategory', () {
    test('has correct constant values', () {
      expect(AlertCategory.security, 'security');
      expect(AlertCategory.fraud, 'fraud');
      expect(AlertCategory.system, 'system');
      expect(AlertCategory.users, 'users');
    });

    test('all list contains all categories', () {
      expect(AlertCategory.all, hasLength(4));
      expect(AlertCategory.all, contains(AlertCategory.security));
      expect(AlertCategory.all, contains(AlertCategory.fraud));
      expect(AlertCategory.all, contains(AlertCategory.system));
      expect(AlertCategory.all, contains(AlertCategory.users));
    });

    test('label returns human-readable string for all categories', () {
      expect(AlertCategory.label('security'), 'Security');
      expect(AlertCategory.label('fraud'), 'Fraud');
      expect(AlertCategory.label('system'), 'System');
      expect(AlertCategory.label('users'), 'Users');
    });

    test('label returns raw value for unknown category', () {
      expect(AlertCategory.label('unknown'), 'unknown');
    });
  });
}

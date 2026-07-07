import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/data/models/notification_model.dart';

void main() {
  final now = DateTime(2025, 3, 15, 10, 30);

  NotificationModel createNotification({
    String id = 'notif-1',
    String title = 'Welcome',
    String message = 'Welcome to Vaulted!',
    String type = 'info',
    bool read = false,
    String? actionRoute,
    Map<String, dynamic>? actionParams,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      type: type,
      read: read,
      actionRoute: actionRoute,
      actionParams: actionParams,
      createdAt: createdAt ?? now,
    );
  }

  group('NotificationModel', () {
    test('creates with required fields and correct defaults', () {
      final notification = NotificationModel(
        id: 'n1',
        title: 'Test',
        message: 'A test notification',
        createdAt: now,
      );

      expect(notification.id, 'n1');
      expect(notification.title, 'Test');
      expect(notification.message, 'A test notification');
      // Defaults
      expect(notification.type, 'info');
      expect(notification.read, false);
      // Nullable fields default to null
      expect(notification.actionRoute, isNull);
      expect(notification.actionParams, isNull);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'notif-42',
        'title': 'Balance Update',
        'message': 'Your card balance changed',
        'type': 'success',
        'read': true,
        'actionRoute': '/cards/detail',
        'actionParams': {'cardId': 'card-7'},
        'createdAt': '2025-03-15T10:30:00.000',
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.id, 'notif-42');
      expect(notification.title, 'Balance Update');
      expect(notification.message, 'Your card balance changed');
      expect(notification.type, 'success');
      expect(notification.read, true);
      expect(notification.actionRoute, '/cards/detail');
      expect(notification.actionParams, {'cardId': 'card-7'});
    });

    test('fromJson applies defaults when optional fields are absent', () {
      final json = {
        'id': 'n2',
        'title': 'Hello',
        'message': 'Hi there',
        'createdAt': '2025-01-01T00:00:00.000',
      };

      final notification = NotificationModel.fromJson(json);

      expect(notification.type, 'info');
      expect(notification.read, false);
      expect(notification.actionRoute, isNull);
      expect(notification.actionParams, isNull);
    });

    test('toJson then fromJson roundtrip preserves data', () {
      final original = createNotification(
        id: 'rt-1',
        title: 'Roundtrip',
        message: 'Testing roundtrip',
        type: 'warning',
        read: true,
        actionRoute: '/settings',
        actionParams: {'tab': 'security'},
      );

      final json = original.toJson();
      final restored = NotificationModel.fromJson(json);

      expect(restored, original);
    });

    test('equality works for identical data (freezed ==)', () {
      final a = createNotification();
      final b = createNotification();
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      final a = createNotification(read: false);
      final b = createNotification(read: true);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      final original = createNotification(read: false, type: 'info');
      final updated = original.copyWith(read: true, type: 'success');

      expect(updated.read, true);
      expect(updated.type, 'success');
      // Unchanged fields remain
      expect(updated.id, original.id);
      expect(updated.title, original.title);
      expect(updated.message, original.message);
    });

    test('hashCode is equal for equal objects', () {
      final a = createNotification();
      final b = createNotification();
      expect(a.hashCode, b.hashCode);
    });
  });

  // -- NotificationType Constants ------------------------------------------

  group('NotificationType', () {
    test('has correct constant values', () {
      expect(NotificationType.info, 'info');
      expect(NotificationType.success, 'success');
      expect(NotificationType.warning, 'warning');
      expect(NotificationType.danger, 'danger');
      expect(NotificationType.system, 'system');
    });

    test('all list contains all types', () {
      expect(NotificationType.all, hasLength(5));
      expect(NotificationType.all, contains(NotificationType.info));
      expect(NotificationType.all, contains(NotificationType.success));
      expect(NotificationType.all, contains(NotificationType.warning));
      expect(NotificationType.all, contains(NotificationType.danger));
      expect(NotificationType.all, contains(NotificationType.system));
    });

    test('label returns human-readable string for all types', () {
      expect(NotificationType.label('info'), 'Info');
      expect(NotificationType.label('success'), 'Success');
      expect(NotificationType.label('warning'), 'Warning');
      expect(NotificationType.label('danger'), 'Alert');
      expect(NotificationType.label('system'), 'System');
    });

    test('label returns raw value for unknown type', () {
      expect(NotificationType.label('unknown'), 'unknown');
    });
  });
}

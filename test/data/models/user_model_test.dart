import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/data/models/user_model.dart';

void main() {
  UserModel createUser({
    String uid = 'uid-1',
    String email = 'test@example.com',
    String? displayName,
    String role = 'user',
    String plan = 'free',
    bool mfaEnabled = false,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      role: role,
      plan: plan,
      mfaEnabled: mfaEnabled,
    );
  }

  group('UserModel', () {
    test('creates with required fields and correct defaults', () {
      final user = UserModel(uid: 'u1', email: 'a@b.com');

      expect(user.uid, 'u1');
      expect(user.email, 'a@b.com');
      // Defaults
      expect(user.role, 'user');
      expect(user.plan, 'free');
      expect(user.mfaEnabled, false);
      expect(user.biometricEnabled, false);
      expect(user.onboardingComplete, false);
      expect(user.autoLockMinutes, 5);
      expect(user.loginCount, 0);
      expect(user.isSuspended, false);
      // Nullable fields
      expect(user.displayName, isNull);
      expect(user.avatarUrl, isNull);
      expect(user.pushToken, isNull);
      expect(user.notificationPreferences, isNull);
      expect(user.createdAt, isNull);
      expect(user.updatedAt, isNull);
      expect(user.lastLoginAt, isNull);
      expect(user.suspensionReason, isNull);
    });

    test('fromJson parses all fields', () {
      final json = {
        'uid': 'user-99',
        'email': 'admin@vaulted.app',
        'displayName': 'Admin User',
        'avatarUrl': 'https://example.com/avatar.png',
        'role': 'admin',
        'plan': 'premium',
        'mfaEnabled': true,
        'biometricEnabled': true,
        'onboardingComplete': true,
        'pushToken': 'fcm-token-123',
        'autoLockMinutes': 10,
        'notificationPreferences': {
          'push': true,
          'email': false,
        },
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-03-15T10:00:00.000',
        'lastLoginAt': '2025-03-15T09:30:00.000',
        'loginCount': 42,
        'isSuspended': false,
        'suspensionReason': null,
      };

      final user = UserModel.fromJson(json);

      expect(user.uid, 'user-99');
      expect(user.email, 'admin@vaulted.app');
      expect(user.displayName, 'Admin User');
      expect(user.role, 'admin');
      expect(user.plan, 'premium');
      expect(user.mfaEnabled, true);
      expect(user.biometricEnabled, true);
      expect(user.onboardingComplete, true);
      expect(user.autoLockMinutes, 10);
      expect(user.loginCount, 42);
      expect(user.notificationPreferences, {'push': true, 'email': false});
    });

    test('fromJson applies defaults when optional fields are absent', () {
      final json = {
        'uid': 'u2',
        'email': 'minimal@test.com',
      };

      final user = UserModel.fromJson(json);

      expect(user.role, 'user');
      expect(user.plan, 'free');
      expect(user.mfaEnabled, false);
      expect(user.biometricEnabled, false);
      expect(user.onboardingComplete, false);
      expect(user.autoLockMinutes, 5);
      expect(user.loginCount, 0);
      expect(user.isSuspended, false);
    });

    test('toJson then fromJson roundtrip preserves data', () {
      final original = createUser(
        uid: 'round-trip',
        email: 'rt@test.com',
        displayName: 'RT User',
        role: 'admin',
        plan: 'premium',
        mfaEnabled: true,
      );

      final json = original.toJson();
      final restored = UserModel.fromJson(json);

      expect(restored, original);
    });

    test('equality works for identical data (freezed ==)', () {
      final a = createUser();
      final b = createUser();
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      final a = createUser(email: 'a@test.com');
      final b = createUser(email: 'b@test.com');
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      final original = createUser(plan: 'free');
      final upgraded = original.copyWith(plan: 'premium', mfaEnabled: true);

      expect(upgraded.plan, 'premium');
      expect(upgraded.mfaEnabled, true);
      // Unchanged
      expect(upgraded.uid, original.uid);
      expect(upgraded.email, original.email);
    });

    test('hashCode is equal for equal objects', () {
      final a = createUser();
      final b = createUser();
      expect(a.hashCode, b.hashCode);
    });
  });
}

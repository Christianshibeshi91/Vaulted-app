import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/data/models/feature_flag_model.dart';

void main() {
  final now = DateTime(2025, 3, 15, 10, 30);

  FeatureFlagModel createFlag({
    String id = 'flag-1',
    String name = 'dark_mode',
    String description = 'Enable dark mode theme',
    bool isEnabled = false,
    int rolloutPercentage = 100,
    String? enabledBy,
    DateTime? enabledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeatureFlagModel(
      id: id,
      name: name,
      description: description,
      isEnabled: isEnabled,
      rolloutPercentage: rolloutPercentage,
      enabledBy: enabledBy,
      enabledAt: enabledAt,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  group('FeatureFlagModel', () {
    test('creates with required fields and correct defaults', () {
      final flag = FeatureFlagModel(
        id: 'f1',
        name: 'new_feature',
        description: 'A new feature',
      );

      expect(flag.id, 'f1');
      expect(flag.name, 'new_feature');
      expect(flag.description, 'A new feature');
      // Defaults
      expect(flag.isEnabled, false);
      expect(flag.rolloutPercentage, 100);
      // Nullable fields default to null
      expect(flag.enabledBy, isNull);
      expect(flag.enabledAt, isNull);
      expect(flag.createdAt, isNull);
      expect(flag.updatedAt, isNull);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'flag-42',
        'name': 'card_scanning',
        'description': 'Enable barcode scanning for gift cards',
        'isEnabled': true,
        'rolloutPercentage': 50,
        'enabledBy': 'admin-1',
        'enabledAt': '2025-03-10T08:00:00.000',
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-03-15T10:30:00.000',
      };

      final flag = FeatureFlagModel.fromJson(json);

      expect(flag.id, 'flag-42');
      expect(flag.name, 'card_scanning');
      expect(flag.description, 'Enable barcode scanning for gift cards');
      expect(flag.isEnabled, true);
      expect(flag.rolloutPercentage, 50);
      expect(flag.enabledBy, 'admin-1');
    });

    test('fromJson applies defaults when optional fields are absent', () {
      final json = {
        'id': 'f2',
        'name': 'beta_feature',
        'description': 'A beta feature',
      };

      final flag = FeatureFlagModel.fromJson(json);

      expect(flag.isEnabled, false);
      expect(flag.rolloutPercentage, 100);
      expect(flag.enabledBy, isNull);
      expect(flag.enabledAt, isNull);
      expect(flag.createdAt, isNull);
      expect(flag.updatedAt, isNull);
    });

    test('toJson then fromJson roundtrip preserves data', () {
      final original = createFlag(
        id: 'rt-1',
        name: 'roundtrip_flag',
        description: 'Testing roundtrip',
        isEnabled: true,
        rolloutPercentage: 75,
        enabledBy: 'admin-5',
        enabledAt: DateTime(2025, 3, 10, 8, 0),
      );

      final json = original.toJson();
      final restored = FeatureFlagModel.fromJson(json);

      expect(restored, original);
    });

    test('equality works for identical data (freezed ==)', () {
      final a = createFlag();
      final b = createFlag();
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      final a = createFlag(isEnabled: false);
      final b = createFlag(isEnabled: true);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      final original = createFlag(isEnabled: false, rolloutPercentage: 100);
      final updated = original.copyWith(
        isEnabled: true,
        rolloutPercentage: 25,
        enabledBy: 'admin-3',
      );

      expect(updated.isEnabled, true);
      expect(updated.rolloutPercentage, 25);
      expect(updated.enabledBy, 'admin-3');
      // Unchanged fields remain
      expect(updated.id, original.id);
      expect(updated.name, original.name);
      expect(updated.description, original.description);
    });

    test('hashCode is equal for equal objects', () {
      final a = createFlag();
      final b = createFlag();
      expect(a.hashCode, b.hashCode);
    });
  });
}

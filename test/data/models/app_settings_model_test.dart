import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/data/models/app_settings_model.dart';

void main() {
  AppSettingsModel createSettings({
    double defaultFeePercent = 2.5,
    double premiumFeePercent = 1.5,
    double minFeeAmount = 1.0,
    double maxFeeAmount = 50.0,
    bool cardIssuingEnabled = true,
    String cardNetwork = 'visa',
    double dailyCardLimit = 500.0,
    double monthlyCardLimit = 5000.0,
    double autoFlagThreshold = 1000.0,
    int velocityLimit = 5,
    int newUserDelayHours = 24,
    double kycThreshold = 500.0,
    bool notifyFlaggedTransactions = true,
    bool notifyDailyRevenue = true,
    bool notifyNewSignups = true,
    bool notifyWeeklyDigest = false,
    bool maintenanceEnabled = false,
    String maintenanceMessage = '',
  }) {
    return AppSettingsModel(
      defaultFeePercent: defaultFeePercent,
      premiumFeePercent: premiumFeePercent,
      minFeeAmount: minFeeAmount,
      maxFeeAmount: maxFeeAmount,
      cardIssuingEnabled: cardIssuingEnabled,
      cardNetwork: cardNetwork,
      dailyCardLimit: dailyCardLimit,
      monthlyCardLimit: monthlyCardLimit,
      autoFlagThreshold: autoFlagThreshold,
      velocityLimit: velocityLimit,
      newUserDelayHours: newUserDelayHours,
      kycThreshold: kycThreshold,
      notifyFlaggedTransactions: notifyFlaggedTransactions,
      notifyDailyRevenue: notifyDailyRevenue,
      notifyNewSignups: notifyNewSignups,
      notifyWeeklyDigest: notifyWeeklyDigest,
      maintenanceEnabled: maintenanceEnabled,
      maintenanceMessage: maintenanceMessage,
    );
  }

  group('AppSettingsModel', () {
    test('creates with all correct default values', () {
      const settings = AppSettingsModel();

      // Fees
      expect(settings.defaultFeePercent, 2.5);
      expect(settings.premiumFeePercent, 1.5);
      expect(settings.minFeeAmount, 1.0);
      expect(settings.maxFeeAmount, 50.0);
      // Card Issuing
      expect(settings.cardIssuingEnabled, true);
      expect(settings.cardNetwork, 'visa');
      expect(settings.dailyCardLimit, 500.0);
      expect(settings.monthlyCardLimit, 5000.0);
      // Fraud
      expect(settings.autoFlagThreshold, 1000.0);
      expect(settings.velocityLimit, 5);
      expect(settings.newUserDelayHours, 24);
      expect(settings.kycThreshold, 500.0);
      // Notifications
      expect(settings.notifyFlaggedTransactions, true);
      expect(settings.notifyDailyRevenue, true);
      expect(settings.notifyNewSignups, true);
      expect(settings.notifyWeeklyDigest, false);
      // Maintenance
      expect(settings.maintenanceEnabled, false);
      expect(settings.maintenanceMessage, '');
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'defaultFeePercent': 3.0,
        'premiumFeePercent': 2.0,
        'minFeeAmount': 0.5,
        'maxFeeAmount': 100.0,
        'cardIssuingEnabled': false,
        'cardNetwork': 'mastercard',
        'dailyCardLimit': 1000.0,
        'monthlyCardLimit': 10000.0,
        'autoFlagThreshold': 2000.0,
        'velocityLimit': 10,
        'newUserDelayHours': 48,
        'kycThreshold': 1000.0,
        'notifyFlaggedTransactions': false,
        'notifyDailyRevenue': false,
        'notifyNewSignups': false,
        'notifyWeeklyDigest': true,
        'maintenanceEnabled': true,
        'maintenanceMessage': 'Down for maintenance',
      };

      final settings = AppSettingsModel.fromJson(json);

      expect(settings.defaultFeePercent, 3.0);
      expect(settings.premiumFeePercent, 2.0);
      expect(settings.minFeeAmount, 0.5);
      expect(settings.maxFeeAmount, 100.0);
      expect(settings.cardIssuingEnabled, false);
      expect(settings.cardNetwork, 'mastercard');
      expect(settings.dailyCardLimit, 1000.0);
      expect(settings.monthlyCardLimit, 10000.0);
      expect(settings.autoFlagThreshold, 2000.0);
      expect(settings.velocityLimit, 10);
      expect(settings.newUserDelayHours, 48);
      expect(settings.kycThreshold, 1000.0);
      expect(settings.notifyFlaggedTransactions, false);
      expect(settings.notifyDailyRevenue, false);
      expect(settings.notifyNewSignups, false);
      expect(settings.notifyWeeklyDigest, true);
      expect(settings.maintenanceEnabled, true);
      expect(settings.maintenanceMessage, 'Down for maintenance');
    });

    test('fromJson applies defaults when fields are absent', () {
      final json = <String, dynamic>{};

      final settings = AppSettingsModel.fromJson(json);

      expect(settings.defaultFeePercent, 2.5);
      expect(settings.premiumFeePercent, 1.5);
      expect(settings.minFeeAmount, 1.0);
      expect(settings.maxFeeAmount, 50.0);
      expect(settings.cardIssuingEnabled, true);
      expect(settings.cardNetwork, 'visa');
      expect(settings.dailyCardLimit, 500.0);
      expect(settings.monthlyCardLimit, 5000.0);
      expect(settings.autoFlagThreshold, 1000.0);
      expect(settings.velocityLimit, 5);
      expect(settings.newUserDelayHours, 24);
      expect(settings.kycThreshold, 500.0);
      expect(settings.notifyFlaggedTransactions, true);
      expect(settings.notifyDailyRevenue, true);
      expect(settings.notifyNewSignups, true);
      expect(settings.notifyWeeklyDigest, false);
      expect(settings.maintenanceEnabled, false);
      expect(settings.maintenanceMessage, '');
    });

    test('toJson then fromJson roundtrip preserves data', () {
      final original = createSettings(
        defaultFeePercent: 3.5,
        premiumFeePercent: 2.0,
        cardNetwork: 'mastercard',
        maintenanceEnabled: true,
        maintenanceMessage: 'Scheduled downtime',
      );

      final json = original.toJson();
      final restored = AppSettingsModel.fromJson(json);

      expect(restored, original);
    });

    test('equality works for identical data (freezed ==)', () {
      final a = createSettings();
      final b = createSettings();
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      final a = createSettings(defaultFeePercent: 2.5);
      final b = createSettings(defaultFeePercent: 5.0);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      final original = createSettings();
      final updated = original.copyWith(
        maintenanceEnabled: true,
        maintenanceMessage: 'Under maintenance',
      );

      expect(updated.maintenanceEnabled, true);
      expect(updated.maintenanceMessage, 'Under maintenance');
      // Unchanged fields remain
      expect(updated.defaultFeePercent, original.defaultFeePercent);
      expect(updated.cardNetwork, original.cardNetwork);
    });

    test('hashCode is equal for equal objects', () {
      final a = createSettings();
      final b = createSettings();
      expect(a.hashCode, b.hashCode);
    });
  });
}

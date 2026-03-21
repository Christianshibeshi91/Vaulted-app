import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings_model.freezed.dart';
part 'app_settings_model.g.dart';

/// Global app settings stored in Firestore `/admin/settings`.
@freezed
class AppSettingsModel with _$AppSettingsModel {
  const factory AppSettingsModel({
    // ── Fees ──────────────────────────────────────────────────────
    @Default(2.5) double defaultFeePercent,
    @Default(1.5) double premiumFeePercent,
    @Default(1.0) double minFeeAmount,
    @Default(50.0) double maxFeeAmount,

    // ── Card Issuing ─────────────────────────────────────────────
    @Default(true) bool cardIssuingEnabled,
    @Default('visa') String cardNetwork,
    @Default(500.0) double dailyCardLimit,
    @Default(5000.0) double monthlyCardLimit,

    // ── Fraud ────────────────────────────────────────────────────
    @Default(1000.0) double autoFlagThreshold,
    @Default(5) int velocityLimit,
    @Default(24) int newUserDelayHours,
    @Default(500.0) double kycThreshold,

    // ── Notifications ────────────────────────────────────────────
    @Default(true) bool notifyFlaggedTransactions,
    @Default(true) bool notifyDailyRevenue,
    @Default(true) bool notifyNewSignups,
    @Default(false) bool notifyWeeklyDigest,

    // ── Maintenance ──────────────────────────────────────────────
    @Default(false) bool maintenanceEnabled,
    @Default('') String maintenanceMessage,
  }) = _AppSettingsModel;

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsModelFromJson(json);
}

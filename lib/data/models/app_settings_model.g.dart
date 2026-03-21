// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppSettingsModelImpl _$$AppSettingsModelImplFromJson(
  Map<String, dynamic> json,
) => _$AppSettingsModelImpl(
  defaultFeePercent: (json['defaultFeePercent'] as num?)?.toDouble() ?? 2.5,
  premiumFeePercent: (json['premiumFeePercent'] as num?)?.toDouble() ?? 1.5,
  minFeeAmount: (json['minFeeAmount'] as num?)?.toDouble() ?? 1.0,
  maxFeeAmount: (json['maxFeeAmount'] as num?)?.toDouble() ?? 50.0,
  cardIssuingEnabled: json['cardIssuingEnabled'] as bool? ?? true,
  cardNetwork: json['cardNetwork'] as String? ?? 'visa',
  dailyCardLimit: (json['dailyCardLimit'] as num?)?.toDouble() ?? 500.0,
  monthlyCardLimit: (json['monthlyCardLimit'] as num?)?.toDouble() ?? 5000.0,
  autoFlagThreshold: (json['autoFlagThreshold'] as num?)?.toDouble() ?? 1000.0,
  velocityLimit: (json['velocityLimit'] as num?)?.toInt() ?? 5,
  newUserDelayHours: (json['newUserDelayHours'] as num?)?.toInt() ?? 24,
  kycThreshold: (json['kycThreshold'] as num?)?.toDouble() ?? 500.0,
  notifyFlaggedTransactions: json['notifyFlaggedTransactions'] as bool? ?? true,
  notifyDailyRevenue: json['notifyDailyRevenue'] as bool? ?? true,
  notifyNewSignups: json['notifyNewSignups'] as bool? ?? true,
  notifyWeeklyDigest: json['notifyWeeklyDigest'] as bool? ?? false,
  maintenanceEnabled: json['maintenanceEnabled'] as bool? ?? false,
  maintenanceMessage: json['maintenanceMessage'] as String? ?? '',
);

Map<String, dynamic> _$$AppSettingsModelImplToJson(
  _$AppSettingsModelImpl instance,
) => <String, dynamic>{
  'defaultFeePercent': instance.defaultFeePercent,
  'premiumFeePercent': instance.premiumFeePercent,
  'minFeeAmount': instance.minFeeAmount,
  'maxFeeAmount': instance.maxFeeAmount,
  'cardIssuingEnabled': instance.cardIssuingEnabled,
  'cardNetwork': instance.cardNetwork,
  'dailyCardLimit': instance.dailyCardLimit,
  'monthlyCardLimit': instance.monthlyCardLimit,
  'autoFlagThreshold': instance.autoFlagThreshold,
  'velocityLimit': instance.velocityLimit,
  'newUserDelayHours': instance.newUserDelayHours,
  'kycThreshold': instance.kycThreshold,
  'notifyFlaggedTransactions': instance.notifyFlaggedTransactions,
  'notifyDailyRevenue': instance.notifyDailyRevenue,
  'notifyNewSignups': instance.notifyNewSignups,
  'notifyWeeklyDigest': instance.notifyWeeklyDigest,
  'maintenanceEnabled': instance.maintenanceEnabled,
  'maintenanceMessage': instance.maintenanceMessage,
};

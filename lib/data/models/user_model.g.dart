// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      role: json['role'] as String? ?? 'user',
      plan: json['plan'] as String? ?? 'free',
      mfaEnabled: json['mfaEnabled'] as bool? ?? false,
      biometricEnabled: json['biometricEnabled'] as bool? ?? false,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      pushToken: json['pushToken'] as String?,
      autoLockMinutes: (json['autoLockMinutes'] as num?)?.toInt() ?? 5,
      notificationPreferences:
          (json['notificationPreferences'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      lastLoginAt: json['lastLoginAt'] == null
          ? null
          : DateTime.parse(json['lastLoginAt'] as String),
      loginCount: (json['loginCount'] as num?)?.toInt() ?? 0,
      isSuspended: json['isSuspended'] as bool? ?? false,
      suspensionReason: json['suspensionReason'] as String?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'role': instance.role,
      'plan': instance.plan,
      'mfaEnabled': instance.mfaEnabled,
      'biometricEnabled': instance.biometricEnabled,
      'onboardingComplete': instance.onboardingComplete,
      'pushToken': instance.pushToken,
      'autoLockMinutes': instance.autoLockMinutes,
      'notificationPreferences': instance.notificationPreferences,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'lastLoginAt': instance.lastLoginAt?.toIso8601String(),
      'loginCount': instance.loginCount,
      'isSuspended': instance.isSuspended,
      'suspensionReason': instance.suspensionReason,
    };

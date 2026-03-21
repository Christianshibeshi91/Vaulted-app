// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_flag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeatureFlagModelImpl _$$FeatureFlagModelImplFromJson(
  Map<String, dynamic> json,
) => _$FeatureFlagModelImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  isEnabled: json['isEnabled'] as bool? ?? false,
  rolloutPercentage: (json['rolloutPercentage'] as num?)?.toInt() ?? 100,
  enabledBy: json['enabledBy'] as String?,
  enabledAt: json['enabledAt'] == null
      ? null
      : DateTime.parse(json['enabledAt'] as String),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$FeatureFlagModelImplToJson(
  _$FeatureFlagModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'isEnabled': instance.isEnabled,
  'rolloutPercentage': instance.rolloutPercentage,
  'enabledBy': instance.enabledBy,
  'enabledAt': instance.enabledAt?.toIso8601String(),
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

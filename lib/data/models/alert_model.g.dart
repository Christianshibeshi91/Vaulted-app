// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlertModelImpl _$$AlertModelImplFromJson(Map<String, dynamic> json) =>
    _$AlertModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      category: json['category'] as String,
      isAcknowledged: json['isAcknowledged'] as bool? ?? false,
      isResolved: json['isResolved'] as bool? ?? false,
      acknowledgedBy: json['acknowledgedBy'] as String?,
      resolvedBy: json['resolvedBy'] as String?,
      acknowledgedAt: json['acknowledgedAt'] == null
          ? null
          : DateTime.parse(json['acknowledgedAt'] as String),
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AlertModelImplToJson(_$AlertModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'message': instance.message,
      'severity': instance.severity,
      'category': instance.category,
      'isAcknowledged': instance.isAcknowledged,
      'isResolved': instance.isResolved,
      'acknowledgedBy': instance.acknowledgedBy,
      'resolvedBy': instance.resolvedBy,
      'acknowledgedAt': instance.acknowledgedAt?.toIso8601String(),
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'metadata': instance.metadata,
    };

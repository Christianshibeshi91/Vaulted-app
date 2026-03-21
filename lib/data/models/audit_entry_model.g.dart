// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_entry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuditEntryModelImpl _$$AuditEntryModelImplFromJson(
  Map<String, dynamic> json,
) => _$AuditEntryModelImpl(
  id: json['id'] as String,
  adminUid: json['adminUid'] as String,
  adminEmail: json['adminEmail'] as String,
  adminDisplayName: json['adminDisplayName'] as String?,
  action: json['action'] as String,
  targetType: json['targetType'] as String,
  targetId: json['targetId'] as String?,
  targetLabel: json['targetLabel'] as String?,
  details: json['details'] as String?,
  previousValue: json['previousValue'] as Map<String, dynamic>?,
  newValue: json['newValue'] as Map<String, dynamic>?,
  timestamp: DateTime.parse(json['timestamp'] as String),
  ipAddress: json['ipAddress'] as String?,
);

Map<String, dynamic> _$$AuditEntryModelImplToJson(
  _$AuditEntryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'adminUid': instance.adminUid,
  'adminEmail': instance.adminEmail,
  'adminDisplayName': instance.adminDisplayName,
  'action': instance.action,
  'targetType': instance.targetType,
  'targetId': instance.targetId,
  'targetLabel': instance.targetLabel,
  'details': instance.details,
  'previousValue': instance.previousValue,
  'newValue': instance.newValue,
  'timestamp': instance.timestamp.toIso8601String(),
  'ipAddress': instance.ipAddress,
};

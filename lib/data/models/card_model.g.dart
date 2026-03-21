// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CardModelImpl _$$CardModelImplFromJson(Map<String, dynamic> json) =>
    _$CardModelImpl(
      id: json['id'] as String,
      retailer: json['retailer'] as String,
      retailerColor: json['retailerColor'] as String,
      cardNumberEncrypted: json['cardNumberEncrypted'] as String?,
      pinEncrypted: json['pinEncrypted'] as String?,
      balance: (json['balance'] as num).toDouble(),
      originalBalance: (json['originalBalance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String? ?? 'active',
      lastBalanceCheck: json['lastBalanceCheck'] == null
          ? null
          : DateTime.parse(json['lastBalanceCheck'] as String),
      expirationDate: json['expirationDate'] == null
          ? null
          : DateTime.parse(json['expirationDate'] as String),
      notes: json['notes'] as String?,
      addedVia: json['addedVia'] as String? ?? 'manual',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$CardModelImplToJson(_$CardModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'retailer': instance.retailer,
      'retailerColor': instance.retailerColor,
      'cardNumberEncrypted': instance.cardNumberEncrypted,
      'pinEncrypted': instance.pinEncrypted,
      'balance': instance.balance,
      'originalBalance': instance.originalBalance,
      'currency': instance.currency,
      'status': instance.status,
      'lastBalanceCheck': instance.lastBalanceCheck?.toIso8601String(),
      'expirationDate': instance.expirationDate?.toIso8601String(),
      'notes': instance.notes,
      'addedVia': instance.addedVia,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

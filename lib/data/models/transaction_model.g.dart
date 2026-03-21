// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
  Map<String, dynamic> json,
) => _$TransactionModelImpl(
  id: json['id'] as String,
  cardId: json['cardId'] as String,
  retailer: json['retailer'] as String,
  type: json['type'] as String,
  amount: (json['amount'] as num).toDouble(),
  balanceAfter: (json['balanceAfter'] as num).toDouble(),
  description: json['description'] as String?,
  merchant: json['merchant'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$$TransactionModelImplToJson(
  _$TransactionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'cardId': instance.cardId,
  'retailer': instance.retailer,
  'type': instance.type,
  'amount': instance.amount,
  'balanceAfter': instance.balanceAfter,
  'description': instance.description,
  'merchant': instance.merchant,
  'createdAt': instance.createdAt.toIso8601String(),
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyStatsModelImpl _$$DailyStatsModelImplFromJson(
  Map<String, dynamic> json,
) => _$DailyStatsModelImpl(
  date: json['date'] as String,
  newUsers: (json['newUsers'] as num?)?.toInt() ?? 0,
  activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
  totalTransactions: (json['totalTransactions'] as num?)?.toInt() ?? 0,
  totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
  conversionRevenue: (json['conversionRevenue'] as num?)?.toDouble() ?? 0.0,
  interchangeRevenue: (json['interchangeRevenue'] as num?)?.toDouble() ?? 0.0,
  premiumRevenue: (json['premiumRevenue'] as num?)?.toDouble() ?? 0.0,
  affiliateRevenue: (json['affiliateRevenue'] as num?)?.toDouble() ?? 0.0,
  cardsAdded: (json['cardsAdded'] as num?)?.toInt() ?? 0,
  cardsRedeemed: (json['cardsRedeemed'] as num?)?.toInt() ?? 0,
  totalCardValue: (json['totalCardValue'] as num?)?.toDouble() ?? 0.0,
  flaggedTransactions: (json['flaggedTransactions'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$DailyStatsModelImplToJson(
  _$DailyStatsModelImpl instance,
) => <String, dynamic>{
  'date': instance.date,
  'newUsers': instance.newUsers,
  'activeUsers': instance.activeUsers,
  'totalTransactions': instance.totalTransactions,
  'totalRevenue': instance.totalRevenue,
  'conversionRevenue': instance.conversionRevenue,
  'interchangeRevenue': instance.interchangeRevenue,
  'premiumRevenue': instance.premiumRevenue,
  'affiliateRevenue': instance.affiliateRevenue,
  'cardsAdded': instance.cardsAdded,
  'cardsRedeemed': instance.cardsRedeemed,
  'totalCardValue': instance.totalCardValue,
  'flaggedTransactions': instance.flaggedTransactions,
};

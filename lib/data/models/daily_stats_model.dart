import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_stats_model.freezed.dart';
part 'daily_stats_model.g.dart';

/// Daily aggregated statistics stored in Firestore `/admin/stats/daily/{date}`.
@freezed
class DailyStatsModel with _$DailyStatsModel {
  const factory DailyStatsModel({
    required String date, // ISO 8601 yyyy-MM-dd
    @Default(0) int newUsers,
    @Default(0) int activeUsers,
    @Default(0) int totalTransactions,
    @Default(0.0) double totalRevenue,
    @Default(0.0) double conversionRevenue,
    @Default(0.0) double interchangeRevenue,
    @Default(0.0) double premiumRevenue,
    @Default(0.0) double affiliateRevenue,
    @Default(0) int cardsAdded,
    @Default(0) int cardsRedeemed,
    @Default(0.0) double totalCardValue,
    @Default(0) int flaggedTransactions,
  }) = _DailyStatsModel;

  factory DailyStatsModel.fromJson(Map<String, dynamic> json) =>
      _$DailyStatsModelFromJson(json);
}

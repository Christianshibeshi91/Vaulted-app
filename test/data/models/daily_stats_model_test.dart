import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/data/models/daily_stats_model.dart';

void main() {
  DailyStatsModel createStats({
    String date = '2025-03-15',
    int newUsers = 0,
    int activeUsers = 0,
    int totalTransactions = 0,
    double totalRevenue = 0.0,
    double conversionRevenue = 0.0,
    double interchangeRevenue = 0.0,
    double premiumRevenue = 0.0,
    double affiliateRevenue = 0.0,
    int cardsAdded = 0,
    int cardsRedeemed = 0,
    double totalCardValue = 0.0,
    int flaggedTransactions = 0,
  }) {
    return DailyStatsModel(
      date: date,
      newUsers: newUsers,
      activeUsers: activeUsers,
      totalTransactions: totalTransactions,
      totalRevenue: totalRevenue,
      conversionRevenue: conversionRevenue,
      interchangeRevenue: interchangeRevenue,
      premiumRevenue: premiumRevenue,
      affiliateRevenue: affiliateRevenue,
      cardsAdded: cardsAdded,
      cardsRedeemed: cardsRedeemed,
      totalCardValue: totalCardValue,
      flaggedTransactions: flaggedTransactions,
    );
  }

  group('DailyStatsModel', () {
    test('creates with required date and all defaults are 0', () {
      final stats = DailyStatsModel(date: '2025-03-15');

      expect(stats.date, '2025-03-15');
      expect(stats.newUsers, 0);
      expect(stats.activeUsers, 0);
      expect(stats.totalTransactions, 0);
      expect(stats.totalRevenue, 0.0);
      expect(stats.conversionRevenue, 0.0);
      expect(stats.interchangeRevenue, 0.0);
      expect(stats.premiumRevenue, 0.0);
      expect(stats.affiliateRevenue, 0.0);
      expect(stats.cardsAdded, 0);
      expect(stats.cardsRedeemed, 0);
      expect(stats.totalCardValue, 0.0);
      expect(stats.flaggedTransactions, 0);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'date': '2025-03-15',
        'newUsers': 42,
        'activeUsers': 150,
        'totalTransactions': 300,
        'totalRevenue': 1250.75,
        'conversionRevenue': 500.0,
        'interchangeRevenue': 350.25,
        'premiumRevenue': 200.50,
        'affiliateRevenue': 200.0,
        'cardsAdded': 85,
        'cardsRedeemed': 60,
        'totalCardValue': 4250.0,
        'flaggedTransactions': 3,
      };

      final stats = DailyStatsModel.fromJson(json);

      expect(stats.date, '2025-03-15');
      expect(stats.newUsers, 42);
      expect(stats.activeUsers, 150);
      expect(stats.totalTransactions, 300);
      expect(stats.totalRevenue, 1250.75);
      expect(stats.conversionRevenue, 500.0);
      expect(stats.interchangeRevenue, 350.25);
      expect(stats.premiumRevenue, 200.50);
      expect(stats.affiliateRevenue, 200.0);
      expect(stats.cardsAdded, 85);
      expect(stats.cardsRedeemed, 60);
      expect(stats.totalCardValue, 4250.0);
      expect(stats.flaggedTransactions, 3);
    });

    test('fromJson applies defaults when optional fields are absent', () {
      final json = {
        'date': '2025-01-01',
      };

      final stats = DailyStatsModel.fromJson(json);

      expect(stats.date, '2025-01-01');
      expect(stats.newUsers, 0);
      expect(stats.activeUsers, 0);
      expect(stats.totalTransactions, 0);
      expect(stats.totalRevenue, 0.0);
      expect(stats.conversionRevenue, 0.0);
      expect(stats.interchangeRevenue, 0.0);
      expect(stats.premiumRevenue, 0.0);
      expect(stats.affiliateRevenue, 0.0);
      expect(stats.cardsAdded, 0);
      expect(stats.cardsRedeemed, 0);
      expect(stats.totalCardValue, 0.0);
      expect(stats.flaggedTransactions, 0);
    });

    test('toJson then fromJson roundtrip preserves data', () {
      final original = createStats(
        date: '2025-03-15',
        newUsers: 10,
        activeUsers: 50,
        totalTransactions: 100,
        totalRevenue: 500.0,
        conversionRevenue: 200.0,
        interchangeRevenue: 150.0,
        premiumRevenue: 100.0,
        affiliateRevenue: 50.0,
        cardsAdded: 20,
        cardsRedeemed: 15,
        totalCardValue: 1000.0,
        flaggedTransactions: 2,
      );

      final json = original.toJson();
      final restored = DailyStatsModel.fromJson(json);

      expect(restored, original);
    });

    test('equality works for identical data (freezed ==)', () {
      final a = createStats();
      final b = createStats();
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      final a = createStats(newUsers: 0);
      final b = createStats(newUsers: 10);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      final original = createStats(totalRevenue: 100.0);
      final updated = original.copyWith(
        totalRevenue: 500.0,
        flaggedTransactions: 1,
      );

      expect(updated.totalRevenue, 500.0);
      expect(updated.flaggedTransactions, 1);
      // Unchanged fields remain
      expect(updated.date, original.date);
      expect(updated.newUsers, original.newUsers);
    });

    test('hashCode is equal for equal objects', () {
      final a = createStats();
      final b = createStats();
      expect(a.hashCode, b.hashCode);
    });
  });
}

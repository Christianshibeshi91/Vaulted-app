import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/data/models/card_model.dart';

void main() {
  final now = DateTime(2025, 3, 15, 10, 30);

  CardModel createCard({
    String id = 'card-1',
    String retailer = 'Amazon',
    String retailerColor = '#FF9900',
    double balance = 50.0,
    double originalBalance = 100.0,
    String currency = 'USD',
    String status = 'active',
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CardModel(
      id: id,
      retailer: retailer,
      retailerColor: retailerColor,
      balance: balance,
      originalBalance: originalBalance,
      currency: currency,
      status: status,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  group('CardModel', () {
    test('creates with required fields and correct defaults', () {
      final card = CardModel(
        id: 'c1',
        retailer: 'Target',
        retailerColor: '#CC0000',
        balance: 25.0,
        originalBalance: 25.0,
        createdAt: now,
        updatedAt: now,
      );

      expect(card.id, 'c1');
      expect(card.retailer, 'Target');
      expect(card.balance, 25.0);
      // Defaults
      expect(card.currency, 'USD');
      expect(card.status, 'active');
      expect(card.addedVia, 'manual');
      // Nullable fields default to null
      expect(card.cardNumberEncrypted, isNull);
      expect(card.pinEncrypted, isNull);
      expect(card.lastBalanceCheck, isNull);
      expect(card.expirationDate, isNull);
      expect(card.notes, isNull);
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'card-42',
        'retailer': 'Starbucks',
        'retailerColor': '#00704A',
        'cardNumberEncrypted': 'iv:cipher',
        'pinEncrypted': 'iv:pin',
        'balance': 15.50,
        'originalBalance': 25.0,
        'currency': 'EUR',
        'status': 'depleted',
        'lastBalanceCheck': '2025-03-10T08:00:00.000',
        'expirationDate': '2026-01-01T00:00:00.000',
        'notes': 'Birthday gift',
        'addedVia': 'scan',
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-03-15T10:30:00.000',
      };

      final card = CardModel.fromJson(json);

      expect(card.id, 'card-42');
      expect(card.retailer, 'Starbucks');
      expect(card.retailerColor, '#00704A');
      expect(card.cardNumberEncrypted, 'iv:cipher');
      expect(card.pinEncrypted, 'iv:pin');
      expect(card.balance, 15.50);
      expect(card.originalBalance, 25.0);
      expect(card.currency, 'EUR');
      expect(card.status, 'depleted');
      expect(card.notes, 'Birthday gift');
      expect(card.addedVia, 'scan');
    });

    test('fromJson applies defaults when fields are absent', () {
      final json = {
        'id': 'c2',
        'retailer': 'Nike',
        'retailerColor': '#000',
        'balance': 100.0,
        'originalBalance': 100.0,
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-01-01T00:00:00.000',
      };

      final card = CardModel.fromJson(json);

      expect(card.currency, 'USD');
      expect(card.status, 'active');
      expect(card.addedVia, 'manual');
    });

    test('toJson then fromJson roundtrip preserves data', () {
      final original = createCard(
        id: 'rt-1',
        retailer: 'BestBuy',
        retailerColor: '#0046BE',
        balance: 75.25,
        originalBalance: 100.0,
      );

      final json = original.toJson();
      final restored = CardModel.fromJson(json);

      expect(restored, original);
    });

    test('equality works for identical data (freezed ==)', () {
      final a = createCard();
      final b = createCard();
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      final a = createCard(balance: 50.0);
      final b = createCard(balance: 25.0);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      final original = createCard(balance: 100.0, status: 'active');
      final updated = original.copyWith(balance: 0, status: 'depleted');

      expect(updated.balance, 0);
      expect(updated.status, 'depleted');
      // Unchanged fields remain
      expect(updated.id, original.id);
      expect(updated.retailer, original.retailer);
    });

    test('hashCode is equal for equal objects', () {
      final a = createCard();
      final b = createCard();
      expect(a.hashCode, b.hashCode);
    });
  });

  // ── CardStatus Constants ──────────────────────────────────────

  group('CardStatus', () {
    test('has correct constant values', () {
      expect(CardStatus.active, 'active');
      expect(CardStatus.depleted, 'depleted');
      expect(CardStatus.expired, 'expired');
      expect(CardStatus.archived, 'archived');
    });

    test('all list contains all statuses', () {
      expect(CardStatus.all, hasLength(4));
      expect(CardStatus.all, contains(CardStatus.active));
      expect(CardStatus.all, contains(CardStatus.depleted));
      expect(CardStatus.all, contains(CardStatus.expired));
      expect(CardStatus.all, contains(CardStatus.archived));
    });

    test('label returns human-readable string for known statuses', () {
      expect(CardStatus.label('active'), 'Active');
      expect(CardStatus.label('depleted'), 'Depleted');
      expect(CardStatus.label('expired'), 'Expired');
      expect(CardStatus.label('archived'), 'Archived');
    });

    test('label returns raw value for unknown status', () {
      expect(CardStatus.label('unknown'), 'unknown');
    });
  });
}

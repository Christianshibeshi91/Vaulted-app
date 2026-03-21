import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/data/models/transaction_model.dart';

void main() {
  final testDate = DateTime(2025, 3, 15, 14, 30);

  TransactionModel createTransaction({
    String id = 'txn-1',
    String cardId = 'card-1',
    String retailer = 'Amazon',
    String type = 'purchase',
    double amount = 25.99,
    double balanceAfter = 74.01,
    String? description,
    String? merchant,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id,
      cardId: cardId,
      retailer: retailer,
      type: type,
      amount: amount,
      balanceAfter: balanceAfter,
      description: description,
      merchant: merchant,
      createdAt: createdAt ?? testDate,
    );
  }

  group('TransactionModel', () {
    test('creates with required fields', () {
      final txn = createTransaction();

      expect(txn.id, 'txn-1');
      expect(txn.cardId, 'card-1');
      expect(txn.retailer, 'Amazon');
      expect(txn.type, 'purchase');
      expect(txn.amount, 25.99);
      expect(txn.balanceAfter, 74.01);
      expect(txn.description, isNull);
      expect(txn.merchant, isNull);
      expect(txn.createdAt, testDate);
    });

    test('fromJson parses all fields', () {
      final json = {
        'id': 'txn-99',
        'cardId': 'card-5',
        'retailer': 'Target',
        'type': 'refund',
        'amount': 10.0,
        'balanceAfter': 60.0,
        'description': 'Return item',
        'merchant': 'Target Store #1234',
        'createdAt': '2025-03-15T14:30:00.000',
      };

      final txn = TransactionModel.fromJson(json);

      expect(txn.id, 'txn-99');
      expect(txn.cardId, 'card-5');
      expect(txn.retailer, 'Target');
      expect(txn.type, 'refund');
      expect(txn.amount, 10.0);
      expect(txn.balanceAfter, 60.0);
      expect(txn.description, 'Return item');
      expect(txn.merchant, 'Target Store #1234');
    });

    test('fromJson handles null optional fields', () {
      final json = {
        'id': 'txn-min',
        'cardId': 'card-1',
        'retailer': 'Nike',
        'type': 'purchase',
        'amount': 50.0,
        'balanceAfter': 50.0,
        'createdAt': '2025-01-01T00:00:00.000',
      };

      final txn = TransactionModel.fromJson(json);

      expect(txn.description, isNull);
      expect(txn.merchant, isNull);
    });

    test('toJson then fromJson roundtrip preserves data', () {
      final original = createTransaction(
        id: 'rt-1',
        description: 'Coffee order',
        merchant: 'Starbucks #42',
      );

      final json = original.toJson();
      final restored = TransactionModel.fromJson(json);

      expect(restored, original);
    });

    test('equality works for identical data (freezed ==)', () {
      final a = createTransaction();
      final b = createTransaction();
      expect(a, equals(b));
    });

    test('inequality when fields differ', () {
      final a = createTransaction(amount: 25.0);
      final b = createTransaction(amount: 50.0);
      expect(a, isNot(equals(b)));
    });

    test('copyWith creates modified copy', () {
      final original = createTransaction(type: 'purchase', amount: 30.0);
      final refunded = original.copyWith(
        type: 'refund',
        amount: 30.0,
        balanceAfter: 130.0,
      );

      expect(refunded.type, 'refund');
      expect(refunded.balanceAfter, 130.0);
      expect(refunded.id, original.id);
    });

    test('hashCode is equal for equal objects', () {
      final a = createTransaction();
      final b = createTransaction();
      expect(a.hashCode, b.hashCode);
    });
  });

  // ── TransactionType Constants ──────────────────────────────────

  group('TransactionType', () {
    test('has correct constant values', () {
      expect(TransactionType.purchase, 'purchase');
      expect(TransactionType.refund, 'refund');
      expect(TransactionType.balanceCheck, 'balance_check');
      expect(TransactionType.adjustment, 'adjustment');
      expect(TransactionType.transfer, 'transfer');
    });

    test('all list contains all types', () {
      expect(TransactionType.all, hasLength(5));
      expect(TransactionType.all, contains(TransactionType.purchase));
      expect(TransactionType.all, contains(TransactionType.refund));
      expect(TransactionType.all, contains(TransactionType.balanceCheck));
      expect(TransactionType.all, contains(TransactionType.adjustment));
      expect(TransactionType.all, contains(TransactionType.transfer));
    });

    test('label returns human-readable string for known types', () {
      expect(TransactionType.label('purchase'), 'Purchase');
      expect(TransactionType.label('refund'), 'Refund');
      expect(TransactionType.label('balance_check'), 'Balance Check');
      expect(TransactionType.label('adjustment'), 'Adjustment');
      expect(TransactionType.label('transfer'), 'Transfer');
    });

    test('label returns raw value for unknown type', () {
      expect(TransactionType.label('unknown_type'), 'unknown_type');
    });
  });
}

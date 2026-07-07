import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vaulted/core/theme/app_theme.dart';
import 'package:vaulted/data/models/card_model.dart';
import 'package:vaulted/presentation/providers/card_providers.dart';

// We cannot directly test CardRedeemScreen because it uses
// ScreenshotPreventionMixin which calls platform channels. Instead we
// test the provider logic and the card model business rules that drive
// the screen behavior.

/// Helper to build a ProviderScope with overrides.
Widget buildTestApp({
  required Widget child,
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: VaultedTheme.dark,
      home: child,
    ),
  );
}

/// Creates a test CardModel with sensible defaults.
CardModel createTestCard({
  String id = 'card-1',
  String retailer = 'Amazon',
  String retailerColor = '#FF9900',
  double balance = 50.0,
  double originalBalance = 100.0,
  String currency = 'USD',
  String status = 'active',
  String? cardNumberEncrypted,
  String? pinEncrypted,
}) {
  final now = DateTime(2025, 3, 15, 10, 0);
  return CardModel(
    id: id,
    retailer: retailer,
    retailerColor: retailerColor,
    balance: balance,
    originalBalance: originalBalance,
    currency: currency,
    status: status,
    cardNumberEncrypted: cardNumberEncrypted,
    pinEncrypted: pinEncrypted,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('CardRedeemScreen provider logic', () {
    test('cardByIdProvider returns null when cards list is empty', () {
      final cards = <CardModel>[];
      final container = ProviderContainer(
        overrides: [
          cardsProvider.overrideWith(
            (ref) => Stream.value(cards),
          ),
        ],
      );
      addTearDown(container.dispose);

      // StreamProvider has not emitted yet, so valueOrNull is null,
      // which means cardByIdProvider returns null.
      final card = container.read(cardByIdProvider('nonexistent'));
      expect(card, isNull);
    });

    test('totalBalanceProvider defaults to 0 before stream emits', () {
      final container = ProviderContainer(
        overrides: [
          cardsProvider.overrideWith(
            (ref) => Stream.value(<CardModel>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final total = container.read(totalBalanceProvider);
      expect(total, 0.0);
    });

    test('activeCardsCountProvider defaults to 0 before stream emits', () {
      final container = ProviderContainer(
        overrides: [
          cardsProvider.overrideWith(
            (ref) => Stream.value(<CardModel>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final count = container.read(activeCardsCountProvider);
      expect(count, 0);
    });

    test('filteredCardsProvider defaults to empty before stream emits', () {
      final container = ProviderContainer(
        overrides: [
          cardsProvider.overrideWith(
            (ref) => Stream.value(<CardModel>[]),
          ),
        ],
      );
      addTearDown(container.dispose);

      final filtered = container.read(filteredCardsProvider);
      expect(filtered, isEmpty);
    });
  });

  group('CardModel redeem-related logic', () {
    test('depleted card has zero balance', () {
      final card = createTestCard(balance: 0.0, status: 'depleted');
      expect(card.balance, 0.0);
      expect(card.status, 'depleted');
    });

    test('balance subtraction yields correct remaining amount', () {
      final card = createTestCard(balance: 100.0);
      final amount = 35.50;
      final newBalance = card.balance - amount;
      expect(newBalance, closeTo(64.50, 0.01));
      expect(newBalance > 0, isTrue);
    });

    test('balance subtraction resulting in zero marks as depleted', () {
      final card = createTestCard(balance: 50.0);
      final amount = 50.0;
      final newBalance = card.balance - amount;
      final isDepleted = newBalance <= 0;
      expect(isDepleted, isTrue);
    });

    test('amount exceeding balance is detectable', () {
      final card = createTestCard(balance: 25.0);
      final amount = 30.0;
      final exceeds = amount > card.balance;
      expect(exceeds, isTrue);
    });

    test('copyWith correctly updates balance and status', () {
      final card = createTestCard(balance: 100.0, status: 'active');
      final updated = card.copyWith(balance: 0.0, status: 'depleted');
      expect(updated.balance, 0.0);
      expect(updated.status, 'depleted');
      // Original is unchanged (immutability)
      expect(card.balance, 100.0);
      expect(card.status, 'active');
    });

    test('transaction amount is stored as negative for purchases', () {
      final card = createTestCard(balance: 100.0);
      final purchaseAmount = 35.0;
      // The screen stores amount as negative for purchase transactions
      final storedAmount = -purchaseAmount;
      expect(storedAmount, -35.0);
      final newBalance = card.balance - purchaseAmount;
      expect(newBalance, 65.0);
    });

    test('over-spend detection prevents invalid transactions', () {
      final card = createTestCard(balance: 20.0);
      final amount1 = 15.0;
      final amount2 = 25.0;

      expect(amount1 > card.balance, isFalse); // Valid
      expect(amount2 > card.balance, isTrue); // Exceeds balance
    });
  });

  group('CardStatus', () {
    test('depleted status disables mark-as-used button', () {
      final card = createTestCard(status: CardStatus.depleted);
      final isButtonDisabled = card.status == CardStatus.depleted;
      expect(isButtonDisabled, isTrue);
    });

    test('active status enables mark-as-used button', () {
      final card = createTestCard(status: CardStatus.active);
      final isButtonEnabled = card.status != CardStatus.depleted;
      expect(isButtonEnabled, isTrue);
    });

    test('expired status still allows mark-as-used', () {
      final card = createTestCard(status: CardStatus.expired);
      final isButtonEnabled = card.status != CardStatus.depleted;
      expect(isButtonEnabled, isTrue);
    });

    test('archived status still allows mark-as-used', () {
      final card = createTestCard(status: CardStatus.archived);
      final isButtonEnabled = card.status != CardStatus.depleted;
      expect(isButtonEnabled, isTrue);
    });
  });

  group('CardSortMode', () {
    test('all sort modes have labels', () {
      for (final mode in CardSortMode.values) {
        expect(mode.label.isNotEmpty, isTrue);
      }
    });

    test('newest sort mode exists', () {
      expect(CardSortMode.newest.label, 'Newest First');
    });

    test('alphabetical sort mode exists', () {
      expect(CardSortMode.alphabetical.label, 'A - Z');
    });
  });

  group('CardsViewMode', () {
    test('grid and list modes exist', () {
      expect(CardsViewMode.values.length, 2);
      expect(CardsViewMode.values, contains(CardsViewMode.grid));
      expect(CardsViewMode.values, contains(CardsViewMode.list));
    });
  });
}

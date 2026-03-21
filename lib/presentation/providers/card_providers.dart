import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/card_model.dart';
import '../../data/models/transaction_model.dart';

// ── Firestore card stream ────────────────────────────────────────

/// Streams all cards for the currently authenticated user,
/// ordered by [createdAt] descending (newest first).
final cardsProvider = StreamProvider<List<CardModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('cards')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return CardModel.fromJson(data);
          }).toList());
});

// ── Derived providers ────────────────────────────────────────────

/// Sum of all card balances.
final totalBalanceProvider = Provider<double>((ref) {
  final cards = ref.watch(cardsProvider).valueOrNull ?? [];
  return cards.fold(0.0, (total, card) => total + card.balance);
});

/// Count of cards with status == 'active'.
final activeCardsCountProvider = Provider<int>((ref) {
  final cards = ref.watch(cardsProvider).valueOrNull ?? [];
  return cards.where((c) => c.status == CardStatus.active).length;
});

/// Single card look-up by id.
final cardByIdProvider =
    Provider.family<CardModel?, String>((ref, cardId) {
  final cards = ref.watch(cardsProvider).valueOrNull ?? [];
  try {
    return cards.firstWhere((c) => c.id == cardId);
  } catch (_) {
    return null;
  }
});

// ── Transactions stream ──────────────────────────────────────────

/// Streams recent transactions across all cards, limited to 20.
final recentTransactionsProvider =
    StreamProvider<List<TransactionModel>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('transactions')
      .orderBy('createdAt', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return TransactionModel.fromJson(data);
          }).toList());
});

/// Transactions for a specific card.
final cardTransactionsProvider =
    StreamProvider.family<List<TransactionModel>, String>((ref, cardId) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('transactions')
      .where('cardId', isEqualTo: cardId)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return TransactionModel.fromJson(data);
          }).toList());
});

// ── Cards filter state ───────────────────────────────────────────

/// Active filter for the cards list screen.
final cardsFilterProvider = StateProvider<String>((ref) => 'all');

/// Search query for the cards list screen.
final cardsSearchProvider = StateProvider<String>((ref) => '');

/// Sort mode for the cards list screen.
final cardsSortProvider = StateProvider<CardSortMode>((ref) => CardSortMode.newest);

/// Grid vs list toggle.
final cardsViewModeProvider = StateProvider<CardsViewMode>((ref) => CardsViewMode.grid);

/// Filtered + searched + sorted cards.
final filteredCardsProvider = Provider<List<CardModel>>((ref) {
  final cards = ref.watch(cardsProvider).valueOrNull ?? [];
  final filter = ref.watch(cardsFilterProvider);
  final search = ref.watch(cardsSearchProvider).toLowerCase();
  final sort = ref.watch(cardsSortProvider);

  var result = cards.where((c) {
    if (filter != 'all' && c.status != filter) return false;
    if (search.isNotEmpty && !c.retailer.toLowerCase().contains(search)) {
      return false;
    }
    return true;
  }).toList();

  switch (sort) {
    case CardSortMode.newest:
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case CardSortMode.oldest:
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    case CardSortMode.highestBalance:
      result.sort((a, b) => b.balance.compareTo(a.balance));
    case CardSortMode.lowestBalance:
      result.sort((a, b) => a.balance.compareTo(b.balance));
    case CardSortMode.alphabetical:
      result.sort((a, b) => a.retailer.compareTo(b.retailer));
  }

  return result;
});

// ── Enums ────────────────────────────────────────────────────────

enum CardSortMode {
  newest('Newest First'),
  oldest('Oldest First'),
  highestBalance('Highest Balance'),
  lowestBalance('Lowest Balance'),
  alphabetical('A - Z');

  const CardSortMode(this.label);
  final String label;
}

enum CardsViewMode { grid, list }

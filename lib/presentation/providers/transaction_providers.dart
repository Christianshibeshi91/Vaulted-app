import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/transaction_model.dart';

// -- Filter state --------------------------------------------------------

/// Active filter for transaction type (null = all).
final txFilterTypeProvider = StateProvider<String?>((ref) => null);

/// Active date-range filter for transactions.
final txFilterDateRangeProvider = StateProvider<DateTimeRange?>((ref) => null);

// -- Paginated transaction list ------------------------------------------

/// Holds a page of transactions plus the Firestore cursor for the next page.
class TransactionPage {
  final List<TransactionModel> items;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const TransactionPage({
    required this.items,
    this.lastDocument,
    this.hasMore = true,
  });

  TransactionPage copyWithAppended(TransactionPage next) {
    return TransactionPage(
      items: [...items, ...next.items],
      lastDocument: next.lastDocument,
      hasMore: next.hasMore,
    );
  }
}

/// Notifier that manages paginated, filtered transaction fetching.
class TransactionListNotifier extends StateNotifier<AsyncValue<TransactionPage>> {
  final Ref _ref;

  TransactionListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _fetchInitial();
  }

  Future<void> _fetchInitial() async {
    state = const AsyncValue.loading();
    try {
      final page = await _fetchPage(null);
      state = AsyncValue.data(page);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _fetchInitial();

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore) return;

    try {
      final nextPage = await _fetchPage(current.lastDocument);
      state = AsyncValue.data(current.copyWithAppended(nextPage));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<TransactionPage> _fetchPage(DocumentSnapshot? startAfter) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const TransactionPage(items: [], hasMore: false);
    }

    final typeFilter = _ref.read(txFilterTypeProvider);
    final dateRange = _ref.read(txFilterDateRangeProvider);

    var query = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.pageSize);

    if (typeFilter != null) {
      query = query.where('type', isEqualTo: typeFilter);
    }
    if (dateRange != null) {
      query = query
          .where('createdAt', isGreaterThanOrEqualTo: dateRange.start)
          .where('createdAt', isLessThanOrEqualTo: dateRange.end);
    }
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final items = snapshot.docs.map((doc) {
      return TransactionModel.fromJson({'id': doc.id, ...doc.data()});
    }).toList();

    return TransactionPage(
      items: items,
      lastDocument: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == AppConstants.pageSize,
    );
  }
}

/// Provider for the paginated transaction list.
final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, AsyncValue<TransactionPage>>(
  (ref) => TransactionListNotifier(ref),
);

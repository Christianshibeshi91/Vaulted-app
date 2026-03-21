import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

/// A single balance-change event for a gift card.
///
/// Stored in Firestore `/users/{uid}/transactions/{id}`.
@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String cardId,
    required String retailer,
    required String type,
    required double amount,
    required double balanceAfter,
    String? description,
    String? merchant,
    required DateTime createdAt,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}

/// Transaction type constants.
abstract final class TransactionType {
  static const purchase = 'purchase';
  static const refund = 'refund';
  static const balanceCheck = 'balance_check';
  static const adjustment = 'adjustment';
  static const transfer = 'transfer';

  static const all = [purchase, refund, balanceCheck, adjustment, transfer];

  static String label(String type) => switch (type) {
        purchase => 'Purchase',
        refund => 'Refund',
        balanceCheck => 'Balance Check',
        adjustment => 'Adjustment',
        transfer => 'Transfer',
        _ => type,
      };
}

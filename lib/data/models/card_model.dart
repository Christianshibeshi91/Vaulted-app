import 'package:freezed_annotation/freezed_annotation.dart';

part 'card_model.freezed.dart';
part 'card_model.g.dart';

/// Gift card stored in Firestore `/users/{uid}/cards/{id}`.
///
/// Sensitive fields [cardNumberEncrypted] and [pinEncrypted] are
/// AES-256-CBC encrypted at rest via [EncryptionService].
@freezed
class CardModel with _$CardModel {
  const factory CardModel({
    required String id,
    required String retailer,
    required String retailerColor,
    String? cardNumberEncrypted,
    String? pinEncrypted,
    required double balance,
    required double originalBalance,
    @Default('USD') String currency,
    @Default('active') String status,
    DateTime? lastBalanceCheck,
    DateTime? expirationDate,
    String? notes,
    @Default('manual') String addedVia,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CardModel;

  factory CardModel.fromJson(Map<String, dynamic> json) =>
      _$CardModelFromJson(json);
}

/// Status constants to avoid stringly-typed comparisons.
abstract final class CardStatus {
  static const active = 'active';
  static const depleted = 'depleted';
  static const expired = 'expired';
  static const archived = 'archived';

  static const all = [active, depleted, expired, archived];

  /// Human-readable label for display.
  static String label(String status) => switch (status) {
        active => 'Active',
        depleted => 'Depleted',
        expired => 'Expired',
        archived => 'Archived',
        _ => status,
      };
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'card_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

CardModel _$CardModelFromJson(Map<String, dynamic> json) {
  return _CardModel.fromJson(json);
}

/// @nodoc
mixin _$CardModel {
  String get id => throw _privateConstructorUsedError;
  String get retailer => throw _privateConstructorUsedError;
  String get retailerColor => throw _privateConstructorUsedError;
  String? get cardNumberEncrypted => throw _privateConstructorUsedError;
  String? get pinEncrypted => throw _privateConstructorUsedError;
  double get balance => throw _privateConstructorUsedError;
  double get originalBalance => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  DateTime? get lastBalanceCheck => throw _privateConstructorUsedError;
  DateTime? get expirationDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String get addedVia => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this CardModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CardModelCopyWith<CardModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CardModelCopyWith<$Res> {
  factory $CardModelCopyWith(CardModel value, $Res Function(CardModel) then) =
      _$CardModelCopyWithImpl<$Res, CardModel>;
  @useResult
  $Res call({
    String id,
    String retailer,
    String retailerColor,
    String? cardNumberEncrypted,
    String? pinEncrypted,
    double balance,
    double originalBalance,
    String currency,
    String status,
    DateTime? lastBalanceCheck,
    DateTime? expirationDate,
    String? notes,
    String addedVia,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class _$CardModelCopyWithImpl<$Res, $Val extends CardModel>
    implements $CardModelCopyWith<$Res> {
  _$CardModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? retailer = null,
    Object? retailerColor = null,
    Object? cardNumberEncrypted = freezed,
    Object? pinEncrypted = freezed,
    Object? balance = null,
    Object? originalBalance = null,
    Object? currency = null,
    Object? status = null,
    Object? lastBalanceCheck = freezed,
    Object? expirationDate = freezed,
    Object? notes = freezed,
    Object? addedVia = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            retailer: null == retailer
                ? _value.retailer
                : retailer // ignore: cast_nullable_to_non_nullable
                      as String,
            retailerColor: null == retailerColor
                ? _value.retailerColor
                : retailerColor // ignore: cast_nullable_to_non_nullable
                      as String,
            cardNumberEncrypted: freezed == cardNumberEncrypted
                ? _value.cardNumberEncrypted
                : cardNumberEncrypted // ignore: cast_nullable_to_non_nullable
                      as String?,
            pinEncrypted: freezed == pinEncrypted
                ? _value.pinEncrypted
                : pinEncrypted // ignore: cast_nullable_to_non_nullable
                      as String?,
            balance: null == balance
                ? _value.balance
                : balance // ignore: cast_nullable_to_non_nullable
                      as double,
            originalBalance: null == originalBalance
                ? _value.originalBalance
                : originalBalance // ignore: cast_nullable_to_non_nullable
                      as double,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            lastBalanceCheck: freezed == lastBalanceCheck
                ? _value.lastBalanceCheck
                : lastBalanceCheck // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            expirationDate: freezed == expirationDate
                ? _value.expirationDate
                : expirationDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            addedVia: null == addedVia
                ? _value.addedVia
                : addedVia // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CardModelImplCopyWith<$Res>
    implements $CardModelCopyWith<$Res> {
  factory _$$CardModelImplCopyWith(
    _$CardModelImpl value,
    $Res Function(_$CardModelImpl) then,
  ) = __$$CardModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String retailer,
    String retailerColor,
    String? cardNumberEncrypted,
    String? pinEncrypted,
    double balance,
    double originalBalance,
    String currency,
    String status,
    DateTime? lastBalanceCheck,
    DateTime? expirationDate,
    String? notes,
    String addedVia,
    DateTime createdAt,
    DateTime updatedAt,
  });
}

/// @nodoc
class __$$CardModelImplCopyWithImpl<$Res>
    extends _$CardModelCopyWithImpl<$Res, _$CardModelImpl>
    implements _$$CardModelImplCopyWith<$Res> {
  __$$CardModelImplCopyWithImpl(
    _$CardModelImpl _value,
    $Res Function(_$CardModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CardModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? retailer = null,
    Object? retailerColor = null,
    Object? cardNumberEncrypted = freezed,
    Object? pinEncrypted = freezed,
    Object? balance = null,
    Object? originalBalance = null,
    Object? currency = null,
    Object? status = null,
    Object? lastBalanceCheck = freezed,
    Object? expirationDate = freezed,
    Object? notes = freezed,
    Object? addedVia = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$CardModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        retailer: null == retailer
            ? _value.retailer
            : retailer // ignore: cast_nullable_to_non_nullable
                  as String,
        retailerColor: null == retailerColor
            ? _value.retailerColor
            : retailerColor // ignore: cast_nullable_to_non_nullable
                  as String,
        cardNumberEncrypted: freezed == cardNumberEncrypted
            ? _value.cardNumberEncrypted
            : cardNumberEncrypted // ignore: cast_nullable_to_non_nullable
                  as String?,
        pinEncrypted: freezed == pinEncrypted
            ? _value.pinEncrypted
            : pinEncrypted // ignore: cast_nullable_to_non_nullable
                  as String?,
        balance: null == balance
            ? _value.balance
            : balance // ignore: cast_nullable_to_non_nullable
                  as double,
        originalBalance: null == originalBalance
            ? _value.originalBalance
            : originalBalance // ignore: cast_nullable_to_non_nullable
                  as double,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        lastBalanceCheck: freezed == lastBalanceCheck
            ? _value.lastBalanceCheck
            : lastBalanceCheck // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        expirationDate: freezed == expirationDate
            ? _value.expirationDate
            : expirationDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        addedVia: null == addedVia
            ? _value.addedVia
            : addedVia // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CardModelImpl implements _CardModel {
  const _$CardModelImpl({
    required this.id,
    required this.retailer,
    required this.retailerColor,
    this.cardNumberEncrypted,
    this.pinEncrypted,
    required this.balance,
    required this.originalBalance,
    this.currency = 'USD',
    this.status = 'active',
    this.lastBalanceCheck,
    this.expirationDate,
    this.notes,
    this.addedVia = 'manual',
    required this.createdAt,
    required this.updatedAt,
  });

  factory _$CardModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CardModelImplFromJson(json);

  @override
  final String id;
  @override
  final String retailer;
  @override
  final String retailerColor;
  @override
  final String? cardNumberEncrypted;
  @override
  final String? pinEncrypted;
  @override
  final double balance;
  @override
  final double originalBalance;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final String status;
  @override
  final DateTime? lastBalanceCheck;
  @override
  final DateTime? expirationDate;
  @override
  final String? notes;
  @override
  @JsonKey()
  final String addedVia;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'CardModel(id: $id, retailer: $retailer, retailerColor: $retailerColor, cardNumberEncrypted: $cardNumberEncrypted, pinEncrypted: $pinEncrypted, balance: $balance, originalBalance: $originalBalance, currency: $currency, status: $status, lastBalanceCheck: $lastBalanceCheck, expirationDate: $expirationDate, notes: $notes, addedVia: $addedVia, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CardModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.retailer, retailer) ||
                other.retailer == retailer) &&
            (identical(other.retailerColor, retailerColor) ||
                other.retailerColor == retailerColor) &&
            (identical(other.cardNumberEncrypted, cardNumberEncrypted) ||
                other.cardNumberEncrypted == cardNumberEncrypted) &&
            (identical(other.pinEncrypted, pinEncrypted) ||
                other.pinEncrypted == pinEncrypted) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.originalBalance, originalBalance) ||
                other.originalBalance == originalBalance) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastBalanceCheck, lastBalanceCheck) ||
                other.lastBalanceCheck == lastBalanceCheck) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.addedVia, addedVia) ||
                other.addedVia == addedVia) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    retailer,
    retailerColor,
    cardNumberEncrypted,
    pinEncrypted,
    balance,
    originalBalance,
    currency,
    status,
    lastBalanceCheck,
    expirationDate,
    notes,
    addedVia,
    createdAt,
    updatedAt,
  );

  /// Create a copy of CardModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CardModelImplCopyWith<_$CardModelImpl> get copyWith =>
      __$$CardModelImplCopyWithImpl<_$CardModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CardModelImplToJson(this);
  }
}

abstract class _CardModel implements CardModel {
  const factory _CardModel({
    required final String id,
    required final String retailer,
    required final String retailerColor,
    final String? cardNumberEncrypted,
    final String? pinEncrypted,
    required final double balance,
    required final double originalBalance,
    final String currency,
    final String status,
    final DateTime? lastBalanceCheck,
    final DateTime? expirationDate,
    final String? notes,
    final String addedVia,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$CardModelImpl;

  factory _CardModel.fromJson(Map<String, dynamic> json) =
      _$CardModelImpl.fromJson;

  @override
  String get id;
  @override
  String get retailer;
  @override
  String get retailerColor;
  @override
  String? get cardNumberEncrypted;
  @override
  String? get pinEncrypted;
  @override
  double get balance;
  @override
  double get originalBalance;
  @override
  String get currency;
  @override
  String get status;
  @override
  DateTime? get lastBalanceCheck;
  @override
  DateTime? get expirationDate;
  @override
  String? get notes;
  @override
  String get addedVia;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of CardModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CardModelImplCopyWith<_$CardModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

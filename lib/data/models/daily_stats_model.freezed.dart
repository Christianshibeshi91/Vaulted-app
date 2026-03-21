// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DailyStatsModel _$DailyStatsModelFromJson(Map<String, dynamic> json) {
  return _DailyStatsModel.fromJson(json);
}

/// @nodoc
mixin _$DailyStatsModel {
  String get date => throw _privateConstructorUsedError; // ISO 8601 yyyy-MM-dd
  int get newUsers => throw _privateConstructorUsedError;
  int get activeUsers => throw _privateConstructorUsedError;
  int get totalTransactions => throw _privateConstructorUsedError;
  double get totalRevenue => throw _privateConstructorUsedError;
  double get conversionRevenue => throw _privateConstructorUsedError;
  double get interchangeRevenue => throw _privateConstructorUsedError;
  double get premiumRevenue => throw _privateConstructorUsedError;
  double get affiliateRevenue => throw _privateConstructorUsedError;
  int get cardsAdded => throw _privateConstructorUsedError;
  int get cardsRedeemed => throw _privateConstructorUsedError;
  double get totalCardValue => throw _privateConstructorUsedError;
  int get flaggedTransactions => throw _privateConstructorUsedError;

  /// Serializes this DailyStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyStatsModelCopyWith<DailyStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyStatsModelCopyWith<$Res> {
  factory $DailyStatsModelCopyWith(
    DailyStatsModel value,
    $Res Function(DailyStatsModel) then,
  ) = _$DailyStatsModelCopyWithImpl<$Res, DailyStatsModel>;
  @useResult
  $Res call({
    String date,
    int newUsers,
    int activeUsers,
    int totalTransactions,
    double totalRevenue,
    double conversionRevenue,
    double interchangeRevenue,
    double premiumRevenue,
    double affiliateRevenue,
    int cardsAdded,
    int cardsRedeemed,
    double totalCardValue,
    int flaggedTransactions,
  });
}

/// @nodoc
class _$DailyStatsModelCopyWithImpl<$Res, $Val extends DailyStatsModel>
    implements $DailyStatsModelCopyWith<$Res> {
  _$DailyStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? newUsers = null,
    Object? activeUsers = null,
    Object? totalTransactions = null,
    Object? totalRevenue = null,
    Object? conversionRevenue = null,
    Object? interchangeRevenue = null,
    Object? premiumRevenue = null,
    Object? affiliateRevenue = null,
    Object? cardsAdded = null,
    Object? cardsRedeemed = null,
    Object? totalCardValue = null,
    Object? flaggedTransactions = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            newUsers: null == newUsers
                ? _value.newUsers
                : newUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            activeUsers: null == activeUsers
                ? _value.activeUsers
                : activeUsers // ignore: cast_nullable_to_non_nullable
                      as int,
            totalTransactions: null == totalTransactions
                ? _value.totalTransactions
                : totalTransactions // ignore: cast_nullable_to_non_nullable
                      as int,
            totalRevenue: null == totalRevenue
                ? _value.totalRevenue
                : totalRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            conversionRevenue: null == conversionRevenue
                ? _value.conversionRevenue
                : conversionRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            interchangeRevenue: null == interchangeRevenue
                ? _value.interchangeRevenue
                : interchangeRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            premiumRevenue: null == premiumRevenue
                ? _value.premiumRevenue
                : premiumRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            affiliateRevenue: null == affiliateRevenue
                ? _value.affiliateRevenue
                : affiliateRevenue // ignore: cast_nullable_to_non_nullable
                      as double,
            cardsAdded: null == cardsAdded
                ? _value.cardsAdded
                : cardsAdded // ignore: cast_nullable_to_non_nullable
                      as int,
            cardsRedeemed: null == cardsRedeemed
                ? _value.cardsRedeemed
                : cardsRedeemed // ignore: cast_nullable_to_non_nullable
                      as int,
            totalCardValue: null == totalCardValue
                ? _value.totalCardValue
                : totalCardValue // ignore: cast_nullable_to_non_nullable
                      as double,
            flaggedTransactions: null == flaggedTransactions
                ? _value.flaggedTransactions
                : flaggedTransactions // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyStatsModelImplCopyWith<$Res>
    implements $DailyStatsModelCopyWith<$Res> {
  factory _$$DailyStatsModelImplCopyWith(
    _$DailyStatsModelImpl value,
    $Res Function(_$DailyStatsModelImpl) then,
  ) = __$$DailyStatsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String date,
    int newUsers,
    int activeUsers,
    int totalTransactions,
    double totalRevenue,
    double conversionRevenue,
    double interchangeRevenue,
    double premiumRevenue,
    double affiliateRevenue,
    int cardsAdded,
    int cardsRedeemed,
    double totalCardValue,
    int flaggedTransactions,
  });
}

/// @nodoc
class __$$DailyStatsModelImplCopyWithImpl<$Res>
    extends _$DailyStatsModelCopyWithImpl<$Res, _$DailyStatsModelImpl>
    implements _$$DailyStatsModelImplCopyWith<$Res> {
  __$$DailyStatsModelImplCopyWithImpl(
    _$DailyStatsModelImpl _value,
    $Res Function(_$DailyStatsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? newUsers = null,
    Object? activeUsers = null,
    Object? totalTransactions = null,
    Object? totalRevenue = null,
    Object? conversionRevenue = null,
    Object? interchangeRevenue = null,
    Object? premiumRevenue = null,
    Object? affiliateRevenue = null,
    Object? cardsAdded = null,
    Object? cardsRedeemed = null,
    Object? totalCardValue = null,
    Object? flaggedTransactions = null,
  }) {
    return _then(
      _$DailyStatsModelImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        newUsers: null == newUsers
            ? _value.newUsers
            : newUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        activeUsers: null == activeUsers
            ? _value.activeUsers
            : activeUsers // ignore: cast_nullable_to_non_nullable
                  as int,
        totalTransactions: null == totalTransactions
            ? _value.totalTransactions
            : totalTransactions // ignore: cast_nullable_to_non_nullable
                  as int,
        totalRevenue: null == totalRevenue
            ? _value.totalRevenue
            : totalRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        conversionRevenue: null == conversionRevenue
            ? _value.conversionRevenue
            : conversionRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        interchangeRevenue: null == interchangeRevenue
            ? _value.interchangeRevenue
            : interchangeRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        premiumRevenue: null == premiumRevenue
            ? _value.premiumRevenue
            : premiumRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        affiliateRevenue: null == affiliateRevenue
            ? _value.affiliateRevenue
            : affiliateRevenue // ignore: cast_nullable_to_non_nullable
                  as double,
        cardsAdded: null == cardsAdded
            ? _value.cardsAdded
            : cardsAdded // ignore: cast_nullable_to_non_nullable
                  as int,
        cardsRedeemed: null == cardsRedeemed
            ? _value.cardsRedeemed
            : cardsRedeemed // ignore: cast_nullable_to_non_nullable
                  as int,
        totalCardValue: null == totalCardValue
            ? _value.totalCardValue
            : totalCardValue // ignore: cast_nullable_to_non_nullable
                  as double,
        flaggedTransactions: null == flaggedTransactions
            ? _value.flaggedTransactions
            : flaggedTransactions // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyStatsModelImpl implements _DailyStatsModel {
  const _$DailyStatsModelImpl({
    required this.date,
    this.newUsers = 0,
    this.activeUsers = 0,
    this.totalTransactions = 0,
    this.totalRevenue = 0.0,
    this.conversionRevenue = 0.0,
    this.interchangeRevenue = 0.0,
    this.premiumRevenue = 0.0,
    this.affiliateRevenue = 0.0,
    this.cardsAdded = 0,
    this.cardsRedeemed = 0,
    this.totalCardValue = 0.0,
    this.flaggedTransactions = 0,
  });

  factory _$DailyStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyStatsModelImplFromJson(json);

  @override
  final String date;
  // ISO 8601 yyyy-MM-dd
  @override
  @JsonKey()
  final int newUsers;
  @override
  @JsonKey()
  final int activeUsers;
  @override
  @JsonKey()
  final int totalTransactions;
  @override
  @JsonKey()
  final double totalRevenue;
  @override
  @JsonKey()
  final double conversionRevenue;
  @override
  @JsonKey()
  final double interchangeRevenue;
  @override
  @JsonKey()
  final double premiumRevenue;
  @override
  @JsonKey()
  final double affiliateRevenue;
  @override
  @JsonKey()
  final int cardsAdded;
  @override
  @JsonKey()
  final int cardsRedeemed;
  @override
  @JsonKey()
  final double totalCardValue;
  @override
  @JsonKey()
  final int flaggedTransactions;

  @override
  String toString() {
    return 'DailyStatsModel(date: $date, newUsers: $newUsers, activeUsers: $activeUsers, totalTransactions: $totalTransactions, totalRevenue: $totalRevenue, conversionRevenue: $conversionRevenue, interchangeRevenue: $interchangeRevenue, premiumRevenue: $premiumRevenue, affiliateRevenue: $affiliateRevenue, cardsAdded: $cardsAdded, cardsRedeemed: $cardsRedeemed, totalCardValue: $totalCardValue, flaggedTransactions: $flaggedTransactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyStatsModelImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.newUsers, newUsers) ||
                other.newUsers == newUsers) &&
            (identical(other.activeUsers, activeUsers) ||
                other.activeUsers == activeUsers) &&
            (identical(other.totalTransactions, totalTransactions) ||
                other.totalTransactions == totalTransactions) &&
            (identical(other.totalRevenue, totalRevenue) ||
                other.totalRevenue == totalRevenue) &&
            (identical(other.conversionRevenue, conversionRevenue) ||
                other.conversionRevenue == conversionRevenue) &&
            (identical(other.interchangeRevenue, interchangeRevenue) ||
                other.interchangeRevenue == interchangeRevenue) &&
            (identical(other.premiumRevenue, premiumRevenue) ||
                other.premiumRevenue == premiumRevenue) &&
            (identical(other.affiliateRevenue, affiliateRevenue) ||
                other.affiliateRevenue == affiliateRevenue) &&
            (identical(other.cardsAdded, cardsAdded) ||
                other.cardsAdded == cardsAdded) &&
            (identical(other.cardsRedeemed, cardsRedeemed) ||
                other.cardsRedeemed == cardsRedeemed) &&
            (identical(other.totalCardValue, totalCardValue) ||
                other.totalCardValue == totalCardValue) &&
            (identical(other.flaggedTransactions, flaggedTransactions) ||
                other.flaggedTransactions == flaggedTransactions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    newUsers,
    activeUsers,
    totalTransactions,
    totalRevenue,
    conversionRevenue,
    interchangeRevenue,
    premiumRevenue,
    affiliateRevenue,
    cardsAdded,
    cardsRedeemed,
    totalCardValue,
    flaggedTransactions,
  );

  /// Create a copy of DailyStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyStatsModelImplCopyWith<_$DailyStatsModelImpl> get copyWith =>
      __$$DailyStatsModelImplCopyWithImpl<_$DailyStatsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyStatsModelImplToJson(this);
  }
}

abstract class _DailyStatsModel implements DailyStatsModel {
  const factory _DailyStatsModel({
    required final String date,
    final int newUsers,
    final int activeUsers,
    final int totalTransactions,
    final double totalRevenue,
    final double conversionRevenue,
    final double interchangeRevenue,
    final double premiumRevenue,
    final double affiliateRevenue,
    final int cardsAdded,
    final int cardsRedeemed,
    final double totalCardValue,
    final int flaggedTransactions,
  }) = _$DailyStatsModelImpl;

  factory _DailyStatsModel.fromJson(Map<String, dynamic> json) =
      _$DailyStatsModelImpl.fromJson;

  @override
  String get date; // ISO 8601 yyyy-MM-dd
  @override
  int get newUsers;
  @override
  int get activeUsers;
  @override
  int get totalTransactions;
  @override
  double get totalRevenue;
  @override
  double get conversionRevenue;
  @override
  double get interchangeRevenue;
  @override
  double get premiumRevenue;
  @override
  double get affiliateRevenue;
  @override
  int get cardsAdded;
  @override
  int get cardsRedeemed;
  @override
  double get totalCardValue;
  @override
  int get flaggedTransactions;

  /// Create a copy of DailyStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyStatsModelImplCopyWith<_$DailyStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

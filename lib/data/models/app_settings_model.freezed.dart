// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppSettingsModel _$AppSettingsModelFromJson(Map<String, dynamic> json) {
  return _AppSettingsModel.fromJson(json);
}

/// @nodoc
mixin _$AppSettingsModel {
  // ── Fees ──────────────────────────────────────────────────────
  double get defaultFeePercent => throw _privateConstructorUsedError;
  double get premiumFeePercent => throw _privateConstructorUsedError;
  double get minFeeAmount => throw _privateConstructorUsedError;
  double get maxFeeAmount =>
      throw _privateConstructorUsedError; // ── Card Issuing ─────────────────────────────────────────────
  bool get cardIssuingEnabled => throw _privateConstructorUsedError;
  String get cardNetwork => throw _privateConstructorUsedError;
  double get dailyCardLimit => throw _privateConstructorUsedError;
  double get monthlyCardLimit =>
      throw _privateConstructorUsedError; // ── Fraud ────────────────────────────────────────────────────
  double get autoFlagThreshold => throw _privateConstructorUsedError;
  int get velocityLimit => throw _privateConstructorUsedError;
  int get newUserDelayHours => throw _privateConstructorUsedError;
  double get kycThreshold =>
      throw _privateConstructorUsedError; // ── Notifications ────────────────────────────────────────────
  bool get notifyFlaggedTransactions => throw _privateConstructorUsedError;
  bool get notifyDailyRevenue => throw _privateConstructorUsedError;
  bool get notifyNewSignups => throw _privateConstructorUsedError;
  bool get notifyWeeklyDigest =>
      throw _privateConstructorUsedError; // ── Maintenance ──────────────────────────────────────────────
  bool get maintenanceEnabled => throw _privateConstructorUsedError;
  String get maintenanceMessage => throw _privateConstructorUsedError;

  /// Serializes this AppSettingsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppSettingsModelCopyWith<AppSettingsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppSettingsModelCopyWith<$Res> {
  factory $AppSettingsModelCopyWith(
    AppSettingsModel value,
    $Res Function(AppSettingsModel) then,
  ) = _$AppSettingsModelCopyWithImpl<$Res, AppSettingsModel>;
  @useResult
  $Res call({
    double defaultFeePercent,
    double premiumFeePercent,
    double minFeeAmount,
    double maxFeeAmount,
    bool cardIssuingEnabled,
    String cardNetwork,
    double dailyCardLimit,
    double monthlyCardLimit,
    double autoFlagThreshold,
    int velocityLimit,
    int newUserDelayHours,
    double kycThreshold,
    bool notifyFlaggedTransactions,
    bool notifyDailyRevenue,
    bool notifyNewSignups,
    bool notifyWeeklyDigest,
    bool maintenanceEnabled,
    String maintenanceMessage,
  });
}

/// @nodoc
class _$AppSettingsModelCopyWithImpl<$Res, $Val extends AppSettingsModel>
    implements $AppSettingsModelCopyWith<$Res> {
  _$AppSettingsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? defaultFeePercent = null,
    Object? premiumFeePercent = null,
    Object? minFeeAmount = null,
    Object? maxFeeAmount = null,
    Object? cardIssuingEnabled = null,
    Object? cardNetwork = null,
    Object? dailyCardLimit = null,
    Object? monthlyCardLimit = null,
    Object? autoFlagThreshold = null,
    Object? velocityLimit = null,
    Object? newUserDelayHours = null,
    Object? kycThreshold = null,
    Object? notifyFlaggedTransactions = null,
    Object? notifyDailyRevenue = null,
    Object? notifyNewSignups = null,
    Object? notifyWeeklyDigest = null,
    Object? maintenanceEnabled = null,
    Object? maintenanceMessage = null,
  }) {
    return _then(
      _value.copyWith(
            defaultFeePercent: null == defaultFeePercent
                ? _value.defaultFeePercent
                : defaultFeePercent // ignore: cast_nullable_to_non_nullable
                      as double,
            premiumFeePercent: null == premiumFeePercent
                ? _value.premiumFeePercent
                : premiumFeePercent // ignore: cast_nullable_to_non_nullable
                      as double,
            minFeeAmount: null == minFeeAmount
                ? _value.minFeeAmount
                : minFeeAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            maxFeeAmount: null == maxFeeAmount
                ? _value.maxFeeAmount
                : maxFeeAmount // ignore: cast_nullable_to_non_nullable
                      as double,
            cardIssuingEnabled: null == cardIssuingEnabled
                ? _value.cardIssuingEnabled
                : cardIssuingEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            cardNetwork: null == cardNetwork
                ? _value.cardNetwork
                : cardNetwork // ignore: cast_nullable_to_non_nullable
                      as String,
            dailyCardLimit: null == dailyCardLimit
                ? _value.dailyCardLimit
                : dailyCardLimit // ignore: cast_nullable_to_non_nullable
                      as double,
            monthlyCardLimit: null == monthlyCardLimit
                ? _value.monthlyCardLimit
                : monthlyCardLimit // ignore: cast_nullable_to_non_nullable
                      as double,
            autoFlagThreshold: null == autoFlagThreshold
                ? _value.autoFlagThreshold
                : autoFlagThreshold // ignore: cast_nullable_to_non_nullable
                      as double,
            velocityLimit: null == velocityLimit
                ? _value.velocityLimit
                : velocityLimit // ignore: cast_nullable_to_non_nullable
                      as int,
            newUserDelayHours: null == newUserDelayHours
                ? _value.newUserDelayHours
                : newUserDelayHours // ignore: cast_nullable_to_non_nullable
                      as int,
            kycThreshold: null == kycThreshold
                ? _value.kycThreshold
                : kycThreshold // ignore: cast_nullable_to_non_nullable
                      as double,
            notifyFlaggedTransactions: null == notifyFlaggedTransactions
                ? _value.notifyFlaggedTransactions
                : notifyFlaggedTransactions // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyDailyRevenue: null == notifyDailyRevenue
                ? _value.notifyDailyRevenue
                : notifyDailyRevenue // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyNewSignups: null == notifyNewSignups
                ? _value.notifyNewSignups
                : notifyNewSignups // ignore: cast_nullable_to_non_nullable
                      as bool,
            notifyWeeklyDigest: null == notifyWeeklyDigest
                ? _value.notifyWeeklyDigest
                : notifyWeeklyDigest // ignore: cast_nullable_to_non_nullable
                      as bool,
            maintenanceEnabled: null == maintenanceEnabled
                ? _value.maintenanceEnabled
                : maintenanceEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            maintenanceMessage: null == maintenanceMessage
                ? _value.maintenanceMessage
                : maintenanceMessage // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppSettingsModelImplCopyWith<$Res>
    implements $AppSettingsModelCopyWith<$Res> {
  factory _$$AppSettingsModelImplCopyWith(
    _$AppSettingsModelImpl value,
    $Res Function(_$AppSettingsModelImpl) then,
  ) = __$$AppSettingsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double defaultFeePercent,
    double premiumFeePercent,
    double minFeeAmount,
    double maxFeeAmount,
    bool cardIssuingEnabled,
    String cardNetwork,
    double dailyCardLimit,
    double monthlyCardLimit,
    double autoFlagThreshold,
    int velocityLimit,
    int newUserDelayHours,
    double kycThreshold,
    bool notifyFlaggedTransactions,
    bool notifyDailyRevenue,
    bool notifyNewSignups,
    bool notifyWeeklyDigest,
    bool maintenanceEnabled,
    String maintenanceMessage,
  });
}

/// @nodoc
class __$$AppSettingsModelImplCopyWithImpl<$Res>
    extends _$AppSettingsModelCopyWithImpl<$Res, _$AppSettingsModelImpl>
    implements _$$AppSettingsModelImplCopyWith<$Res> {
  __$$AppSettingsModelImplCopyWithImpl(
    _$AppSettingsModelImpl _value,
    $Res Function(_$AppSettingsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? defaultFeePercent = null,
    Object? premiumFeePercent = null,
    Object? minFeeAmount = null,
    Object? maxFeeAmount = null,
    Object? cardIssuingEnabled = null,
    Object? cardNetwork = null,
    Object? dailyCardLimit = null,
    Object? monthlyCardLimit = null,
    Object? autoFlagThreshold = null,
    Object? velocityLimit = null,
    Object? newUserDelayHours = null,
    Object? kycThreshold = null,
    Object? notifyFlaggedTransactions = null,
    Object? notifyDailyRevenue = null,
    Object? notifyNewSignups = null,
    Object? notifyWeeklyDigest = null,
    Object? maintenanceEnabled = null,
    Object? maintenanceMessage = null,
  }) {
    return _then(
      _$AppSettingsModelImpl(
        defaultFeePercent: null == defaultFeePercent
            ? _value.defaultFeePercent
            : defaultFeePercent // ignore: cast_nullable_to_non_nullable
                  as double,
        premiumFeePercent: null == premiumFeePercent
            ? _value.premiumFeePercent
            : premiumFeePercent // ignore: cast_nullable_to_non_nullable
                  as double,
        minFeeAmount: null == minFeeAmount
            ? _value.minFeeAmount
            : minFeeAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        maxFeeAmount: null == maxFeeAmount
            ? _value.maxFeeAmount
            : maxFeeAmount // ignore: cast_nullable_to_non_nullable
                  as double,
        cardIssuingEnabled: null == cardIssuingEnabled
            ? _value.cardIssuingEnabled
            : cardIssuingEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        cardNetwork: null == cardNetwork
            ? _value.cardNetwork
            : cardNetwork // ignore: cast_nullable_to_non_nullable
                  as String,
        dailyCardLimit: null == dailyCardLimit
            ? _value.dailyCardLimit
            : dailyCardLimit // ignore: cast_nullable_to_non_nullable
                  as double,
        monthlyCardLimit: null == monthlyCardLimit
            ? _value.monthlyCardLimit
            : monthlyCardLimit // ignore: cast_nullable_to_non_nullable
                  as double,
        autoFlagThreshold: null == autoFlagThreshold
            ? _value.autoFlagThreshold
            : autoFlagThreshold // ignore: cast_nullable_to_non_nullable
                  as double,
        velocityLimit: null == velocityLimit
            ? _value.velocityLimit
            : velocityLimit // ignore: cast_nullable_to_non_nullable
                  as int,
        newUserDelayHours: null == newUserDelayHours
            ? _value.newUserDelayHours
            : newUserDelayHours // ignore: cast_nullable_to_non_nullable
                  as int,
        kycThreshold: null == kycThreshold
            ? _value.kycThreshold
            : kycThreshold // ignore: cast_nullable_to_non_nullable
                  as double,
        notifyFlaggedTransactions: null == notifyFlaggedTransactions
            ? _value.notifyFlaggedTransactions
            : notifyFlaggedTransactions // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyDailyRevenue: null == notifyDailyRevenue
            ? _value.notifyDailyRevenue
            : notifyDailyRevenue // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyNewSignups: null == notifyNewSignups
            ? _value.notifyNewSignups
            : notifyNewSignups // ignore: cast_nullable_to_non_nullable
                  as bool,
        notifyWeeklyDigest: null == notifyWeeklyDigest
            ? _value.notifyWeeklyDigest
            : notifyWeeklyDigest // ignore: cast_nullable_to_non_nullable
                  as bool,
        maintenanceEnabled: null == maintenanceEnabled
            ? _value.maintenanceEnabled
            : maintenanceEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        maintenanceMessage: null == maintenanceMessage
            ? _value.maintenanceMessage
            : maintenanceMessage // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppSettingsModelImpl implements _AppSettingsModel {
  const _$AppSettingsModelImpl({
    this.defaultFeePercent = 2.5,
    this.premiumFeePercent = 1.5,
    this.minFeeAmount = 1.0,
    this.maxFeeAmount = 50.0,
    this.cardIssuingEnabled = true,
    this.cardNetwork = 'visa',
    this.dailyCardLimit = 500.0,
    this.monthlyCardLimit = 5000.0,
    this.autoFlagThreshold = 1000.0,
    this.velocityLimit = 5,
    this.newUserDelayHours = 24,
    this.kycThreshold = 500.0,
    this.notifyFlaggedTransactions = true,
    this.notifyDailyRevenue = true,
    this.notifyNewSignups = true,
    this.notifyWeeklyDigest = false,
    this.maintenanceEnabled = false,
    this.maintenanceMessage = '',
  });

  factory _$AppSettingsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppSettingsModelImplFromJson(json);

  // ── Fees ──────────────────────────────────────────────────────
  @override
  @JsonKey()
  final double defaultFeePercent;
  @override
  @JsonKey()
  final double premiumFeePercent;
  @override
  @JsonKey()
  final double minFeeAmount;
  @override
  @JsonKey()
  final double maxFeeAmount;
  // ── Card Issuing ─────────────────────────────────────────────
  @override
  @JsonKey()
  final bool cardIssuingEnabled;
  @override
  @JsonKey()
  final String cardNetwork;
  @override
  @JsonKey()
  final double dailyCardLimit;
  @override
  @JsonKey()
  final double monthlyCardLimit;
  // ── Fraud ────────────────────────────────────────────────────
  @override
  @JsonKey()
  final double autoFlagThreshold;
  @override
  @JsonKey()
  final int velocityLimit;
  @override
  @JsonKey()
  final int newUserDelayHours;
  @override
  @JsonKey()
  final double kycThreshold;
  // ── Notifications ────────────────────────────────────────────
  @override
  @JsonKey()
  final bool notifyFlaggedTransactions;
  @override
  @JsonKey()
  final bool notifyDailyRevenue;
  @override
  @JsonKey()
  final bool notifyNewSignups;
  @override
  @JsonKey()
  final bool notifyWeeklyDigest;
  // ── Maintenance ──────────────────────────────────────────────
  @override
  @JsonKey()
  final bool maintenanceEnabled;
  @override
  @JsonKey()
  final String maintenanceMessage;

  @override
  String toString() {
    return 'AppSettingsModel(defaultFeePercent: $defaultFeePercent, premiumFeePercent: $premiumFeePercent, minFeeAmount: $minFeeAmount, maxFeeAmount: $maxFeeAmount, cardIssuingEnabled: $cardIssuingEnabled, cardNetwork: $cardNetwork, dailyCardLimit: $dailyCardLimit, monthlyCardLimit: $monthlyCardLimit, autoFlagThreshold: $autoFlagThreshold, velocityLimit: $velocityLimit, newUserDelayHours: $newUserDelayHours, kycThreshold: $kycThreshold, notifyFlaggedTransactions: $notifyFlaggedTransactions, notifyDailyRevenue: $notifyDailyRevenue, notifyNewSignups: $notifyNewSignups, notifyWeeklyDigest: $notifyWeeklyDigest, maintenanceEnabled: $maintenanceEnabled, maintenanceMessage: $maintenanceMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppSettingsModelImpl &&
            (identical(other.defaultFeePercent, defaultFeePercent) ||
                other.defaultFeePercent == defaultFeePercent) &&
            (identical(other.premiumFeePercent, premiumFeePercent) ||
                other.premiumFeePercent == premiumFeePercent) &&
            (identical(other.minFeeAmount, minFeeAmount) ||
                other.minFeeAmount == minFeeAmount) &&
            (identical(other.maxFeeAmount, maxFeeAmount) ||
                other.maxFeeAmount == maxFeeAmount) &&
            (identical(other.cardIssuingEnabled, cardIssuingEnabled) ||
                other.cardIssuingEnabled == cardIssuingEnabled) &&
            (identical(other.cardNetwork, cardNetwork) ||
                other.cardNetwork == cardNetwork) &&
            (identical(other.dailyCardLimit, dailyCardLimit) ||
                other.dailyCardLimit == dailyCardLimit) &&
            (identical(other.monthlyCardLimit, monthlyCardLimit) ||
                other.monthlyCardLimit == monthlyCardLimit) &&
            (identical(other.autoFlagThreshold, autoFlagThreshold) ||
                other.autoFlagThreshold == autoFlagThreshold) &&
            (identical(other.velocityLimit, velocityLimit) ||
                other.velocityLimit == velocityLimit) &&
            (identical(other.newUserDelayHours, newUserDelayHours) ||
                other.newUserDelayHours == newUserDelayHours) &&
            (identical(other.kycThreshold, kycThreshold) ||
                other.kycThreshold == kycThreshold) &&
            (identical(
                  other.notifyFlaggedTransactions,
                  notifyFlaggedTransactions,
                ) ||
                other.notifyFlaggedTransactions == notifyFlaggedTransactions) &&
            (identical(other.notifyDailyRevenue, notifyDailyRevenue) ||
                other.notifyDailyRevenue == notifyDailyRevenue) &&
            (identical(other.notifyNewSignups, notifyNewSignups) ||
                other.notifyNewSignups == notifyNewSignups) &&
            (identical(other.notifyWeeklyDigest, notifyWeeklyDigest) ||
                other.notifyWeeklyDigest == notifyWeeklyDigest) &&
            (identical(other.maintenanceEnabled, maintenanceEnabled) ||
                other.maintenanceEnabled == maintenanceEnabled) &&
            (identical(other.maintenanceMessage, maintenanceMessage) ||
                other.maintenanceMessage == maintenanceMessage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    defaultFeePercent,
    premiumFeePercent,
    minFeeAmount,
    maxFeeAmount,
    cardIssuingEnabled,
    cardNetwork,
    dailyCardLimit,
    monthlyCardLimit,
    autoFlagThreshold,
    velocityLimit,
    newUserDelayHours,
    kycThreshold,
    notifyFlaggedTransactions,
    notifyDailyRevenue,
    notifyNewSignups,
    notifyWeeklyDigest,
    maintenanceEnabled,
    maintenanceMessage,
  );

  /// Create a copy of AppSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppSettingsModelImplCopyWith<_$AppSettingsModelImpl> get copyWith =>
      __$$AppSettingsModelImplCopyWithImpl<_$AppSettingsModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppSettingsModelImplToJson(this);
  }
}

abstract class _AppSettingsModel implements AppSettingsModel {
  const factory _AppSettingsModel({
    final double defaultFeePercent,
    final double premiumFeePercent,
    final double minFeeAmount,
    final double maxFeeAmount,
    final bool cardIssuingEnabled,
    final String cardNetwork,
    final double dailyCardLimit,
    final double monthlyCardLimit,
    final double autoFlagThreshold,
    final int velocityLimit,
    final int newUserDelayHours,
    final double kycThreshold,
    final bool notifyFlaggedTransactions,
    final bool notifyDailyRevenue,
    final bool notifyNewSignups,
    final bool notifyWeeklyDigest,
    final bool maintenanceEnabled,
    final String maintenanceMessage,
  }) = _$AppSettingsModelImpl;

  factory _AppSettingsModel.fromJson(Map<String, dynamic> json) =
      _$AppSettingsModelImpl.fromJson;

  // ── Fees ──────────────────────────────────────────────────────
  @override
  double get defaultFeePercent;
  @override
  double get premiumFeePercent;
  @override
  double get minFeeAmount;
  @override
  double get maxFeeAmount; // ── Card Issuing ─────────────────────────────────────────────
  @override
  bool get cardIssuingEnabled;
  @override
  String get cardNetwork;
  @override
  double get dailyCardLimit;
  @override
  double get monthlyCardLimit; // ── Fraud ────────────────────────────────────────────────────
  @override
  double get autoFlagThreshold;
  @override
  int get velocityLimit;
  @override
  int get newUserDelayHours;
  @override
  double get kycThreshold; // ── Notifications ────────────────────────────────────────────
  @override
  bool get notifyFlaggedTransactions;
  @override
  bool get notifyDailyRevenue;
  @override
  bool get notifyNewSignups;
  @override
  bool get notifyWeeklyDigest; // ── Maintenance ──────────────────────────────────────────────
  @override
  bool get maintenanceEnabled;
  @override
  String get maintenanceMessage;

  /// Create a copy of AppSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppSettingsModelImplCopyWith<_$AppSettingsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

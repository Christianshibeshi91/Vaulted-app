// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get displayName => throw _privateConstructorUsedError;
  String? get avatarUrl => throw _privateConstructorUsedError;
  String get role => throw _privateConstructorUsedError;
  String get plan => throw _privateConstructorUsedError;
  bool get mfaEnabled => throw _privateConstructorUsedError;
  bool get biometricEnabled => throw _privateConstructorUsedError;
  bool get onboardingComplete => throw _privateConstructorUsedError;
  String? get pushToken => throw _privateConstructorUsedError;
  int get autoLockMinutes => throw _privateConstructorUsedError;
  Map<String, bool>? get notificationPreferences =>
      throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;
  int get loginCount => throw _privateConstructorUsedError;
  bool get isSuspended => throw _privateConstructorUsedError;
  String? get suspensionReason => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call({
    String uid,
    String email,
    String? displayName,
    String? avatarUrl,
    String role,
    String plan,
    bool mfaEnabled,
    bool biometricEnabled,
    bool onboardingComplete,
    String? pushToken,
    int autoLockMinutes,
    Map<String, bool>? notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    int loginCount,
    bool isSuspended,
    String? suspensionReason,
  });
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? plan = null,
    Object? mfaEnabled = null,
    Object? biometricEnabled = null,
    Object? onboardingComplete = null,
    Object? pushToken = freezed,
    Object? autoLockMinutes = null,
    Object? notificationPreferences = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastLoginAt = freezed,
    Object? loginCount = null,
    Object? isSuspended = null,
    Object? suspensionReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            uid: null == uid
                ? _value.uid
                : uid // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as String,
            plan: null == plan
                ? _value.plan
                : plan // ignore: cast_nullable_to_non_nullable
                      as String,
            mfaEnabled: null == mfaEnabled
                ? _value.mfaEnabled
                : mfaEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            biometricEnabled: null == biometricEnabled
                ? _value.biometricEnabled
                : biometricEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            onboardingComplete: null == onboardingComplete
                ? _value.onboardingComplete
                : onboardingComplete // ignore: cast_nullable_to_non_nullable
                      as bool,
            pushToken: freezed == pushToken
                ? _value.pushToken
                : pushToken // ignore: cast_nullable_to_non_nullable
                      as String?,
            autoLockMinutes: null == autoLockMinutes
                ? _value.autoLockMinutes
                : autoLockMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            notificationPreferences: freezed == notificationPreferences
                ? _value.notificationPreferences
                : notificationPreferences // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            lastLoginAt: freezed == lastLoginAt
                ? _value.lastLoginAt
                : lastLoginAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            loginCount: null == loginCount
                ? _value.loginCount
                : loginCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isSuspended: null == isSuspended
                ? _value.isSuspended
                : isSuspended // ignore: cast_nullable_to_non_nullable
                      as bool,
            suspensionReason: freezed == suspensionReason
                ? _value.suspensionReason
                : suspensionReason // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
    _$UserModelImpl value,
    $Res Function(_$UserModelImpl) then,
  ) = __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String uid,
    String email,
    String? displayName,
    String? avatarUrl,
    String role,
    String plan,
    bool mfaEnabled,
    bool biometricEnabled,
    bool onboardingComplete,
    String? pushToken,
    int autoLockMinutes,
    Map<String, bool>? notificationPreferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    int loginCount,
    bool isSuspended,
    String? suspensionReason,
  });
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
    _$UserModelImpl _value,
    $Res Function(_$UserModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? role = null,
    Object? plan = null,
    Object? mfaEnabled = null,
    Object? biometricEnabled = null,
    Object? onboardingComplete = null,
    Object? pushToken = freezed,
    Object? autoLockMinutes = null,
    Object? notificationPreferences = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastLoginAt = freezed,
    Object? loginCount = null,
    Object? isSuspended = null,
    Object? suspensionReason = freezed,
  }) {
    return _then(
      _$UserModelImpl(
        uid: null == uid
            ? _value.uid
            : uid // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as String,
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as String,
        mfaEnabled: null == mfaEnabled
            ? _value.mfaEnabled
            : mfaEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        biometricEnabled: null == biometricEnabled
            ? _value.biometricEnabled
            : biometricEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        onboardingComplete: null == onboardingComplete
            ? _value.onboardingComplete
            : onboardingComplete // ignore: cast_nullable_to_non_nullable
                  as bool,
        pushToken: freezed == pushToken
            ? _value.pushToken
            : pushToken // ignore: cast_nullable_to_non_nullable
                  as String?,
        autoLockMinutes: null == autoLockMinutes
            ? _value.autoLockMinutes
            : autoLockMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        notificationPreferences: freezed == notificationPreferences
            ? _value._notificationPreferences
            : notificationPreferences // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        lastLoginAt: freezed == lastLoginAt
            ? _value.lastLoginAt
            : lastLoginAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        loginCount: null == loginCount
            ? _value.loginCount
            : loginCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isSuspended: null == isSuspended
            ? _value.isSuspended
            : isSuspended // ignore: cast_nullable_to_non_nullable
                  as bool,
        suspensionReason: freezed == suspensionReason
            ? _value.suspensionReason
            : suspensionReason // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl({
    required this.uid,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.role = 'user',
    this.plan = 'free',
    this.mfaEnabled = false,
    this.biometricEnabled = false,
    this.onboardingComplete = false,
    this.pushToken,
    this.autoLockMinutes = 5,
    final Map<String, bool>? notificationPreferences,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.loginCount = 0,
    this.isSuspended = false,
    this.suspensionReason,
  }) : _notificationPreferences = notificationPreferences;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String uid;
  @override
  final String email;
  @override
  final String? displayName;
  @override
  final String? avatarUrl;
  @override
  @JsonKey()
  final String role;
  @override
  @JsonKey()
  final String plan;
  @override
  @JsonKey()
  final bool mfaEnabled;
  @override
  @JsonKey()
  final bool biometricEnabled;
  @override
  @JsonKey()
  final bool onboardingComplete;
  @override
  final String? pushToken;
  @override
  @JsonKey()
  final int autoLockMinutes;
  final Map<String, bool>? _notificationPreferences;
  @override
  Map<String, bool>? get notificationPreferences {
    final value = _notificationPreferences;
    if (value == null) return null;
    if (_notificationPreferences is EqualUnmodifiableMapView)
      return _notificationPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? lastLoginAt;
  @override
  @JsonKey()
  final int loginCount;
  @override
  @JsonKey()
  final bool isSuspended;
  @override
  final String? suspensionReason;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, avatarUrl: $avatarUrl, role: $role, plan: $plan, mfaEnabled: $mfaEnabled, biometricEnabled: $biometricEnabled, onboardingComplete: $onboardingComplete, pushToken: $pushToken, autoLockMinutes: $autoLockMinutes, notificationPreferences: $notificationPreferences, createdAt: $createdAt, updatedAt: $updatedAt, lastLoginAt: $lastLoginAt, loginCount: $loginCount, isSuspended: $isSuspended, suspensionReason: $suspensionReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.mfaEnabled, mfaEnabled) ||
                other.mfaEnabled == mfaEnabled) &&
            (identical(other.biometricEnabled, biometricEnabled) ||
                other.biometricEnabled == biometricEnabled) &&
            (identical(other.onboardingComplete, onboardingComplete) ||
                other.onboardingComplete == onboardingComplete) &&
            (identical(other.pushToken, pushToken) ||
                other.pushToken == pushToken) &&
            (identical(other.autoLockMinutes, autoLockMinutes) ||
                other.autoLockMinutes == autoLockMinutes) &&
            const DeepCollectionEquality().equals(
              other._notificationPreferences,
              _notificationPreferences,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.loginCount, loginCount) ||
                other.loginCount == loginCount) &&
            (identical(other.isSuspended, isSuspended) ||
                other.isSuspended == isSuspended) &&
            (identical(other.suspensionReason, suspensionReason) ||
                other.suspensionReason == suspensionReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    uid,
    email,
    displayName,
    avatarUrl,
    role,
    plan,
    mfaEnabled,
    biometricEnabled,
    onboardingComplete,
    pushToken,
    autoLockMinutes,
    const DeepCollectionEquality().hash(_notificationPreferences),
    createdAt,
    updatedAt,
    lastLoginAt,
    loginCount,
    isSuspended,
    suspensionReason,
  );

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(this);
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel({
    required final String uid,
    required final String email,
    final String? displayName,
    final String? avatarUrl,
    final String role,
    final String plan,
    final bool mfaEnabled,
    final bool biometricEnabled,
    final bool onboardingComplete,
    final String? pushToken,
    final int autoLockMinutes,
    final Map<String, bool>? notificationPreferences,
    final DateTime? createdAt,
    final DateTime? updatedAt,
    final DateTime? lastLoginAt,
    final int loginCount,
    final bool isSuspended,
    final String? suspensionReason,
  }) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get uid;
  @override
  String get email;
  @override
  String? get displayName;
  @override
  String? get avatarUrl;
  @override
  String get role;
  @override
  String get plan;
  @override
  bool get mfaEnabled;
  @override
  bool get biometricEnabled;
  @override
  bool get onboardingComplete;
  @override
  String? get pushToken;
  @override
  int get autoLockMinutes;
  @override
  Map<String, bool>? get notificationPreferences;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get lastLoginAt;
  @override
  int get loginCount;
  @override
  bool get isSuspended;
  @override
  String? get suspensionReason;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

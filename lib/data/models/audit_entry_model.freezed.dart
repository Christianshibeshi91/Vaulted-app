// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'audit_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AuditEntryModel _$AuditEntryModelFromJson(Map<String, dynamic> json) {
  return _AuditEntryModel.fromJson(json);
}

/// @nodoc
mixin _$AuditEntryModel {
  String get id => throw _privateConstructorUsedError;
  String get adminUid => throw _privateConstructorUsedError;
  String get adminEmail => throw _privateConstructorUsedError;
  String? get adminDisplayName => throw _privateConstructorUsedError;
  String get action => throw _privateConstructorUsedError;
  String get targetType =>
      throw _privateConstructorUsedError; // user, card, transaction, setting, feature_flag
  String? get targetId => throw _privateConstructorUsedError;
  String? get targetLabel => throw _privateConstructorUsedError;
  String? get details => throw _privateConstructorUsedError;
  Map<String, dynamic>? get previousValue => throw _privateConstructorUsedError;
  Map<String, dynamic>? get newValue => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get ipAddress => throw _privateConstructorUsedError;

  /// Serializes this AuditEntryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuditEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuditEntryModelCopyWith<AuditEntryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuditEntryModelCopyWith<$Res> {
  factory $AuditEntryModelCopyWith(
    AuditEntryModel value,
    $Res Function(AuditEntryModel) then,
  ) = _$AuditEntryModelCopyWithImpl<$Res, AuditEntryModel>;
  @useResult
  $Res call({
    String id,
    String adminUid,
    String adminEmail,
    String? adminDisplayName,
    String action,
    String targetType,
    String? targetId,
    String? targetLabel,
    String? details,
    Map<String, dynamic>? previousValue,
    Map<String, dynamic>? newValue,
    DateTime timestamp,
    String? ipAddress,
  });
}

/// @nodoc
class _$AuditEntryModelCopyWithImpl<$Res, $Val extends AuditEntryModel>
    implements $AuditEntryModelCopyWith<$Res> {
  _$AuditEntryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuditEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? adminUid = null,
    Object? adminEmail = null,
    Object? adminDisplayName = freezed,
    Object? action = null,
    Object? targetType = null,
    Object? targetId = freezed,
    Object? targetLabel = freezed,
    Object? details = freezed,
    Object? previousValue = freezed,
    Object? newValue = freezed,
    Object? timestamp = null,
    Object? ipAddress = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            adminUid: null == adminUid
                ? _value.adminUid
                : adminUid // ignore: cast_nullable_to_non_nullable
                      as String,
            adminEmail: null == adminEmail
                ? _value.adminEmail
                : adminEmail // ignore: cast_nullable_to_non_nullable
                      as String,
            adminDisplayName: freezed == adminDisplayName
                ? _value.adminDisplayName
                : adminDisplayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            action: null == action
                ? _value.action
                : action // ignore: cast_nullable_to_non_nullable
                      as String,
            targetType: null == targetType
                ? _value.targetType
                : targetType // ignore: cast_nullable_to_non_nullable
                      as String,
            targetId: freezed == targetId
                ? _value.targetId
                : targetId // ignore: cast_nullable_to_non_nullable
                      as String?,
            targetLabel: freezed == targetLabel
                ? _value.targetLabel
                : targetLabel // ignore: cast_nullable_to_non_nullable
                      as String?,
            details: freezed == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as String?,
            previousValue: freezed == previousValue
                ? _value.previousValue
                : previousValue // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            newValue: freezed == newValue
                ? _value.newValue
                : newValue // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            ipAddress: freezed == ipAddress
                ? _value.ipAddress
                : ipAddress // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AuditEntryModelImplCopyWith<$Res>
    implements $AuditEntryModelCopyWith<$Res> {
  factory _$$AuditEntryModelImplCopyWith(
    _$AuditEntryModelImpl value,
    $Res Function(_$AuditEntryModelImpl) then,
  ) = __$$AuditEntryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String adminUid,
    String adminEmail,
    String? adminDisplayName,
    String action,
    String targetType,
    String? targetId,
    String? targetLabel,
    String? details,
    Map<String, dynamic>? previousValue,
    Map<String, dynamic>? newValue,
    DateTime timestamp,
    String? ipAddress,
  });
}

/// @nodoc
class __$$AuditEntryModelImplCopyWithImpl<$Res>
    extends _$AuditEntryModelCopyWithImpl<$Res, _$AuditEntryModelImpl>
    implements _$$AuditEntryModelImplCopyWith<$Res> {
  __$$AuditEntryModelImplCopyWithImpl(
    _$AuditEntryModelImpl _value,
    $Res Function(_$AuditEntryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuditEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? adminUid = null,
    Object? adminEmail = null,
    Object? adminDisplayName = freezed,
    Object? action = null,
    Object? targetType = null,
    Object? targetId = freezed,
    Object? targetLabel = freezed,
    Object? details = freezed,
    Object? previousValue = freezed,
    Object? newValue = freezed,
    Object? timestamp = null,
    Object? ipAddress = freezed,
  }) {
    return _then(
      _$AuditEntryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        adminUid: null == adminUid
            ? _value.adminUid
            : adminUid // ignore: cast_nullable_to_non_nullable
                  as String,
        adminEmail: null == adminEmail
            ? _value.adminEmail
            : adminEmail // ignore: cast_nullable_to_non_nullable
                  as String,
        adminDisplayName: freezed == adminDisplayName
            ? _value.adminDisplayName
            : adminDisplayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        action: null == action
            ? _value.action
            : action // ignore: cast_nullable_to_non_nullable
                  as String,
        targetType: null == targetType
            ? _value.targetType
            : targetType // ignore: cast_nullable_to_non_nullable
                  as String,
        targetId: freezed == targetId
            ? _value.targetId
            : targetId // ignore: cast_nullable_to_non_nullable
                  as String?,
        targetLabel: freezed == targetLabel
            ? _value.targetLabel
            : targetLabel // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value.details
            : details // ignore: cast_nullable_to_non_nullable
                  as String?,
        previousValue: freezed == previousValue
            ? _value._previousValue
            : previousValue // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        newValue: freezed == newValue
            ? _value._newValue
            : newValue // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        ipAddress: freezed == ipAddress
            ? _value.ipAddress
            : ipAddress // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuditEntryModelImpl implements _AuditEntryModel {
  const _$AuditEntryModelImpl({
    required this.id,
    required this.adminUid,
    required this.adminEmail,
    this.adminDisplayName,
    required this.action,
    required this.targetType,
    this.targetId,
    this.targetLabel,
    this.details,
    final Map<String, dynamic>? previousValue,
    final Map<String, dynamic>? newValue,
    required this.timestamp,
    this.ipAddress,
  }) : _previousValue = previousValue,
       _newValue = newValue;

  factory _$AuditEntryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuditEntryModelImplFromJson(json);

  @override
  final String id;
  @override
  final String adminUid;
  @override
  final String adminEmail;
  @override
  final String? adminDisplayName;
  @override
  final String action;
  @override
  final String targetType;
  // user, card, transaction, setting, feature_flag
  @override
  final String? targetId;
  @override
  final String? targetLabel;
  @override
  final String? details;
  final Map<String, dynamic>? _previousValue;
  @override
  Map<String, dynamic>? get previousValue {
    final value = _previousValue;
    if (value == null) return null;
    if (_previousValue is EqualUnmodifiableMapView) return _previousValue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _newValue;
  @override
  Map<String, dynamic>? get newValue {
    final value = _newValue;
    if (value == null) return null;
    if (_newValue is EqualUnmodifiableMapView) return _newValue;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final DateTime timestamp;
  @override
  final String? ipAddress;

  @override
  String toString() {
    return 'AuditEntryModel(id: $id, adminUid: $adminUid, adminEmail: $adminEmail, adminDisplayName: $adminDisplayName, action: $action, targetType: $targetType, targetId: $targetId, targetLabel: $targetLabel, details: $details, previousValue: $previousValue, newValue: $newValue, timestamp: $timestamp, ipAddress: $ipAddress)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuditEntryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.adminUid, adminUid) ||
                other.adminUid == adminUid) &&
            (identical(other.adminEmail, adminEmail) ||
                other.adminEmail == adminEmail) &&
            (identical(other.adminDisplayName, adminDisplayName) ||
                other.adminDisplayName == adminDisplayName) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetLabel, targetLabel) ||
                other.targetLabel == targetLabel) &&
            (identical(other.details, details) || other.details == details) &&
            const DeepCollectionEquality().equals(
              other._previousValue,
              _previousValue,
            ) &&
            const DeepCollectionEquality().equals(other._newValue, _newValue) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.ipAddress, ipAddress) ||
                other.ipAddress == ipAddress));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    adminUid,
    adminEmail,
    adminDisplayName,
    action,
    targetType,
    targetId,
    targetLabel,
    details,
    const DeepCollectionEquality().hash(_previousValue),
    const DeepCollectionEquality().hash(_newValue),
    timestamp,
    ipAddress,
  );

  /// Create a copy of AuditEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuditEntryModelImplCopyWith<_$AuditEntryModelImpl> get copyWith =>
      __$$AuditEntryModelImplCopyWithImpl<_$AuditEntryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AuditEntryModelImplToJson(this);
  }
}

abstract class _AuditEntryModel implements AuditEntryModel {
  const factory _AuditEntryModel({
    required final String id,
    required final String adminUid,
    required final String adminEmail,
    final String? adminDisplayName,
    required final String action,
    required final String targetType,
    final String? targetId,
    final String? targetLabel,
    final String? details,
    final Map<String, dynamic>? previousValue,
    final Map<String, dynamic>? newValue,
    required final DateTime timestamp,
    final String? ipAddress,
  }) = _$AuditEntryModelImpl;

  factory _AuditEntryModel.fromJson(Map<String, dynamic> json) =
      _$AuditEntryModelImpl.fromJson;

  @override
  String get id;
  @override
  String get adminUid;
  @override
  String get adminEmail;
  @override
  String? get adminDisplayName;
  @override
  String get action;
  @override
  String get targetType; // user, card, transaction, setting, feature_flag
  @override
  String? get targetId;
  @override
  String? get targetLabel;
  @override
  String? get details;
  @override
  Map<String, dynamic>? get previousValue;
  @override
  Map<String, dynamic>? get newValue;
  @override
  DateTime get timestamp;
  @override
  String? get ipAddress;

  /// Create a copy of AuditEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuditEntryModelImplCopyWith<_$AuditEntryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

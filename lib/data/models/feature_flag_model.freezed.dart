// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feature_flag_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FeatureFlagModel _$FeatureFlagModelFromJson(Map<String, dynamic> json) {
  return _FeatureFlagModel.fromJson(json);
}

/// @nodoc
mixin _$FeatureFlagModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  bool get isEnabled => throw _privateConstructorUsedError;
  int get rolloutPercentage => throw _privateConstructorUsedError;
  String? get enabledBy => throw _privateConstructorUsedError;
  DateTime? get enabledAt => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this FeatureFlagModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeatureFlagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeatureFlagModelCopyWith<FeatureFlagModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeatureFlagModelCopyWith<$Res> {
  factory $FeatureFlagModelCopyWith(
    FeatureFlagModel value,
    $Res Function(FeatureFlagModel) then,
  ) = _$FeatureFlagModelCopyWithImpl<$Res, FeatureFlagModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    bool isEnabled,
    int rolloutPercentage,
    String? enabledBy,
    DateTime? enabledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$FeatureFlagModelCopyWithImpl<$Res, $Val extends FeatureFlagModel>
    implements $FeatureFlagModelCopyWith<$Res> {
  _$FeatureFlagModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeatureFlagModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? isEnabled = null,
    Object? rolloutPercentage = null,
    Object? enabledBy = freezed,
    Object? enabledAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            isEnabled: null == isEnabled
                ? _value.isEnabled
                : isEnabled // ignore: cast_nullable_to_non_nullable
                      as bool,
            rolloutPercentage: null == rolloutPercentage
                ? _value.rolloutPercentage
                : rolloutPercentage // ignore: cast_nullable_to_non_nullable
                      as int,
            enabledBy: freezed == enabledBy
                ? _value.enabledBy
                : enabledBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            enabledAt: freezed == enabledAt
                ? _value.enabledAt
                : enabledAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FeatureFlagModelImplCopyWith<$Res>
    implements $FeatureFlagModelCopyWith<$Res> {
  factory _$$FeatureFlagModelImplCopyWith(
    _$FeatureFlagModelImpl value,
    $Res Function(_$FeatureFlagModelImpl) then,
  ) = __$$FeatureFlagModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    bool isEnabled,
    int rolloutPercentage,
    String? enabledBy,
    DateTime? enabledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$FeatureFlagModelImplCopyWithImpl<$Res>
    extends _$FeatureFlagModelCopyWithImpl<$Res, _$FeatureFlagModelImpl>
    implements _$$FeatureFlagModelImplCopyWith<$Res> {
  __$$FeatureFlagModelImplCopyWithImpl(
    _$FeatureFlagModelImpl _value,
    $Res Function(_$FeatureFlagModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeatureFlagModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? isEnabled = null,
    Object? rolloutPercentage = null,
    Object? enabledBy = freezed,
    Object? enabledAt = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$FeatureFlagModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        isEnabled: null == isEnabled
            ? _value.isEnabled
            : isEnabled // ignore: cast_nullable_to_non_nullable
                  as bool,
        rolloutPercentage: null == rolloutPercentage
            ? _value.rolloutPercentage
            : rolloutPercentage // ignore: cast_nullable_to_non_nullable
                  as int,
        enabledBy: freezed == enabledBy
            ? _value.enabledBy
            : enabledBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        enabledAt: freezed == enabledAt
            ? _value.enabledAt
            : enabledAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeatureFlagModelImpl implements _FeatureFlagModel {
  const _$FeatureFlagModelImpl({
    required this.id,
    required this.name,
    required this.description,
    this.isEnabled = false,
    this.rolloutPercentage = 100,
    this.enabledBy,
    this.enabledAt,
    this.createdAt,
    this.updatedAt,
  });

  factory _$FeatureFlagModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeatureFlagModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey()
  final bool isEnabled;
  @override
  @JsonKey()
  final int rolloutPercentage;
  @override
  final String? enabledBy;
  @override
  final DateTime? enabledAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'FeatureFlagModel(id: $id, name: $name, description: $description, isEnabled: $isEnabled, rolloutPercentage: $rolloutPercentage, enabledBy: $enabledBy, enabledAt: $enabledAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeatureFlagModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.rolloutPercentage, rolloutPercentage) ||
                other.rolloutPercentage == rolloutPercentage) &&
            (identical(other.enabledBy, enabledBy) ||
                other.enabledBy == enabledBy) &&
            (identical(other.enabledAt, enabledAt) ||
                other.enabledAt == enabledAt) &&
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
    name,
    description,
    isEnabled,
    rolloutPercentage,
    enabledBy,
    enabledAt,
    createdAt,
    updatedAt,
  );

  /// Create a copy of FeatureFlagModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeatureFlagModelImplCopyWith<_$FeatureFlagModelImpl> get copyWith =>
      __$$FeatureFlagModelImplCopyWithImpl<_$FeatureFlagModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FeatureFlagModelImplToJson(this);
  }
}

abstract class _FeatureFlagModel implements FeatureFlagModel {
  const factory _FeatureFlagModel({
    required final String id,
    required final String name,
    required final String description,
    final bool isEnabled,
    final int rolloutPercentage,
    final String? enabledBy,
    final DateTime? enabledAt,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$FeatureFlagModelImpl;

  factory _FeatureFlagModel.fromJson(Map<String, dynamic> json) =
      _$FeatureFlagModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  bool get isEnabled;
  @override
  int get rolloutPercentage;
  @override
  String? get enabledBy;
  @override
  DateTime? get enabledAt;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of FeatureFlagModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeatureFlagModelImplCopyWith<_$FeatureFlagModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

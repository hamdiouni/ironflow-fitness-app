// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BodyEntryModel _$BodyEntryModelFromJson(Map<String, dynamic> json) {
  return _BodyEntryModel.fromJson(json);
}

/// @nodoc
mixin _$BodyEntryModel {
  String get id => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError; // ISO 8601 string
  double get weight => throw _privateConstructorUsedError;
  Map<String, double> get measurements =>
      throw _privateConstructorUsedError; // MeasurementType.name → double
  String? get photoPath =>
      throw _privateConstructorUsedError; // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  String? get userId =>
      throw _privateConstructorUsedError; // Phase 2: LWW key + tombstone (ISO 8601 strings).
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get deletedAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BodyEntryModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BodyEntryModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BodyEntryModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this BodyEntryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BodyEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BodyEntryModelCopyWith<BodyEntryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodyEntryModelCopyWith<$Res> {
  factory $BodyEntryModelCopyWith(
    BodyEntryModel value,
    $Res Function(BodyEntryModel) then,
  ) = _$BodyEntryModelCopyWithImpl<$Res, BodyEntryModel>;
  @useResult
  $Res call({
    String id,
    String date,
    double weight,
    Map<String, double> measurements,
    String? photoPath,
    String? userId,
    String? updatedAt,
    String? deletedAt,
  });
}

/// @nodoc
class _$BodyEntryModelCopyWithImpl<$Res, $Val extends BodyEntryModel>
    implements $BodyEntryModelCopyWith<$Res> {
  _$BodyEntryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BodyEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? weight = null,
    Object? measurements = null,
    Object? photoPath = freezed,
    Object? userId = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as String,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
            measurements: null == measurements
                ? _value.measurements
                : measurements // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
            photoPath: freezed == photoPath
                ? _value.photoPath
                : photoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BodyEntryModelImplCopyWith<$Res>
    implements $BodyEntryModelCopyWith<$Res> {
  factory _$$BodyEntryModelImplCopyWith(
    _$BodyEntryModelImpl value,
    $Res Function(_$BodyEntryModelImpl) then,
  ) = __$$BodyEntryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String date,
    double weight,
    Map<String, double> measurements,
    String? photoPath,
    String? userId,
    String? updatedAt,
    String? deletedAt,
  });
}

/// @nodoc
class __$$BodyEntryModelImplCopyWithImpl<$Res>
    extends _$BodyEntryModelCopyWithImpl<$Res, _$BodyEntryModelImpl>
    implements _$$BodyEntryModelImplCopyWith<$Res> {
  __$$BodyEntryModelImplCopyWithImpl(
    _$BodyEntryModelImpl _value,
    $Res Function(_$BodyEntryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BodyEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? weight = null,
    Object? measurements = null,
    Object? photoPath = freezed,
    Object? userId = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$BodyEntryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
        measurements: null == measurements
            ? _value._measurements
            : measurements // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
        photoPath: freezed == photoPath
            ? _value.photoPath
            : photoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BodyEntryModelImpl implements _BodyEntryModel {
  const _$BodyEntryModelImpl({
    required this.id,
    required this.date,
    required this.weight,
    required final Map<String, double> measurements,
    this.photoPath,
    this.userId,
    this.updatedAt,
    this.deletedAt,
  }) : _measurements = measurements;

  factory _$BodyEntryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BodyEntryModelImplFromJson(json);

  @override
  final String id;
  @override
  final String date;
  // ISO 8601 string
  @override
  final double weight;
  final Map<String, double> _measurements;
  @override
  Map<String, double> get measurements {
    if (_measurements is EqualUnmodifiableMapView) return _measurements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_measurements);
  }

  // MeasurementType.name → double
  @override
  final String? photoPath;
  // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  @override
  final String? userId;
  // Phase 2: LWW key + tombstone (ISO 8601 strings).
  @override
  final String? updatedAt;
  @override
  final String? deletedAt;

  @override
  String toString() {
    return 'BodyEntryModel(id: $id, date: $date, weight: $weight, measurements: $measurements, photoPath: $photoPath, userId: $userId, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodyEntryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            const DeepCollectionEquality().equals(
              other._measurements,
              _measurements,
            ) &&
            (identical(other.photoPath, photoPath) ||
                other.photoPath == photoPath) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    weight,
    const DeepCollectionEquality().hash(_measurements),
    photoPath,
    userId,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of BodyEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BodyEntryModelImplCopyWith<_$BodyEntryModelImpl> get copyWith =>
      __$$BodyEntryModelImplCopyWithImpl<_$BodyEntryModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BodyEntryModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BodyEntryModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BodyEntryModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$BodyEntryModelImplToJson(this);
  }
}

abstract class _BodyEntryModel implements BodyEntryModel {
  const factory _BodyEntryModel({
    required final String id,
    required final String date,
    required final double weight,
    required final Map<String, double> measurements,
    final String? photoPath,
    final String? userId,
    final String? updatedAt,
    final String? deletedAt,
  }) = _$BodyEntryModelImpl;

  factory _BodyEntryModel.fromJson(Map<String, dynamic> json) =
      _$BodyEntryModelImpl.fromJson;

  @override
  String get id;
  @override
  String get date; // ISO 8601 string
  @override
  double get weight;
  @override
  Map<String, double> get measurements; // MeasurementType.name → double
  @override
  String? get photoPath; // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  @override
  String? get userId; // Phase 2: LWW key + tombstone (ISO 8601 strings).
  @override
  String? get updatedAt;
  @override
  String? get deletedAt;

  /// Create a copy of BodyEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BodyEntryModelImplCopyWith<_$BodyEntryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

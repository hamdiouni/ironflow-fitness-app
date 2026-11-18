// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'body_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$BodyEntry {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  Map<MeasurementType, double> get measurements =>
      throw _privateConstructorUsedError;
  String? get photoPath => throw _privateConstructorUsedError;

  /// Owning user (auth uid), Phase 1 schema v2. Null for legacy rows.
  String? get userId => throw _privateConstructorUsedError;

  /// Last modification time (Phase 2) — the LWW conflict key for sync.
  /// Without it, two devices editing the same entry could not be
  /// ordered (`date` is the measurement date, not a modification time).
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Tombstone (Phase 2): set when deleted on another device; pulls
  /// apply it as a local delete.
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BodyEntry value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BodyEntry value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BodyEntry value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of BodyEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BodyEntryCopyWith<BodyEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BodyEntryCopyWith<$Res> {
  factory $BodyEntryCopyWith(BodyEntry value, $Res Function(BodyEntry) then) =
      _$BodyEntryCopyWithImpl<$Res, BodyEntry>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    double weight,
    Map<MeasurementType, double> measurements,
    String? photoPath,
    String? userId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$BodyEntryCopyWithImpl<$Res, $Val extends BodyEntry>
    implements $BodyEntryCopyWith<$Res> {
  _$BodyEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BodyEntry
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
                      as DateTime,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
            measurements: null == measurements
                ? _value.measurements
                : measurements // ignore: cast_nullable_to_non_nullable
                      as Map<MeasurementType, double>,
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
                      as DateTime?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BodyEntryImplCopyWith<$Res>
    implements $BodyEntryCopyWith<$Res> {
  factory _$$BodyEntryImplCopyWith(
    _$BodyEntryImpl value,
    $Res Function(_$BodyEntryImpl) then,
  ) = __$$BodyEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    double weight,
    Map<MeasurementType, double> measurements,
    String? photoPath,
    String? userId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$BodyEntryImplCopyWithImpl<$Res>
    extends _$BodyEntryCopyWithImpl<$Res, _$BodyEntryImpl>
    implements _$$BodyEntryImplCopyWith<$Res> {
  __$$BodyEntryImplCopyWithImpl(
    _$BodyEntryImpl _value,
    $Res Function(_$BodyEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BodyEntry
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
      _$BodyEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
        measurements: null == measurements
            ? _value._measurements
            : measurements // ignore: cast_nullable_to_non_nullable
                  as Map<MeasurementType, double>,
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
                  as DateTime?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$BodyEntryImpl implements _BodyEntry {
  const _$BodyEntryImpl({
    required this.id,
    required this.date,
    required this.weight,
    required final Map<MeasurementType, double> measurements,
    this.photoPath,
    this.userId,
    this.updatedAt,
    this.deletedAt,
  }) : _measurements = measurements;

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final double weight;
  final Map<MeasurementType, double> _measurements;
  @override
  Map<MeasurementType, double> get measurements {
    if (_measurements is EqualUnmodifiableMapView) return _measurements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_measurements);
  }

  @override
  final String? photoPath;

  /// Owning user (auth uid), Phase 1 schema v2. Null for legacy rows.
  @override
  final String? userId;

  /// Last modification time (Phase 2) — the LWW conflict key for sync.
  /// Without it, two devices editing the same entry could not be
  /// ordered (`date` is the measurement date, not a modification time).
  @override
  final DateTime? updatedAt;

  /// Tombstone (Phase 2): set when deleted on another device; pulls
  /// apply it as a local delete.
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'BodyEntry(id: $id, date: $date, weight: $weight, measurements: $measurements, photoPath: $photoPath, userId: $userId, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BodyEntryImpl &&
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

  /// Create a copy of BodyEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BodyEntryImplCopyWith<_$BodyEntryImpl> get copyWith =>
      __$$BodyEntryImplCopyWithImpl<_$BodyEntryImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_BodyEntry value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_BodyEntry value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_BodyEntry value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _BodyEntry implements BodyEntry {
  const factory _BodyEntry({
    required final String id,
    required final DateTime date,
    required final double weight,
    required final Map<MeasurementType, double> measurements,
    final String? photoPath,
    final String? userId,
    final DateTime? updatedAt,
    final DateTime? deletedAt,
  }) = _$BodyEntryImpl;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  double get weight;
  @override
  Map<MeasurementType, double> get measurements;
  @override
  String? get photoPath;

  /// Owning user (auth uid), Phase 1 schema v2. Null for legacy rows.
  @override
  String? get userId;

  /// Last modification time (Phase 2) — the LWW conflict key for sync.
  /// Without it, two devices editing the same entry could not be
  /// ordered (`date` is the measurement date, not a modification time).
  @override
  DateTime? get updatedAt;

  /// Tombstone (Phase 2): set when deleted on another device; pulls
  /// apply it as a local delete.
  @override
  DateTime? get deletedAt;

  /// Create a copy of BodyEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BodyEntryImplCopyWith<_$BodyEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

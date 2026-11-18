// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Workout {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  List<Exercise> get exercises => throw _privateConstructorUsedError;
  Duration get duration => throw _privateConstructorUsedError;
  double get totalVolume => throw _privateConstructorUsedError;
  double get caloriesBurned =>
      throw _privateConstructorUsedError; // Schema v2 links (Phase 1, DATABASE_AND_SYNC_AUDIT §8.2). All optional
  // so pre-v2 data/constructions keep working; populated by
  // StartWorkoutUseCase + repositories + DataMigration backfill.
  /// Owning user (auth uid). Null for legacy/local-only rows.
  String? get userId => throw _privateConstructorUsedError;

  /// Program this session fulfilled, if started from a program.
  String? get programId => throw _privateConstructorUsedError;

  /// 0-based day index within [programId]'s program at start time.
  int? get programDayIndex => throw _privateConstructorUsedError;

  /// Last modification time — the LWW conflict key for sync.
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Tombstone (Phase 2): set when this record was deleted on another
  /// device. Local deletes are hard deletes; the cloud copy is kept as
  /// a tombstone so pulls can propagate the deletion instead of
  /// resurrecting the record.
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Workout value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Workout value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Workout value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutCopyWith<Workout> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutCopyWith<$Res> {
  factory $WorkoutCopyWith(Workout value, $Res Function(Workout) then) =
      _$WorkoutCopyWithImpl<$Res, Workout>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    List<Exercise> exercises,
    Duration duration,
    double totalVolume,
    double caloriesBurned,
    String? userId,
    String? programId,
    int? programDayIndex,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class _$WorkoutCopyWithImpl<$Res, $Val extends Workout>
    implements $WorkoutCopyWith<$Res> {
  _$WorkoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? exercises = null,
    Object? duration = null,
    Object? totalVolume = null,
    Object? caloriesBurned = null,
    Object? userId = freezed,
    Object? programId = freezed,
    Object? programDayIndex = freezed,
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
            exercises: null == exercises
                ? _value.exercises
                : exercises // ignore: cast_nullable_to_non_nullable
                      as List<Exercise>,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as Duration,
            totalVolume: null == totalVolume
                ? _value.totalVolume
                : totalVolume // ignore: cast_nullable_to_non_nullable
                      as double,
            caloriesBurned: null == caloriesBurned
                ? _value.caloriesBurned
                : caloriesBurned // ignore: cast_nullable_to_non_nullable
                      as double,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            programId: freezed == programId
                ? _value.programId
                : programId // ignore: cast_nullable_to_non_nullable
                      as String?,
            programDayIndex: freezed == programDayIndex
                ? _value.programDayIndex
                : programDayIndex // ignore: cast_nullable_to_non_nullable
                      as int?,
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
abstract class _$$WorkoutImplCopyWith<$Res> implements $WorkoutCopyWith<$Res> {
  factory _$$WorkoutImplCopyWith(
    _$WorkoutImpl value,
    $Res Function(_$WorkoutImpl) then,
  ) = __$$WorkoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    List<Exercise> exercises,
    Duration duration,
    double totalVolume,
    double caloriesBurned,
    String? userId,
    String? programId,
    int? programDayIndex,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });
}

/// @nodoc
class __$$WorkoutImplCopyWithImpl<$Res>
    extends _$WorkoutCopyWithImpl<$Res, _$WorkoutImpl>
    implements _$$WorkoutImplCopyWith<$Res> {
  __$$WorkoutImplCopyWithImpl(
    _$WorkoutImpl _value,
    $Res Function(_$WorkoutImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? exercises = null,
    Object? duration = null,
    Object? totalVolume = null,
    Object? caloriesBurned = null,
    Object? userId = freezed,
    Object? programId = freezed,
    Object? programDayIndex = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$WorkoutImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        exercises: null == exercises
            ? _value._exercises
            : exercises // ignore: cast_nullable_to_non_nullable
                  as List<Exercise>,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as Duration,
        totalVolume: null == totalVolume
            ? _value.totalVolume
            : totalVolume // ignore: cast_nullable_to_non_nullable
                  as double,
        caloriesBurned: null == caloriesBurned
            ? _value.caloriesBurned
            : caloriesBurned // ignore: cast_nullable_to_non_nullable
                  as double,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        programId: freezed == programId
            ? _value.programId
            : programId // ignore: cast_nullable_to_non_nullable
                  as String?,
        programDayIndex: freezed == programDayIndex
            ? _value.programDayIndex
            : programDayIndex // ignore: cast_nullable_to_non_nullable
                  as int?,
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

class _$WorkoutImpl implements _Workout {
  const _$WorkoutImpl({
    required this.id,
    required this.date,
    required final List<Exercise> exercises,
    required this.duration,
    required this.totalVolume,
    this.caloriesBurned = 0,
    this.userId,
    this.programId,
    this.programDayIndex,
    this.updatedAt,
    this.deletedAt,
  }) : _exercises = exercises;

  @override
  final String id;
  @override
  final DateTime date;
  final List<Exercise> _exercises;
  @override
  List<Exercise> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  final Duration duration;
  @override
  final double totalVolume;
  @override
  @JsonKey()
  final double caloriesBurned;
  // Schema v2 links (Phase 1, DATABASE_AND_SYNC_AUDIT §8.2). All optional
  // so pre-v2 data/constructions keep working; populated by
  // StartWorkoutUseCase + repositories + DataMigration backfill.
  /// Owning user (auth uid). Null for legacy/local-only rows.
  @override
  final String? userId;

  /// Program this session fulfilled, if started from a program.
  @override
  final String? programId;

  /// 0-based day index within [programId]'s program at start time.
  @override
  final int? programDayIndex;

  /// Last modification time — the LWW conflict key for sync.
  @override
  final DateTime? updatedAt;

  /// Tombstone (Phase 2): set when this record was deleted on another
  /// device. Local deletes are hard deletes; the cloud copy is kept as
  /// a tombstone so pulls can propagate the deletion instead of
  /// resurrecting the record.
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'Workout(id: $id, date: $date, exercises: $exercises, duration: $duration, totalVolume: $totalVolume, caloriesBurned: $caloriesBurned, userId: $userId, programId: $programId, programDayIndex: $programDayIndex, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(
              other._exercises,
              _exercises,
            ) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.totalVolume, totalVolume) ||
                other.totalVolume == totalVolume) &&
            (identical(other.caloriesBurned, caloriesBurned) ||
                other.caloriesBurned == caloriesBurned) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.programId, programId) ||
                other.programId == programId) &&
            (identical(other.programDayIndex, programDayIndex) ||
                other.programDayIndex == programDayIndex) &&
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
    const DeepCollectionEquality().hash(_exercises),
    duration,
    totalVolume,
    caloriesBurned,
    userId,
    programId,
    programDayIndex,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutImplCopyWith<_$WorkoutImpl> get copyWith =>
      __$$WorkoutImplCopyWithImpl<_$WorkoutImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Workout value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Workout value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Workout value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _Workout implements Workout {
  const factory _Workout({
    required final String id,
    required final DateTime date,
    required final List<Exercise> exercises,
    required final Duration duration,
    required final double totalVolume,
    final double caloriesBurned,
    final String? userId,
    final String? programId,
    final int? programDayIndex,
    final DateTime? updatedAt,
    final DateTime? deletedAt,
  }) = _$WorkoutImpl;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  List<Exercise> get exercises;
  @override
  Duration get duration;
  @override
  double get totalVolume;
  @override
  double get caloriesBurned; // Schema v2 links (Phase 1, DATABASE_AND_SYNC_AUDIT §8.2). All optional
  // so pre-v2 data/constructions keep working; populated by
  // StartWorkoutUseCase + repositories + DataMigration backfill.
  /// Owning user (auth uid). Null for legacy/local-only rows.
  @override
  String? get userId;

  /// Program this session fulfilled, if started from a program.
  @override
  String? get programId;

  /// 0-based day index within [programId]'s program at start time.
  @override
  int? get programDayIndex;

  /// Last modification time — the LWW conflict key for sync.
  @override
  DateTime? get updatedAt;

  /// Tombstone (Phase 2): set when this record was deleted on another
  /// device. Local deletes are hard deletes; the cloud copy is kept as
  /// a tombstone so pulls can propagate the deletion instead of
  /// resurrecting the record.
  @override
  DateTime? get deletedAt;

  /// Create a copy of Workout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutImplCopyWith<_$WorkoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

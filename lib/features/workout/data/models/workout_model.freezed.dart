// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkoutModel _$WorkoutModelFromJson(Map<String, dynamic> json) {
  return _WorkoutModel.fromJson(json);
}

/// @nodoc
mixin _$WorkoutModel {
  String get id => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  List<ExerciseModel> get exercises => throw _privateConstructorUsedError;
  int get durationSeconds => throw _privateConstructorUsedError;
  double get totalVolume => throw _privateConstructorUsedError;
  double get caloriesBurned =>
      throw _privateConstructorUsedError; // Schema v2 (Phase 1) — nullable so pre-v2 stored JSON still loads.
  String? get userId => throw _privateConstructorUsedError;
  String? get programId => throw _privateConstructorUsedError;
  int? get programDayIndex => throw _privateConstructorUsedError;
  String? get updatedAt =>
      throw _privateConstructorUsedError; // ISO 8601 string
  // Phase 2 tombstone (ISO 8601 string) on cloud-deleted records.
  String? get deletedAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WorkoutModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WorkoutModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WorkoutModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this WorkoutModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutModelCopyWith<WorkoutModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutModelCopyWith<$Res> {
  factory $WorkoutModelCopyWith(
    WorkoutModel value,
    $Res Function(WorkoutModel) then,
  ) = _$WorkoutModelCopyWithImpl<$Res, WorkoutModel>;
  @useResult
  $Res call({
    String id,
    String date,
    List<ExerciseModel> exercises,
    int durationSeconds,
    double totalVolume,
    double caloriesBurned,
    String? userId,
    String? programId,
    int? programDayIndex,
    String? updatedAt,
    String? deletedAt,
  });
}

/// @nodoc
class _$WorkoutModelCopyWithImpl<$Res, $Val extends WorkoutModel>
    implements $WorkoutModelCopyWith<$Res> {
  _$WorkoutModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? exercises = null,
    Object? durationSeconds = null,
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
                      as String,
            exercises: null == exercises
                ? _value.exercises
                : exercises // ignore: cast_nullable_to_non_nullable
                      as List<ExerciseModel>,
            durationSeconds: null == durationSeconds
                ? _value.durationSeconds
                : durationSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$WorkoutModelImplCopyWith<$Res>
    implements $WorkoutModelCopyWith<$Res> {
  factory _$$WorkoutModelImplCopyWith(
    _$WorkoutModelImpl value,
    $Res Function(_$WorkoutModelImpl) then,
  ) = __$$WorkoutModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String date,
    List<ExerciseModel> exercises,
    int durationSeconds,
    double totalVolume,
    double caloriesBurned,
    String? userId,
    String? programId,
    int? programDayIndex,
    String? updatedAt,
    String? deletedAt,
  });
}

/// @nodoc
class __$$WorkoutModelImplCopyWithImpl<$Res>
    extends _$WorkoutModelCopyWithImpl<$Res, _$WorkoutModelImpl>
    implements _$$WorkoutModelImplCopyWith<$Res> {
  __$$WorkoutModelImplCopyWithImpl(
    _$WorkoutModelImpl _value,
    $Res Function(_$WorkoutModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? exercises = null,
    Object? durationSeconds = null,
    Object? totalVolume = null,
    Object? caloriesBurned = null,
    Object? userId = freezed,
    Object? programId = freezed,
    Object? programDayIndex = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$WorkoutModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as String,
        exercises: null == exercises
            ? _value._exercises
            : exercises // ignore: cast_nullable_to_non_nullable
                  as List<ExerciseModel>,
        durationSeconds: null == durationSeconds
            ? _value.durationSeconds
            : durationSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$WorkoutModelImpl implements _WorkoutModel {
  const _$WorkoutModelImpl({
    required this.id,
    required this.date,
    required final List<ExerciseModel> exercises,
    required this.durationSeconds,
    required this.totalVolume,
    this.caloriesBurned = 0,
    this.userId,
    this.programId,
    this.programDayIndex,
    this.updatedAt,
    this.deletedAt,
  }) : _exercises = exercises;

  factory _$WorkoutModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutModelImplFromJson(json);

  @override
  final String id;
  @override
  final String date;
  final List<ExerciseModel> _exercises;
  @override
  List<ExerciseModel> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  final int durationSeconds;
  @override
  final double totalVolume;
  @override
  @JsonKey()
  final double caloriesBurned;
  // Schema v2 (Phase 1) — nullable so pre-v2 stored JSON still loads.
  @override
  final String? userId;
  @override
  final String? programId;
  @override
  final int? programDayIndex;
  @override
  final String? updatedAt;
  // ISO 8601 string
  // Phase 2 tombstone (ISO 8601 string) on cloud-deleted records.
  @override
  final String? deletedAt;

  @override
  String toString() {
    return 'WorkoutModel(id: $id, date: $date, exercises: $exercises, durationSeconds: $durationSeconds, totalVolume: $totalVolume, caloriesBurned: $caloriesBurned, userId: $userId, programId: $programId, programDayIndex: $programDayIndex, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(
              other._exercises,
              _exercises,
            ) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    const DeepCollectionEquality().hash(_exercises),
    durationSeconds,
    totalVolume,
    caloriesBurned,
    userId,
    programId,
    programDayIndex,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of WorkoutModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutModelImplCopyWith<_$WorkoutModelImpl> get copyWith =>
      __$$WorkoutModelImplCopyWithImpl<_$WorkoutModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WorkoutModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WorkoutModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WorkoutModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutModelImplToJson(this);
  }
}

abstract class _WorkoutModel implements WorkoutModel {
  const factory _WorkoutModel({
    required final String id,
    required final String date,
    required final List<ExerciseModel> exercises,
    required final int durationSeconds,
    required final double totalVolume,
    final double caloriesBurned,
    final String? userId,
    final String? programId,
    final int? programDayIndex,
    final String? updatedAt,
    final String? deletedAt,
  }) = _$WorkoutModelImpl;

  factory _WorkoutModel.fromJson(Map<String, dynamic> json) =
      _$WorkoutModelImpl.fromJson;

  @override
  String get id;
  @override
  String get date;
  @override
  List<ExerciseModel> get exercises;
  @override
  int get durationSeconds;
  @override
  double get totalVolume;
  @override
  double get caloriesBurned; // Schema v2 (Phase 1) — nullable so pre-v2 stored JSON still loads.
  @override
  String? get userId;
  @override
  String? get programId;
  @override
  int? get programDayIndex;
  @override
  String? get updatedAt; // ISO 8601 string
  // Phase 2 tombstone (ISO 8601 string) on cloud-deleted records.
  @override
  String? get deletedAt;

  /// Create a copy of WorkoutModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutModelImplCopyWith<_$WorkoutModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

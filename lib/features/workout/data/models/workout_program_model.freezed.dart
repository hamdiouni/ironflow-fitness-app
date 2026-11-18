// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_program_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkoutProgramModel _$WorkoutProgramModelFromJson(Map<String, dynamic> json) {
  return _WorkoutProgramModel.fromJson(json);
}

/// @nodoc
mixin _$WorkoutProgramModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  List<ProgramDayModel> get days => throw _privateConstructorUsedError;
  int get durationWeeks => throw _privateConstructorUsedError;
  String get difficulty => throw _privateConstructorUsedError;
  String? get splitId => throw _privateConstructorUsedError;
  String? get hybridSplitId => throw _privateConstructorUsedError;
  String? get hybridMode => throw _privateConstructorUsedError;
  int? get cycleLength =>
      throw _privateConstructorUsedError; // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  String? get userId => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WorkoutProgramModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WorkoutProgramModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WorkoutProgramModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this WorkoutProgramModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutProgramModelCopyWith<WorkoutProgramModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutProgramModelCopyWith<$Res> {
  factory $WorkoutProgramModelCopyWith(
    WorkoutProgramModel value,
    $Res Function(WorkoutProgramModel) then,
  ) = _$WorkoutProgramModelCopyWithImpl<$Res, WorkoutProgramModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    List<ProgramDayModel> days,
    int durationWeeks,
    String difficulty,
    String? splitId,
    String? hybridSplitId,
    String? hybridMode,
    int? cycleLength,
    String? userId,
  });
}

/// @nodoc
class _$WorkoutProgramModelCopyWithImpl<$Res, $Val extends WorkoutProgramModel>
    implements $WorkoutProgramModelCopyWith<$Res> {
  _$WorkoutProgramModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? days = null,
    Object? durationWeeks = null,
    Object? difficulty = null,
    Object? splitId = freezed,
    Object? hybridSplitId = freezed,
    Object? hybridMode = freezed,
    Object? cycleLength = freezed,
    Object? userId = freezed,
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
            days: null == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as List<ProgramDayModel>,
            durationWeeks: null == durationWeeks
                ? _value.durationWeeks
                : durationWeeks // ignore: cast_nullable_to_non_nullable
                      as int,
            difficulty: null == difficulty
                ? _value.difficulty
                : difficulty // ignore: cast_nullable_to_non_nullable
                      as String,
            splitId: freezed == splitId
                ? _value.splitId
                : splitId // ignore: cast_nullable_to_non_nullable
                      as String?,
            hybridSplitId: freezed == hybridSplitId
                ? _value.hybridSplitId
                : hybridSplitId // ignore: cast_nullable_to_non_nullable
                      as String?,
            hybridMode: freezed == hybridMode
                ? _value.hybridMode
                : hybridMode // ignore: cast_nullable_to_non_nullable
                      as String?,
            cycleLength: freezed == cycleLength
                ? _value.cycleLength
                : cycleLength // ignore: cast_nullable_to_non_nullable
                      as int?,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkoutProgramModelImplCopyWith<$Res>
    implements $WorkoutProgramModelCopyWith<$Res> {
  factory _$$WorkoutProgramModelImplCopyWith(
    _$WorkoutProgramModelImpl value,
    $Res Function(_$WorkoutProgramModelImpl) then,
  ) = __$$WorkoutProgramModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    List<ProgramDayModel> days,
    int durationWeeks,
    String difficulty,
    String? splitId,
    String? hybridSplitId,
    String? hybridMode,
    int? cycleLength,
    String? userId,
  });
}

/// @nodoc
class __$$WorkoutProgramModelImplCopyWithImpl<$Res>
    extends _$WorkoutProgramModelCopyWithImpl<$Res, _$WorkoutProgramModelImpl>
    implements _$$WorkoutProgramModelImplCopyWith<$Res> {
  __$$WorkoutProgramModelImplCopyWithImpl(
    _$WorkoutProgramModelImpl _value,
    $Res Function(_$WorkoutProgramModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? days = null,
    Object? durationWeeks = null,
    Object? difficulty = null,
    Object? splitId = freezed,
    Object? hybridSplitId = freezed,
    Object? hybridMode = freezed,
    Object? cycleLength = freezed,
    Object? userId = freezed,
  }) {
    return _then(
      _$WorkoutProgramModelImpl(
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
        days: null == days
            ? _value._days
            : days // ignore: cast_nullable_to_non_nullable
                  as List<ProgramDayModel>,
        durationWeeks: null == durationWeeks
            ? _value.durationWeeks
            : durationWeeks // ignore: cast_nullable_to_non_nullable
                  as int,
        difficulty: null == difficulty
            ? _value.difficulty
            : difficulty // ignore: cast_nullable_to_non_nullable
                  as String,
        splitId: freezed == splitId
            ? _value.splitId
            : splitId // ignore: cast_nullable_to_non_nullable
                  as String?,
        hybridSplitId: freezed == hybridSplitId
            ? _value.hybridSplitId
            : hybridSplitId // ignore: cast_nullable_to_non_nullable
                  as String?,
        hybridMode: freezed == hybridMode
            ? _value.hybridMode
            : hybridMode // ignore: cast_nullable_to_non_nullable
                  as String?,
        cycleLength: freezed == cycleLength
            ? _value.cycleLength
            : cycleLength // ignore: cast_nullable_to_non_nullable
                  as int?,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutProgramModelImpl implements _WorkoutProgramModel {
  const _$WorkoutProgramModelImpl({
    required this.id,
    required this.name,
    required this.description,
    required final List<ProgramDayModel> days,
    required this.durationWeeks,
    required this.difficulty,
    this.splitId,
    this.hybridSplitId,
    this.hybridMode,
    this.cycleLength,
    this.userId,
  }) : _days = days;

  factory _$WorkoutProgramModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutProgramModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  final List<ProgramDayModel> _days;
  @override
  List<ProgramDayModel> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  @override
  final int durationWeeks;
  @override
  final String difficulty;
  @override
  final String? splitId;
  @override
  final String? hybridSplitId;
  @override
  final String? hybridMode;
  @override
  final int? cycleLength;
  // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  @override
  final String? userId;

  @override
  String toString() {
    return 'WorkoutProgramModel(id: $id, name: $name, description: $description, days: $days, durationWeeks: $durationWeeks, difficulty: $difficulty, splitId: $splitId, hybridSplitId: $hybridSplitId, hybridMode: $hybridMode, cycleLength: $cycleLength, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutProgramModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other._days, _days) &&
            (identical(other.durationWeeks, durationWeeks) ||
                other.durationWeeks == durationWeeks) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.splitId, splitId) || other.splitId == splitId) &&
            (identical(other.hybridSplitId, hybridSplitId) ||
                other.hybridSplitId == hybridSplitId) &&
            (identical(other.hybridMode, hybridMode) ||
                other.hybridMode == hybridMode) &&
            (identical(other.cycleLength, cycleLength) ||
                other.cycleLength == cycleLength) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    const DeepCollectionEquality().hash(_days),
    durationWeeks,
    difficulty,
    splitId,
    hybridSplitId,
    hybridMode,
    cycleLength,
    userId,
  );

  /// Create a copy of WorkoutProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutProgramModelImplCopyWith<_$WorkoutProgramModelImpl> get copyWith =>
      __$$WorkoutProgramModelImplCopyWithImpl<_$WorkoutProgramModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WorkoutProgramModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WorkoutProgramModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WorkoutProgramModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutProgramModelImplToJson(this);
  }
}

abstract class _WorkoutProgramModel implements WorkoutProgramModel {
  const factory _WorkoutProgramModel({
    required final String id,
    required final String name,
    required final String description,
    required final List<ProgramDayModel> days,
    required final int durationWeeks,
    required final String difficulty,
    final String? splitId,
    final String? hybridSplitId,
    final String? hybridMode,
    final int? cycleLength,
    final String? userId,
  }) = _$WorkoutProgramModelImpl;

  factory _WorkoutProgramModel.fromJson(Map<String, dynamic> json) =
      _$WorkoutProgramModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  List<ProgramDayModel> get days;
  @override
  int get durationWeeks;
  @override
  String get difficulty;
  @override
  String? get splitId;
  @override
  String? get hybridSplitId;
  @override
  String? get hybridMode;
  @override
  int? get cycleLength; // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  @override
  String? get userId;

  /// Create a copy of WorkoutProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutProgramModelImplCopyWith<_$WorkoutProgramModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgramDayModel _$ProgramDayModelFromJson(Map<String, dynamic> json) {
  return _ProgramDayModel.fromJson(json);
}

/// @nodoc
mixin _$ProgramDayModel {
  int get dayNumber => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get focus => throw _privateConstructorUsedError;
  List<ProgramExerciseModel> get exercises =>
      throw _privateConstructorUsedError;
  bool get isRestDay => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProgramDayModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProgramDayModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProgramDayModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ProgramDayModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgramDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgramDayModelCopyWith<ProgramDayModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgramDayModelCopyWith<$Res> {
  factory $ProgramDayModelCopyWith(
    ProgramDayModel value,
    $Res Function(ProgramDayModel) then,
  ) = _$ProgramDayModelCopyWithImpl<$Res, ProgramDayModel>;
  @useResult
  $Res call({
    int dayNumber,
    String name,
    String focus,
    List<ProgramExerciseModel> exercises,
    bool isRestDay,
  });
}

/// @nodoc
class _$ProgramDayModelCopyWithImpl<$Res, $Val extends ProgramDayModel>
    implements $ProgramDayModelCopyWith<$Res> {
  _$ProgramDayModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgramDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayNumber = null,
    Object? name = null,
    Object? focus = null,
    Object? exercises = null,
    Object? isRestDay = null,
  }) {
    return _then(
      _value.copyWith(
            dayNumber: null == dayNumber
                ? _value.dayNumber
                : dayNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            focus: null == focus
                ? _value.focus
                : focus // ignore: cast_nullable_to_non_nullable
                      as String,
            exercises: null == exercises
                ? _value.exercises
                : exercises // ignore: cast_nullable_to_non_nullable
                      as List<ProgramExerciseModel>,
            isRestDay: null == isRestDay
                ? _value.isRestDay
                : isRestDay // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgramDayModelImplCopyWith<$Res>
    implements $ProgramDayModelCopyWith<$Res> {
  factory _$$ProgramDayModelImplCopyWith(
    _$ProgramDayModelImpl value,
    $Res Function(_$ProgramDayModelImpl) then,
  ) = __$$ProgramDayModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int dayNumber,
    String name,
    String focus,
    List<ProgramExerciseModel> exercises,
    bool isRestDay,
  });
}

/// @nodoc
class __$$ProgramDayModelImplCopyWithImpl<$Res>
    extends _$ProgramDayModelCopyWithImpl<$Res, _$ProgramDayModelImpl>
    implements _$$ProgramDayModelImplCopyWith<$Res> {
  __$$ProgramDayModelImplCopyWithImpl(
    _$ProgramDayModelImpl _value,
    $Res Function(_$ProgramDayModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgramDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayNumber = null,
    Object? name = null,
    Object? focus = null,
    Object? exercises = null,
    Object? isRestDay = null,
  }) {
    return _then(
      _$ProgramDayModelImpl(
        dayNumber: null == dayNumber
            ? _value.dayNumber
            : dayNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        focus: null == focus
            ? _value.focus
            : focus // ignore: cast_nullable_to_non_nullable
                  as String,
        exercises: null == exercises
            ? _value._exercises
            : exercises // ignore: cast_nullable_to_non_nullable
                  as List<ProgramExerciseModel>,
        isRestDay: null == isRestDay
            ? _value.isRestDay
            : isRestDay // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgramDayModelImpl implements _ProgramDayModel {
  const _$ProgramDayModelImpl({
    required this.dayNumber,
    required this.name,
    required this.focus,
    required final List<ProgramExerciseModel> exercises,
    this.isRestDay = false,
  }) : _exercises = exercises;

  factory _$ProgramDayModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgramDayModelImplFromJson(json);

  @override
  final int dayNumber;
  @override
  final String name;
  @override
  final String focus;
  final List<ProgramExerciseModel> _exercises;
  @override
  List<ProgramExerciseModel> get exercises {
    if (_exercises is EqualUnmodifiableListView) return _exercises;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_exercises);
  }

  @override
  @JsonKey()
  final bool isRestDay;

  @override
  String toString() {
    return 'ProgramDayModel(dayNumber: $dayNumber, name: $name, focus: $focus, exercises: $exercises, isRestDay: $isRestDay)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgramDayModelImpl &&
            (identical(other.dayNumber, dayNumber) ||
                other.dayNumber == dayNumber) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.focus, focus) || other.focus == focus) &&
            const DeepCollectionEquality().equals(
              other._exercises,
              _exercises,
            ) &&
            (identical(other.isRestDay, isRestDay) ||
                other.isRestDay == isRestDay));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dayNumber,
    name,
    focus,
    const DeepCollectionEquality().hash(_exercises),
    isRestDay,
  );

  /// Create a copy of ProgramDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgramDayModelImplCopyWith<_$ProgramDayModelImpl> get copyWith =>
      __$$ProgramDayModelImplCopyWithImpl<_$ProgramDayModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProgramDayModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProgramDayModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProgramDayModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgramDayModelImplToJson(this);
  }
}

abstract class _ProgramDayModel implements ProgramDayModel {
  const factory _ProgramDayModel({
    required final int dayNumber,
    required final String name,
    required final String focus,
    required final List<ProgramExerciseModel> exercises,
    final bool isRestDay,
  }) = _$ProgramDayModelImpl;

  factory _ProgramDayModel.fromJson(Map<String, dynamic> json) =
      _$ProgramDayModelImpl.fromJson;

  @override
  int get dayNumber;
  @override
  String get name;
  @override
  String get focus;
  @override
  List<ProgramExerciseModel> get exercises;
  @override
  bool get isRestDay;

  /// Create a copy of ProgramDayModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgramDayModelImplCopyWith<_$ProgramDayModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProgramExerciseModel _$ProgramExerciseModelFromJson(Map<String, dynamic> json) {
  return _ProgramExerciseModel.fromJson(json);
}

/// @nodoc
mixin _$ProgramExerciseModel {
  String get exerciseName => throw _privateConstructorUsedError;
  int get sets => throw _privateConstructorUsedError;
  String get reps => throw _privateConstructorUsedError;
  int get restSeconds => throw _privateConstructorUsedError;
  double? get targetWeight => throw _privateConstructorUsedError;
  String? get notes =>
      throw _privateConstructorUsedError; // Phase 1 schema v2: stable catalog link (ExerciseDefinition.id).
  String? get exerciseDefinitionId => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProgramExerciseModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProgramExerciseModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProgramExerciseModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ProgramExerciseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProgramExerciseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgramExerciseModelCopyWith<ProgramExerciseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgramExerciseModelCopyWith<$Res> {
  factory $ProgramExerciseModelCopyWith(
    ProgramExerciseModel value,
    $Res Function(ProgramExerciseModel) then,
  ) = _$ProgramExerciseModelCopyWithImpl<$Res, ProgramExerciseModel>;
  @useResult
  $Res call({
    String exerciseName,
    int sets,
    String reps,
    int restSeconds,
    double? targetWeight,
    String? notes,
    String? exerciseDefinitionId,
  });
}

/// @nodoc
class _$ProgramExerciseModelCopyWithImpl<
  $Res,
  $Val extends ProgramExerciseModel
>
    implements $ProgramExerciseModelCopyWith<$Res> {
  _$ProgramExerciseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgramExerciseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? sets = null,
    Object? reps = null,
    Object? restSeconds = null,
    Object? targetWeight = freezed,
    Object? notes = freezed,
    Object? exerciseDefinitionId = freezed,
  }) {
    return _then(
      _value.copyWith(
            exerciseName: null == exerciseName
                ? _value.exerciseName
                : exerciseName // ignore: cast_nullable_to_non_nullable
                      as String,
            sets: null == sets
                ? _value.sets
                : sets // ignore: cast_nullable_to_non_nullable
                      as int,
            reps: null == reps
                ? _value.reps
                : reps // ignore: cast_nullable_to_non_nullable
                      as String,
            restSeconds: null == restSeconds
                ? _value.restSeconds
                : restSeconds // ignore: cast_nullable_to_non_nullable
                      as int,
            targetWeight: freezed == targetWeight
                ? _value.targetWeight
                : targetWeight // ignore: cast_nullable_to_non_nullable
                      as double?,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
            exerciseDefinitionId: freezed == exerciseDefinitionId
                ? _value.exerciseDefinitionId
                : exerciseDefinitionId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgramExerciseModelImplCopyWith<$Res>
    implements $ProgramExerciseModelCopyWith<$Res> {
  factory _$$ProgramExerciseModelImplCopyWith(
    _$ProgramExerciseModelImpl value,
    $Res Function(_$ProgramExerciseModelImpl) then,
  ) = __$$ProgramExerciseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String exerciseName,
    int sets,
    String reps,
    int restSeconds,
    double? targetWeight,
    String? notes,
    String? exerciseDefinitionId,
  });
}

/// @nodoc
class __$$ProgramExerciseModelImplCopyWithImpl<$Res>
    extends _$ProgramExerciseModelCopyWithImpl<$Res, _$ProgramExerciseModelImpl>
    implements _$$ProgramExerciseModelImplCopyWith<$Res> {
  __$$ProgramExerciseModelImplCopyWithImpl(
    _$ProgramExerciseModelImpl _value,
    $Res Function(_$ProgramExerciseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgramExerciseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exerciseName = null,
    Object? sets = null,
    Object? reps = null,
    Object? restSeconds = null,
    Object? targetWeight = freezed,
    Object? notes = freezed,
    Object? exerciseDefinitionId = freezed,
  }) {
    return _then(
      _$ProgramExerciseModelImpl(
        exerciseName: null == exerciseName
            ? _value.exerciseName
            : exerciseName // ignore: cast_nullable_to_non_nullable
                  as String,
        sets: null == sets
            ? _value.sets
            : sets // ignore: cast_nullable_to_non_nullable
                  as int,
        reps: null == reps
            ? _value.reps
            : reps // ignore: cast_nullable_to_non_nullable
                  as String,
        restSeconds: null == restSeconds
            ? _value.restSeconds
            : restSeconds // ignore: cast_nullable_to_non_nullable
                  as int,
        targetWeight: freezed == targetWeight
            ? _value.targetWeight
            : targetWeight // ignore: cast_nullable_to_non_nullable
                  as double?,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
        exerciseDefinitionId: freezed == exerciseDefinitionId
            ? _value.exerciseDefinitionId
            : exerciseDefinitionId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProgramExerciseModelImpl implements _ProgramExerciseModel {
  const _$ProgramExerciseModelImpl({
    required this.exerciseName,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.targetWeight,
    this.notes,
    this.exerciseDefinitionId,
  });

  factory _$ProgramExerciseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProgramExerciseModelImplFromJson(json);

  @override
  final String exerciseName;
  @override
  final int sets;
  @override
  final String reps;
  @override
  final int restSeconds;
  @override
  final double? targetWeight;
  @override
  final String? notes;
  // Phase 1 schema v2: stable catalog link (ExerciseDefinition.id).
  @override
  final String? exerciseDefinitionId;

  @override
  String toString() {
    return 'ProgramExerciseModel(exerciseName: $exerciseName, sets: $sets, reps: $reps, restSeconds: $restSeconds, targetWeight: $targetWeight, notes: $notes, exerciseDefinitionId: $exerciseDefinitionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgramExerciseModelImpl &&
            (identical(other.exerciseName, exerciseName) ||
                other.exerciseName == exerciseName) &&
            (identical(other.sets, sets) || other.sets == sets) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.restSeconds, restSeconds) ||
                other.restSeconds == restSeconds) &&
            (identical(other.targetWeight, targetWeight) ||
                other.targetWeight == targetWeight) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.exerciseDefinitionId, exerciseDefinitionId) ||
                other.exerciseDefinitionId == exerciseDefinitionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    exerciseName,
    sets,
    reps,
    restSeconds,
    targetWeight,
    notes,
    exerciseDefinitionId,
  );

  /// Create a copy of ProgramExerciseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgramExerciseModelImplCopyWith<_$ProgramExerciseModelImpl>
  get copyWith =>
      __$$ProgramExerciseModelImplCopyWithImpl<_$ProgramExerciseModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProgramExerciseModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProgramExerciseModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProgramExerciseModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ProgramExerciseModelImplToJson(this);
  }
}

abstract class _ProgramExerciseModel implements ProgramExerciseModel {
  const factory _ProgramExerciseModel({
    required final String exerciseName,
    required final int sets,
    required final String reps,
    required final int restSeconds,
    final double? targetWeight,
    final String? notes,
    final String? exerciseDefinitionId,
  }) = _$ProgramExerciseModelImpl;

  factory _ProgramExerciseModel.fromJson(Map<String, dynamic> json) =
      _$ProgramExerciseModelImpl.fromJson;

  @override
  String get exerciseName;
  @override
  int get sets;
  @override
  String get reps;
  @override
  int get restSeconds;
  @override
  double? get targetWeight;
  @override
  String? get notes; // Phase 1 schema v2: stable catalog link (ExerciseDefinition.id).
  @override
  String? get exerciseDefinitionId;

  /// Create a copy of ProgramExerciseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgramExerciseModelImplCopyWith<_$ProgramExerciseModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

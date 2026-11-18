// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_program.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ActiveProgram {
  String get id => throw _privateConstructorUsedError;
  WorkoutProgram get program => throw _privateConstructorUsedError;
  int get currentDayIndex =>
      throw _privateConstructorUsedError; // 0-based index into program.days
  bool get isActive => throw _privateConstructorUsedError;
  DateTime? get lastWorkoutDate => throw _privateConstructorUsedError;
  Map<int, DateTime> get completedDays =>
      throw _privateConstructorUsedError; // dayIndex -> completionDate
  /// Owning user (auth uid), Phase 1 schema v2. Null for legacy rows.
  String? get userId => throw _privateConstructorUsedError;

  /// Last modification time (Phase 2) — LWW key for program sync.
  /// Stamped by ActiveProgramRepositoryImpl on every save/update.
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ActiveProgram value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ActiveProgram value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ActiveProgram value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of ActiveProgram
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActiveProgramCopyWith<ActiveProgram> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActiveProgramCopyWith<$Res> {
  factory $ActiveProgramCopyWith(
    ActiveProgram value,
    $Res Function(ActiveProgram) then,
  ) = _$ActiveProgramCopyWithImpl<$Res, ActiveProgram>;
  @useResult
  $Res call({
    String id,
    WorkoutProgram program,
    int currentDayIndex,
    bool isActive,
    DateTime? lastWorkoutDate,
    Map<int, DateTime> completedDays,
    String? userId,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$ActiveProgramCopyWithImpl<$Res, $Val extends ActiveProgram>
    implements $ActiveProgramCopyWith<$Res> {
  _$ActiveProgramCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActiveProgram
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? program = null,
    Object? currentDayIndex = null,
    Object? isActive = null,
    Object? lastWorkoutDate = freezed,
    Object? completedDays = null,
    Object? userId = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            program: null == program
                ? _value.program
                : program // ignore: cast_nullable_to_non_nullable
                      as WorkoutProgram,
            currentDayIndex: null == currentDayIndex
                ? _value.currentDayIndex
                : currentDayIndex // ignore: cast_nullable_to_non_nullable
                      as int,
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastWorkoutDate: freezed == lastWorkoutDate
                ? _value.lastWorkoutDate
                : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            completedDays: null == completedDays
                ? _value.completedDays
                : completedDays // ignore: cast_nullable_to_non_nullable
                      as Map<int, DateTime>,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
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
abstract class _$$ActiveProgramImplCopyWith<$Res>
    implements $ActiveProgramCopyWith<$Res> {
  factory _$$ActiveProgramImplCopyWith(
    _$ActiveProgramImpl value,
    $Res Function(_$ActiveProgramImpl) then,
  ) = __$$ActiveProgramImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    WorkoutProgram program,
    int currentDayIndex,
    bool isActive,
    DateTime? lastWorkoutDate,
    Map<int, DateTime> completedDays,
    String? userId,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$ActiveProgramImplCopyWithImpl<$Res>
    extends _$ActiveProgramCopyWithImpl<$Res, _$ActiveProgramImpl>
    implements _$$ActiveProgramImplCopyWith<$Res> {
  __$$ActiveProgramImplCopyWithImpl(
    _$ActiveProgramImpl _value,
    $Res Function(_$ActiveProgramImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActiveProgram
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? program = null,
    Object? currentDayIndex = null,
    Object? isActive = null,
    Object? lastWorkoutDate = freezed,
    Object? completedDays = null,
    Object? userId = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$ActiveProgramImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        program: null == program
            ? _value.program
            : program // ignore: cast_nullable_to_non_nullable
                  as WorkoutProgram,
        currentDayIndex: null == currentDayIndex
            ? _value.currentDayIndex
            : currentDayIndex // ignore: cast_nullable_to_non_nullable
                  as int,
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastWorkoutDate: freezed == lastWorkoutDate
            ? _value.lastWorkoutDate
            : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        completedDays: null == completedDays
            ? _value._completedDays
            : completedDays // ignore: cast_nullable_to_non_nullable
                  as Map<int, DateTime>,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$ActiveProgramImpl extends _ActiveProgram {
  const _$ActiveProgramImpl({
    required this.id,
    required this.program,
    required this.currentDayIndex,
    required this.isActive,
    this.lastWorkoutDate,
    final Map<int, DateTime> completedDays = const {},
    this.userId,
    this.updatedAt,
  }) : _completedDays = completedDays,
       super._();

  @override
  final String id;
  @override
  final WorkoutProgram program;
  @override
  final int currentDayIndex;
  // 0-based index into program.days
  @override
  final bool isActive;
  @override
  final DateTime? lastWorkoutDate;
  final Map<int, DateTime> _completedDays;
  @override
  @JsonKey()
  Map<int, DateTime> get completedDays {
    if (_completedDays is EqualUnmodifiableMapView) return _completedDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_completedDays);
  }

  // dayIndex -> completionDate
  /// Owning user (auth uid), Phase 1 schema v2. Null for legacy rows.
  @override
  final String? userId;

  /// Last modification time (Phase 2) — LWW key for program sync.
  /// Stamped by ActiveProgramRepositoryImpl on every save/update.
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'ActiveProgram(id: $id, program: $program, currentDayIndex: $currentDayIndex, isActive: $isActive, lastWorkoutDate: $lastWorkoutDate, completedDays: $completedDays, userId: $userId, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActiveProgramImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.program, program) || other.program == program) &&
            (identical(other.currentDayIndex, currentDayIndex) ||
                other.currentDayIndex == currentDayIndex) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.lastWorkoutDate, lastWorkoutDate) ||
                other.lastWorkoutDate == lastWorkoutDate) &&
            const DeepCollectionEquality().equals(
              other._completedDays,
              _completedDays,
            ) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    program,
    currentDayIndex,
    isActive,
    lastWorkoutDate,
    const DeepCollectionEquality().hash(_completedDays),
    userId,
    updatedAt,
  );

  /// Create a copy of ActiveProgram
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActiveProgramImplCopyWith<_$ActiveProgramImpl> get copyWith =>
      __$$ActiveProgramImplCopyWithImpl<_$ActiveProgramImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ActiveProgram value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ActiveProgram value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ActiveProgram value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _ActiveProgram extends ActiveProgram {
  const factory _ActiveProgram({
    required final String id,
    required final WorkoutProgram program,
    required final int currentDayIndex,
    required final bool isActive,
    final DateTime? lastWorkoutDate,
    final Map<int, DateTime> completedDays,
    final String? userId,
    final DateTime? updatedAt,
  }) = _$ActiveProgramImpl;
  const _ActiveProgram._() : super._();

  @override
  String get id;
  @override
  WorkoutProgram get program;
  @override
  int get currentDayIndex; // 0-based index into program.days
  @override
  bool get isActive;
  @override
  DateTime? get lastWorkoutDate;
  @override
  Map<int, DateTime> get completedDays; // dayIndex -> completionDate
  /// Owning user (auth uid), Phase 1 schema v2. Null for legacy rows.
  @override
  String? get userId;

  /// Last modification time (Phase 2) — LWW key for program sync.
  /// Stamped by ActiveProgramRepositoryImpl on every save/update.
  @override
  DateTime? get updatedAt;

  /// Create a copy of ActiveProgram
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActiveProgramImplCopyWith<_$ActiveProgramImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

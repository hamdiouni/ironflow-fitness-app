// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'active_program_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ActiveProgramModel _$ActiveProgramModelFromJson(Map<String, dynamic> json) {
  return _ActiveProgramModel.fromJson(json);
}

/// @nodoc
mixin _$ActiveProgramModel {
  String get id => throw _privateConstructorUsedError;
  WorkoutProgramModel get program => throw _privateConstructorUsedError;
  int get currentDayIndex => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String? get lastWorkoutDate =>
      throw _privateConstructorUsedError; // ISO 8601 string
  Map<String, String> get completedDays =>
      throw _privateConstructorUsedError; // dayIndex as string -> ISO date
  // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  String? get userId =>
      throw _privateConstructorUsedError; // Phase 2: LWW key for program sync (ISO 8601 string).
  String? get updatedAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ActiveProgramModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ActiveProgramModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ActiveProgramModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ActiveProgramModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ActiveProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActiveProgramModelCopyWith<ActiveProgramModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActiveProgramModelCopyWith<$Res> {
  factory $ActiveProgramModelCopyWith(
    ActiveProgramModel value,
    $Res Function(ActiveProgramModel) then,
  ) = _$ActiveProgramModelCopyWithImpl<$Res, ActiveProgramModel>;
  @useResult
  $Res call({
    String id,
    WorkoutProgramModel program,
    int currentDayIndex,
    bool isActive,
    String? lastWorkoutDate,
    Map<String, String> completedDays,
    String? userId,
    String? updatedAt,
  });

  $WorkoutProgramModelCopyWith<$Res> get program;
}

/// @nodoc
class _$ActiveProgramModelCopyWithImpl<$Res, $Val extends ActiveProgramModel>
    implements $ActiveProgramModelCopyWith<$Res> {
  _$ActiveProgramModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActiveProgramModel
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
                      as WorkoutProgramModel,
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
                      as String?,
            completedDays: null == completedDays
                ? _value.completedDays
                : completedDays // ignore: cast_nullable_to_non_nullable
                      as Map<String, String>,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of ActiveProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $WorkoutProgramModelCopyWith<$Res> get program {
    return $WorkoutProgramModelCopyWith<$Res>(_value.program, (value) {
      return _then(_value.copyWith(program: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ActiveProgramModelImplCopyWith<$Res>
    implements $ActiveProgramModelCopyWith<$Res> {
  factory _$$ActiveProgramModelImplCopyWith(
    _$ActiveProgramModelImpl value,
    $Res Function(_$ActiveProgramModelImpl) then,
  ) = __$$ActiveProgramModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    WorkoutProgramModel program,
    int currentDayIndex,
    bool isActive,
    String? lastWorkoutDate,
    Map<String, String> completedDays,
    String? userId,
    String? updatedAt,
  });

  @override
  $WorkoutProgramModelCopyWith<$Res> get program;
}

/// @nodoc
class __$$ActiveProgramModelImplCopyWithImpl<$Res>
    extends _$ActiveProgramModelCopyWithImpl<$Res, _$ActiveProgramModelImpl>
    implements _$$ActiveProgramModelImplCopyWith<$Res> {
  __$$ActiveProgramModelImplCopyWithImpl(
    _$ActiveProgramModelImpl _value,
    $Res Function(_$ActiveProgramModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActiveProgramModel
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
      _$ActiveProgramModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        program: null == program
            ? _value.program
            : program // ignore: cast_nullable_to_non_nullable
                  as WorkoutProgramModel,
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
                  as String?,
        completedDays: null == completedDays
            ? _value._completedDays
            : completedDays // ignore: cast_nullable_to_non_nullable
                  as Map<String, String>,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ActiveProgramModelImpl implements _ActiveProgramModel {
  const _$ActiveProgramModelImpl({
    required this.id,
    required this.program,
    required this.currentDayIndex,
    required this.isActive,
    this.lastWorkoutDate,
    final Map<String, String> completedDays = const {},
    this.userId,
    this.updatedAt,
  }) : _completedDays = completedDays;

  factory _$ActiveProgramModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ActiveProgramModelImplFromJson(json);

  @override
  final String id;
  @override
  final WorkoutProgramModel program;
  @override
  final int currentDayIndex;
  @override
  final bool isActive;
  @override
  final String? lastWorkoutDate;
  // ISO 8601 string
  final Map<String, String> _completedDays;
  // ISO 8601 string
  @override
  @JsonKey()
  Map<String, String> get completedDays {
    if (_completedDays is EqualUnmodifiableMapView) return _completedDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_completedDays);
  }

  // dayIndex as string -> ISO date
  // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  @override
  final String? userId;
  // Phase 2: LWW key for program sync (ISO 8601 string).
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'ActiveProgramModel(id: $id, program: $program, currentDayIndex: $currentDayIndex, isActive: $isActive, lastWorkoutDate: $lastWorkoutDate, completedDays: $completedDays, userId: $userId, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActiveProgramModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of ActiveProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActiveProgramModelImplCopyWith<_$ActiveProgramModelImpl> get copyWith =>
      __$$ActiveProgramModelImplCopyWithImpl<_$ActiveProgramModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ActiveProgramModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ActiveProgramModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ActiveProgramModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ActiveProgramModelImplToJson(this);
  }
}

abstract class _ActiveProgramModel implements ActiveProgramModel {
  const factory _ActiveProgramModel({
    required final String id,
    required final WorkoutProgramModel program,
    required final int currentDayIndex,
    required final bool isActive,
    final String? lastWorkoutDate,
    final Map<String, String> completedDays,
    final String? userId,
    final String? updatedAt,
  }) = _$ActiveProgramModelImpl;

  factory _ActiveProgramModel.fromJson(Map<String, dynamic> json) =
      _$ActiveProgramModelImpl.fromJson;

  @override
  String get id;
  @override
  WorkoutProgramModel get program;
  @override
  int get currentDayIndex;
  @override
  bool get isActive;
  @override
  String? get lastWorkoutDate; // ISO 8601 string
  @override
  Map<String, String> get completedDays; // dayIndex as string -> ISO date
  // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  @override
  String? get userId; // Phase 2: LWW key for program sync (ISO 8601 string).
  @override
  String? get updatedAt;

  /// Create a copy of ActiveProgramModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActiveProgramModelImplCopyWith<_$ActiveProgramModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

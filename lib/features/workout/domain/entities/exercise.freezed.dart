// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$Exercise {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ExerciseType get type => throw _privateConstructorUsedError;
  List<SetEntry> get sets => throw _privateConstructorUsedError;
  int? get suggestedReps => throw _privateConstructorUsedError;
  int? get suggestedSets => throw _privateConstructorUsedError;

  /// Stable catalog link → ExerciseDefinition.id (Phase 1 schema v2).
  /// [name] remains the display snapshot; identity/history should prefer
  /// this id when present. Null for legacy/custom entries.
  String? get exerciseDefinitionId => throw _privateConstructorUsedError;
  String? get supersetGroupId => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Exercise value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Exercise value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Exercise value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseCopyWith<Exercise> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseCopyWith<$Res> {
  factory $ExerciseCopyWith(Exercise value, $Res Function(Exercise) then) =
      _$ExerciseCopyWithImpl<$Res, Exercise>;
  @useResult
  $Res call({
    String id,
    String name,
    ExerciseType type,
    List<SetEntry> sets,
    int? suggestedReps,
    int? suggestedSets,
    String? exerciseDefinitionId,
    String? supersetGroupId,
  });
}

/// @nodoc
class _$ExerciseCopyWithImpl<$Res, $Val extends Exercise>
    implements $ExerciseCopyWith<$Res> {
  _$ExerciseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? sets = null,
    Object? suggestedReps = freezed,
    Object? suggestedSets = freezed,
    Object? exerciseDefinitionId = freezed,
    Object? supersetGroupId = freezed,
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
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ExerciseType,
            sets: null == sets
                ? _value.sets
                : sets // ignore: cast_nullable_to_non_nullable
                      as List<SetEntry>,
            suggestedReps: freezed == suggestedReps
                ? _value.suggestedReps
                : suggestedReps // ignore: cast_nullable_to_non_nullable
                      as int?,
            suggestedSets: freezed == suggestedSets
                ? _value.suggestedSets
                : suggestedSets // ignore: cast_nullable_to_non_nullable
                      as int?,
            exerciseDefinitionId: freezed == exerciseDefinitionId
                ? _value.exerciseDefinitionId
                : exerciseDefinitionId // ignore: cast_nullable_to_non_nullable
                      as String?,
            supersetGroupId: freezed == supersetGroupId
                ? _value.supersetGroupId
                : supersetGroupId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExerciseImplCopyWith<$Res>
    implements $ExerciseCopyWith<$Res> {
  factory _$$ExerciseImplCopyWith(
    _$ExerciseImpl value,
    $Res Function(_$ExerciseImpl) then,
  ) = __$$ExerciseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    ExerciseType type,
    List<SetEntry> sets,
    int? suggestedReps,
    int? suggestedSets,
    String? exerciseDefinitionId,
    String? supersetGroupId,
  });
}

/// @nodoc
class __$$ExerciseImplCopyWithImpl<$Res>
    extends _$ExerciseCopyWithImpl<$Res, _$ExerciseImpl>
    implements _$$ExerciseImplCopyWith<$Res> {
  __$$ExerciseImplCopyWithImpl(
    _$ExerciseImpl _value,
    $Res Function(_$ExerciseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? sets = null,
    Object? suggestedReps = freezed,
    Object? suggestedSets = freezed,
    Object? exerciseDefinitionId = freezed,
    Object? supersetGroupId = freezed,
  }) {
    return _then(
      _$ExerciseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ExerciseType,
        sets: null == sets
            ? _value._sets
            : sets // ignore: cast_nullable_to_non_nullable
                  as List<SetEntry>,
        suggestedReps: freezed == suggestedReps
            ? _value.suggestedReps
            : suggestedReps // ignore: cast_nullable_to_non_nullable
                  as int?,
        suggestedSets: freezed == suggestedSets
            ? _value.suggestedSets
            : suggestedSets // ignore: cast_nullable_to_non_nullable
                  as int?,
        exerciseDefinitionId: freezed == exerciseDefinitionId
            ? _value.exerciseDefinitionId
            : exerciseDefinitionId // ignore: cast_nullable_to_non_nullable
                  as String?,
        supersetGroupId: freezed == supersetGroupId
            ? _value.supersetGroupId
            : supersetGroupId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ExerciseImpl implements _Exercise {
  const _$ExerciseImpl({
    required this.id,
    required this.name,
    required this.type,
    required final List<SetEntry> sets,
    this.suggestedReps,
    this.suggestedSets,
    this.exerciseDefinitionId,
    this.supersetGroupId,
  }) : _sets = sets;

  @override
  final String id;
  @override
  final String name;
  @override
  final ExerciseType type;
  final List<SetEntry> _sets;
  @override
  List<SetEntry> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  @override
  final int? suggestedReps;
  @override
  final int? suggestedSets;

  /// Stable catalog link → ExerciseDefinition.id (Phase 1 schema v2).
  /// [name] remains the display snapshot; identity/history should prefer
  /// this id when present. Null for legacy/custom entries.
  @override
  final String? exerciseDefinitionId;
  @override
  final String? supersetGroupId;

  @override
  String toString() {
    return 'Exercise(id: $id, name: $name, type: $type, sets: $sets, suggestedReps: $suggestedReps, suggestedSets: $suggestedSets, exerciseDefinitionId: $exerciseDefinitionId, supersetGroupId: $supersetGroupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._sets, _sets) &&
            (identical(other.suggestedReps, suggestedReps) ||
                other.suggestedReps == suggestedReps) &&
            (identical(other.suggestedSets, suggestedSets) ||
                other.suggestedSets == suggestedSets) &&
            (identical(other.exerciseDefinitionId, exerciseDefinitionId) ||
                other.exerciseDefinitionId == exerciseDefinitionId) &&
            (identical(other.supersetGroupId, supersetGroupId) ||
                other.supersetGroupId == supersetGroupId));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    type,
    const DeepCollectionEquality().hash(_sets),
    suggestedReps,
    suggestedSets,
    exerciseDefinitionId,
    supersetGroupId,
  );

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      __$$ExerciseImplCopyWithImpl<_$ExerciseImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Exercise value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Exercise value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Exercise value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _Exercise implements Exercise {
  const factory _Exercise({
    required final String id,
    required final String name,
    required final ExerciseType type,
    required final List<SetEntry> sets,
    final int? suggestedReps,
    final int? suggestedSets,
    final String? exerciseDefinitionId,
    final String? supersetGroupId,
  }) = _$ExerciseImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  ExerciseType get type;
  @override
  List<SetEntry> get sets;
  @override
  int? get suggestedReps;
  @override
  int? get suggestedSets;

  /// Stable catalog link → ExerciseDefinition.id (Phase 1 schema v2).
  /// [name] remains the display snapshot; identity/history should prefer
  /// this id when present. Null for legacy/custom entries.
  @override
  String? get exerciseDefinitionId;
  @override
  String? get supersetGroupId;

  /// Create a copy of Exercise
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseImplCopyWith<_$ExerciseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

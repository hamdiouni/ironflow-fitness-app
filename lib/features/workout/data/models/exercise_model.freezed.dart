// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'exercise_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExerciseModel _$ExerciseModelFromJson(Map<String, dynamic> json) {
  return _ExerciseModel.fromJson(json);
}

/// @nodoc
mixin _$ExerciseModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  List<SetEntryModel> get sets =>
      throw _privateConstructorUsedError; // Persisted since Phase 0 (DATABASE_AND_SYNC_AUDIT F-05): these used to
  // be dropped by fromEntity/toEntity, so planned sets/reps were lost on
  // every save/load round-trip. Nullable = old stored JSON still loads.
  // Requires `dart run build_runner build` to regenerate the model code.
  int? get suggestedReps => throw _privateConstructorUsedError;
  int? get suggestedSets =>
      throw _privateConstructorUsedError; // Phase 1 schema v2: stable catalog link (ExerciseDefinition.id).
  String? get exerciseDefinitionId => throw _privateConstructorUsedError;
  String? get supersetGroupId => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ExerciseModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ExerciseModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ExerciseModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this ExerciseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExerciseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExerciseModelCopyWith<ExerciseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExerciseModelCopyWith<$Res> {
  factory $ExerciseModelCopyWith(
    ExerciseModel value,
    $Res Function(ExerciseModel) then,
  ) = _$ExerciseModelCopyWithImpl<$Res, ExerciseModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    List<SetEntryModel> sets,
    int? suggestedReps,
    int? suggestedSets,
    String? exerciseDefinitionId,
    String? supersetGroupId,
  });
}

/// @nodoc
class _$ExerciseModelCopyWithImpl<$Res, $Val extends ExerciseModel>
    implements $ExerciseModelCopyWith<$Res> {
  _$ExerciseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExerciseModel
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
                      as String,
            sets: null == sets
                ? _value.sets
                : sets // ignore: cast_nullable_to_non_nullable
                      as List<SetEntryModel>,
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
abstract class _$$ExerciseModelImplCopyWith<$Res>
    implements $ExerciseModelCopyWith<$Res> {
  factory _$$ExerciseModelImplCopyWith(
    _$ExerciseModelImpl value,
    $Res Function(_$ExerciseModelImpl) then,
  ) = __$$ExerciseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String type,
    List<SetEntryModel> sets,
    int? suggestedReps,
    int? suggestedSets,
    String? exerciseDefinitionId,
    String? supersetGroupId,
  });
}

/// @nodoc
class __$$ExerciseModelImplCopyWithImpl<$Res>
    extends _$ExerciseModelCopyWithImpl<$Res, _$ExerciseModelImpl>
    implements _$$ExerciseModelImplCopyWith<$Res> {
  __$$ExerciseModelImplCopyWithImpl(
    _$ExerciseModelImpl _value,
    $Res Function(_$ExerciseModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExerciseModel
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
      _$ExerciseModelImpl(
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
                  as String,
        sets: null == sets
            ? _value._sets
            : sets // ignore: cast_nullable_to_non_nullable
                  as List<SetEntryModel>,
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
@JsonSerializable()
class _$ExerciseModelImpl implements _ExerciseModel {
  const _$ExerciseModelImpl({
    required this.id,
    required this.name,
    required this.type,
    required final List<SetEntryModel> sets,
    this.suggestedReps,
    this.suggestedSets,
    this.exerciseDefinitionId,
    this.supersetGroupId,
  }) : _sets = sets;

  factory _$ExerciseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExerciseModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String type;
  final List<SetEntryModel> _sets;
  @override
  List<SetEntryModel> get sets {
    if (_sets is EqualUnmodifiableListView) return _sets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sets);
  }

  // Persisted since Phase 0 (DATABASE_AND_SYNC_AUDIT F-05): these used to
  // be dropped by fromEntity/toEntity, so planned sets/reps were lost on
  // every save/load round-trip. Nullable = old stored JSON still loads.
  // Requires `dart run build_runner build` to regenerate the model code.
  @override
  final int? suggestedReps;
  @override
  final int? suggestedSets;
  // Phase 1 schema v2: stable catalog link (ExerciseDefinition.id).
  @override
  final String? exerciseDefinitionId;
  @override
  final String? supersetGroupId;

  @override
  String toString() {
    return 'ExerciseModel(id: $id, name: $name, type: $type, sets: $sets, suggestedReps: $suggestedReps, suggestedSets: $suggestedSets, exerciseDefinitionId: $exerciseDefinitionId, supersetGroupId: $supersetGroupId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExerciseModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of ExerciseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExerciseModelImplCopyWith<_$ExerciseModelImpl> get copyWith =>
      __$$ExerciseModelImplCopyWithImpl<_$ExerciseModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ExerciseModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ExerciseModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ExerciseModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$ExerciseModelImplToJson(this);
  }
}

abstract class _ExerciseModel implements ExerciseModel {
  const factory _ExerciseModel({
    required final String id,
    required final String name,
    required final String type,
    required final List<SetEntryModel> sets,
    final int? suggestedReps,
    final int? suggestedSets,
    final String? exerciseDefinitionId,
    final String? supersetGroupId,
  }) = _$ExerciseModelImpl;

  factory _ExerciseModel.fromJson(Map<String, dynamic> json) =
      _$ExerciseModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get type;
  @override
  List<SetEntryModel> get sets; // Persisted since Phase 0 (DATABASE_AND_SYNC_AUDIT F-05): these used to
  // be dropped by fromEntity/toEntity, so planned sets/reps were lost on
  // every save/load round-trip. Nullable = old stored JSON still loads.
  // Requires `dart run build_runner build` to regenerate the model code.
  @override
  int? get suggestedReps;
  @override
  int? get suggestedSets; // Phase 1 schema v2: stable catalog link (ExerciseDefinition.id).
  @override
  String? get exerciseDefinitionId;
  @override
  String? get supersetGroupId;

  /// Create a copy of ExerciseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExerciseModelImplCopyWith<_$ExerciseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

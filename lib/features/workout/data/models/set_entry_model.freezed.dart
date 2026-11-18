// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SetEntryModel _$SetEntryModelFromJson(Map<String, dynamic> json) {
  return _SetEntryModel.fromJson(json);
}

/// @nodoc
mixin _$SetEntryModel {
  String get id => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int? get rpe => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SetEntryModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SetEntryModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SetEntryModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this SetEntryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SetEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetEntryModelCopyWith<SetEntryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetEntryModelCopyWith<$Res> {
  factory $SetEntryModelCopyWith(
    SetEntryModel value,
    $Res Function(SetEntryModel) then,
  ) = _$SetEntryModelCopyWithImpl<$Res, SetEntryModel>;
  @useResult
  $Res call({
    String id,
    int reps,
    double weight,
    int? rpe,
    String type,
    String timestamp,
  });
}

/// @nodoc
class _$SetEntryModelCopyWithImpl<$Res, $Val extends SetEntryModel>
    implements $SetEntryModelCopyWith<$Res> {
  _$SetEntryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reps = null,
    Object? weight = null,
    Object? rpe = freezed,
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            reps: null == reps
                ? _value.reps
                : reps // ignore: cast_nullable_to_non_nullable
                      as int,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
            rpe: freezed == rpe
                ? _value.rpe
                : rpe // ignore: cast_nullable_to_non_nullable
                      as int?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SetEntryModelImplCopyWith<$Res>
    implements $SetEntryModelCopyWith<$Res> {
  factory _$$SetEntryModelImplCopyWith(
    _$SetEntryModelImpl value,
    $Res Function(_$SetEntryModelImpl) then,
  ) = __$$SetEntryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int reps,
    double weight,
    int? rpe,
    String type,
    String timestamp,
  });
}

/// @nodoc
class __$$SetEntryModelImplCopyWithImpl<$Res>
    extends _$SetEntryModelCopyWithImpl<$Res, _$SetEntryModelImpl>
    implements _$$SetEntryModelImplCopyWith<$Res> {
  __$$SetEntryModelImplCopyWithImpl(
    _$SetEntryModelImpl _value,
    $Res Function(_$SetEntryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SetEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? reps = null,
    Object? weight = null,
    Object? rpe = freezed,
    Object? type = null,
    Object? timestamp = null,
  }) {
    return _then(
      _$SetEntryModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        reps: null == reps
            ? _value.reps
            : reps // ignore: cast_nullable_to_non_nullable
                  as int,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
        rpe: freezed == rpe
            ? _value.rpe
            : rpe // ignore: cast_nullable_to_non_nullable
                  as int?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SetEntryModelImpl implements _SetEntryModel {
  const _$SetEntryModelImpl({
    required this.id,
    required this.reps,
    required this.weight,
    this.rpe,
    this.type = 'normal',
    required this.timestamp,
  });

  factory _$SetEntryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SetEntryModelImplFromJson(json);

  @override
  final String id;
  @override
  final int reps;
  @override
  final double weight;
  @override
  final int? rpe;
  @override
  @JsonKey()
  final String type;
  @override
  final String timestamp;

  @override
  String toString() {
    return 'SetEntryModel(id: $id, reps: $reps, weight: $weight, rpe: $rpe, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetEntryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, reps, weight, rpe, type, timestamp);

  /// Create a copy of SetEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetEntryModelImplCopyWith<_$SetEntryModelImpl> get copyWith =>
      __$$SetEntryModelImplCopyWithImpl<_$SetEntryModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SetEntryModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SetEntryModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SetEntryModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SetEntryModelImplToJson(this);
  }
}

abstract class _SetEntryModel implements SetEntryModel {
  const factory _SetEntryModel({
    required final String id,
    required final int reps,
    required final double weight,
    final int? rpe,
    final String type,
    required final String timestamp,
  }) = _$SetEntryModelImpl;

  factory _SetEntryModel.fromJson(Map<String, dynamic> json) =
      _$SetEntryModelImpl.fromJson;

  @override
  String get id;
  @override
  int get reps;
  @override
  double get weight;
  @override
  int? get rpe;
  @override
  String get type;
  @override
  String get timestamp;

  /// Create a copy of SetEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetEntryModelImplCopyWith<_$SetEntryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

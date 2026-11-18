// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'set_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SetEntry {
  String get id => throw _privateConstructorUsedError;
  int get reps => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;
  int? get rpe => throw _privateConstructorUsedError;
  SetType get type => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SetEntry value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SetEntry value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SetEntry value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of SetEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SetEntryCopyWith<SetEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SetEntryCopyWith<$Res> {
  factory $SetEntryCopyWith(SetEntry value, $Res Function(SetEntry) then) =
      _$SetEntryCopyWithImpl<$Res, SetEntry>;
  @useResult
  $Res call({
    String id,
    int reps,
    double weight,
    int? rpe,
    SetType type,
    DateTime timestamp,
  });
}

/// @nodoc
class _$SetEntryCopyWithImpl<$Res, $Val extends SetEntry>
    implements $SetEntryCopyWith<$Res> {
  _$SetEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SetEntry
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
                      as SetType,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SetEntryImplCopyWith<$Res>
    implements $SetEntryCopyWith<$Res> {
  factory _$$SetEntryImplCopyWith(
    _$SetEntryImpl value,
    $Res Function(_$SetEntryImpl) then,
  ) = __$$SetEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int reps,
    double weight,
    int? rpe,
    SetType type,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$SetEntryImplCopyWithImpl<$Res>
    extends _$SetEntryCopyWithImpl<$Res, _$SetEntryImpl>
    implements _$$SetEntryImplCopyWith<$Res> {
  __$$SetEntryImplCopyWithImpl(
    _$SetEntryImpl _value,
    $Res Function(_$SetEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SetEntry
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
      _$SetEntryImpl(
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
                  as SetType,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$SetEntryImpl implements _SetEntry {
  const _$SetEntryImpl({
    required this.id,
    required this.reps,
    required this.weight,
    this.rpe,
    this.type = SetType.normal,
    required this.timestamp,
  });

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
  final SetType type;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'SetEntry(id: $id, reps: $reps, weight: $weight, rpe: $rpe, type: $type, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SetEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.reps, reps) || other.reps == reps) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.rpe, rpe) || other.rpe == rpe) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, reps, weight, rpe, type, timestamp);

  /// Create a copy of SetEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SetEntryImplCopyWith<_$SetEntryImpl> get copyWith =>
      __$$SetEntryImplCopyWithImpl<_$SetEntryImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SetEntry value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SetEntry value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SetEntry value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _SetEntry implements SetEntry {
  const factory _SetEntry({
    required final String id,
    required final int reps,
    required final double weight,
    final int? rpe,
    final SetType type,
    required final DateTime timestamp,
  }) = _$SetEntryImpl;

  @override
  String get id;
  @override
  int get reps;
  @override
  double get weight;
  @override
  int? get rpe;
  @override
  SetType get type;
  @override
  DateTime get timestamp;

  /// Create a copy of SetEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SetEntryImplCopyWith<_$SetEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

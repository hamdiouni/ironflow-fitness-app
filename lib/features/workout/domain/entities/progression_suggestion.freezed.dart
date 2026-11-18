// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progression_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProgressionSuggestion {
  double get suggestedWeight => throw _privateConstructorUsedError;
  int get suggestedReps => throw _privateConstructorUsedError;
  bool get isStagnant => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProgressionSuggestion value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProgressionSuggestion value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProgressionSuggestion value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of ProgressionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressionSuggestionCopyWith<ProgressionSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressionSuggestionCopyWith<$Res> {
  factory $ProgressionSuggestionCopyWith(
    ProgressionSuggestion value,
    $Res Function(ProgressionSuggestion) then,
  ) = _$ProgressionSuggestionCopyWithImpl<$Res, ProgressionSuggestion>;
  @useResult
  $Res call({
    double suggestedWeight,
    int suggestedReps,
    bool isStagnant,
    String? message,
  });
}

/// @nodoc
class _$ProgressionSuggestionCopyWithImpl<
  $Res,
  $Val extends ProgressionSuggestion
>
    implements $ProgressionSuggestionCopyWith<$Res> {
  _$ProgressionSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProgressionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestedWeight = null,
    Object? suggestedReps = null,
    Object? isStagnant = null,
    Object? message = freezed,
  }) {
    return _then(
      _value.copyWith(
            suggestedWeight: null == suggestedWeight
                ? _value.suggestedWeight
                : suggestedWeight // ignore: cast_nullable_to_non_nullable
                      as double,
            suggestedReps: null == suggestedReps
                ? _value.suggestedReps
                : suggestedReps // ignore: cast_nullable_to_non_nullable
                      as int,
            isStagnant: null == isStagnant
                ? _value.isStagnant
                : isStagnant // ignore: cast_nullable_to_non_nullable
                      as bool,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProgressionSuggestionImplCopyWith<$Res>
    implements $ProgressionSuggestionCopyWith<$Res> {
  factory _$$ProgressionSuggestionImplCopyWith(
    _$ProgressionSuggestionImpl value,
    $Res Function(_$ProgressionSuggestionImpl) then,
  ) = __$$ProgressionSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double suggestedWeight,
    int suggestedReps,
    bool isStagnant,
    String? message,
  });
}

/// @nodoc
class __$$ProgressionSuggestionImplCopyWithImpl<$Res>
    extends
        _$ProgressionSuggestionCopyWithImpl<$Res, _$ProgressionSuggestionImpl>
    implements _$$ProgressionSuggestionImplCopyWith<$Res> {
  __$$ProgressionSuggestionImplCopyWithImpl(
    _$ProgressionSuggestionImpl _value,
    $Res Function(_$ProgressionSuggestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProgressionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? suggestedWeight = null,
    Object? suggestedReps = null,
    Object? isStagnant = null,
    Object? message = freezed,
  }) {
    return _then(
      _$ProgressionSuggestionImpl(
        suggestedWeight: null == suggestedWeight
            ? _value.suggestedWeight
            : suggestedWeight // ignore: cast_nullable_to_non_nullable
                  as double,
        suggestedReps: null == suggestedReps
            ? _value.suggestedReps
            : suggestedReps // ignore: cast_nullable_to_non_nullable
                  as int,
        isStagnant: null == isStagnant
            ? _value.isStagnant
            : isStagnant // ignore: cast_nullable_to_non_nullable
                  as bool,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ProgressionSuggestionImpl implements _ProgressionSuggestion {
  const _$ProgressionSuggestionImpl({
    required this.suggestedWeight,
    required this.suggestedReps,
    required this.isStagnant,
    this.message,
  });

  @override
  final double suggestedWeight;
  @override
  final int suggestedReps;
  @override
  final bool isStagnant;
  @override
  final String? message;

  @override
  String toString() {
    return 'ProgressionSuggestion(suggestedWeight: $suggestedWeight, suggestedReps: $suggestedReps, isStagnant: $isStagnant, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressionSuggestionImpl &&
            (identical(other.suggestedWeight, suggestedWeight) ||
                other.suggestedWeight == suggestedWeight) &&
            (identical(other.suggestedReps, suggestedReps) ||
                other.suggestedReps == suggestedReps) &&
            (identical(other.isStagnant, isStagnant) ||
                other.isStagnant == isStagnant) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    suggestedWeight,
    suggestedReps,
    isStagnant,
    message,
  );

  /// Create a copy of ProgressionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressionSuggestionImplCopyWith<_$ProgressionSuggestionImpl>
  get copyWith =>
      __$$ProgressionSuggestionImplCopyWithImpl<_$ProgressionSuggestionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProgressionSuggestion value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProgressionSuggestion value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProgressionSuggestion value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _ProgressionSuggestion implements ProgressionSuggestion {
  const factory _ProgressionSuggestion({
    required final double suggestedWeight,
    required final int suggestedReps,
    required final bool isStagnant,
    final String? message,
  }) = _$ProgressionSuggestionImpl;

  @override
  double get suggestedWeight;
  @override
  int get suggestedReps;
  @override
  bool get isStagnant;
  @override
  String? get message;

  /// Create a copy of ProgressionSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressionSuggestionImplCopyWith<_$ProgressionSuggestionImpl>
  get copyWith => throw _privateConstructorUsedError;
}

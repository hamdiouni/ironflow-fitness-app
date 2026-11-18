// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'streak.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Streak _$StreakFromJson(Map<String, dynamic> json) {
  return _Streak.fromJson(json);
}

/// @nodoc
mixin _$Streak {
  /// Current consecutive day count
  int get currentStreak => throw _privateConstructorUsedError;

  /// Longest streak ever achieved
  int get longestStreak => throw _privateConstructorUsedError;

  /// Date of the last workout
  DateTime get lastWorkoutDate => throw _privateConstructorUsedError;

  /// Date when the current streak started
  DateTime get streakStartDate => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Streak value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Streak value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Streak value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this Streak to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Streak
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakCopyWith<Streak> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakCopyWith<$Res> {
  factory $StreakCopyWith(Streak value, $Res Function(Streak) then) =
      _$StreakCopyWithImpl<$Res, Streak>;
  @useResult
  $Res call({
    int currentStreak,
    int longestStreak,
    DateTime lastWorkoutDate,
    DateTime streakStartDate,
  });
}

/// @nodoc
class _$StreakCopyWithImpl<$Res, $Val extends Streak>
    implements $StreakCopyWith<$Res> {
  _$StreakCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Streak
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastWorkoutDate = null,
    Object? streakStartDate = null,
  }) {
    return _then(
      _value.copyWith(
            currentStreak: null == currentStreak
                ? _value.currentStreak
                : currentStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            longestStreak: null == longestStreak
                ? _value.longestStreak
                : longestStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            lastWorkoutDate: null == lastWorkoutDate
                ? _value.lastWorkoutDate
                : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            streakStartDate: null == streakStartDate
                ? _value.streakStartDate
                : streakStartDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StreakImplCopyWith<$Res> implements $StreakCopyWith<$Res> {
  factory _$$StreakImplCopyWith(
    _$StreakImpl value,
    $Res Function(_$StreakImpl) then,
  ) = __$$StreakImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int currentStreak,
    int longestStreak,
    DateTime lastWorkoutDate,
    DateTime streakStartDate,
  });
}

/// @nodoc
class __$$StreakImplCopyWithImpl<$Res>
    extends _$StreakCopyWithImpl<$Res, _$StreakImpl>
    implements _$$StreakImplCopyWith<$Res> {
  __$$StreakImplCopyWithImpl(
    _$StreakImpl _value,
    $Res Function(_$StreakImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Streak
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastWorkoutDate = null,
    Object? streakStartDate = null,
  }) {
    return _then(
      _$StreakImpl(
        currentStreak: null == currentStreak
            ? _value.currentStreak
            : currentStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        longestStreak: null == longestStreak
            ? _value.longestStreak
            : longestStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        lastWorkoutDate: null == lastWorkoutDate
            ? _value.lastWorkoutDate
            : lastWorkoutDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        streakStartDate: null == streakStartDate
            ? _value.streakStartDate
            : streakStartDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakImpl extends _Streak {
  const _$StreakImpl({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastWorkoutDate,
    required this.streakStartDate,
  }) : super._();

  factory _$StreakImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakImplFromJson(json);

  /// Current consecutive day count
  @override
  final int currentStreak;

  /// Longest streak ever achieved
  @override
  final int longestStreak;

  /// Date of the last workout
  @override
  final DateTime lastWorkoutDate;

  /// Date when the current streak started
  @override
  final DateTime streakStartDate;

  @override
  String toString() {
    return 'Streak(currentStreak: $currentStreak, longestStreak: $longestStreak, lastWorkoutDate: $lastWorkoutDate, streakStartDate: $streakStartDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakImpl &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.lastWorkoutDate, lastWorkoutDate) ||
                other.lastWorkoutDate == lastWorkoutDate) &&
            (identical(other.streakStartDate, streakStartDate) ||
                other.streakStartDate == streakStartDate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentStreak,
    longestStreak,
    lastWorkoutDate,
    streakStartDate,
  );

  /// Create a copy of Streak
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakImplCopyWith<_$StreakImpl> get copyWith =>
      __$$StreakImplCopyWithImpl<_$StreakImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Streak value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Streak value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Streak value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakImplToJson(this);
  }
}

abstract class _Streak extends Streak {
  const factory _Streak({
    required final int currentStreak,
    required final int longestStreak,
    required final DateTime lastWorkoutDate,
    required final DateTime streakStartDate,
  }) = _$StreakImpl;
  const _Streak._() : super._();

  factory _Streak.fromJson(Map<String, dynamic> json) = _$StreakImpl.fromJson;

  /// Current consecutive day count
  @override
  int get currentStreak;

  /// Longest streak ever achieved
  @override
  int get longestStreak;

  /// Date of the last workout
  @override
  DateTime get lastWorkoutDate;

  /// Date when the current streak started
  @override
  DateTime get streakStartDate;

  /// Create a copy of Streak
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakImplCopyWith<_$StreakImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_workout_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaginatedWorkoutState {
  List<Workout> get workouts => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get hasReachedEnd => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PaginatedWorkoutState value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PaginatedWorkoutState value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PaginatedWorkoutState value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of PaginatedWorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginatedWorkoutStateCopyWith<PaginatedWorkoutState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginatedWorkoutStateCopyWith<$Res> {
  factory $PaginatedWorkoutStateCopyWith(
    PaginatedWorkoutState value,
    $Res Function(PaginatedWorkoutState) then,
  ) = _$PaginatedWorkoutStateCopyWithImpl<$Res, PaginatedWorkoutState>;
  @useResult
  $Res call({
    List<Workout> workouts,
    bool isLoading,
    bool isLoadingMore,
    bool hasReachedEnd,
    String? error,
    int totalCount,
  });
}

/// @nodoc
class _$PaginatedWorkoutStateCopyWithImpl<
  $Res,
  $Val extends PaginatedWorkoutState
>
    implements $PaginatedWorkoutStateCopyWith<$Res> {
  _$PaginatedWorkoutStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginatedWorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workouts = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasReachedEnd = null,
    Object? error = freezed,
    Object? totalCount = null,
  }) {
    return _then(
      _value.copyWith(
            workouts: null == workouts
                ? _value.workouts
                : workouts // ignore: cast_nullable_to_non_nullable
                      as List<Workout>,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingMore: null == isLoadingMore
                ? _value.isLoadingMore
                : isLoadingMore // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasReachedEnd: null == hasReachedEnd
                ? _value.hasReachedEnd
                : hasReachedEnd // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            totalCount: null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PaginatedWorkoutStateImplCopyWith<$Res>
    implements $PaginatedWorkoutStateCopyWith<$Res> {
  factory _$$PaginatedWorkoutStateImplCopyWith(
    _$PaginatedWorkoutStateImpl value,
    $Res Function(_$PaginatedWorkoutStateImpl) then,
  ) = __$$PaginatedWorkoutStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Workout> workouts,
    bool isLoading,
    bool isLoadingMore,
    bool hasReachedEnd,
    String? error,
    int totalCount,
  });
}

/// @nodoc
class __$$PaginatedWorkoutStateImplCopyWithImpl<$Res>
    extends
        _$PaginatedWorkoutStateCopyWithImpl<$Res, _$PaginatedWorkoutStateImpl>
    implements _$$PaginatedWorkoutStateImplCopyWith<$Res> {
  __$$PaginatedWorkoutStateImplCopyWithImpl(
    _$PaginatedWorkoutStateImpl _value,
    $Res Function(_$PaginatedWorkoutStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginatedWorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? workouts = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasReachedEnd = null,
    Object? error = freezed,
    Object? totalCount = null,
  }) {
    return _then(
      _$PaginatedWorkoutStateImpl(
        workouts: null == workouts
            ? _value._workouts
            : workouts // ignore: cast_nullable_to_non_nullable
                  as List<Workout>,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingMore: null == isLoadingMore
            ? _value.isLoadingMore
            : isLoadingMore // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasReachedEnd: null == hasReachedEnd
            ? _value.hasReachedEnd
            : hasReachedEnd // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        totalCount: null == totalCount
            ? _value.totalCount
            : totalCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$PaginatedWorkoutStateImpl implements _PaginatedWorkoutState {
  const _$PaginatedWorkoutStateImpl({
    final List<Workout> workouts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.error = null,
    this.totalCount = 0,
  }) : _workouts = workouts;

  final List<Workout> _workouts;
  @override
  @JsonKey()
  List<Workout> get workouts {
    if (_workouts is EqualUnmodifiableListView) return _workouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workouts);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool hasReachedEnd;
  @override
  @JsonKey()
  final String? error;
  @override
  @JsonKey()
  final int totalCount;

  @override
  String toString() {
    return 'PaginatedWorkoutState(workouts: $workouts, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasReachedEnd: $hasReachedEnd, error: $error, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginatedWorkoutStateImpl &&
            const DeepCollectionEquality().equals(other._workouts, _workouts) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasReachedEnd, hasReachedEnd) ||
                other.hasReachedEnd == hasReachedEnd) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_workouts),
    isLoading,
    isLoadingMore,
    hasReachedEnd,
    error,
    totalCount,
  );

  /// Create a copy of PaginatedWorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginatedWorkoutStateImplCopyWith<_$PaginatedWorkoutStateImpl>
  get copyWith =>
      __$$PaginatedWorkoutStateImplCopyWithImpl<_$PaginatedWorkoutStateImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PaginatedWorkoutState value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PaginatedWorkoutState value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PaginatedWorkoutState value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _PaginatedWorkoutState implements PaginatedWorkoutState {
  const factory _PaginatedWorkoutState({
    final List<Workout> workouts,
    final bool isLoading,
    final bool isLoadingMore,
    final bool hasReachedEnd,
    final String? error,
    final int totalCount,
  }) = _$PaginatedWorkoutStateImpl;

  @override
  List<Workout> get workouts;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get hasReachedEnd;
  @override
  String? get error;
  @override
  int get totalCount;

  /// Create a copy of PaginatedWorkoutState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginatedWorkoutStateImplCopyWith<_$PaginatedWorkoutStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

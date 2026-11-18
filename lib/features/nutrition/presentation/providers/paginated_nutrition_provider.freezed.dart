// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'paginated_nutrition_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PaginatedNutritionState {
  List<DailyNutritionSummary> get nutritionHistory =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get hasReachedEnd => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  int get totalCount => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PaginatedNutritionState value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PaginatedNutritionState value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PaginatedNutritionState value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of PaginatedNutritionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PaginatedNutritionStateCopyWith<PaginatedNutritionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginatedNutritionStateCopyWith<$Res> {
  factory $PaginatedNutritionStateCopyWith(
    PaginatedNutritionState value,
    $Res Function(PaginatedNutritionState) then,
  ) = _$PaginatedNutritionStateCopyWithImpl<$Res, PaginatedNutritionState>;
  @useResult
  $Res call({
    List<DailyNutritionSummary> nutritionHistory,
    bool isLoading,
    bool isLoadingMore,
    bool hasReachedEnd,
    String? error,
    int totalCount,
  });
}

/// @nodoc
class _$PaginatedNutritionStateCopyWithImpl<
  $Res,
  $Val extends PaginatedNutritionState
>
    implements $PaginatedNutritionStateCopyWith<$Res> {
  _$PaginatedNutritionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PaginatedNutritionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nutritionHistory = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasReachedEnd = null,
    Object? error = freezed,
    Object? totalCount = null,
  }) {
    return _then(
      _value.copyWith(
            nutritionHistory: null == nutritionHistory
                ? _value.nutritionHistory
                : nutritionHistory // ignore: cast_nullable_to_non_nullable
                      as List<DailyNutritionSummary>,
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
abstract class _$$PaginatedNutritionStateImplCopyWith<$Res>
    implements $PaginatedNutritionStateCopyWith<$Res> {
  factory _$$PaginatedNutritionStateImplCopyWith(
    _$PaginatedNutritionStateImpl value,
    $Res Function(_$PaginatedNutritionStateImpl) then,
  ) = __$$PaginatedNutritionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<DailyNutritionSummary> nutritionHistory,
    bool isLoading,
    bool isLoadingMore,
    bool hasReachedEnd,
    String? error,
    int totalCount,
  });
}

/// @nodoc
class __$$PaginatedNutritionStateImplCopyWithImpl<$Res>
    extends
        _$PaginatedNutritionStateCopyWithImpl<
          $Res,
          _$PaginatedNutritionStateImpl
        >
    implements _$$PaginatedNutritionStateImplCopyWith<$Res> {
  __$$PaginatedNutritionStateImplCopyWithImpl(
    _$PaginatedNutritionStateImpl _value,
    $Res Function(_$PaginatedNutritionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PaginatedNutritionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? nutritionHistory = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasReachedEnd = null,
    Object? error = freezed,
    Object? totalCount = null,
  }) {
    return _then(
      _$PaginatedNutritionStateImpl(
        nutritionHistory: null == nutritionHistory
            ? _value._nutritionHistory
            : nutritionHistory // ignore: cast_nullable_to_non_nullable
                  as List<DailyNutritionSummary>,
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

class _$PaginatedNutritionStateImpl implements _PaginatedNutritionState {
  const _$PaginatedNutritionStateImpl({
    final List<DailyNutritionSummary> nutritionHistory = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.error = null,
    this.totalCount = 0,
  }) : _nutritionHistory = nutritionHistory;

  final List<DailyNutritionSummary> _nutritionHistory;
  @override
  @JsonKey()
  List<DailyNutritionSummary> get nutritionHistory {
    if (_nutritionHistory is EqualUnmodifiableListView)
      return _nutritionHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nutritionHistory);
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
    return 'PaginatedNutritionState(nutritionHistory: $nutritionHistory, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasReachedEnd: $hasReachedEnd, error: $error, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PaginatedNutritionStateImpl &&
            const DeepCollectionEquality().equals(
              other._nutritionHistory,
              _nutritionHistory,
            ) &&
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
    const DeepCollectionEquality().hash(_nutritionHistory),
    isLoading,
    isLoadingMore,
    hasReachedEnd,
    error,
    totalCount,
  );

  /// Create a copy of PaginatedNutritionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PaginatedNutritionStateImplCopyWith<_$PaginatedNutritionStateImpl>
  get copyWith =>
      __$$PaginatedNutritionStateImplCopyWithImpl<
        _$PaginatedNutritionStateImpl
      >(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_PaginatedNutritionState value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_PaginatedNutritionState value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_PaginatedNutritionState value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _PaginatedNutritionState implements PaginatedNutritionState {
  const factory _PaginatedNutritionState({
    final List<DailyNutritionSummary> nutritionHistory,
    final bool isLoading,
    final bool isLoadingMore,
    final bool hasReachedEnd,
    final String? error,
    final int totalCount,
  }) = _$PaginatedNutritionStateImpl;

  @override
  List<DailyNutritionSummary> get nutritionHistory;
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

  /// Create a copy of PaginatedNutritionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PaginatedNutritionStateImplCopyWith<_$PaginatedNutritionStateImpl>
  get copyWith => throw _privateConstructorUsedError;
}

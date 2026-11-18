// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diet_plan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DietPlanState {
  DietPlan get plan => throw _privateConstructorUsedError;
  Map<String, DietMeal> get mealSwaps =>
      throw _privateConstructorUsedError; // mealId -> swapped meal
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DietPlanState value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DietPlanState value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DietPlanState value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of DietPlanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DietPlanStateCopyWith<DietPlanState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DietPlanStateCopyWith<$Res> {
  factory $DietPlanStateCopyWith(
    DietPlanState value,
    $Res Function(DietPlanState) then,
  ) = _$DietPlanStateCopyWithImpl<$Res, DietPlanState>;
  @useResult
  $Res call({
    DietPlan plan,
    Map<String, DietMeal> mealSwaps,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class _$DietPlanStateCopyWithImpl<$Res, $Val extends DietPlanState>
    implements $DietPlanStateCopyWith<$Res> {
  _$DietPlanStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DietPlanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = null,
    Object? mealSwaps = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _value.copyWith(
            plan: null == plan
                ? _value.plan
                : plan // ignore: cast_nullable_to_non_nullable
                      as DietPlan,
            mealSwaps: null == mealSwaps
                ? _value.mealSwaps
                : mealSwaps // ignore: cast_nullable_to_non_nullable
                      as Map<String, DietMeal>,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DietPlanStateImplCopyWith<$Res>
    implements $DietPlanStateCopyWith<$Res> {
  factory _$$DietPlanStateImplCopyWith(
    _$DietPlanStateImpl value,
    $Res Function(_$DietPlanStateImpl) then,
  ) = __$$DietPlanStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DietPlan plan,
    Map<String, DietMeal> mealSwaps,
    DateTime? lastUpdated,
  });
}

/// @nodoc
class __$$DietPlanStateImplCopyWithImpl<$Res>
    extends _$DietPlanStateCopyWithImpl<$Res, _$DietPlanStateImpl>
    implements _$$DietPlanStateImplCopyWith<$Res> {
  __$$DietPlanStateImplCopyWithImpl(
    _$DietPlanStateImpl _value,
    $Res Function(_$DietPlanStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DietPlanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = null,
    Object? mealSwaps = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _$DietPlanStateImpl(
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as DietPlan,
        mealSwaps: null == mealSwaps
            ? _value._mealSwaps
            : mealSwaps // ignore: cast_nullable_to_non_nullable
                  as Map<String, DietMeal>,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$DietPlanStateImpl extends _DietPlanState {
  const _$DietPlanStateImpl({
    required this.plan,
    final Map<String, DietMeal> mealSwaps = const {},
    this.lastUpdated,
  }) : _mealSwaps = mealSwaps,
       super._();

  @override
  final DietPlan plan;
  final Map<String, DietMeal> _mealSwaps;
  @override
  @JsonKey()
  Map<String, DietMeal> get mealSwaps {
    if (_mealSwaps is EqualUnmodifiableMapView) return _mealSwaps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_mealSwaps);
  }

  // mealId -> swapped meal
  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'DietPlanState(plan: $plan, mealSwaps: $mealSwaps, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DietPlanStateImpl &&
            (identical(other.plan, plan) || other.plan == plan) &&
            const DeepCollectionEquality().equals(
              other._mealSwaps,
              _mealSwaps,
            ) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    plan,
    const DeepCollectionEquality().hash(_mealSwaps),
    lastUpdated,
  );

  /// Create a copy of DietPlanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DietPlanStateImplCopyWith<_$DietPlanStateImpl> get copyWith =>
      __$$DietPlanStateImplCopyWithImpl<_$DietPlanStateImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DietPlanState value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DietPlanState value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DietPlanState value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _DietPlanState extends DietPlanState {
  const factory _DietPlanState({
    required final DietPlan plan,
    final Map<String, DietMeal> mealSwaps,
    final DateTime? lastUpdated,
  }) = _$DietPlanStateImpl;
  const _DietPlanState._() : super._();

  @override
  DietPlan get plan;
  @override
  Map<String, DietMeal> get mealSwaps; // mealId -> swapped meal
  @override
  DateTime? get lastUpdated;

  /// Create a copy of DietPlanState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DietPlanStateImplCopyWith<_$DietPlanStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

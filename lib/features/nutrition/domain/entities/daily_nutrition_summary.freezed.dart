// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_nutrition_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DailyNutritionSummary {
  DateTime get date => throw _privateConstructorUsedError;
  List<Meal> get meals => throw _privateConstructorUsedError;
  NutritionTargets? get target => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DailyNutritionSummary value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DailyNutritionSummary value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DailyNutritionSummary value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyNutritionSummaryCopyWith<DailyNutritionSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyNutritionSummaryCopyWith<$Res> {
  factory $DailyNutritionSummaryCopyWith(
    DailyNutritionSummary value,
    $Res Function(DailyNutritionSummary) then,
  ) = _$DailyNutritionSummaryCopyWithImpl<$Res, DailyNutritionSummary>;
  @useResult
  $Res call({DateTime date, List<Meal> meals, NutritionTargets? target});

  $NutritionTargetsCopyWith<$Res>? get target;
}

/// @nodoc
class _$DailyNutritionSummaryCopyWithImpl<
  $Res,
  $Val extends DailyNutritionSummary
>
    implements $DailyNutritionSummaryCopyWith<$Res> {
  _$DailyNutritionSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? meals = null,
    Object? target = freezed,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            meals: null == meals
                ? _value.meals
                : meals // ignore: cast_nullable_to_non_nullable
                      as List<Meal>,
            target: freezed == target
                ? _value.target
                : target // ignore: cast_nullable_to_non_nullable
                      as NutritionTargets?,
          )
          as $Val,
    );
  }

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionTargetsCopyWith<$Res>? get target {
    if (_value.target == null) {
      return null;
    }

    return $NutritionTargetsCopyWith<$Res>(_value.target!, (value) {
      return _then(_value.copyWith(target: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DailyNutritionSummaryImplCopyWith<$Res>
    implements $DailyNutritionSummaryCopyWith<$Res> {
  factory _$$DailyNutritionSummaryImplCopyWith(
    _$DailyNutritionSummaryImpl value,
    $Res Function(_$DailyNutritionSummaryImpl) then,
  ) = __$$DailyNutritionSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, List<Meal> meals, NutritionTargets? target});

  @override
  $NutritionTargetsCopyWith<$Res>? get target;
}

/// @nodoc
class __$$DailyNutritionSummaryImplCopyWithImpl<$Res>
    extends
        _$DailyNutritionSummaryCopyWithImpl<$Res, _$DailyNutritionSummaryImpl>
    implements _$$DailyNutritionSummaryImplCopyWith<$Res> {
  __$$DailyNutritionSummaryImplCopyWithImpl(
    _$DailyNutritionSummaryImpl _value,
    $Res Function(_$DailyNutritionSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? meals = null,
    Object? target = freezed,
  }) {
    return _then(
      _$DailyNutritionSummaryImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        meals: null == meals
            ? _value._meals
            : meals // ignore: cast_nullable_to_non_nullable
                  as List<Meal>,
        target: freezed == target
            ? _value.target
            : target // ignore: cast_nullable_to_non_nullable
                  as NutritionTargets?,
      ),
    );
  }
}

/// @nodoc

class _$DailyNutritionSummaryImpl extends _DailyNutritionSummary {
  const _$DailyNutritionSummaryImpl({
    required this.date,
    required final List<Meal> meals,
    required this.target,
  }) : _meals = meals,
       super._();

  @override
  final DateTime date;
  final List<Meal> _meals;
  @override
  List<Meal> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  @override
  final NutritionTargets? target;

  @override
  String toString() {
    return 'DailyNutritionSummary(date: $date, meals: $meals, target: $target)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyNutritionSummaryImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._meals, _meals) &&
            (identical(other.target, target) || other.target == target));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    const DeepCollectionEquality().hash(_meals),
    target,
  );

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyNutritionSummaryImplCopyWith<_$DailyNutritionSummaryImpl>
  get copyWith =>
      __$$DailyNutritionSummaryImplCopyWithImpl<_$DailyNutritionSummaryImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DailyNutritionSummary value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DailyNutritionSummary value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DailyNutritionSummary value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _DailyNutritionSummary extends DailyNutritionSummary {
  const factory _DailyNutritionSummary({
    required final DateTime date,
    required final List<Meal> meals,
    required final NutritionTargets? target,
  }) = _$DailyNutritionSummaryImpl;
  const _DailyNutritionSummary._() : super._();

  @override
  DateTime get date;
  @override
  List<Meal> get meals;
  @override
  NutritionTargets? get target;

  /// Create a copy of DailyNutritionSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyNutritionSummaryImplCopyWith<_$DailyNutritionSummaryImpl>
  get copyWith => throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$NutritionState {
  /// All preloaded foods from database
  List<FoodItem> get allFoods => throw _privateConstructorUsedError;

  /// User-created custom foods
  List<FoodItem> get customFoods => throw _privateConstructorUsedError;

  /// Today's logged meals
  List<Meal> get todayMeals => throw _privateConstructorUsedError;

  /// Current date being viewed
  DateTime get currentDate => throw _privateConstructorUsedError;

  /// Daily nutrition targets (calories, macros)
  NutritionTargets? get targets => throw _privateConstructorUsedError;

  /// Loading state
  bool get isLoading => throw _privateConstructorUsedError;

  /// Error message (null if no error)
  String? get error => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NutritionState value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NutritionState value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NutritionState value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NutritionStateCopyWith<NutritionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NutritionStateCopyWith<$Res> {
  factory $NutritionStateCopyWith(
    NutritionState value,
    $Res Function(NutritionState) then,
  ) = _$NutritionStateCopyWithImpl<$Res, NutritionState>;
  @useResult
  $Res call({
    List<FoodItem> allFoods,
    List<FoodItem> customFoods,
    List<Meal> todayMeals,
    DateTime currentDate,
    NutritionTargets? targets,
    bool isLoading,
    String? error,
  });

  $NutritionTargetsCopyWith<$Res>? get targets;
}

/// @nodoc
class _$NutritionStateCopyWithImpl<$Res, $Val extends NutritionState>
    implements $NutritionStateCopyWith<$Res> {
  _$NutritionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allFoods = null,
    Object? customFoods = null,
    Object? todayMeals = null,
    Object? currentDate = null,
    Object? targets = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            allFoods: null == allFoods
                ? _value.allFoods
                : allFoods // ignore: cast_nullable_to_non_nullable
                      as List<FoodItem>,
            customFoods: null == customFoods
                ? _value.customFoods
                : customFoods // ignore: cast_nullable_to_non_nullable
                      as List<FoodItem>,
            todayMeals: null == todayMeals
                ? _value.todayMeals
                : todayMeals // ignore: cast_nullable_to_non_nullable
                      as List<Meal>,
            currentDate: null == currentDate
                ? _value.currentDate
                : currentDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            targets: freezed == targets
                ? _value.targets
                : targets // ignore: cast_nullable_to_non_nullable
                      as NutritionTargets?,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionTargetsCopyWith<$Res>? get targets {
    if (_value.targets == null) {
      return null;
    }

    return $NutritionTargetsCopyWith<$Res>(_value.targets!, (value) {
      return _then(_value.copyWith(targets: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NutritionStateImplCopyWith<$Res>
    implements $NutritionStateCopyWith<$Res> {
  factory _$$NutritionStateImplCopyWith(
    _$NutritionStateImpl value,
    $Res Function(_$NutritionStateImpl) then,
  ) = __$$NutritionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<FoodItem> allFoods,
    List<FoodItem> customFoods,
    List<Meal> todayMeals,
    DateTime currentDate,
    NutritionTargets? targets,
    bool isLoading,
    String? error,
  });

  @override
  $NutritionTargetsCopyWith<$Res>? get targets;
}

/// @nodoc
class __$$NutritionStateImplCopyWithImpl<$Res>
    extends _$NutritionStateCopyWithImpl<$Res, _$NutritionStateImpl>
    implements _$$NutritionStateImplCopyWith<$Res> {
  __$$NutritionStateImplCopyWithImpl(
    _$NutritionStateImpl _value,
    $Res Function(_$NutritionStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allFoods = null,
    Object? customFoods = null,
    Object? todayMeals = null,
    Object? currentDate = null,
    Object? targets = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$NutritionStateImpl(
        allFoods: null == allFoods
            ? _value._allFoods
            : allFoods // ignore: cast_nullable_to_non_nullable
                  as List<FoodItem>,
        customFoods: null == customFoods
            ? _value._customFoods
            : customFoods // ignore: cast_nullable_to_non_nullable
                  as List<FoodItem>,
        todayMeals: null == todayMeals
            ? _value._todayMeals
            : todayMeals // ignore: cast_nullable_to_non_nullable
                  as List<Meal>,
        currentDate: null == currentDate
            ? _value.currentDate
            : currentDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        targets: freezed == targets
            ? _value.targets
            : targets // ignore: cast_nullable_to_non_nullable
                  as NutritionTargets?,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$NutritionStateImpl extends _NutritionState {
  const _$NutritionStateImpl({
    final List<FoodItem> allFoods = const [],
    final List<FoodItem> customFoods = const [],
    final List<Meal> todayMeals = const [],
    required this.currentDate,
    this.targets,
    this.isLoading = false,
    this.error,
  }) : _allFoods = allFoods,
       _customFoods = customFoods,
       _todayMeals = todayMeals,
       super._();

  /// All preloaded foods from database
  final List<FoodItem> _allFoods;

  /// All preloaded foods from database
  @override
  @JsonKey()
  List<FoodItem> get allFoods {
    if (_allFoods is EqualUnmodifiableListView) return _allFoods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allFoods);
  }

  /// User-created custom foods
  final List<FoodItem> _customFoods;

  /// User-created custom foods
  @override
  @JsonKey()
  List<FoodItem> get customFoods {
    if (_customFoods is EqualUnmodifiableListView) return _customFoods;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customFoods);
  }

  /// Today's logged meals
  final List<Meal> _todayMeals;

  /// Today's logged meals
  @override
  @JsonKey()
  List<Meal> get todayMeals {
    if (_todayMeals is EqualUnmodifiableListView) return _todayMeals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todayMeals);
  }

  /// Current date being viewed
  @override
  final DateTime currentDate;

  /// Daily nutrition targets (calories, macros)
  @override
  final NutritionTargets? targets;

  /// Loading state
  @override
  @JsonKey()
  final bool isLoading;

  /// Error message (null if no error)
  @override
  final String? error;

  @override
  String toString() {
    return 'NutritionState(allFoods: $allFoods, customFoods: $customFoods, todayMeals: $todayMeals, currentDate: $currentDate, targets: $targets, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NutritionStateImpl &&
            const DeepCollectionEquality().equals(other._allFoods, _allFoods) &&
            const DeepCollectionEquality().equals(
              other._customFoods,
              _customFoods,
            ) &&
            const DeepCollectionEquality().equals(
              other._todayMeals,
              _todayMeals,
            ) &&
            (identical(other.currentDate, currentDate) ||
                other.currentDate == currentDate) &&
            (identical(other.targets, targets) || other.targets == targets) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_allFoods),
    const DeepCollectionEquality().hash(_customFoods),
    const DeepCollectionEquality().hash(_todayMeals),
    currentDate,
    targets,
    isLoading,
    error,
  );

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NutritionStateImplCopyWith<_$NutritionStateImpl> get copyWith =>
      __$$NutritionStateImplCopyWithImpl<_$NutritionStateImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NutritionState value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NutritionState value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NutritionState value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _NutritionState extends NutritionState {
  const factory _NutritionState({
    final List<FoodItem> allFoods,
    final List<FoodItem> customFoods,
    final List<Meal> todayMeals,
    required final DateTime currentDate,
    final NutritionTargets? targets,
    final bool isLoading,
    final String? error,
  }) = _$NutritionStateImpl;
  const _NutritionState._() : super._();

  /// All preloaded foods from database
  @override
  List<FoodItem> get allFoods;

  /// User-created custom foods
  @override
  List<FoodItem> get customFoods;

  /// Today's logged meals
  @override
  List<Meal> get todayMeals;

  /// Current date being viewed
  @override
  DateTime get currentDate;

  /// Daily nutrition targets (calories, macros)
  @override
  NutritionTargets? get targets;

  /// Loading state
  @override
  bool get isLoading;

  /// Error message (null if no error)
  @override
  String? get error;

  /// Create a copy of NutritionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NutritionStateImplCopyWith<_$NutritionStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

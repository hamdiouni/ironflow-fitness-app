// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'diet_plan_state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DietPlanStateModel _$DietPlanStateModelFromJson(Map<String, dynamic> json) {
  return _DietPlanStateModel.fromJson(json);
}

/// @nodoc
mixin _$DietPlanStateModel {
  DietPlanModel get plan => throw _privateConstructorUsedError;
  Map<String, DietMealModel> get mealSwaps =>
      throw _privateConstructorUsedError;
  DateTime? get lastUpdated => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DietPlanStateModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DietPlanStateModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DietPlanStateModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this DietPlanStateModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DietPlanStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DietPlanStateModelCopyWith<DietPlanStateModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DietPlanStateModelCopyWith<$Res> {
  factory $DietPlanStateModelCopyWith(
    DietPlanStateModel value,
    $Res Function(DietPlanStateModel) then,
  ) = _$DietPlanStateModelCopyWithImpl<$Res, DietPlanStateModel>;
  @useResult
  $Res call({
    DietPlanModel plan,
    Map<String, DietMealModel> mealSwaps,
    DateTime? lastUpdated,
  });

  $DietPlanModelCopyWith<$Res> get plan;
}

/// @nodoc
class _$DietPlanStateModelCopyWithImpl<$Res, $Val extends DietPlanStateModel>
    implements $DietPlanStateModelCopyWith<$Res> {
  _$DietPlanStateModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DietPlanStateModel
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
                      as DietPlanModel,
            mealSwaps: null == mealSwaps
                ? _value.mealSwaps
                : mealSwaps // ignore: cast_nullable_to_non_nullable
                      as Map<String, DietMealModel>,
            lastUpdated: freezed == lastUpdated
                ? _value.lastUpdated
                : lastUpdated // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of DietPlanStateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $DietPlanModelCopyWith<$Res> get plan {
    return $DietPlanModelCopyWith<$Res>(_value.plan, (value) {
      return _then(_value.copyWith(plan: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DietPlanStateModelImplCopyWith<$Res>
    implements $DietPlanStateModelCopyWith<$Res> {
  factory _$$DietPlanStateModelImplCopyWith(
    _$DietPlanStateModelImpl value,
    $Res Function(_$DietPlanStateModelImpl) then,
  ) = __$$DietPlanStateModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DietPlanModel plan,
    Map<String, DietMealModel> mealSwaps,
    DateTime? lastUpdated,
  });

  @override
  $DietPlanModelCopyWith<$Res> get plan;
}

/// @nodoc
class __$$DietPlanStateModelImplCopyWithImpl<$Res>
    extends _$DietPlanStateModelCopyWithImpl<$Res, _$DietPlanStateModelImpl>
    implements _$$DietPlanStateModelImplCopyWith<$Res> {
  __$$DietPlanStateModelImplCopyWithImpl(
    _$DietPlanStateModelImpl _value,
    $Res Function(_$DietPlanStateModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DietPlanStateModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? plan = null,
    Object? mealSwaps = null,
    Object? lastUpdated = freezed,
  }) {
    return _then(
      _$DietPlanStateModelImpl(
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as DietPlanModel,
        mealSwaps: null == mealSwaps
            ? _value._mealSwaps
            : mealSwaps // ignore: cast_nullable_to_non_nullable
                  as Map<String, DietMealModel>,
        lastUpdated: freezed == lastUpdated
            ? _value.lastUpdated
            : lastUpdated // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DietPlanStateModelImpl implements _DietPlanStateModel {
  const _$DietPlanStateModelImpl({
    required this.plan,
    final Map<String, DietMealModel> mealSwaps = const {},
    this.lastUpdated,
  }) : _mealSwaps = mealSwaps;

  factory _$DietPlanStateModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DietPlanStateModelImplFromJson(json);

  @override
  final DietPlanModel plan;
  final Map<String, DietMealModel> _mealSwaps;
  @override
  @JsonKey()
  Map<String, DietMealModel> get mealSwaps {
    if (_mealSwaps is EqualUnmodifiableMapView) return _mealSwaps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_mealSwaps);
  }

  @override
  final DateTime? lastUpdated;

  @override
  String toString() {
    return 'DietPlanStateModel(plan: $plan, mealSwaps: $mealSwaps, lastUpdated: $lastUpdated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DietPlanStateModelImpl &&
            (identical(other.plan, plan) || other.plan == plan) &&
            const DeepCollectionEquality().equals(
              other._mealSwaps,
              _mealSwaps,
            ) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    plan,
    const DeepCollectionEquality().hash(_mealSwaps),
    lastUpdated,
  );

  /// Create a copy of DietPlanStateModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DietPlanStateModelImplCopyWith<_$DietPlanStateModelImpl> get copyWith =>
      __$$DietPlanStateModelImplCopyWithImpl<_$DietPlanStateModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DietPlanStateModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DietPlanStateModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DietPlanStateModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DietPlanStateModelImplToJson(this);
  }
}

abstract class _DietPlanStateModel implements DietPlanStateModel {
  const factory _DietPlanStateModel({
    required final DietPlanModel plan,
    final Map<String, DietMealModel> mealSwaps,
    final DateTime? lastUpdated,
  }) = _$DietPlanStateModelImpl;

  factory _DietPlanStateModel.fromJson(Map<String, dynamic> json) =
      _$DietPlanStateModelImpl.fromJson;

  @override
  DietPlanModel get plan;
  @override
  Map<String, DietMealModel> get mealSwaps;
  @override
  DateTime? get lastUpdated;

  /// Create a copy of DietPlanStateModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DietPlanStateModelImplCopyWith<_$DietPlanStateModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DietPlanModel _$DietPlanModelFromJson(Map<String, dynamic> json) {
  return _DietPlanModel.fromJson(json);
}

/// @nodoc
mixin _$DietPlanModel {
  String get name => throw _privateConstructorUsedError;
  double get dailyCalories => throw _privateConstructorUsedError;
  double get proteinG => throw _privateConstructorUsedError;
  double get carbsG => throw _privateConstructorUsedError;
  double get fatsG => throw _privateConstructorUsedError;
  List<DietDayModel> get days => throw _privateConstructorUsedError;
  List<String> get tips => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DietPlanModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DietPlanModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DietPlanModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this DietPlanModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DietPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DietPlanModelCopyWith<DietPlanModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DietPlanModelCopyWith<$Res> {
  factory $DietPlanModelCopyWith(
    DietPlanModel value,
    $Res Function(DietPlanModel) then,
  ) = _$DietPlanModelCopyWithImpl<$Res, DietPlanModel>;
  @useResult
  $Res call({
    String name,
    double dailyCalories,
    double proteinG,
    double carbsG,
    double fatsG,
    List<DietDayModel> days,
    List<String> tips,
  });
}

/// @nodoc
class _$DietPlanModelCopyWithImpl<$Res, $Val extends DietPlanModel>
    implements $DietPlanModelCopyWith<$Res> {
  _$DietPlanModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DietPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dailyCalories = null,
    Object? proteinG = null,
    Object? carbsG = null,
    Object? fatsG = null,
    Object? days = null,
    Object? tips = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            dailyCalories: null == dailyCalories
                ? _value.dailyCalories
                : dailyCalories // ignore: cast_nullable_to_non_nullable
                      as double,
            proteinG: null == proteinG
                ? _value.proteinG
                : proteinG // ignore: cast_nullable_to_non_nullable
                      as double,
            carbsG: null == carbsG
                ? _value.carbsG
                : carbsG // ignore: cast_nullable_to_non_nullable
                      as double,
            fatsG: null == fatsG
                ? _value.fatsG
                : fatsG // ignore: cast_nullable_to_non_nullable
                      as double,
            days: null == days
                ? _value.days
                : days // ignore: cast_nullable_to_non_nullable
                      as List<DietDayModel>,
            tips: null == tips
                ? _value.tips
                : tips // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DietPlanModelImplCopyWith<$Res>
    implements $DietPlanModelCopyWith<$Res> {
  factory _$$DietPlanModelImplCopyWith(
    _$DietPlanModelImpl value,
    $Res Function(_$DietPlanModelImpl) then,
  ) = __$$DietPlanModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    double dailyCalories,
    double proteinG,
    double carbsG,
    double fatsG,
    List<DietDayModel> days,
    List<String> tips,
  });
}

/// @nodoc
class __$$DietPlanModelImplCopyWithImpl<$Res>
    extends _$DietPlanModelCopyWithImpl<$Res, _$DietPlanModelImpl>
    implements _$$DietPlanModelImplCopyWith<$Res> {
  __$$DietPlanModelImplCopyWithImpl(
    _$DietPlanModelImpl _value,
    $Res Function(_$DietPlanModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DietPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dailyCalories = null,
    Object? proteinG = null,
    Object? carbsG = null,
    Object? fatsG = null,
    Object? days = null,
    Object? tips = null,
  }) {
    return _then(
      _$DietPlanModelImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        dailyCalories: null == dailyCalories
            ? _value.dailyCalories
            : dailyCalories // ignore: cast_nullable_to_non_nullable
                  as double,
        proteinG: null == proteinG
            ? _value.proteinG
            : proteinG // ignore: cast_nullable_to_non_nullable
                  as double,
        carbsG: null == carbsG
            ? _value.carbsG
            : carbsG // ignore: cast_nullable_to_non_nullable
                  as double,
        fatsG: null == fatsG
            ? _value.fatsG
            : fatsG // ignore: cast_nullable_to_non_nullable
                  as double,
        days: null == days
            ? _value._days
            : days // ignore: cast_nullable_to_non_nullable
                  as List<DietDayModel>,
        tips: null == tips
            ? _value._tips
            : tips // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DietPlanModelImpl implements _DietPlanModel {
  const _$DietPlanModelImpl({
    required this.name,
    required this.dailyCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required final List<DietDayModel> days,
    required final List<String> tips,
  }) : _days = days,
       _tips = tips;

  factory _$DietPlanModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DietPlanModelImplFromJson(json);

  @override
  final String name;
  @override
  final double dailyCalories;
  @override
  final double proteinG;
  @override
  final double carbsG;
  @override
  final double fatsG;
  final List<DietDayModel> _days;
  @override
  List<DietDayModel> get days {
    if (_days is EqualUnmodifiableListView) return _days;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_days);
  }

  final List<String> _tips;
  @override
  List<String> get tips {
    if (_tips is EqualUnmodifiableListView) return _tips;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tips);
  }

  @override
  String toString() {
    return 'DietPlanModel(name: $name, dailyCalories: $dailyCalories, proteinG: $proteinG, carbsG: $carbsG, fatsG: $fatsG, days: $days, tips: $tips)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DietPlanModelImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dailyCalories, dailyCalories) ||
                other.dailyCalories == dailyCalories) &&
            (identical(other.proteinG, proteinG) ||
                other.proteinG == proteinG) &&
            (identical(other.carbsG, carbsG) || other.carbsG == carbsG) &&
            (identical(other.fatsG, fatsG) || other.fatsG == fatsG) &&
            const DeepCollectionEquality().equals(other._days, _days) &&
            const DeepCollectionEquality().equals(other._tips, _tips));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    dailyCalories,
    proteinG,
    carbsG,
    fatsG,
    const DeepCollectionEquality().hash(_days),
    const DeepCollectionEquality().hash(_tips),
  );

  /// Create a copy of DietPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DietPlanModelImplCopyWith<_$DietPlanModelImpl> get copyWith =>
      __$$DietPlanModelImplCopyWithImpl<_$DietPlanModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DietPlanModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DietPlanModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DietPlanModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DietPlanModelImplToJson(this);
  }
}

abstract class _DietPlanModel implements DietPlanModel {
  const factory _DietPlanModel({
    required final String name,
    required final double dailyCalories,
    required final double proteinG,
    required final double carbsG,
    required final double fatsG,
    required final List<DietDayModel> days,
    required final List<String> tips,
  }) = _$DietPlanModelImpl;

  factory _DietPlanModel.fromJson(Map<String, dynamic> json) =
      _$DietPlanModelImpl.fromJson;

  @override
  String get name;
  @override
  double get dailyCalories;
  @override
  double get proteinG;
  @override
  double get carbsG;
  @override
  double get fatsG;
  @override
  List<DietDayModel> get days;
  @override
  List<String> get tips;

  /// Create a copy of DietPlanModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DietPlanModelImplCopyWith<_$DietPlanModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DietDayModel _$DietDayModelFromJson(Map<String, dynamic> json) {
  return _DietDayModel.fromJson(json);
}

/// @nodoc
mixin _$DietDayModel {
  String get dayName => throw _privateConstructorUsedError;
  List<DietMealModel> get meals => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DietDayModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DietDayModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DietDayModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this DietDayModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DietDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DietDayModelCopyWith<DietDayModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DietDayModelCopyWith<$Res> {
  factory $DietDayModelCopyWith(
    DietDayModel value,
    $Res Function(DietDayModel) then,
  ) = _$DietDayModelCopyWithImpl<$Res, DietDayModel>;
  @useResult
  $Res call({String dayName, List<DietMealModel> meals});
}

/// @nodoc
class _$DietDayModelCopyWithImpl<$Res, $Val extends DietDayModel>
    implements $DietDayModelCopyWith<$Res> {
  _$DietDayModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DietDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? dayName = null, Object? meals = null}) {
    return _then(
      _value.copyWith(
            dayName: null == dayName
                ? _value.dayName
                : dayName // ignore: cast_nullable_to_non_nullable
                      as String,
            meals: null == meals
                ? _value.meals
                : meals // ignore: cast_nullable_to_non_nullable
                      as List<DietMealModel>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DietDayModelImplCopyWith<$Res>
    implements $DietDayModelCopyWith<$Res> {
  factory _$$DietDayModelImplCopyWith(
    _$DietDayModelImpl value,
    $Res Function(_$DietDayModelImpl) then,
  ) = __$$DietDayModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String dayName, List<DietMealModel> meals});
}

/// @nodoc
class __$$DietDayModelImplCopyWithImpl<$Res>
    extends _$DietDayModelCopyWithImpl<$Res, _$DietDayModelImpl>
    implements _$$DietDayModelImplCopyWith<$Res> {
  __$$DietDayModelImplCopyWithImpl(
    _$DietDayModelImpl _value,
    $Res Function(_$DietDayModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DietDayModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? dayName = null, Object? meals = null}) {
    return _then(
      _$DietDayModelImpl(
        dayName: null == dayName
            ? _value.dayName
            : dayName // ignore: cast_nullable_to_non_nullable
                  as String,
        meals: null == meals
            ? _value._meals
            : meals // ignore: cast_nullable_to_non_nullable
                  as List<DietMealModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DietDayModelImpl implements _DietDayModel {
  const _$DietDayModelImpl({
    required this.dayName,
    required final List<DietMealModel> meals,
  }) : _meals = meals;

  factory _$DietDayModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DietDayModelImplFromJson(json);

  @override
  final String dayName;
  final List<DietMealModel> _meals;
  @override
  List<DietMealModel> get meals {
    if (_meals is EqualUnmodifiableListView) return _meals;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_meals);
  }

  @override
  String toString() {
    return 'DietDayModel(dayName: $dayName, meals: $meals)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DietDayModelImpl &&
            (identical(other.dayName, dayName) || other.dayName == dayName) &&
            const DeepCollectionEquality().equals(other._meals, _meals));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dayName,
    const DeepCollectionEquality().hash(_meals),
  );

  /// Create a copy of DietDayModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DietDayModelImplCopyWith<_$DietDayModelImpl> get copyWith =>
      __$$DietDayModelImplCopyWithImpl<_$DietDayModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DietDayModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DietDayModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DietDayModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DietDayModelImplToJson(this);
  }
}

abstract class _DietDayModel implements DietDayModel {
  const factory _DietDayModel({
    required final String dayName,
    required final List<DietMealModel> meals,
  }) = _$DietDayModelImpl;

  factory _DietDayModel.fromJson(Map<String, dynamic> json) =
      _$DietDayModelImpl.fromJson;

  @override
  String get dayName;
  @override
  List<DietMealModel> get meals;

  /// Create a copy of DietDayModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DietDayModelImplCopyWith<_$DietDayModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DietMealModel _$DietMealModelFromJson(Map<String, dynamic> json) {
  return _DietMealModel.fromJson(json);
}

/// @nodoc
mixin _$DietMealModel {
  MealType get mealType => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get ingredients => throw _privateConstructorUsedError;
  double get calories => throw _privateConstructorUsedError;
  double get proteinG => throw _privateConstructorUsedError;
  double get carbsG => throw _privateConstructorUsedError;
  double get fatsG => throw _privateConstructorUsedError;
  String? get prepTime => throw _privateConstructorUsedError;
  List<String> get alternatives => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DietMealModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DietMealModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DietMealModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this DietMealModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DietMealModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DietMealModelCopyWith<DietMealModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DietMealModelCopyWith<$Res> {
  factory $DietMealModelCopyWith(
    DietMealModel value,
    $Res Function(DietMealModel) then,
  ) = _$DietMealModelCopyWithImpl<$Res, DietMealModel>;
  @useResult
  $Res call({
    MealType mealType,
    String name,
    List<String> ingredients,
    double calories,
    double proteinG,
    double carbsG,
    double fatsG,
    String? prepTime,
    List<String> alternatives,
  });
}

/// @nodoc
class _$DietMealModelCopyWithImpl<$Res, $Val extends DietMealModel>
    implements $DietMealModelCopyWith<$Res> {
  _$DietMealModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DietMealModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mealType = null,
    Object? name = null,
    Object? ingredients = null,
    Object? calories = null,
    Object? proteinG = null,
    Object? carbsG = null,
    Object? fatsG = null,
    Object? prepTime = freezed,
    Object? alternatives = null,
  }) {
    return _then(
      _value.copyWith(
            mealType: null == mealType
                ? _value.mealType
                : mealType // ignore: cast_nullable_to_non_nullable
                      as MealType,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            ingredients: null == ingredients
                ? _value.ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            calories: null == calories
                ? _value.calories
                : calories // ignore: cast_nullable_to_non_nullable
                      as double,
            proteinG: null == proteinG
                ? _value.proteinG
                : proteinG // ignore: cast_nullable_to_non_nullable
                      as double,
            carbsG: null == carbsG
                ? _value.carbsG
                : carbsG // ignore: cast_nullable_to_non_nullable
                      as double,
            fatsG: null == fatsG
                ? _value.fatsG
                : fatsG // ignore: cast_nullable_to_non_nullable
                      as double,
            prepTime: freezed == prepTime
                ? _value.prepTime
                : prepTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            alternatives: null == alternatives
                ? _value.alternatives
                : alternatives // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DietMealModelImplCopyWith<$Res>
    implements $DietMealModelCopyWith<$Res> {
  factory _$$DietMealModelImplCopyWith(
    _$DietMealModelImpl value,
    $Res Function(_$DietMealModelImpl) then,
  ) = __$$DietMealModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    MealType mealType,
    String name,
    List<String> ingredients,
    double calories,
    double proteinG,
    double carbsG,
    double fatsG,
    String? prepTime,
    List<String> alternatives,
  });
}

/// @nodoc
class __$$DietMealModelImplCopyWithImpl<$Res>
    extends _$DietMealModelCopyWithImpl<$Res, _$DietMealModelImpl>
    implements _$$DietMealModelImplCopyWith<$Res> {
  __$$DietMealModelImplCopyWithImpl(
    _$DietMealModelImpl _value,
    $Res Function(_$DietMealModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DietMealModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? mealType = null,
    Object? name = null,
    Object? ingredients = null,
    Object? calories = null,
    Object? proteinG = null,
    Object? carbsG = null,
    Object? fatsG = null,
    Object? prepTime = freezed,
    Object? alternatives = null,
  }) {
    return _then(
      _$DietMealModelImpl(
        mealType: null == mealType
            ? _value.mealType
            : mealType // ignore: cast_nullable_to_non_nullable
                  as MealType,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        ingredients: null == ingredients
            ? _value._ingredients
            : ingredients // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        calories: null == calories
            ? _value.calories
            : calories // ignore: cast_nullable_to_non_nullable
                  as double,
        proteinG: null == proteinG
            ? _value.proteinG
            : proteinG // ignore: cast_nullable_to_non_nullable
                  as double,
        carbsG: null == carbsG
            ? _value.carbsG
            : carbsG // ignore: cast_nullable_to_non_nullable
                  as double,
        fatsG: null == fatsG
            ? _value.fatsG
            : fatsG // ignore: cast_nullable_to_non_nullable
                  as double,
        prepTime: freezed == prepTime
            ? _value.prepTime
            : prepTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        alternatives: null == alternatives
            ? _value._alternatives
            : alternatives // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DietMealModelImpl implements _DietMealModel {
  const _$DietMealModelImpl({
    required this.mealType,
    required this.name,
    required final List<String> ingredients,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    this.prepTime,
    final List<String> alternatives = const [],
  }) : _ingredients = ingredients,
       _alternatives = alternatives;

  factory _$DietMealModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DietMealModelImplFromJson(json);

  @override
  final MealType mealType;
  @override
  final String name;
  final List<String> _ingredients;
  @override
  List<String> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  @override
  final double calories;
  @override
  final double proteinG;
  @override
  final double carbsG;
  @override
  final double fatsG;
  @override
  final String? prepTime;
  final List<String> _alternatives;
  @override
  @JsonKey()
  List<String> get alternatives {
    if (_alternatives is EqualUnmodifiableListView) return _alternatives;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternatives);
  }

  @override
  String toString() {
    return 'DietMealModel(mealType: $mealType, name: $name, ingredients: $ingredients, calories: $calories, proteinG: $proteinG, carbsG: $carbsG, fatsG: $fatsG, prepTime: $prepTime, alternatives: $alternatives)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DietMealModelImpl &&
            (identical(other.mealType, mealType) ||
                other.mealType == mealType) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._ingredients,
              _ingredients,
            ) &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.proteinG, proteinG) ||
                other.proteinG == proteinG) &&
            (identical(other.carbsG, carbsG) || other.carbsG == carbsG) &&
            (identical(other.fatsG, fatsG) || other.fatsG == fatsG) &&
            (identical(other.prepTime, prepTime) ||
                other.prepTime == prepTime) &&
            const DeepCollectionEquality().equals(
              other._alternatives,
              _alternatives,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    mealType,
    name,
    const DeepCollectionEquality().hash(_ingredients),
    calories,
    proteinG,
    carbsG,
    fatsG,
    prepTime,
    const DeepCollectionEquality().hash(_alternatives),
  );

  /// Create a copy of DietMealModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DietMealModelImplCopyWith<_$DietMealModelImpl> get copyWith =>
      __$$DietMealModelImplCopyWithImpl<_$DietMealModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_DietMealModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_DietMealModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_DietMealModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$DietMealModelImplToJson(this);
  }
}

abstract class _DietMealModel implements DietMealModel {
  const factory _DietMealModel({
    required final MealType mealType,
    required final String name,
    required final List<String> ingredients,
    required final double calories,
    required final double proteinG,
    required final double carbsG,
    required final double fatsG,
    final String? prepTime,
    final List<String> alternatives,
  }) = _$DietMealModelImpl;

  factory _DietMealModel.fromJson(Map<String, dynamic> json) =
      _$DietMealModelImpl.fromJson;

  @override
  MealType get mealType;
  @override
  String get name;
  @override
  List<String> get ingredients;
  @override
  double get calories;
  @override
  double get proteinG;
  @override
  double get carbsG;
  @override
  double get fatsG;
  @override
  String? get prepTime;
  @override
  List<String> get alternatives;

  /// Create a copy of DietMealModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DietMealModelImplCopyWith<_$DietMealModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

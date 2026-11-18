// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MealMacros {
  double get calories => throw _privateConstructorUsedError;
  double get protein => throw _privateConstructorUsedError;
  double get carbs => throw _privateConstructorUsedError;
  double get fats => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMacros value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMacros value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMacros value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of MealMacros
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealMacrosCopyWith<MealMacros> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealMacrosCopyWith<$Res> {
  factory $MealMacrosCopyWith(
    MealMacros value,
    $Res Function(MealMacros) then,
  ) = _$MealMacrosCopyWithImpl<$Res, MealMacros>;
  @useResult
  $Res call({double calories, double protein, double carbs, double fats});
}

/// @nodoc
class _$MealMacrosCopyWithImpl<$Res, $Val extends MealMacros>
    implements $MealMacrosCopyWith<$Res> {
  _$MealMacrosCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealMacros
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calories = null,
    Object? protein = null,
    Object? carbs = null,
    Object? fats = null,
  }) {
    return _then(
      _value.copyWith(
            calories: null == calories
                ? _value.calories
                : calories // ignore: cast_nullable_to_non_nullable
                      as double,
            protein: null == protein
                ? _value.protein
                : protein // ignore: cast_nullable_to_non_nullable
                      as double,
            carbs: null == carbs
                ? _value.carbs
                : carbs // ignore: cast_nullable_to_non_nullable
                      as double,
            fats: null == fats
                ? _value.fats
                : fats // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealMacrosImplCopyWith<$Res>
    implements $MealMacrosCopyWith<$Res> {
  factory _$$MealMacrosImplCopyWith(
    _$MealMacrosImpl value,
    $Res Function(_$MealMacrosImpl) then,
  ) = __$$MealMacrosImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double calories, double protein, double carbs, double fats});
}

/// @nodoc
class __$$MealMacrosImplCopyWithImpl<$Res>
    extends _$MealMacrosCopyWithImpl<$Res, _$MealMacrosImpl>
    implements _$$MealMacrosImplCopyWith<$Res> {
  __$$MealMacrosImplCopyWithImpl(
    _$MealMacrosImpl _value,
    $Res Function(_$MealMacrosImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealMacros
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calories = null,
    Object? protein = null,
    Object? carbs = null,
    Object? fats = null,
  }) {
    return _then(
      _$MealMacrosImpl(
        calories: null == calories
            ? _value.calories
            : calories // ignore: cast_nullable_to_non_nullable
                  as double,
        protein: null == protein
            ? _value.protein
            : protein // ignore: cast_nullable_to_non_nullable
                  as double,
        carbs: null == carbs
            ? _value.carbs
            : carbs // ignore: cast_nullable_to_non_nullable
                  as double,
        fats: null == fats
            ? _value.fats
            : fats // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$MealMacrosImpl implements _MealMacros {
  const _$MealMacrosImpl({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  @override
  final double calories;
  @override
  final double protein;
  @override
  final double carbs;
  @override
  final double fats;

  @override
  String toString() {
    return 'MealMacros(calories: $calories, protein: $protein, carbs: $carbs, fats: $fats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealMacrosImpl &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.protein, protein) || other.protein == protein) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fats, fats) || other.fats == fats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, calories, protein, carbs, fats);

  /// Create a copy of MealMacros
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealMacrosImplCopyWith<_$MealMacrosImpl> get copyWith =>
      __$$MealMacrosImplCopyWithImpl<_$MealMacrosImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMacros value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMacros value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMacros value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MealMacros implements MealMacros {
  const factory _MealMacros({
    required final double calories,
    required final double protein,
    required final double carbs,
    required final double fats,
  }) = _$MealMacrosImpl;

  @override
  double get calories;
  @override
  double get protein;
  @override
  double get carbs;
  @override
  double get fats;

  /// Create a copy of MealMacros
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealMacrosImplCopyWith<_$MealMacrosImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MealMicros {
  double get fiber => throw _privateConstructorUsedError;
  double get sugar => throw _privateConstructorUsedError;
  double get sodium => throw _privateConstructorUsedError;
  double get potassium => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMicros value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMicros value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMicros value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of MealMicros
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealMicrosCopyWith<MealMicros> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealMicrosCopyWith<$Res> {
  factory $MealMicrosCopyWith(
    MealMicros value,
    $Res Function(MealMicros) then,
  ) = _$MealMicrosCopyWithImpl<$Res, MealMicros>;
  @useResult
  $Res call({double fiber, double sugar, double sodium, double potassium});
}

/// @nodoc
class _$MealMicrosCopyWithImpl<$Res, $Val extends MealMicros>
    implements $MealMicrosCopyWith<$Res> {
  _$MealMicrosCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealMicros
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fiber = null,
    Object? sugar = null,
    Object? sodium = null,
    Object? potassium = null,
  }) {
    return _then(
      _value.copyWith(
            fiber: null == fiber
                ? _value.fiber
                : fiber // ignore: cast_nullable_to_non_nullable
                      as double,
            sugar: null == sugar
                ? _value.sugar
                : sugar // ignore: cast_nullable_to_non_nullable
                      as double,
            sodium: null == sodium
                ? _value.sodium
                : sodium // ignore: cast_nullable_to_non_nullable
                      as double,
            potassium: null == potassium
                ? _value.potassium
                : potassium // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealMicrosImplCopyWith<$Res>
    implements $MealMicrosCopyWith<$Res> {
  factory _$$MealMicrosImplCopyWith(
    _$MealMicrosImpl value,
    $Res Function(_$MealMicrosImpl) then,
  ) = __$$MealMicrosImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double fiber, double sugar, double sodium, double potassium});
}

/// @nodoc
class __$$MealMicrosImplCopyWithImpl<$Res>
    extends _$MealMicrosCopyWithImpl<$Res, _$MealMicrosImpl>
    implements _$$MealMicrosImplCopyWith<$Res> {
  __$$MealMicrosImplCopyWithImpl(
    _$MealMicrosImpl _value,
    $Res Function(_$MealMicrosImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealMicros
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fiber = null,
    Object? sugar = null,
    Object? sodium = null,
    Object? potassium = null,
  }) {
    return _then(
      _$MealMicrosImpl(
        fiber: null == fiber
            ? _value.fiber
            : fiber // ignore: cast_nullable_to_non_nullable
                  as double,
        sugar: null == sugar
            ? _value.sugar
            : sugar // ignore: cast_nullable_to_non_nullable
                  as double,
        sodium: null == sodium
            ? _value.sodium
            : sodium // ignore: cast_nullable_to_non_nullable
                  as double,
        potassium: null == potassium
            ? _value.potassium
            : potassium // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$MealMicrosImpl implements _MealMicros {
  const _$MealMicrosImpl({
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.potassium,
  });

  @override
  final double fiber;
  @override
  final double sugar;
  @override
  final double sodium;
  @override
  final double potassium;

  @override
  String toString() {
    return 'MealMicros(fiber: $fiber, sugar: $sugar, sodium: $sodium, potassium: $potassium)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealMicrosImpl &&
            (identical(other.fiber, fiber) || other.fiber == fiber) &&
            (identical(other.sugar, sugar) || other.sugar == sugar) &&
            (identical(other.sodium, sodium) || other.sodium == sodium) &&
            (identical(other.potassium, potassium) ||
                other.potassium == potassium));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fiber, sugar, sodium, potassium);

  /// Create a copy of MealMicros
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealMicrosImplCopyWith<_$MealMicrosImpl> get copyWith =>
      __$$MealMicrosImplCopyWithImpl<_$MealMicrosImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMicros value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMicros value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMicros value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MealMicros implements MealMicros {
  const factory _MealMicros({
    required final double fiber,
    required final double sugar,
    required final double sodium,
    required final double potassium,
  }) = _$MealMicrosImpl;

  @override
  double get fiber;
  @override
  double get sugar;
  @override
  double get sodium;
  @override
  double get potassium;

  /// Create a copy of MealMicros
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealMicrosImplCopyWith<_$MealMicrosImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MealVitamins {
  double get vitaminA => throw _privateConstructorUsedError;
  double get vitaminB => throw _privateConstructorUsedError;
  double get vitaminC => throw _privateConstructorUsedError;
  double get vitaminD => throw _privateConstructorUsedError;
  double get vitaminE => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealVitamins value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealVitamins value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealVitamins value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of MealVitamins
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealVitaminsCopyWith<MealVitamins> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealVitaminsCopyWith<$Res> {
  factory $MealVitaminsCopyWith(
    MealVitamins value,
    $Res Function(MealVitamins) then,
  ) = _$MealVitaminsCopyWithImpl<$Res, MealVitamins>;
  @useResult
  $Res call({
    double vitaminA,
    double vitaminB,
    double vitaminC,
    double vitaminD,
    double vitaminE,
  });
}

/// @nodoc
class _$MealVitaminsCopyWithImpl<$Res, $Val extends MealVitamins>
    implements $MealVitaminsCopyWith<$Res> {
  _$MealVitaminsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealVitamins
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vitaminA = null,
    Object? vitaminB = null,
    Object? vitaminC = null,
    Object? vitaminD = null,
    Object? vitaminE = null,
  }) {
    return _then(
      _value.copyWith(
            vitaminA: null == vitaminA
                ? _value.vitaminA
                : vitaminA // ignore: cast_nullable_to_non_nullable
                      as double,
            vitaminB: null == vitaminB
                ? _value.vitaminB
                : vitaminB // ignore: cast_nullable_to_non_nullable
                      as double,
            vitaminC: null == vitaminC
                ? _value.vitaminC
                : vitaminC // ignore: cast_nullable_to_non_nullable
                      as double,
            vitaminD: null == vitaminD
                ? _value.vitaminD
                : vitaminD // ignore: cast_nullable_to_non_nullable
                      as double,
            vitaminE: null == vitaminE
                ? _value.vitaminE
                : vitaminE // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealVitaminsImplCopyWith<$Res>
    implements $MealVitaminsCopyWith<$Res> {
  factory _$$MealVitaminsImplCopyWith(
    _$MealVitaminsImpl value,
    $Res Function(_$MealVitaminsImpl) then,
  ) = __$$MealVitaminsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double vitaminA,
    double vitaminB,
    double vitaminC,
    double vitaminD,
    double vitaminE,
  });
}

/// @nodoc
class __$$MealVitaminsImplCopyWithImpl<$Res>
    extends _$MealVitaminsCopyWithImpl<$Res, _$MealVitaminsImpl>
    implements _$$MealVitaminsImplCopyWith<$Res> {
  __$$MealVitaminsImplCopyWithImpl(
    _$MealVitaminsImpl _value,
    $Res Function(_$MealVitaminsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealVitamins
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? vitaminA = null,
    Object? vitaminB = null,
    Object? vitaminC = null,
    Object? vitaminD = null,
    Object? vitaminE = null,
  }) {
    return _then(
      _$MealVitaminsImpl(
        vitaminA: null == vitaminA
            ? _value.vitaminA
            : vitaminA // ignore: cast_nullable_to_non_nullable
                  as double,
        vitaminB: null == vitaminB
            ? _value.vitaminB
            : vitaminB // ignore: cast_nullable_to_non_nullable
                  as double,
        vitaminC: null == vitaminC
            ? _value.vitaminC
            : vitaminC // ignore: cast_nullable_to_non_nullable
                  as double,
        vitaminD: null == vitaminD
            ? _value.vitaminD
            : vitaminD // ignore: cast_nullable_to_non_nullable
                  as double,
        vitaminE: null == vitaminE
            ? _value.vitaminE
            : vitaminE // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$MealVitaminsImpl implements _MealVitamins {
  const _$MealVitaminsImpl({
    required this.vitaminA,
    required this.vitaminB,
    required this.vitaminC,
    required this.vitaminD,
    required this.vitaminE,
  });

  @override
  final double vitaminA;
  @override
  final double vitaminB;
  @override
  final double vitaminC;
  @override
  final double vitaminD;
  @override
  final double vitaminE;

  @override
  String toString() {
    return 'MealVitamins(vitaminA: $vitaminA, vitaminB: $vitaminB, vitaminC: $vitaminC, vitaminD: $vitaminD, vitaminE: $vitaminE)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealVitaminsImpl &&
            (identical(other.vitaminA, vitaminA) ||
                other.vitaminA == vitaminA) &&
            (identical(other.vitaminB, vitaminB) ||
                other.vitaminB == vitaminB) &&
            (identical(other.vitaminC, vitaminC) ||
                other.vitaminC == vitaminC) &&
            (identical(other.vitaminD, vitaminD) ||
                other.vitaminD == vitaminD) &&
            (identical(other.vitaminE, vitaminE) ||
                other.vitaminE == vitaminE));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    vitaminA,
    vitaminB,
    vitaminC,
    vitaminD,
    vitaminE,
  );

  /// Create a copy of MealVitamins
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealVitaminsImplCopyWith<_$MealVitaminsImpl> get copyWith =>
      __$$MealVitaminsImplCopyWithImpl<_$MealVitaminsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealVitamins value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealVitamins value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealVitamins value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MealVitamins implements MealVitamins {
  const factory _MealVitamins({
    required final double vitaminA,
    required final double vitaminB,
    required final double vitaminC,
    required final double vitaminD,
    required final double vitaminE,
  }) = _$MealVitaminsImpl;

  @override
  double get vitaminA;
  @override
  double get vitaminB;
  @override
  double get vitaminC;
  @override
  double get vitaminD;
  @override
  double get vitaminE;

  /// Create a copy of MealVitamins
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealVitaminsImplCopyWith<_$MealVitaminsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MealMinerals {
  double get calcium => throw _privateConstructorUsedError;
  double get iron => throw _privateConstructorUsedError;
  double get magnesium => throw _privateConstructorUsedError;
  double get zinc => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMinerals value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMinerals value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMinerals value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of MealMinerals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealMineralsCopyWith<MealMinerals> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealMineralsCopyWith<$Res> {
  factory $MealMineralsCopyWith(
    MealMinerals value,
    $Res Function(MealMinerals) then,
  ) = _$MealMineralsCopyWithImpl<$Res, MealMinerals>;
  @useResult
  $Res call({double calcium, double iron, double magnesium, double zinc});
}

/// @nodoc
class _$MealMineralsCopyWithImpl<$Res, $Val extends MealMinerals>
    implements $MealMineralsCopyWith<$Res> {
  _$MealMineralsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealMinerals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calcium = null,
    Object? iron = null,
    Object? magnesium = null,
    Object? zinc = null,
  }) {
    return _then(
      _value.copyWith(
            calcium: null == calcium
                ? _value.calcium
                : calcium // ignore: cast_nullable_to_non_nullable
                      as double,
            iron: null == iron
                ? _value.iron
                : iron // ignore: cast_nullable_to_non_nullable
                      as double,
            magnesium: null == magnesium
                ? _value.magnesium
                : magnesium // ignore: cast_nullable_to_non_nullable
                      as double,
            zinc: null == zinc
                ? _value.zinc
                : zinc // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealMineralsImplCopyWith<$Res>
    implements $MealMineralsCopyWith<$Res> {
  factory _$$MealMineralsImplCopyWith(
    _$MealMineralsImpl value,
    $Res Function(_$MealMineralsImpl) then,
  ) = __$$MealMineralsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double calcium, double iron, double magnesium, double zinc});
}

/// @nodoc
class __$$MealMineralsImplCopyWithImpl<$Res>
    extends _$MealMineralsCopyWithImpl<$Res, _$MealMineralsImpl>
    implements _$$MealMineralsImplCopyWith<$Res> {
  __$$MealMineralsImplCopyWithImpl(
    _$MealMineralsImpl _value,
    $Res Function(_$MealMineralsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealMinerals
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calcium = null,
    Object? iron = null,
    Object? magnesium = null,
    Object? zinc = null,
  }) {
    return _then(
      _$MealMineralsImpl(
        calcium: null == calcium
            ? _value.calcium
            : calcium // ignore: cast_nullable_to_non_nullable
                  as double,
        iron: null == iron
            ? _value.iron
            : iron // ignore: cast_nullable_to_non_nullable
                  as double,
        magnesium: null == magnesium
            ? _value.magnesium
            : magnesium // ignore: cast_nullable_to_non_nullable
                  as double,
        zinc: null == zinc
            ? _value.zinc
            : zinc // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$MealMineralsImpl implements _MealMinerals {
  const _$MealMineralsImpl({
    required this.calcium,
    required this.iron,
    required this.magnesium,
    required this.zinc,
  });

  @override
  final double calcium;
  @override
  final double iron;
  @override
  final double magnesium;
  @override
  final double zinc;

  @override
  String toString() {
    return 'MealMinerals(calcium: $calcium, iron: $iron, magnesium: $magnesium, zinc: $zinc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealMineralsImpl &&
            (identical(other.calcium, calcium) || other.calcium == calcium) &&
            (identical(other.iron, iron) || other.iron == iron) &&
            (identical(other.magnesium, magnesium) ||
                other.magnesium == magnesium) &&
            (identical(other.zinc, zinc) || other.zinc == zinc));
  }

  @override
  int get hashCode => Object.hash(runtimeType, calcium, iron, magnesium, zinc);

  /// Create a copy of MealMinerals
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealMineralsImplCopyWith<_$MealMineralsImpl> get copyWith =>
      __$$MealMineralsImplCopyWithImpl<_$MealMineralsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMinerals value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMinerals value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMinerals value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MealMinerals implements MealMinerals {
  const factory _MealMinerals({
    required final double calcium,
    required final double iron,
    required final double magnesium,
    required final double zinc,
  }) = _$MealMineralsImpl;

  @override
  double get calcium;
  @override
  double get iron;
  @override
  double get magnesium;
  @override
  double get zinc;

  /// Create a copy of MealMinerals
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealMineralsImplCopyWith<_$MealMineralsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Meal {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  MealMacros get macros => throw _privateConstructorUsedError;
  MealMicros get micros => throw _privateConstructorUsedError;
  MealVitamins get vitamins => throw _privateConstructorUsedError;
  MealMinerals get minerals => throw _privateConstructorUsedError;
  DateTime get timestamp =>
      throw _privateConstructorUsedError; // Schema v2 links (Phase 1). All optional; populated by the nutrition
  // repository / logging flows / DataMigration backfill.
  /// Owning user (auth uid). Null for legacy rows.
  String? get userId => throw _privateConstructorUsedError;

  /// Catalog link → FoodItemFull.id when logged from a catalog food.
  /// Nutrient values remain a snapshot on the meal by design.
  String? get foodItemId => throw _privateConstructorUsedError;

  /// Last modification time — the LWW conflict key for sync.
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Tombstone (Phase 2): set when deleted on another device; pulls
  /// apply it as a local delete. See Workout.deletedAt.
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Meal value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Meal value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Meal value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealCopyWith<Meal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealCopyWith<$Res> {
  factory $MealCopyWith(Meal value, $Res Function(Meal) then) =
      _$MealCopyWithImpl<$Res, Meal>;
  @useResult
  $Res call({
    String id,
    String name,
    MealMacros macros,
    MealMicros micros,
    MealVitamins vitamins,
    MealMinerals minerals,
    DateTime timestamp,
    String? userId,
    String? foodItemId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });

  $MealMacrosCopyWith<$Res> get macros;
  $MealMicrosCopyWith<$Res> get micros;
  $MealVitaminsCopyWith<$Res> get vitamins;
  $MealMineralsCopyWith<$Res> get minerals;
}

/// @nodoc
class _$MealCopyWithImpl<$Res, $Val extends Meal>
    implements $MealCopyWith<$Res> {
  _$MealCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? macros = null,
    Object? micros = null,
    Object? vitamins = null,
    Object? minerals = null,
    Object? timestamp = null,
    Object? userId = freezed,
    Object? foodItemId = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            macros: null == macros
                ? _value.macros
                : macros // ignore: cast_nullable_to_non_nullable
                      as MealMacros,
            micros: null == micros
                ? _value.micros
                : micros // ignore: cast_nullable_to_non_nullable
                      as MealMicros,
            vitamins: null == vitamins
                ? _value.vitamins
                : vitamins // ignore: cast_nullable_to_non_nullable
                      as MealVitamins,
            minerals: null == minerals
                ? _value.minerals
                : minerals // ignore: cast_nullable_to_non_nullable
                      as MealMinerals,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            userId: freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String?,
            foodItemId: freezed == foodItemId
                ? _value.foodItemId
                : foodItemId // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealMacrosCopyWith<$Res> get macros {
    return $MealMacrosCopyWith<$Res>(_value.macros, (value) {
      return _then(_value.copyWith(macros: value) as $Val);
    });
  }

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealMicrosCopyWith<$Res> get micros {
    return $MealMicrosCopyWith<$Res>(_value.micros, (value) {
      return _then(_value.copyWith(micros: value) as $Val);
    });
  }

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealVitaminsCopyWith<$Res> get vitamins {
    return $MealVitaminsCopyWith<$Res>(_value.vitamins, (value) {
      return _then(_value.copyWith(vitamins: value) as $Val);
    });
  }

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealMineralsCopyWith<$Res> get minerals {
    return $MealMineralsCopyWith<$Res>(_value.minerals, (value) {
      return _then(_value.copyWith(minerals: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MealImplCopyWith<$Res> implements $MealCopyWith<$Res> {
  factory _$$MealImplCopyWith(
    _$MealImpl value,
    $Res Function(_$MealImpl) then,
  ) = __$$MealImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    MealMacros macros,
    MealMicros micros,
    MealVitamins vitamins,
    MealMinerals minerals,
    DateTime timestamp,
    String? userId,
    String? foodItemId,
    DateTime? updatedAt,
    DateTime? deletedAt,
  });

  @override
  $MealMacrosCopyWith<$Res> get macros;
  @override
  $MealMicrosCopyWith<$Res> get micros;
  @override
  $MealVitaminsCopyWith<$Res> get vitamins;
  @override
  $MealMineralsCopyWith<$Res> get minerals;
}

/// @nodoc
class __$$MealImplCopyWithImpl<$Res>
    extends _$MealCopyWithImpl<$Res, _$MealImpl>
    implements _$$MealImplCopyWith<$Res> {
  __$$MealImplCopyWithImpl(_$MealImpl _value, $Res Function(_$MealImpl) _then)
    : super(_value, _then);

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? macros = null,
    Object? micros = null,
    Object? vitamins = null,
    Object? minerals = null,
    Object? timestamp = null,
    Object? userId = freezed,
    Object? foodItemId = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(
      _$MealImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        macros: null == macros
            ? _value.macros
            : macros // ignore: cast_nullable_to_non_nullable
                  as MealMacros,
        micros: null == micros
            ? _value.micros
            : micros // ignore: cast_nullable_to_non_nullable
                  as MealMicros,
        vitamins: null == vitamins
            ? _value.vitamins
            : vitamins // ignore: cast_nullable_to_non_nullable
                  as MealVitamins,
        minerals: null == minerals
            ? _value.minerals
            : minerals // ignore: cast_nullable_to_non_nullable
                  as MealMinerals,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        userId: freezed == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String?,
        foodItemId: freezed == foodItemId
            ? _value.foodItemId
            : foodItemId // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc

class _$MealImpl extends _Meal {
  const _$MealImpl({
    required this.id,
    required this.name,
    required this.macros,
    required this.micros,
    required this.vitamins,
    required this.minerals,
    required this.timestamp,
    this.userId,
    this.foodItemId,
    this.updatedAt,
    this.deletedAt,
  }) : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final MealMacros macros;
  @override
  final MealMicros micros;
  @override
  final MealVitamins vitamins;
  @override
  final MealMinerals minerals;
  @override
  final DateTime timestamp;
  // Schema v2 links (Phase 1). All optional; populated by the nutrition
  // repository / logging flows / DataMigration backfill.
  /// Owning user (auth uid). Null for legacy rows.
  @override
  final String? userId;

  /// Catalog link → FoodItemFull.id when logged from a catalog food.
  /// Nutrient values remain a snapshot on the meal by design.
  @override
  final String? foodItemId;

  /// Last modification time — the LWW conflict key for sync.
  @override
  final DateTime? updatedAt;

  /// Tombstone (Phase 2): set when deleted on another device; pulls
  /// apply it as a local delete. See Workout.deletedAt.
  @override
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'Meal(id: $id, name: $name, macros: $macros, micros: $micros, vitamins: $vitamins, minerals: $minerals, timestamp: $timestamp, userId: $userId, foodItemId: $foodItemId, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.macros, macros) || other.macros == macros) &&
            (identical(other.micros, micros) || other.micros == micros) &&
            (identical(other.vitamins, vitamins) ||
                other.vitamins == vitamins) &&
            (identical(other.minerals, minerals) ||
                other.minerals == minerals) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.foodItemId, foodItemId) ||
                other.foodItemId == foodItemId) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    macros,
    micros,
    vitamins,
    minerals,
    timestamp,
    userId,
    foodItemId,
    updatedAt,
    deletedAt,
  );

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealImplCopyWith<_$MealImpl> get copyWith =>
      __$$MealImplCopyWithImpl<_$MealImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(TResult Function(_Meal value) $default) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Meal value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Meal value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _Meal extends Meal {
  const factory _Meal({
    required final String id,
    required final String name,
    required final MealMacros macros,
    required final MealMicros micros,
    required final MealVitamins vitamins,
    required final MealMinerals minerals,
    required final DateTime timestamp,
    final String? userId,
    final String? foodItemId,
    final DateTime? updatedAt,
    final DateTime? deletedAt,
  }) = _$MealImpl;
  const _Meal._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  MealMacros get macros;
  @override
  MealMicros get micros;
  @override
  MealVitamins get vitamins;
  @override
  MealMinerals get minerals;
  @override
  DateTime get timestamp; // Schema v2 links (Phase 1). All optional; populated by the nutrition
  // repository / logging flows / DataMigration backfill.
  /// Owning user (auth uid). Null for legacy rows.
  @override
  String? get userId;

  /// Catalog link → FoodItemFull.id when logged from a catalog food.
  /// Nutrient values remain a snapshot on the meal by design.
  @override
  String? get foodItemId;

  /// Last modification time — the LWW conflict key for sync.
  @override
  DateTime? get updatedAt;

  /// Tombstone (Phase 2): set when deleted on another device; pulls
  /// apply it as a local delete. See Workout.deletedAt.
  @override
  DateTime? get deletedAt;

  /// Create a copy of Meal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealImplCopyWith<_$MealImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

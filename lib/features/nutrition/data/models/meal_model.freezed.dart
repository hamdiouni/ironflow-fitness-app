// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MealMacrosModel _$MealMacrosModelFromJson(Map<String, dynamic> json) {
  return _MealMacrosModel.fromJson(json);
}

/// @nodoc
mixin _$MealMacrosModel {
  double get calories => throw _privateConstructorUsedError;
  double get protein => throw _privateConstructorUsedError;
  double get carbs => throw _privateConstructorUsedError;
  double get fats => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMacrosModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMacrosModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMacrosModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this MealMacrosModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealMacrosModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealMacrosModelCopyWith<MealMacrosModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealMacrosModelCopyWith<$Res> {
  factory $MealMacrosModelCopyWith(
    MealMacrosModel value,
    $Res Function(MealMacrosModel) then,
  ) = _$MealMacrosModelCopyWithImpl<$Res, MealMacrosModel>;
  @useResult
  $Res call({double calories, double protein, double carbs, double fats});
}

/// @nodoc
class _$MealMacrosModelCopyWithImpl<$Res, $Val extends MealMacrosModel>
    implements $MealMacrosModelCopyWith<$Res> {
  _$MealMacrosModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealMacrosModel
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
abstract class _$$MealMacrosModelImplCopyWith<$Res>
    implements $MealMacrosModelCopyWith<$Res> {
  factory _$$MealMacrosModelImplCopyWith(
    _$MealMacrosModelImpl value,
    $Res Function(_$MealMacrosModelImpl) then,
  ) = __$$MealMacrosModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double calories, double protein, double carbs, double fats});
}

/// @nodoc
class __$$MealMacrosModelImplCopyWithImpl<$Res>
    extends _$MealMacrosModelCopyWithImpl<$Res, _$MealMacrosModelImpl>
    implements _$$MealMacrosModelImplCopyWith<$Res> {
  __$$MealMacrosModelImplCopyWithImpl(
    _$MealMacrosModelImpl _value,
    $Res Function(_$MealMacrosModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealMacrosModel
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
      _$MealMacrosModelImpl(
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
@JsonSerializable()
class _$MealMacrosModelImpl implements _MealMacrosModel {
  const _$MealMacrosModelImpl({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory _$MealMacrosModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealMacrosModelImplFromJson(json);

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
    return 'MealMacrosModel(calories: $calories, protein: $protein, carbs: $carbs, fats: $fats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealMacrosModelImpl &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.protein, protein) || other.protein == protein) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fats, fats) || other.fats == fats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, calories, protein, carbs, fats);

  /// Create a copy of MealMacrosModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealMacrosModelImplCopyWith<_$MealMacrosModelImpl> get copyWith =>
      __$$MealMacrosModelImplCopyWithImpl<_$MealMacrosModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMacrosModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMacrosModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMacrosModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MealMacrosModelImplToJson(this);
  }
}

abstract class _MealMacrosModel implements MealMacrosModel {
  const factory _MealMacrosModel({
    required final double calories,
    required final double protein,
    required final double carbs,
    required final double fats,
  }) = _$MealMacrosModelImpl;

  factory _MealMacrosModel.fromJson(Map<String, dynamic> json) =
      _$MealMacrosModelImpl.fromJson;

  @override
  double get calories;
  @override
  double get protein;
  @override
  double get carbs;
  @override
  double get fats;

  /// Create a copy of MealMacrosModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealMacrosModelImplCopyWith<_$MealMacrosModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MealMicrosModel _$MealMicrosModelFromJson(Map<String, dynamic> json) {
  return _MealMicrosModel.fromJson(json);
}

/// @nodoc
mixin _$MealMicrosModel {
  double get fiber => throw _privateConstructorUsedError;
  double get sugar => throw _privateConstructorUsedError;
  double get sodium => throw _privateConstructorUsedError;
  double get potassium => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMicrosModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMicrosModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMicrosModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this MealMicrosModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealMicrosModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealMicrosModelCopyWith<MealMicrosModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealMicrosModelCopyWith<$Res> {
  factory $MealMicrosModelCopyWith(
    MealMicrosModel value,
    $Res Function(MealMicrosModel) then,
  ) = _$MealMicrosModelCopyWithImpl<$Res, MealMicrosModel>;
  @useResult
  $Res call({double fiber, double sugar, double sodium, double potassium});
}

/// @nodoc
class _$MealMicrosModelCopyWithImpl<$Res, $Val extends MealMicrosModel>
    implements $MealMicrosModelCopyWith<$Res> {
  _$MealMicrosModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealMicrosModel
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
abstract class _$$MealMicrosModelImplCopyWith<$Res>
    implements $MealMicrosModelCopyWith<$Res> {
  factory _$$MealMicrosModelImplCopyWith(
    _$MealMicrosModelImpl value,
    $Res Function(_$MealMicrosModelImpl) then,
  ) = __$$MealMicrosModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double fiber, double sugar, double sodium, double potassium});
}

/// @nodoc
class __$$MealMicrosModelImplCopyWithImpl<$Res>
    extends _$MealMicrosModelCopyWithImpl<$Res, _$MealMicrosModelImpl>
    implements _$$MealMicrosModelImplCopyWith<$Res> {
  __$$MealMicrosModelImplCopyWithImpl(
    _$MealMicrosModelImpl _value,
    $Res Function(_$MealMicrosModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealMicrosModel
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
      _$MealMicrosModelImpl(
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
@JsonSerializable()
class _$MealMicrosModelImpl implements _MealMicrosModel {
  const _$MealMicrosModelImpl({
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.potassium,
  });

  factory _$MealMicrosModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealMicrosModelImplFromJson(json);

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
    return 'MealMicrosModel(fiber: $fiber, sugar: $sugar, sodium: $sodium, potassium: $potassium)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealMicrosModelImpl &&
            (identical(other.fiber, fiber) || other.fiber == fiber) &&
            (identical(other.sugar, sugar) || other.sugar == sugar) &&
            (identical(other.sodium, sodium) || other.sodium == sodium) &&
            (identical(other.potassium, potassium) ||
                other.potassium == potassium));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, fiber, sugar, sodium, potassium);

  /// Create a copy of MealMicrosModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealMicrosModelImplCopyWith<_$MealMicrosModelImpl> get copyWith =>
      __$$MealMicrosModelImplCopyWithImpl<_$MealMicrosModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMicrosModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMicrosModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMicrosModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MealMicrosModelImplToJson(this);
  }
}

abstract class _MealMicrosModel implements MealMicrosModel {
  const factory _MealMicrosModel({
    required final double fiber,
    required final double sugar,
    required final double sodium,
    required final double potassium,
  }) = _$MealMicrosModelImpl;

  factory _MealMicrosModel.fromJson(Map<String, dynamic> json) =
      _$MealMicrosModelImpl.fromJson;

  @override
  double get fiber;
  @override
  double get sugar;
  @override
  double get sodium;
  @override
  double get potassium;

  /// Create a copy of MealMicrosModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealMicrosModelImplCopyWith<_$MealMicrosModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MealVitaminsModel _$MealVitaminsModelFromJson(Map<String, dynamic> json) {
  return _MealVitaminsModel.fromJson(json);
}

/// @nodoc
mixin _$MealVitaminsModel {
  double get vitaminA => throw _privateConstructorUsedError;
  double get vitaminB => throw _privateConstructorUsedError;
  double get vitaminC => throw _privateConstructorUsedError;
  double get vitaminD => throw _privateConstructorUsedError;
  double get vitaminE => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealVitaminsModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealVitaminsModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealVitaminsModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this MealVitaminsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealVitaminsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealVitaminsModelCopyWith<MealVitaminsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealVitaminsModelCopyWith<$Res> {
  factory $MealVitaminsModelCopyWith(
    MealVitaminsModel value,
    $Res Function(MealVitaminsModel) then,
  ) = _$MealVitaminsModelCopyWithImpl<$Res, MealVitaminsModel>;
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
class _$MealVitaminsModelCopyWithImpl<$Res, $Val extends MealVitaminsModel>
    implements $MealVitaminsModelCopyWith<$Res> {
  _$MealVitaminsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealVitaminsModel
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
abstract class _$$MealVitaminsModelImplCopyWith<$Res>
    implements $MealVitaminsModelCopyWith<$Res> {
  factory _$$MealVitaminsModelImplCopyWith(
    _$MealVitaminsModelImpl value,
    $Res Function(_$MealVitaminsModelImpl) then,
  ) = __$$MealVitaminsModelImplCopyWithImpl<$Res>;
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
class __$$MealVitaminsModelImplCopyWithImpl<$Res>
    extends _$MealVitaminsModelCopyWithImpl<$Res, _$MealVitaminsModelImpl>
    implements _$$MealVitaminsModelImplCopyWith<$Res> {
  __$$MealVitaminsModelImplCopyWithImpl(
    _$MealVitaminsModelImpl _value,
    $Res Function(_$MealVitaminsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealVitaminsModel
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
      _$MealVitaminsModelImpl(
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
@JsonSerializable()
class _$MealVitaminsModelImpl implements _MealVitaminsModel {
  const _$MealVitaminsModelImpl({
    required this.vitaminA,
    required this.vitaminB,
    required this.vitaminC,
    required this.vitaminD,
    required this.vitaminE,
  });

  factory _$MealVitaminsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealVitaminsModelImplFromJson(json);

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
    return 'MealVitaminsModel(vitaminA: $vitaminA, vitaminB: $vitaminB, vitaminC: $vitaminC, vitaminD: $vitaminD, vitaminE: $vitaminE)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealVitaminsModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    vitaminA,
    vitaminB,
    vitaminC,
    vitaminD,
    vitaminE,
  );

  /// Create a copy of MealVitaminsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealVitaminsModelImplCopyWith<_$MealVitaminsModelImpl> get copyWith =>
      __$$MealVitaminsModelImplCopyWithImpl<_$MealVitaminsModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealVitaminsModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealVitaminsModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealVitaminsModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MealVitaminsModelImplToJson(this);
  }
}

abstract class _MealVitaminsModel implements MealVitaminsModel {
  const factory _MealVitaminsModel({
    required final double vitaminA,
    required final double vitaminB,
    required final double vitaminC,
    required final double vitaminD,
    required final double vitaminE,
  }) = _$MealVitaminsModelImpl;

  factory _MealVitaminsModel.fromJson(Map<String, dynamic> json) =
      _$MealVitaminsModelImpl.fromJson;

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

  /// Create a copy of MealVitaminsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealVitaminsModelImplCopyWith<_$MealVitaminsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MealMineralsModel _$MealMineralsModelFromJson(Map<String, dynamic> json) {
  return _MealMineralsModel.fromJson(json);
}

/// @nodoc
mixin _$MealMineralsModel {
  double get calcium => throw _privateConstructorUsedError;
  double get iron => throw _privateConstructorUsedError;
  double get magnesium => throw _privateConstructorUsedError;
  double get zinc => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMineralsModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMineralsModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMineralsModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this MealMineralsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealMineralsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealMineralsModelCopyWith<MealMineralsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealMineralsModelCopyWith<$Res> {
  factory $MealMineralsModelCopyWith(
    MealMineralsModel value,
    $Res Function(MealMineralsModel) then,
  ) = _$MealMineralsModelCopyWithImpl<$Res, MealMineralsModel>;
  @useResult
  $Res call({double calcium, double iron, double magnesium, double zinc});
}

/// @nodoc
class _$MealMineralsModelCopyWithImpl<$Res, $Val extends MealMineralsModel>
    implements $MealMineralsModelCopyWith<$Res> {
  _$MealMineralsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealMineralsModel
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
abstract class _$$MealMineralsModelImplCopyWith<$Res>
    implements $MealMineralsModelCopyWith<$Res> {
  factory _$$MealMineralsModelImplCopyWith(
    _$MealMineralsModelImpl value,
    $Res Function(_$MealMineralsModelImpl) then,
  ) = __$$MealMineralsModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double calcium, double iron, double magnesium, double zinc});
}

/// @nodoc
class __$$MealMineralsModelImplCopyWithImpl<$Res>
    extends _$MealMineralsModelCopyWithImpl<$Res, _$MealMineralsModelImpl>
    implements _$$MealMineralsModelImplCopyWith<$Res> {
  __$$MealMineralsModelImplCopyWithImpl(
    _$MealMineralsModelImpl _value,
    $Res Function(_$MealMineralsModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealMineralsModel
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
      _$MealMineralsModelImpl(
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
@JsonSerializable()
class _$MealMineralsModelImpl implements _MealMineralsModel {
  const _$MealMineralsModelImpl({
    required this.calcium,
    required this.iron,
    required this.magnesium,
    required this.zinc,
  });

  factory _$MealMineralsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealMineralsModelImplFromJson(json);

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
    return 'MealMineralsModel(calcium: $calcium, iron: $iron, magnesium: $magnesium, zinc: $zinc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealMineralsModelImpl &&
            (identical(other.calcium, calcium) || other.calcium == calcium) &&
            (identical(other.iron, iron) || other.iron == iron) &&
            (identical(other.magnesium, magnesium) ||
                other.magnesium == magnesium) &&
            (identical(other.zinc, zinc) || other.zinc == zinc));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, calcium, iron, magnesium, zinc);

  /// Create a copy of MealMineralsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealMineralsModelImplCopyWith<_$MealMineralsModelImpl> get copyWith =>
      __$$MealMineralsModelImplCopyWithImpl<_$MealMineralsModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealMineralsModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealMineralsModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealMineralsModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MealMineralsModelImplToJson(this);
  }
}

abstract class _MealMineralsModel implements MealMineralsModel {
  const factory _MealMineralsModel({
    required final double calcium,
    required final double iron,
    required final double magnesium,
    required final double zinc,
  }) = _$MealMineralsModelImpl;

  factory _MealMineralsModel.fromJson(Map<String, dynamic> json) =
      _$MealMineralsModelImpl.fromJson;

  @override
  double get calcium;
  @override
  double get iron;
  @override
  double get magnesium;
  @override
  double get zinc;

  /// Create a copy of MealMineralsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealMineralsModelImplCopyWith<_$MealMineralsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MealModel _$MealModelFromJson(Map<String, dynamic> json) {
  return _MealModel.fromJson(json);
}

/// @nodoc
mixin _$MealModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  MealMacrosModel get macros => throw _privateConstructorUsedError;
  MealMicrosModel get micros => throw _privateConstructorUsedError;
  MealVitaminsModel get vitamins => throw _privateConstructorUsedError;
  MealMineralsModel get minerals => throw _privateConstructorUsedError;
  String get timestamp =>
      throw _privateConstructorUsedError; // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  String? get userId => throw _privateConstructorUsedError;
  String? get foodItemId => throw _privateConstructorUsedError;
  String? get updatedAt =>
      throw _privateConstructorUsedError; // ISO 8601 string
  // Phase 2 tombstone (ISO 8601 string) on cloud-deleted records.
  String? get deletedAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this MealModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealModelCopyWith<MealModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealModelCopyWith<$Res> {
  factory $MealModelCopyWith(MealModel value, $Res Function(MealModel) then) =
      _$MealModelCopyWithImpl<$Res, MealModel>;
  @useResult
  $Res call({
    String id,
    String name,
    MealMacrosModel macros,
    MealMicrosModel micros,
    MealVitaminsModel vitamins,
    MealMineralsModel minerals,
    String timestamp,
    String? userId,
    String? foodItemId,
    String? updatedAt,
    String? deletedAt,
  });

  $MealMacrosModelCopyWith<$Res> get macros;
  $MealMicrosModelCopyWith<$Res> get micros;
  $MealVitaminsModelCopyWith<$Res> get vitamins;
  $MealMineralsModelCopyWith<$Res> get minerals;
}

/// @nodoc
class _$MealModelCopyWithImpl<$Res, $Val extends MealModel>
    implements $MealModelCopyWith<$Res> {
  _$MealModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealModel
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
                      as MealMacrosModel,
            micros: null == micros
                ? _value.micros
                : micros // ignore: cast_nullable_to_non_nullable
                      as MealMicrosModel,
            vitamins: null == vitamins
                ? _value.vitamins
                : vitamins // ignore: cast_nullable_to_non_nullable
                      as MealVitaminsModel,
            minerals: null == minerals
                ? _value.minerals
                : minerals // ignore: cast_nullable_to_non_nullable
                      as MealMineralsModel,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as String,
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
                      as String?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealMacrosModelCopyWith<$Res> get macros {
    return $MealMacrosModelCopyWith<$Res>(_value.macros, (value) {
      return _then(_value.copyWith(macros: value) as $Val);
    });
  }

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealMicrosModelCopyWith<$Res> get micros {
    return $MealMicrosModelCopyWith<$Res>(_value.micros, (value) {
      return _then(_value.copyWith(micros: value) as $Val);
    });
  }

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealVitaminsModelCopyWith<$Res> get vitamins {
    return $MealVitaminsModelCopyWith<$Res>(_value.vitamins, (value) {
      return _then(_value.copyWith(vitamins: value) as $Val);
    });
  }

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MealMineralsModelCopyWith<$Res> get minerals {
    return $MealMineralsModelCopyWith<$Res>(_value.minerals, (value) {
      return _then(_value.copyWith(minerals: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MealModelImplCopyWith<$Res>
    implements $MealModelCopyWith<$Res> {
  factory _$$MealModelImplCopyWith(
    _$MealModelImpl value,
    $Res Function(_$MealModelImpl) then,
  ) = __$$MealModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    MealMacrosModel macros,
    MealMicrosModel micros,
    MealVitaminsModel vitamins,
    MealMineralsModel minerals,
    String timestamp,
    String? userId,
    String? foodItemId,
    String? updatedAt,
    String? deletedAt,
  });

  @override
  $MealMacrosModelCopyWith<$Res> get macros;
  @override
  $MealMicrosModelCopyWith<$Res> get micros;
  @override
  $MealVitaminsModelCopyWith<$Res> get vitamins;
  @override
  $MealMineralsModelCopyWith<$Res> get minerals;
}

/// @nodoc
class __$$MealModelImplCopyWithImpl<$Res>
    extends _$MealModelCopyWithImpl<$Res, _$MealModelImpl>
    implements _$$MealModelImplCopyWith<$Res> {
  __$$MealModelImplCopyWithImpl(
    _$MealModelImpl _value,
    $Res Function(_$MealModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealModel
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
      _$MealModelImpl(
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
                  as MealMacrosModel,
        micros: null == micros
            ? _value.micros
            : micros // ignore: cast_nullable_to_non_nullable
                  as MealMicrosModel,
        vitamins: null == vitamins
            ? _value.vitamins
            : vitamins // ignore: cast_nullable_to_non_nullable
                  as MealVitaminsModel,
        minerals: null == minerals
            ? _value.minerals
            : minerals // ignore: cast_nullable_to_non_nullable
                  as MealMineralsModel,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as String,
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
                  as String?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MealModelImpl implements _MealModel {
  const _$MealModelImpl({
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
  });

  factory _$MealModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MealModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final MealMacrosModel macros;
  @override
  final MealMicrosModel micros;
  @override
  final MealVitaminsModel vitamins;
  @override
  final MealMineralsModel minerals;
  @override
  final String timestamp;
  // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  @override
  final String? userId;
  @override
  final String? foodItemId;
  @override
  final String? updatedAt;
  // ISO 8601 string
  // Phase 2 tombstone (ISO 8601 string) on cloud-deleted records.
  @override
  final String? deletedAt;

  @override
  String toString() {
    return 'MealModel(id: $id, name: $name, macros: $macros, micros: $micros, vitamins: $vitamins, minerals: $minerals, timestamp: $timestamp, userId: $userId, foodItemId: $foodItemId, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealModelImpl &&
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

  @JsonKey(includeFromJson: false, includeToJson: false)
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

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealModelImplCopyWith<_$MealModelImpl> get copyWith =>
      __$$MealModelImplCopyWithImpl<_$MealModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MealModelImplToJson(this);
  }
}

abstract class _MealModel implements MealModel {
  const factory _MealModel({
    required final String id,
    required final String name,
    required final MealMacrosModel macros,
    required final MealMicrosModel micros,
    required final MealVitaminsModel vitamins,
    required final MealMineralsModel minerals,
    required final String timestamp,
    final String? userId,
    final String? foodItemId,
    final String? updatedAt,
    final String? deletedAt,
  }) = _$MealModelImpl;

  factory _MealModel.fromJson(Map<String, dynamic> json) =
      _$MealModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  MealMacrosModel get macros;
  @override
  MealMicrosModel get micros;
  @override
  MealVitaminsModel get vitamins;
  @override
  MealMineralsModel get minerals;
  @override
  String get timestamp; // Phase 1 schema v2 — nullable so pre-v2 stored JSON still loads.
  @override
  String? get userId;
  @override
  String? get foodItemId;
  @override
  String? get updatedAt; // ISO 8601 string
  // Phase 2 tombstone (ISO 8601 string) on cloud-deleted records.
  @override
  String? get deletedAt;

  /// Create a copy of MealModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealModelImplCopyWith<_$MealModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

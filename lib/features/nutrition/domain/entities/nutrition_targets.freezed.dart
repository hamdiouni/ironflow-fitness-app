// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'nutrition_targets.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MacroTargets {
  double get calories => throw _privateConstructorUsedError;
  double get protein => throw _privateConstructorUsedError;
  double get carbs => throw _privateConstructorUsedError;
  double get fats => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MacroTargets value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MacroTargets value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MacroTargets value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of MacroTargets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MacroTargetsCopyWith<MacroTargets> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MacroTargetsCopyWith<$Res> {
  factory $MacroTargetsCopyWith(
    MacroTargets value,
    $Res Function(MacroTargets) then,
  ) = _$MacroTargetsCopyWithImpl<$Res, MacroTargets>;
  @useResult
  $Res call({double calories, double protein, double carbs, double fats});
}

/// @nodoc
class _$MacroTargetsCopyWithImpl<$Res, $Val extends MacroTargets>
    implements $MacroTargetsCopyWith<$Res> {
  _$MacroTargetsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MacroTargets
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
abstract class _$$MacroTargetsImplCopyWith<$Res>
    implements $MacroTargetsCopyWith<$Res> {
  factory _$$MacroTargetsImplCopyWith(
    _$MacroTargetsImpl value,
    $Res Function(_$MacroTargetsImpl) then,
  ) = __$$MacroTargetsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double calories, double protein, double carbs, double fats});
}

/// @nodoc
class __$$MacroTargetsImplCopyWithImpl<$Res>
    extends _$MacroTargetsCopyWithImpl<$Res, _$MacroTargetsImpl>
    implements _$$MacroTargetsImplCopyWith<$Res> {
  __$$MacroTargetsImplCopyWithImpl(
    _$MacroTargetsImpl _value,
    $Res Function(_$MacroTargetsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MacroTargets
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
      _$MacroTargetsImpl(
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

class _$MacroTargetsImpl extends _MacroTargets {
  const _$MacroTargetsImpl({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  }) : super._();

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
    return 'MacroTargets(calories: $calories, protein: $protein, carbs: $carbs, fats: $fats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MacroTargetsImpl &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.protein, protein) || other.protein == protein) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fats, fats) || other.fats == fats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, calories, protein, carbs, fats);

  /// Create a copy of MacroTargets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MacroTargetsImplCopyWith<_$MacroTargetsImpl> get copyWith =>
      __$$MacroTargetsImplCopyWithImpl<_$MacroTargetsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MacroTargets value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MacroTargets value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MacroTargets value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MacroTargets extends MacroTargets {
  const factory _MacroTargets({
    required final double calories,
    required final double protein,
    required final double carbs,
    required final double fats,
  }) = _$MacroTargetsImpl;
  const _MacroTargets._() : super._();

  @override
  double get calories;
  @override
  double get protein;
  @override
  double get carbs;
  @override
  double get fats;

  /// Create a copy of MacroTargets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MacroTargetsImplCopyWith<_$MacroTargetsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MicroTargets {
  double get fiber => throw _privateConstructorUsedError;
  double get sugar => throw _privateConstructorUsedError;
  double get sodium => throw _privateConstructorUsedError;
  double get potassium => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MicroTargets value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MicroTargets value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MicroTargets value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of MicroTargets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MicroTargetsCopyWith<MicroTargets> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MicroTargetsCopyWith<$Res> {
  factory $MicroTargetsCopyWith(
    MicroTargets value,
    $Res Function(MicroTargets) then,
  ) = _$MicroTargetsCopyWithImpl<$Res, MicroTargets>;
  @useResult
  $Res call({double fiber, double sugar, double sodium, double potassium});
}

/// @nodoc
class _$MicroTargetsCopyWithImpl<$Res, $Val extends MicroTargets>
    implements $MicroTargetsCopyWith<$Res> {
  _$MicroTargetsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MicroTargets
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
abstract class _$$MicroTargetsImplCopyWith<$Res>
    implements $MicroTargetsCopyWith<$Res> {
  factory _$$MicroTargetsImplCopyWith(
    _$MicroTargetsImpl value,
    $Res Function(_$MicroTargetsImpl) then,
  ) = __$$MicroTargetsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double fiber, double sugar, double sodium, double potassium});
}

/// @nodoc
class __$$MicroTargetsImplCopyWithImpl<$Res>
    extends _$MicroTargetsCopyWithImpl<$Res, _$MicroTargetsImpl>
    implements _$$MicroTargetsImplCopyWith<$Res> {
  __$$MicroTargetsImplCopyWithImpl(
    _$MicroTargetsImpl _value,
    $Res Function(_$MicroTargetsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MicroTargets
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
      _$MicroTargetsImpl(
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

class _$MicroTargetsImpl extends _MicroTargets {
  const _$MicroTargetsImpl({
    required this.fiber,
    required this.sugar,
    required this.sodium,
    required this.potassium,
  }) : super._();

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
    return 'MicroTargets(fiber: $fiber, sugar: $sugar, sodium: $sodium, potassium: $potassium)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MicroTargetsImpl &&
            (identical(other.fiber, fiber) || other.fiber == fiber) &&
            (identical(other.sugar, sugar) || other.sugar == sugar) &&
            (identical(other.sodium, sodium) || other.sodium == sodium) &&
            (identical(other.potassium, potassium) ||
                other.potassium == potassium));
  }

  @override
  int get hashCode => Object.hash(runtimeType, fiber, sugar, sodium, potassium);

  /// Create a copy of MicroTargets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MicroTargetsImplCopyWith<_$MicroTargetsImpl> get copyWith =>
      __$$MicroTargetsImplCopyWithImpl<_$MicroTargetsImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MicroTargets value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MicroTargets value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MicroTargets value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MicroTargets extends MicroTargets {
  const factory _MicroTargets({
    required final double fiber,
    required final double sugar,
    required final double sodium,
    required final double potassium,
  }) = _$MicroTargetsImpl;
  const _MicroTargets._() : super._();

  @override
  double get fiber;
  @override
  double get sugar;
  @override
  double get sodium;
  @override
  double get potassium;

  /// Create a copy of MicroTargets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MicroTargetsImplCopyWith<_$MicroTargetsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$VitaminTargets {
  double get vitaminA => throw _privateConstructorUsedError;
  double get vitaminB => throw _privateConstructorUsedError;
  double get vitaminC => throw _privateConstructorUsedError;
  double get vitaminD => throw _privateConstructorUsedError;
  double get vitaminE => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_VitaminTargets value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_VitaminTargets value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_VitaminTargets value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of VitaminTargets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VitaminTargetsCopyWith<VitaminTargets> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VitaminTargetsCopyWith<$Res> {
  factory $VitaminTargetsCopyWith(
    VitaminTargets value,
    $Res Function(VitaminTargets) then,
  ) = _$VitaminTargetsCopyWithImpl<$Res, VitaminTargets>;
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
class _$VitaminTargetsCopyWithImpl<$Res, $Val extends VitaminTargets>
    implements $VitaminTargetsCopyWith<$Res> {
  _$VitaminTargetsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VitaminTargets
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
abstract class _$$VitaminTargetsImplCopyWith<$Res>
    implements $VitaminTargetsCopyWith<$Res> {
  factory _$$VitaminTargetsImplCopyWith(
    _$VitaminTargetsImpl value,
    $Res Function(_$VitaminTargetsImpl) then,
  ) = __$$VitaminTargetsImplCopyWithImpl<$Res>;
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
class __$$VitaminTargetsImplCopyWithImpl<$Res>
    extends _$VitaminTargetsCopyWithImpl<$Res, _$VitaminTargetsImpl>
    implements _$$VitaminTargetsImplCopyWith<$Res> {
  __$$VitaminTargetsImplCopyWithImpl(
    _$VitaminTargetsImpl _value,
    $Res Function(_$VitaminTargetsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of VitaminTargets
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
      _$VitaminTargetsImpl(
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

class _$VitaminTargetsImpl extends _VitaminTargets {
  const _$VitaminTargetsImpl({
    required this.vitaminA,
    required this.vitaminB,
    required this.vitaminC,
    required this.vitaminD,
    required this.vitaminE,
  }) : super._();

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
    return 'VitaminTargets(vitaminA: $vitaminA, vitaminB: $vitaminB, vitaminC: $vitaminC, vitaminD: $vitaminD, vitaminE: $vitaminE)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VitaminTargetsImpl &&
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

  /// Create a copy of VitaminTargets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VitaminTargetsImplCopyWith<_$VitaminTargetsImpl> get copyWith =>
      __$$VitaminTargetsImplCopyWithImpl<_$VitaminTargetsImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_VitaminTargets value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_VitaminTargets value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_VitaminTargets value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _VitaminTargets extends VitaminTargets {
  const factory _VitaminTargets({
    required final double vitaminA,
    required final double vitaminB,
    required final double vitaminC,
    required final double vitaminD,
    required final double vitaminE,
  }) = _$VitaminTargetsImpl;
  const _VitaminTargets._() : super._();

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

  /// Create a copy of VitaminTargets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VitaminTargetsImplCopyWith<_$VitaminTargetsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MineralTargets {
  double get calcium => throw _privateConstructorUsedError;
  double get iron => throw _privateConstructorUsedError;
  double get magnesium => throw _privateConstructorUsedError;
  double get zinc => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MineralTargets value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MineralTargets value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MineralTargets value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of MineralTargets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MineralTargetsCopyWith<MineralTargets> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MineralTargetsCopyWith<$Res> {
  factory $MineralTargetsCopyWith(
    MineralTargets value,
    $Res Function(MineralTargets) then,
  ) = _$MineralTargetsCopyWithImpl<$Res, MineralTargets>;
  @useResult
  $Res call({double calcium, double iron, double magnesium, double zinc});
}

/// @nodoc
class _$MineralTargetsCopyWithImpl<$Res, $Val extends MineralTargets>
    implements $MineralTargetsCopyWith<$Res> {
  _$MineralTargetsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MineralTargets
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
abstract class _$$MineralTargetsImplCopyWith<$Res>
    implements $MineralTargetsCopyWith<$Res> {
  factory _$$MineralTargetsImplCopyWith(
    _$MineralTargetsImpl value,
    $Res Function(_$MineralTargetsImpl) then,
  ) = __$$MineralTargetsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double calcium, double iron, double magnesium, double zinc});
}

/// @nodoc
class __$$MineralTargetsImplCopyWithImpl<$Res>
    extends _$MineralTargetsCopyWithImpl<$Res, _$MineralTargetsImpl>
    implements _$$MineralTargetsImplCopyWith<$Res> {
  __$$MineralTargetsImplCopyWithImpl(
    _$MineralTargetsImpl _value,
    $Res Function(_$MineralTargetsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MineralTargets
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
      _$MineralTargetsImpl(
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

class _$MineralTargetsImpl extends _MineralTargets {
  const _$MineralTargetsImpl({
    required this.calcium,
    required this.iron,
    required this.magnesium,
    required this.zinc,
  }) : super._();

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
    return 'MineralTargets(calcium: $calcium, iron: $iron, magnesium: $magnesium, zinc: $zinc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MineralTargetsImpl &&
            (identical(other.calcium, calcium) || other.calcium == calcium) &&
            (identical(other.iron, iron) || other.iron == iron) &&
            (identical(other.magnesium, magnesium) ||
                other.magnesium == magnesium) &&
            (identical(other.zinc, zinc) || other.zinc == zinc));
  }

  @override
  int get hashCode => Object.hash(runtimeType, calcium, iron, magnesium, zinc);

  /// Create a copy of MineralTargets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MineralTargetsImplCopyWith<_$MineralTargetsImpl> get copyWith =>
      __$$MineralTargetsImplCopyWithImpl<_$MineralTargetsImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MineralTargets value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MineralTargets value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MineralTargets value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MineralTargets extends MineralTargets {
  const factory _MineralTargets({
    required final double calcium,
    required final double iron,
    required final double magnesium,
    required final double zinc,
  }) = _$MineralTargetsImpl;
  const _MineralTargets._() : super._();

  @override
  double get calcium;
  @override
  double get iron;
  @override
  double get magnesium;
  @override
  double get zinc;

  /// Create a copy of MineralTargets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MineralTargetsImplCopyWith<_$MineralTargetsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$NutritionTargets {
  String get userId => throw _privateConstructorUsedError;
  MacroTargets get macros => throw _privateConstructorUsedError;
  MicroTargets get micros => throw _privateConstructorUsedError;
  VitaminTargets get vitamins => throw _privateConstructorUsedError;
  MineralTargets get minerals => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NutritionTargets value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NutritionTargets value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NutritionTargets value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of NutritionTargets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NutritionTargetsCopyWith<NutritionTargets> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NutritionTargetsCopyWith<$Res> {
  factory $NutritionTargetsCopyWith(
    NutritionTargets value,
    $Res Function(NutritionTargets) then,
  ) = _$NutritionTargetsCopyWithImpl<$Res, NutritionTargets>;
  @useResult
  $Res call({
    String userId,
    MacroTargets macros,
    MicroTargets micros,
    VitaminTargets vitamins,
    MineralTargets minerals,
    DateTime createdAt,
    DateTime updatedAt,
  });

  $MacroTargetsCopyWith<$Res> get macros;
  $MicroTargetsCopyWith<$Res> get micros;
  $VitaminTargetsCopyWith<$Res> get vitamins;
  $MineralTargetsCopyWith<$Res> get minerals;
}

/// @nodoc
class _$NutritionTargetsCopyWithImpl<$Res, $Val extends NutritionTargets>
    implements $NutritionTargetsCopyWith<$Res> {
  _$NutritionTargetsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NutritionTargets
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? macros = null,
    Object? micros = null,
    Object? vitamins = null,
    Object? minerals = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            macros: null == macros
                ? _value.macros
                : macros // ignore: cast_nullable_to_non_nullable
                      as MacroTargets,
            micros: null == micros
                ? _value.micros
                : micros // ignore: cast_nullable_to_non_nullable
                      as MicroTargets,
            vitamins: null == vitamins
                ? _value.vitamins
                : vitamins // ignore: cast_nullable_to_non_nullable
                      as VitaminTargets,
            minerals: null == minerals
                ? _value.minerals
                : minerals // ignore: cast_nullable_to_non_nullable
                      as MineralTargets,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of NutritionTargets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MacroTargetsCopyWith<$Res> get macros {
    return $MacroTargetsCopyWith<$Res>(_value.macros, (value) {
      return _then(_value.copyWith(macros: value) as $Val);
    });
  }

  /// Create a copy of NutritionTargets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MicroTargetsCopyWith<$Res> get micros {
    return $MicroTargetsCopyWith<$Res>(_value.micros, (value) {
      return _then(_value.copyWith(micros: value) as $Val);
    });
  }

  /// Create a copy of NutritionTargets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $VitaminTargetsCopyWith<$Res> get vitamins {
    return $VitaminTargetsCopyWith<$Res>(_value.vitamins, (value) {
      return _then(_value.copyWith(vitamins: value) as $Val);
    });
  }

  /// Create a copy of NutritionTargets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MineralTargetsCopyWith<$Res> get minerals {
    return $MineralTargetsCopyWith<$Res>(_value.minerals, (value) {
      return _then(_value.copyWith(minerals: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NutritionTargetsImplCopyWith<$Res>
    implements $NutritionTargetsCopyWith<$Res> {
  factory _$$NutritionTargetsImplCopyWith(
    _$NutritionTargetsImpl value,
    $Res Function(_$NutritionTargetsImpl) then,
  ) = __$$NutritionTargetsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    MacroTargets macros,
    MicroTargets micros,
    VitaminTargets vitamins,
    MineralTargets minerals,
    DateTime createdAt,
    DateTime updatedAt,
  });

  @override
  $MacroTargetsCopyWith<$Res> get macros;
  @override
  $MicroTargetsCopyWith<$Res> get micros;
  @override
  $VitaminTargetsCopyWith<$Res> get vitamins;
  @override
  $MineralTargetsCopyWith<$Res> get minerals;
}

/// @nodoc
class __$$NutritionTargetsImplCopyWithImpl<$Res>
    extends _$NutritionTargetsCopyWithImpl<$Res, _$NutritionTargetsImpl>
    implements _$$NutritionTargetsImplCopyWith<$Res> {
  __$$NutritionTargetsImplCopyWithImpl(
    _$NutritionTargetsImpl _value,
    $Res Function(_$NutritionTargetsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NutritionTargets
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? macros = null,
    Object? micros = null,
    Object? vitamins = null,
    Object? minerals = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(
      _$NutritionTargetsImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        macros: null == macros
            ? _value.macros
            : macros // ignore: cast_nullable_to_non_nullable
                  as MacroTargets,
        micros: null == micros
            ? _value.micros
            : micros // ignore: cast_nullable_to_non_nullable
                  as MicroTargets,
        vitamins: null == vitamins
            ? _value.vitamins
            : vitamins // ignore: cast_nullable_to_non_nullable
                  as VitaminTargets,
        minerals: null == minerals
            ? _value.minerals
            : minerals // ignore: cast_nullable_to_non_nullable
                  as MineralTargets,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$NutritionTargetsImpl extends _NutritionTargets {
  const _$NutritionTargetsImpl({
    required this.userId,
    required this.macros,
    required this.micros,
    required this.vitamins,
    required this.minerals,
    required this.createdAt,
    required this.updatedAt,
  }) : super._();

  @override
  final String userId;
  @override
  final MacroTargets macros;
  @override
  final MicroTargets micros;
  @override
  final VitaminTargets vitamins;
  @override
  final MineralTargets minerals;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'NutritionTargets(userId: $userId, macros: $macros, micros: $micros, vitamins: $vitamins, minerals: $minerals, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NutritionTargetsImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.macros, macros) || other.macros == macros) &&
            (identical(other.micros, micros) || other.micros == micros) &&
            (identical(other.vitamins, vitamins) ||
                other.vitamins == vitamins) &&
            (identical(other.minerals, minerals) ||
                other.minerals == minerals) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    macros,
    micros,
    vitamins,
    minerals,
    createdAt,
    updatedAt,
  );

  /// Create a copy of NutritionTargets
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NutritionTargetsImplCopyWith<_$NutritionTargetsImpl> get copyWith =>
      __$$NutritionTargetsImplCopyWithImpl<_$NutritionTargetsImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NutritionTargets value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NutritionTargets value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NutritionTargets value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _NutritionTargets extends NutritionTargets {
  const factory _NutritionTargets({
    required final String userId,
    required final MacroTargets macros,
    required final MicroTargets micros,
    required final VitaminTargets vitamins,
    required final MineralTargets minerals,
    required final DateTime createdAt,
    required final DateTime updatedAt,
  }) = _$NutritionTargetsImpl;
  const _NutritionTargets._() : super._();

  @override
  String get userId;
  @override
  MacroTargets get macros;
  @override
  MicroTargets get micros;
  @override
  VitaminTargets get vitamins;
  @override
  MineralTargets get minerals;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of NutritionTargets
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NutritionTargetsImplCopyWith<_$NutritionTargetsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

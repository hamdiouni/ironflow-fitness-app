// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'macro_target.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MacroTarget {
  double get protein => throw _privateConstructorUsedError;
  double get carbs => throw _privateConstructorUsedError;
  double get fats => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MacroTarget value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MacroTarget value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MacroTarget value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of MacroTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MacroTargetCopyWith<MacroTarget> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MacroTargetCopyWith<$Res> {
  factory $MacroTargetCopyWith(
    MacroTarget value,
    $Res Function(MacroTarget) then,
  ) = _$MacroTargetCopyWithImpl<$Res, MacroTarget>;
  @useResult
  $Res call({double protein, double carbs, double fats});
}

/// @nodoc
class _$MacroTargetCopyWithImpl<$Res, $Val extends MacroTarget>
    implements $MacroTargetCopyWith<$Res> {
  _$MacroTargetCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MacroTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? protein = null,
    Object? carbs = null,
    Object? fats = null,
  }) {
    return _then(
      _value.copyWith(
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
abstract class _$$MacroTargetImplCopyWith<$Res>
    implements $MacroTargetCopyWith<$Res> {
  factory _$$MacroTargetImplCopyWith(
    _$MacroTargetImpl value,
    $Res Function(_$MacroTargetImpl) then,
  ) = __$$MacroTargetImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double protein, double carbs, double fats});
}

/// @nodoc
class __$$MacroTargetImplCopyWithImpl<$Res>
    extends _$MacroTargetCopyWithImpl<$Res, _$MacroTargetImpl>
    implements _$$MacroTargetImplCopyWith<$Res> {
  __$$MacroTargetImplCopyWithImpl(
    _$MacroTargetImpl _value,
    $Res Function(_$MacroTargetImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MacroTarget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? protein = null,
    Object? carbs = null,
    Object? fats = null,
  }) {
    return _then(
      _$MacroTargetImpl(
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

class _$MacroTargetImpl extends _MacroTarget {
  const _$MacroTargetImpl({
    required this.protein,
    required this.carbs,
    required this.fats,
  }) : super._();

  @override
  final double protein;
  @override
  final double carbs;
  @override
  final double fats;

  @override
  String toString() {
    return 'MacroTarget(protein: $protein, carbs: $carbs, fats: $fats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MacroTargetImpl &&
            (identical(other.protein, protein) || other.protein == protein) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fats, fats) || other.fats == fats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, protein, carbs, fats);

  /// Create a copy of MacroTarget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MacroTargetImplCopyWith<_$MacroTargetImpl> get copyWith =>
      __$$MacroTargetImplCopyWithImpl<_$MacroTargetImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MacroTarget value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MacroTarget value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MacroTarget value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MacroTarget extends MacroTarget {
  const factory _MacroTarget({
    required final double protein,
    required final double carbs,
    required final double fats,
  }) = _$MacroTargetImpl;
  const _MacroTarget._() : super._();

  @override
  double get protein;
  @override
  double get carbs;
  @override
  double get fats;

  /// Create a copy of MacroTarget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MacroTargetImplCopyWith<_$MacroTargetImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

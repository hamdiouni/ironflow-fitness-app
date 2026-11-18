// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'macro_target_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MacroTargetModel _$MacroTargetModelFromJson(Map<String, dynamic> json) {
  return _MacroTargetModel.fromJson(json);
}

/// @nodoc
mixin _$MacroTargetModel {
  double get protein => throw _privateConstructorUsedError;
  double get carbs => throw _privateConstructorUsedError;
  double get fats => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MacroTargetModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MacroTargetModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MacroTargetModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this MacroTargetModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MacroTargetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MacroTargetModelCopyWith<MacroTargetModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MacroTargetModelCopyWith<$Res> {
  factory $MacroTargetModelCopyWith(
    MacroTargetModel value,
    $Res Function(MacroTargetModel) then,
  ) = _$MacroTargetModelCopyWithImpl<$Res, MacroTargetModel>;
  @useResult
  $Res call({double protein, double carbs, double fats});
}

/// @nodoc
class _$MacroTargetModelCopyWithImpl<$Res, $Val extends MacroTargetModel>
    implements $MacroTargetModelCopyWith<$Res> {
  _$MacroTargetModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MacroTargetModel
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
abstract class _$$MacroTargetModelImplCopyWith<$Res>
    implements $MacroTargetModelCopyWith<$Res> {
  factory _$$MacroTargetModelImplCopyWith(
    _$MacroTargetModelImpl value,
    $Res Function(_$MacroTargetModelImpl) then,
  ) = __$$MacroTargetModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double protein, double carbs, double fats});
}

/// @nodoc
class __$$MacroTargetModelImplCopyWithImpl<$Res>
    extends _$MacroTargetModelCopyWithImpl<$Res, _$MacroTargetModelImpl>
    implements _$$MacroTargetModelImplCopyWith<$Res> {
  __$$MacroTargetModelImplCopyWithImpl(
    _$MacroTargetModelImpl _value,
    $Res Function(_$MacroTargetModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MacroTargetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? protein = null,
    Object? carbs = null,
    Object? fats = null,
  }) {
    return _then(
      _$MacroTargetModelImpl(
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
class _$MacroTargetModelImpl implements _MacroTargetModel {
  const _$MacroTargetModelImpl({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  factory _$MacroTargetModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MacroTargetModelImplFromJson(json);

  @override
  final double protein;
  @override
  final double carbs;
  @override
  final double fats;

  @override
  String toString() {
    return 'MacroTargetModel(protein: $protein, carbs: $carbs, fats: $fats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MacroTargetModelImpl &&
            (identical(other.protein, protein) || other.protein == protein) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fats, fats) || other.fats == fats));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, protein, carbs, fats);

  /// Create a copy of MacroTargetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MacroTargetModelImplCopyWith<_$MacroTargetModelImpl> get copyWith =>
      __$$MacroTargetModelImplCopyWithImpl<_$MacroTargetModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MacroTargetModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MacroTargetModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MacroTargetModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MacroTargetModelImplToJson(this);
  }
}

abstract class _MacroTargetModel implements MacroTargetModel {
  const factory _MacroTargetModel({
    required final double protein,
    required final double carbs,
    required final double fats,
  }) = _$MacroTargetModelImpl;

  factory _MacroTargetModel.fromJson(Map<String, dynamic> json) =
      _$MacroTargetModelImpl.fromJson;

  @override
  double get protein;
  @override
  double get carbs;
  @override
  double get fats;

  /// Create a copy of MacroTargetModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MacroTargetModelImplCopyWith<_$MacroTargetModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'meal_suggestion.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MealSuggestion {
  String get name => throw _privateConstructorUsedError;
  double get protein => throw _privateConstructorUsedError;
  double get carbs => throw _privateConstructorUsedError;
  double get fats => throw _privateConstructorUsedError;
  MealCategory get category => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealSuggestion value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealSuggestion value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealSuggestion value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of MealSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MealSuggestionCopyWith<MealSuggestion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MealSuggestionCopyWith<$Res> {
  factory $MealSuggestionCopyWith(
    MealSuggestion value,
    $Res Function(MealSuggestion) then,
  ) = _$MealSuggestionCopyWithImpl<$Res, MealSuggestion>;
  @useResult
  $Res call({
    String name,
    double protein,
    double carbs,
    double fats,
    MealCategory category,
  });
}

/// @nodoc
class _$MealSuggestionCopyWithImpl<$Res, $Val extends MealSuggestion>
    implements $MealSuggestionCopyWith<$Res> {
  _$MealSuggestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MealSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? protein = null,
    Object? carbs = null,
    Object? fats = null,
    Object? category = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
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
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as MealCategory,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MealSuggestionImplCopyWith<$Res>
    implements $MealSuggestionCopyWith<$Res> {
  factory _$$MealSuggestionImplCopyWith(
    _$MealSuggestionImpl value,
    $Res Function(_$MealSuggestionImpl) then,
  ) = __$$MealSuggestionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    double protein,
    double carbs,
    double fats,
    MealCategory category,
  });
}

/// @nodoc
class __$$MealSuggestionImplCopyWithImpl<$Res>
    extends _$MealSuggestionCopyWithImpl<$Res, _$MealSuggestionImpl>
    implements _$$MealSuggestionImplCopyWith<$Res> {
  __$$MealSuggestionImplCopyWithImpl(
    _$MealSuggestionImpl _value,
    $Res Function(_$MealSuggestionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MealSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? protein = null,
    Object? carbs = null,
    Object? fats = null,
    Object? category = null,
  }) {
    return _then(
      _$MealSuggestionImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
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
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as MealCategory,
      ),
    );
  }
}

/// @nodoc

class _$MealSuggestionImpl extends _MealSuggestion {
  const _$MealSuggestionImpl({
    required this.name,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.category,
  }) : super._();

  @override
  final String name;
  @override
  final double protein;
  @override
  final double carbs;
  @override
  final double fats;
  @override
  final MealCategory category;

  @override
  String toString() {
    return 'MealSuggestion(name: $name, protein: $protein, carbs: $carbs, fats: $fats, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MealSuggestionImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.protein, protein) || other.protein == protein) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fats, fats) || other.fats == fats) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, name, protein, carbs, fats, category);

  /// Create a copy of MealSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MealSuggestionImplCopyWith<_$MealSuggestionImpl> get copyWith =>
      __$$MealSuggestionImplCopyWithImpl<_$MealSuggestionImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MealSuggestion value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MealSuggestion value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MealSuggestion value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MealSuggestion extends MealSuggestion {
  const factory _MealSuggestion({
    required final String name,
    required final double protein,
    required final double carbs,
    required final double fats,
    required final MealCategory category,
  }) = _$MealSuggestionImpl;
  const _MealSuggestion._() : super._();

  @override
  String get name;
  @override
  double get protein;
  @override
  double get carbs;
  @override
  double get fats;
  @override
  MealCategory get category;

  /// Create a copy of MealSuggestion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MealSuggestionImplCopyWith<_$MealSuggestionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

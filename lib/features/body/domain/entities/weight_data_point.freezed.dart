// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_data_point.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$WeightDataPoint {
  DateTime get date => throw _privateConstructorUsedError;
  double get weight => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WeightDataPoint value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WeightDataPoint value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WeightDataPoint value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of WeightDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeightDataPointCopyWith<WeightDataPoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeightDataPointCopyWith<$Res> {
  factory $WeightDataPointCopyWith(
    WeightDataPoint value,
    $Res Function(WeightDataPoint) then,
  ) = _$WeightDataPointCopyWithImpl<$Res, WeightDataPoint>;
  @useResult
  $Res call({DateTime date, double weight});
}

/// @nodoc
class _$WeightDataPointCopyWithImpl<$Res, $Val extends WeightDataPoint>
    implements $WeightDataPointCopyWith<$Res> {
  _$WeightDataPointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeightDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? weight = null}) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            weight: null == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WeightDataPointImplCopyWith<$Res>
    implements $WeightDataPointCopyWith<$Res> {
  factory _$$WeightDataPointImplCopyWith(
    _$WeightDataPointImpl value,
    $Res Function(_$WeightDataPointImpl) then,
  ) = __$$WeightDataPointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime date, double weight});
}

/// @nodoc
class __$$WeightDataPointImplCopyWithImpl<$Res>
    extends _$WeightDataPointCopyWithImpl<$Res, _$WeightDataPointImpl>
    implements _$$WeightDataPointImplCopyWith<$Res> {
  __$$WeightDataPointImplCopyWithImpl(
    _$WeightDataPointImpl _value,
    $Res Function(_$WeightDataPointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeightDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? date = null, Object? weight = null}) {
    return _then(
      _$WeightDataPointImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        weight: null == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$WeightDataPointImpl implements _WeightDataPoint {
  const _$WeightDataPointImpl({required this.date, required this.weight});

  @override
  final DateTime date;
  @override
  final double weight;

  @override
  String toString() {
    return 'WeightDataPoint(date: $date, weight: $weight)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightDataPointImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.weight, weight) || other.weight == weight));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, weight);

  /// Create a copy of WeightDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightDataPointImplCopyWith<_$WeightDataPointImpl> get copyWith =>
      __$$WeightDataPointImplCopyWithImpl<_$WeightDataPointImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_WeightDataPoint value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_WeightDataPoint value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_WeightDataPoint value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _WeightDataPoint implements WeightDataPoint {
  const factory _WeightDataPoint({
    required final DateTime date,
    required final double weight,
  }) = _$WeightDataPointImpl;

  @override
  DateTime get date;
  @override
  double get weight;

  /// Create a copy of WeightDataPoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeightDataPointImplCopyWith<_$WeightDataPointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

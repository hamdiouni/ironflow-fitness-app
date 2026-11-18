// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insight_cache.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InsightCache _$InsightCacheFromJson(Map<String, dynamic> json) {
  return _InsightCache.fromJson(json);
}

/// @nodoc
mixin _$InsightCache {
  InsightContext get context => throw _privateConstructorUsedError;
  List<Insight> get insights => throw _privateConstructorUsedError;
  DateTime get cachedAt => throw _privateConstructorUsedError;
  Map<String, DateTime> get dataTimestamps =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_InsightCache value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_InsightCache value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_InsightCache value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this InsightCache to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InsightCache
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InsightCacheCopyWith<InsightCache> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InsightCacheCopyWith<$Res> {
  factory $InsightCacheCopyWith(
    InsightCache value,
    $Res Function(InsightCache) then,
  ) = _$InsightCacheCopyWithImpl<$Res, InsightCache>;
  @useResult
  $Res call({
    InsightContext context,
    List<Insight> insights,
    DateTime cachedAt,
    Map<String, DateTime> dataTimestamps,
  });
}

/// @nodoc
class _$InsightCacheCopyWithImpl<$Res, $Val extends InsightCache>
    implements $InsightCacheCopyWith<$Res> {
  _$InsightCacheCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InsightCache
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
    Object? insights = null,
    Object? cachedAt = null,
    Object? dataTimestamps = null,
  }) {
    return _then(
      _value.copyWith(
            context: null == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as InsightContext,
            insights: null == insights
                ? _value.insights
                : insights // ignore: cast_nullable_to_non_nullable
                      as List<Insight>,
            cachedAt: null == cachedAt
                ? _value.cachedAt
                : cachedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            dataTimestamps: null == dataTimestamps
                ? _value.dataTimestamps
                : dataTimestamps // ignore: cast_nullable_to_non_nullable
                      as Map<String, DateTime>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InsightCacheImplCopyWith<$Res>
    implements $InsightCacheCopyWith<$Res> {
  factory _$$InsightCacheImplCopyWith(
    _$InsightCacheImpl value,
    $Res Function(_$InsightCacheImpl) then,
  ) = __$$InsightCacheImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    InsightContext context,
    List<Insight> insights,
    DateTime cachedAt,
    Map<String, DateTime> dataTimestamps,
  });
}

/// @nodoc
class __$$InsightCacheImplCopyWithImpl<$Res>
    extends _$InsightCacheCopyWithImpl<$Res, _$InsightCacheImpl>
    implements _$$InsightCacheImplCopyWith<$Res> {
  __$$InsightCacheImplCopyWithImpl(
    _$InsightCacheImpl _value,
    $Res Function(_$InsightCacheImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InsightCache
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
    Object? insights = null,
    Object? cachedAt = null,
    Object? dataTimestamps = null,
  }) {
    return _then(
      _$InsightCacheImpl(
        context: null == context
            ? _value.context
            : context // ignore: cast_nullable_to_non_nullable
                  as InsightContext,
        insights: null == insights
            ? _value._insights
            : insights // ignore: cast_nullable_to_non_nullable
                  as List<Insight>,
        cachedAt: null == cachedAt
            ? _value.cachedAt
            : cachedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        dataTimestamps: null == dataTimestamps
            ? _value._dataTimestamps
            : dataTimestamps // ignore: cast_nullable_to_non_nullable
                  as Map<String, DateTime>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InsightCacheImpl implements _InsightCache {
  const _$InsightCacheImpl({
    required this.context,
    required final List<Insight> insights,
    required this.cachedAt,
    required final Map<String, DateTime> dataTimestamps,
  }) : _insights = insights,
       _dataTimestamps = dataTimestamps;

  factory _$InsightCacheImpl.fromJson(Map<String, dynamic> json) =>
      _$$InsightCacheImplFromJson(json);

  @override
  final InsightContext context;
  final List<Insight> _insights;
  @override
  List<Insight> get insights {
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_insights);
  }

  @override
  final DateTime cachedAt;
  final Map<String, DateTime> _dataTimestamps;
  @override
  Map<String, DateTime> get dataTimestamps {
    if (_dataTimestamps is EqualUnmodifiableMapView) return _dataTimestamps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dataTimestamps);
  }

  @override
  String toString() {
    return 'InsightCache(context: $context, insights: $insights, cachedAt: $cachedAt, dataTimestamps: $dataTimestamps)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InsightCacheImpl &&
            (identical(other.context, context) || other.context == context) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            (identical(other.cachedAt, cachedAt) ||
                other.cachedAt == cachedAt) &&
            const DeepCollectionEquality().equals(
              other._dataTimestamps,
              _dataTimestamps,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    context,
    const DeepCollectionEquality().hash(_insights),
    cachedAt,
    const DeepCollectionEquality().hash(_dataTimestamps),
  );

  /// Create a copy of InsightCache
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InsightCacheImplCopyWith<_$InsightCacheImpl> get copyWith =>
      __$$InsightCacheImplCopyWithImpl<_$InsightCacheImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_InsightCache value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_InsightCache value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_InsightCache value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$InsightCacheImplToJson(this);
  }
}

abstract class _InsightCache implements InsightCache {
  const factory _InsightCache({
    required final InsightContext context,
    required final List<Insight> insights,
    required final DateTime cachedAt,
    required final Map<String, DateTime> dataTimestamps,
  }) = _$InsightCacheImpl;

  factory _InsightCache.fromJson(Map<String, dynamic> json) =
      _$InsightCacheImpl.fromJson;

  @override
  InsightContext get context;
  @override
  List<Insight> get insights;
  @override
  DateTime get cachedAt;
  @override
  Map<String, DateTime> get dataTimestamps;

  /// Create a copy of InsightCache
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InsightCacheImplCopyWith<_$InsightCacheImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

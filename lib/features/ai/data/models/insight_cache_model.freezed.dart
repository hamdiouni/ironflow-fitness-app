// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insight_cache_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InsightCacheModel _$InsightCacheModelFromJson(Map<String, dynamic> json) {
  return _InsightCacheModel.fromJson(json);
}

/// @nodoc
mixin _$InsightCacheModel {
  @HiveField(0)
  String get context => throw _privateConstructorUsedError; // Store context as string
  @HiveField(1)
  List<InsightModel> get insights => throw _privateConstructorUsedError;
  @HiveField(2)
  int get cachedAtMillis => throw _privateConstructorUsedError; // Store as milliseconds since epoch
  @HiveField(3)
  Map<String, int> get dataTimestampsMillis =>
      throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_InsightCacheModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_InsightCacheModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_InsightCacheModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this InsightCacheModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InsightCacheModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InsightCacheModelCopyWith<InsightCacheModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InsightCacheModelCopyWith<$Res> {
  factory $InsightCacheModelCopyWith(
    InsightCacheModel value,
    $Res Function(InsightCacheModel) then,
  ) = _$InsightCacheModelCopyWithImpl<$Res, InsightCacheModel>;
  @useResult
  $Res call({
    @HiveField(0) String context,
    @HiveField(1) List<InsightModel> insights,
    @HiveField(2) int cachedAtMillis,
    @HiveField(3) Map<String, int> dataTimestampsMillis,
  });
}

/// @nodoc
class _$InsightCacheModelCopyWithImpl<$Res, $Val extends InsightCacheModel>
    implements $InsightCacheModelCopyWith<$Res> {
  _$InsightCacheModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InsightCacheModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
    Object? insights = null,
    Object? cachedAtMillis = null,
    Object? dataTimestampsMillis = null,
  }) {
    return _then(
      _value.copyWith(
            context: null == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as String,
            insights: null == insights
                ? _value.insights
                : insights // ignore: cast_nullable_to_non_nullable
                      as List<InsightModel>,
            cachedAtMillis: null == cachedAtMillis
                ? _value.cachedAtMillis
                : cachedAtMillis // ignore: cast_nullable_to_non_nullable
                      as int,
            dataTimestampsMillis: null == dataTimestampsMillis
                ? _value.dataTimestampsMillis
                : dataTimestampsMillis // ignore: cast_nullable_to_non_nullable
                      as Map<String, int>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InsightCacheModelImplCopyWith<$Res>
    implements $InsightCacheModelCopyWith<$Res> {
  factory _$$InsightCacheModelImplCopyWith(
    _$InsightCacheModelImpl value,
    $Res Function(_$InsightCacheModelImpl) then,
  ) = __$$InsightCacheModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @HiveField(0) String context,
    @HiveField(1) List<InsightModel> insights,
    @HiveField(2) int cachedAtMillis,
    @HiveField(3) Map<String, int> dataTimestampsMillis,
  });
}

/// @nodoc
class __$$InsightCacheModelImplCopyWithImpl<$Res>
    extends _$InsightCacheModelCopyWithImpl<$Res, _$InsightCacheModelImpl>
    implements _$$InsightCacheModelImplCopyWith<$Res> {
  __$$InsightCacheModelImplCopyWithImpl(
    _$InsightCacheModelImpl _value,
    $Res Function(_$InsightCacheModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InsightCacheModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? context = null,
    Object? insights = null,
    Object? cachedAtMillis = null,
    Object? dataTimestampsMillis = null,
  }) {
    return _then(
      _$InsightCacheModelImpl(
        context: null == context
            ? _value.context
            : context // ignore: cast_nullable_to_non_nullable
                  as String,
        insights: null == insights
            ? _value._insights
            : insights // ignore: cast_nullable_to_non_nullable
                  as List<InsightModel>,
        cachedAtMillis: null == cachedAtMillis
            ? _value.cachedAtMillis
            : cachedAtMillis // ignore: cast_nullable_to_non_nullable
                  as int,
        dataTimestampsMillis: null == dataTimestampsMillis
            ? _value._dataTimestampsMillis
            : dataTimestampsMillis // ignore: cast_nullable_to_non_nullable
                  as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InsightCacheModelImpl implements _InsightCacheModel {
  const _$InsightCacheModelImpl({
    @HiveField(0) required this.context,
    @HiveField(1) required final List<InsightModel> insights,
    @HiveField(2) required this.cachedAtMillis,
    @HiveField(3) final Map<String, int> dataTimestampsMillis = const {},
  }) : _insights = insights,
       _dataTimestampsMillis = dataTimestampsMillis;

  factory _$InsightCacheModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InsightCacheModelImplFromJson(json);

  @override
  @HiveField(0)
  final String context;
  // Store context as string
  final List<InsightModel> _insights;
  // Store context as string
  @override
  @HiveField(1)
  List<InsightModel> get insights {
    if (_insights is EqualUnmodifiableListView) return _insights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_insights);
  }

  @override
  @HiveField(2)
  final int cachedAtMillis;
  // Store as milliseconds since epoch
  final Map<String, int> _dataTimestampsMillis;
  // Store as milliseconds since epoch
  @override
  @JsonKey()
  @HiveField(3)
  Map<String, int> get dataTimestampsMillis {
    if (_dataTimestampsMillis is EqualUnmodifiableMapView)
      return _dataTimestampsMillis;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dataTimestampsMillis);
  }

  @override
  String toString() {
    return 'InsightCacheModel(context: $context, insights: $insights, cachedAtMillis: $cachedAtMillis, dataTimestampsMillis: $dataTimestampsMillis)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InsightCacheModelImpl &&
            (identical(other.context, context) || other.context == context) &&
            const DeepCollectionEquality().equals(other._insights, _insights) &&
            (identical(other.cachedAtMillis, cachedAtMillis) ||
                other.cachedAtMillis == cachedAtMillis) &&
            const DeepCollectionEquality().equals(
              other._dataTimestampsMillis,
              _dataTimestampsMillis,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    context,
    const DeepCollectionEquality().hash(_insights),
    cachedAtMillis,
    const DeepCollectionEquality().hash(_dataTimestampsMillis),
  );

  /// Create a copy of InsightCacheModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InsightCacheModelImplCopyWith<_$InsightCacheModelImpl> get copyWith =>
      __$$InsightCacheModelImplCopyWithImpl<_$InsightCacheModelImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_InsightCacheModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_InsightCacheModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_InsightCacheModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$InsightCacheModelImplToJson(this);
  }
}

abstract class _InsightCacheModel implements InsightCacheModel {
  const factory _InsightCacheModel({
    @HiveField(0) required final String context,
    @HiveField(1) required final List<InsightModel> insights,
    @HiveField(2) required final int cachedAtMillis,
    @HiveField(3) final Map<String, int> dataTimestampsMillis,
  }) = _$InsightCacheModelImpl;

  factory _InsightCacheModel.fromJson(Map<String, dynamic> json) =
      _$InsightCacheModelImpl.fromJson;

  @override
  @HiveField(0)
  String get context; // Store context as string
  @override
  @HiveField(1)
  List<InsightModel> get insights;
  @override
  @HiveField(2)
  int get cachedAtMillis; // Store as milliseconds since epoch
  @override
  @HiveField(3)
  Map<String, int> get dataTimestampsMillis;

  /// Create a copy of InsightCacheModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InsightCacheModelImplCopyWith<_$InsightCacheModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

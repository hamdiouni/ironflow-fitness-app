// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'insight_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InsightModel _$InsightModelFromJson(Map<String, dynamic> json) {
  return _InsightModel.fromJson(json);
}

/// @nodoc
mixin _$InsightModel {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  int get context => throw _privateConstructorUsedError; // Store as int for Hive compatibility
  @HiveField(2)
  String get title => throw _privateConstructorUsedError;
  @HiveField(3)
  String get message => throw _privateConstructorUsedError;
  @HiveField(4)
  String get icon => throw _privateConstructorUsedError;
  @HiveField(5)
  int get priority => throw _privateConstructorUsedError; // Store as int for Hive compatibility
  @HiveField(6)
  int get generatedAtMillis => throw _privateConstructorUsedError; // Store as milliseconds since epoch
  @HiveField(7)
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_InsightModel value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_InsightModel value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_InsightModel value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this InsightModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InsightModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InsightModelCopyWith<InsightModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InsightModelCopyWith<$Res> {
  factory $InsightModelCopyWith(
    InsightModel value,
    $Res Function(InsightModel) then,
  ) = _$InsightModelCopyWithImpl<$Res, InsightModel>;
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) int context,
    @HiveField(2) String title,
    @HiveField(3) String message,
    @HiveField(4) String icon,
    @HiveField(5) int priority,
    @HiveField(6) int generatedAtMillis,
    @HiveField(7) Map<String, dynamic> metadata,
  });
}

/// @nodoc
class _$InsightModelCopyWithImpl<$Res, $Val extends InsightModel>
    implements $InsightModelCopyWith<$Res> {
  _$InsightModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InsightModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? context = null,
    Object? title = null,
    Object? message = null,
    Object? icon = null,
    Object? priority = null,
    Object? generatedAtMillis = null,
    Object? metadata = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            context: null == context
                ? _value.context
                : context // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as String,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as int,
            generatedAtMillis: null == generatedAtMillis
                ? _value.generatedAtMillis
                : generatedAtMillis // ignore: cast_nullable_to_non_nullable
                      as int,
            metadata: null == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InsightModelImplCopyWith<$Res>
    implements $InsightModelCopyWith<$Res> {
  factory _$$InsightModelImplCopyWith(
    _$InsightModelImpl value,
    $Res Function(_$InsightModelImpl) then,
  ) = __$$InsightModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @HiveField(0) String id,
    @HiveField(1) int context,
    @HiveField(2) String title,
    @HiveField(3) String message,
    @HiveField(4) String icon,
    @HiveField(5) int priority,
    @HiveField(6) int generatedAtMillis,
    @HiveField(7) Map<String, dynamic> metadata,
  });
}

/// @nodoc
class __$$InsightModelImplCopyWithImpl<$Res>
    extends _$InsightModelCopyWithImpl<$Res, _$InsightModelImpl>
    implements _$$InsightModelImplCopyWith<$Res> {
  __$$InsightModelImplCopyWithImpl(
    _$InsightModelImpl _value,
    $Res Function(_$InsightModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InsightModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? context = null,
    Object? title = null,
    Object? message = null,
    Object? icon = null,
    Object? priority = null,
    Object? generatedAtMillis = null,
    Object? metadata = null,
  }) {
    return _then(
      _$InsightModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        context: null == context
            ? _value.context
            : context // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as String,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as int,
        generatedAtMillis: null == generatedAtMillis
            ? _value.generatedAtMillis
            : generatedAtMillis // ignore: cast_nullable_to_non_nullable
                  as int,
        metadata: null == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InsightModelImpl implements _InsightModel {
  const _$InsightModelImpl({
    @HiveField(0) required this.id,
    @HiveField(1) required this.context,
    @HiveField(2) required this.title,
    @HiveField(3) required this.message,
    @HiveField(4) required this.icon,
    @HiveField(5) required this.priority,
    @HiveField(6) required this.generatedAtMillis,
    @HiveField(7) final Map<String, dynamic> metadata = const {},
  }) : _metadata = metadata;

  factory _$InsightModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InsightModelImplFromJson(json);

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final int context;
  // Store as int for Hive compatibility
  @override
  @HiveField(2)
  final String title;
  @override
  @HiveField(3)
  final String message;
  @override
  @HiveField(4)
  final String icon;
  @override
  @HiveField(5)
  final int priority;
  // Store as int for Hive compatibility
  @override
  @HiveField(6)
  final int generatedAtMillis;
  // Store as milliseconds since epoch
  final Map<String, dynamic> _metadata;
  // Store as milliseconds since epoch
  @override
  @JsonKey()
  @HiveField(7)
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'InsightModel(id: $id, context: $context, title: $title, message: $message, icon: $icon, priority: $priority, generatedAtMillis: $generatedAtMillis, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InsightModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.context, context) || other.context == context) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.generatedAtMillis, generatedAtMillis) ||
                other.generatedAtMillis == generatedAtMillis) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    context,
    title,
    message,
    icon,
    priority,
    generatedAtMillis,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of InsightModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InsightModelImplCopyWith<_$InsightModelImpl> get copyWith =>
      __$$InsightModelImplCopyWithImpl<_$InsightModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_InsightModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_InsightModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_InsightModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$InsightModelImplToJson(this);
  }
}

abstract class _InsightModel implements InsightModel {
  const factory _InsightModel({
    @HiveField(0) required final String id,
    @HiveField(1) required final int context,
    @HiveField(2) required final String title,
    @HiveField(3) required final String message,
    @HiveField(4) required final String icon,
    @HiveField(5) required final int priority,
    @HiveField(6) required final int generatedAtMillis,
    @HiveField(7) final Map<String, dynamic> metadata,
  }) = _$InsightModelImpl;

  factory _InsightModel.fromJson(Map<String, dynamic> json) =
      _$InsightModelImpl.fromJson;

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  int get context; // Store as int for Hive compatibility
  @override
  @HiveField(2)
  String get title;
  @override
  @HiveField(3)
  String get message;
  @override
  @HiveField(4)
  String get icon;
  @override
  @HiveField(5)
  int get priority; // Store as int for Hive compatibility
  @override
  @HiveField(6)
  int get generatedAtMillis; // Store as milliseconds since epoch
  @override
  @HiveField(7)
  Map<String, dynamic> get metadata;

  /// Create a copy of InsightModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InsightModelImplCopyWith<_$InsightModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

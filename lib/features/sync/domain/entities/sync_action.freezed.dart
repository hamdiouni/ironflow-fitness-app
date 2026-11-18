// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_action.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SyncAction _$SyncActionFromJson(Map<String, dynamic> json) {
  return _SyncAction.fromJson(json);
}

/// @nodoc
mixin _$SyncAction {
  String get id => throw _privateConstructorUsedError;
  SyncActionType get type => throw _privateConstructorUsedError;
  SyncDataType get dataType => throw _privateConstructorUsedError;
  String get dataId => throw _privateConstructorUsedError;
  Map<String, dynamic> get data => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  SyncStatus get status => throw _privateConstructorUsedError;
  int get retryCount => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SyncAction value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SyncAction value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SyncAction value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this SyncAction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncActionCopyWith<SyncAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncActionCopyWith<$Res> {
  factory $SyncActionCopyWith(
    SyncAction value,
    $Res Function(SyncAction) then,
  ) = _$SyncActionCopyWithImpl<$Res, SyncAction>;
  @useResult
  $Res call({
    String id,
    SyncActionType type,
    SyncDataType dataType,
    String dataId,
    Map<String, dynamic> data,
    DateTime timestamp,
    SyncStatus status,
    int retryCount,
    String? error,
  });
}

/// @nodoc
class _$SyncActionCopyWithImpl<$Res, $Val extends SyncAction>
    implements $SyncActionCopyWith<$Res> {
  _$SyncActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? dataType = null,
    Object? dataId = null,
    Object? data = null,
    Object? timestamp = null,
    Object? status = null,
    Object? retryCount = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as SyncActionType,
            dataType: null == dataType
                ? _value.dataType
                : dataType // ignore: cast_nullable_to_non_nullable
                      as SyncDataType,
            dataId: null == dataId
                ? _value.dataId
                : dataId // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SyncStatus,
            retryCount: null == retryCount
                ? _value.retryCount
                : retryCount // ignore: cast_nullable_to_non_nullable
                      as int,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SyncActionImplCopyWith<$Res>
    implements $SyncActionCopyWith<$Res> {
  factory _$$SyncActionImplCopyWith(
    _$SyncActionImpl value,
    $Res Function(_$SyncActionImpl) then,
  ) = __$$SyncActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    SyncActionType type,
    SyncDataType dataType,
    String dataId,
    Map<String, dynamic> data,
    DateTime timestamp,
    SyncStatus status,
    int retryCount,
    String? error,
  });
}

/// @nodoc
class __$$SyncActionImplCopyWithImpl<$Res>
    extends _$SyncActionCopyWithImpl<$Res, _$SyncActionImpl>
    implements _$$SyncActionImplCopyWith<$Res> {
  __$$SyncActionImplCopyWithImpl(
    _$SyncActionImpl _value,
    $Res Function(_$SyncActionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? dataType = null,
    Object? dataId = null,
    Object? data = null,
    Object? timestamp = null,
    Object? status = null,
    Object? retryCount = null,
    Object? error = freezed,
  }) {
    return _then(
      _$SyncActionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as SyncActionType,
        dataType: null == dataType
            ? _value.dataType
            : dataType // ignore: cast_nullable_to_non_nullable
                  as SyncDataType,
        dataId: null == dataId
            ? _value.dataId
            : dataId // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value._data
            : data // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SyncStatus,
        retryCount: null == retryCount
            ? _value.retryCount
            : retryCount // ignore: cast_nullable_to_non_nullable
                  as int,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncActionImpl implements _SyncAction {
  const _$SyncActionImpl({
    required this.id,
    required this.type,
    required this.dataType,
    required this.dataId,
    required final Map<String, dynamic> data,
    required this.timestamp,
    required this.status,
    this.retryCount = 0,
    this.error,
  }) : _data = data;

  factory _$SyncActionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncActionImplFromJson(json);

  @override
  final String id;
  @override
  final SyncActionType type;
  @override
  final SyncDataType dataType;
  @override
  final String dataId;
  final Map<String, dynamic> _data;
  @override
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  @override
  final DateTime timestamp;
  @override
  final SyncStatus status;
  @override
  @JsonKey()
  final int retryCount;
  @override
  final String? error;

  @override
  String toString() {
    return 'SyncAction(id: $id, type: $type, dataType: $dataType, dataId: $dataId, data: $data, timestamp: $timestamp, status: $status, retryCount: $retryCount, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncActionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.dataType, dataType) ||
                other.dataType == dataType) &&
            (identical(other.dataId, dataId) || other.dataId == dataId) &&
            const DeepCollectionEquality().equals(other._data, _data) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.retryCount, retryCount) ||
                other.retryCount == retryCount) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    dataType,
    dataId,
    const DeepCollectionEquality().hash(_data),
    timestamp,
    status,
    retryCount,
    error,
  );

  /// Create a copy of SyncAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncActionImplCopyWith<_$SyncActionImpl> get copyWith =>
      __$$SyncActionImplCopyWithImpl<_$SyncActionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SyncAction value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SyncAction value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SyncAction value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncActionImplToJson(this);
  }
}

abstract class _SyncAction implements SyncAction {
  const factory _SyncAction({
    required final String id,
    required final SyncActionType type,
    required final SyncDataType dataType,
    required final String dataId,
    required final Map<String, dynamic> data,
    required final DateTime timestamp,
    required final SyncStatus status,
    final int retryCount,
    final String? error,
  }) = _$SyncActionImpl;

  factory _SyncAction.fromJson(Map<String, dynamic> json) =
      _$SyncActionImpl.fromJson;

  @override
  String get id;
  @override
  SyncActionType get type;
  @override
  SyncDataType get dataType;
  @override
  String get dataId;
  @override
  Map<String, dynamic> get data;
  @override
  DateTime get timestamp;
  @override
  SyncStatus get status;
  @override
  int get retryCount;
  @override
  String? get error;

  /// Create a copy of SyncAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncActionImplCopyWith<_$SyncActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SyncStatusEntity _$SyncStatusEntityFromJson(Map<String, dynamic> json) {
  return _SyncStatusEntity.fromJson(json);
}

/// @nodoc
mixin _$SyncStatusEntity {
  bool get isSyncing => throw _privateConstructorUsedError;
  DateTime? get lastSyncTime => throw _privateConstructorUsedError;
  int get pendingActions => throw _privateConstructorUsedError;
  int get failedActions => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SyncStatusEntity value) $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SyncStatusEntity value)? $default,
  ) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SyncStatusEntity value)? $default, {
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Serializes this SyncStatusEntity to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SyncStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SyncStatusEntityCopyWith<SyncStatusEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncStatusEntityCopyWith<$Res> {
  factory $SyncStatusEntityCopyWith(
    SyncStatusEntity value,
    $Res Function(SyncStatusEntity) then,
  ) = _$SyncStatusEntityCopyWithImpl<$Res, SyncStatusEntity>;
  @useResult
  $Res call({
    bool isSyncing,
    DateTime? lastSyncTime,
    int pendingActions,
    int failedActions,
    String? error,
  });
}

/// @nodoc
class _$SyncStatusEntityCopyWithImpl<$Res, $Val extends SyncStatusEntity>
    implements $SyncStatusEntityCopyWith<$Res> {
  _$SyncStatusEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SyncStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSyncing = null,
    Object? lastSyncTime = freezed,
    Object? pendingActions = null,
    Object? failedActions = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            isSyncing: null == isSyncing
                ? _value.isSyncing
                : isSyncing // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastSyncTime: freezed == lastSyncTime
                ? _value.lastSyncTime
                : lastSyncTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            pendingActions: null == pendingActions
                ? _value.pendingActions
                : pendingActions // ignore: cast_nullable_to_non_nullable
                      as int,
            failedActions: null == failedActions
                ? _value.failedActions
                : failedActions // ignore: cast_nullable_to_non_nullable
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
abstract class _$$SyncStatusEntityImplCopyWith<$Res>
    implements $SyncStatusEntityCopyWith<$Res> {
  factory _$$SyncStatusEntityImplCopyWith(
    _$SyncStatusEntityImpl value,
    $Res Function(_$SyncStatusEntityImpl) then,
  ) = __$$SyncStatusEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isSyncing,
    DateTime? lastSyncTime,
    int pendingActions,
    int failedActions,
    String? error,
  });
}

/// @nodoc
class __$$SyncStatusEntityImplCopyWithImpl<$Res>
    extends _$SyncStatusEntityCopyWithImpl<$Res, _$SyncStatusEntityImpl>
    implements _$$SyncStatusEntityImplCopyWith<$Res> {
  __$$SyncStatusEntityImplCopyWithImpl(
    _$SyncStatusEntityImpl _value,
    $Res Function(_$SyncStatusEntityImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SyncStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSyncing = null,
    Object? lastSyncTime = freezed,
    Object? pendingActions = null,
    Object? failedActions = null,
    Object? error = freezed,
  }) {
    return _then(
      _$SyncStatusEntityImpl(
        isSyncing: null == isSyncing
            ? _value.isSyncing
            : isSyncing // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSyncTime: freezed == lastSyncTime
            ? _value.lastSyncTime
            : lastSyncTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        pendingActions: null == pendingActions
            ? _value.pendingActions
            : pendingActions // ignore: cast_nullable_to_non_nullable
                  as int,
        failedActions: null == failedActions
            ? _value.failedActions
            : failedActions // ignore: cast_nullable_to_non_nullable
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
class _$SyncStatusEntityImpl implements _SyncStatusEntity {
  const _$SyncStatusEntityImpl({
    required this.isSyncing,
    required this.lastSyncTime,
    required this.pendingActions,
    required this.failedActions,
    this.error,
  });

  factory _$SyncStatusEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncStatusEntityImplFromJson(json);

  @override
  final bool isSyncing;
  @override
  final DateTime? lastSyncTime;
  @override
  final int pendingActions;
  @override
  final int failedActions;
  @override
  final String? error;

  @override
  String toString() {
    return 'SyncStatusEntity(isSyncing: $isSyncing, lastSyncTime: $lastSyncTime, pendingActions: $pendingActions, failedActions: $failedActions, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncStatusEntityImpl &&
            (identical(other.isSyncing, isSyncing) ||
                other.isSyncing == isSyncing) &&
            (identical(other.lastSyncTime, lastSyncTime) ||
                other.lastSyncTime == lastSyncTime) &&
            (identical(other.pendingActions, pendingActions) ||
                other.pendingActions == pendingActions) &&
            (identical(other.failedActions, failedActions) ||
                other.failedActions == failedActions) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    isSyncing,
    lastSyncTime,
    pendingActions,
    failedActions,
    error,
  );

  /// Create a copy of SyncStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncStatusEntityImplCopyWith<_$SyncStatusEntityImpl> get copyWith =>
      __$$SyncStatusEntityImplCopyWithImpl<_$SyncStatusEntityImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SyncStatusEntity value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SyncStatusEntity value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SyncStatusEntity value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncStatusEntityImplToJson(this);
  }
}

abstract class _SyncStatusEntity implements SyncStatusEntity {
  const factory _SyncStatusEntity({
    required final bool isSyncing,
    required final DateTime? lastSyncTime,
    required final int pendingActions,
    required final int failedActions,
    final String? error,
  }) = _$SyncStatusEntityImpl;

  factory _SyncStatusEntity.fromJson(Map<String, dynamic> json) =
      _$SyncStatusEntityImpl.fromJson;

  @override
  bool get isSyncing;
  @override
  DateTime? get lastSyncTime;
  @override
  int get pendingActions;
  @override
  int get failedActions;
  @override
  String? get error;

  /// Create a copy of SyncStatusEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SyncStatusEntityImplCopyWith<_$SyncStatusEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

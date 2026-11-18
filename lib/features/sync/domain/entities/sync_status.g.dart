// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncStatusEntityImpl _$$SyncStatusEntityImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$SyncStatusEntityImpl', json, ($checkedConvert) {
  final val = _$SyncStatusEntityImpl(
    isSyncing: $checkedConvert('isSyncing', (v) => v as bool),
    lastSyncTime: $checkedConvert(
      'lastSyncTime',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
    pendingActions: $checkedConvert(
      'pendingActions',
      (v) => (v as num).toInt(),
    ),
    failedActions: $checkedConvert('failedActions', (v) => (v as num).toInt()),
    error: $checkedConvert('error', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$$SyncStatusEntityImplToJson(
  _$SyncStatusEntityImpl instance,
) => <String, dynamic>{
  'isSyncing': instance.isSyncing,
  'lastSyncTime': instance.lastSyncTime?.toIso8601String(),
  'pendingActions': instance.pendingActions,
  'failedActions': instance.failedActions,
  'error': instance.error,
};

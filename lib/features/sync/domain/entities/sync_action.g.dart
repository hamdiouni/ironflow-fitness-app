// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_action.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SyncActionImpl _$$SyncActionImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$SyncActionImpl', json, ($checkedConvert) {
  final val = _$SyncActionImpl(
    id: $checkedConvert('id', (v) => v as String),
    type: $checkedConvert(
      'type',
      (v) => $enumDecode(_$SyncActionTypeEnumMap, v),
    ),
    dataType: $checkedConvert(
      'dataType',
      (v) => $enumDecode(_$SyncDataTypeEnumMap, v),
    ),
    dataId: $checkedConvert('dataId', (v) => v as String),
    data: $checkedConvert('data', (v) => v as Map<String, dynamic>),
    timestamp: $checkedConvert('timestamp', (v) => DateTime.parse(v as String)),
    status: $checkedConvert(
      'status',
      (v) => $enumDecode(_$SyncStatusEnumMap, v),
    ),
    retryCount: $checkedConvert('retryCount', (v) => (v as num?)?.toInt() ?? 0),
    error: $checkedConvert('error', (v) => v as String?),
  );
  return val;
});

Map<String, dynamic> _$$SyncActionImplToJson(_$SyncActionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$SyncActionTypeEnumMap[instance.type]!,
      'dataType': _$SyncDataTypeEnumMap[instance.dataType]!,
      'dataId': instance.dataId,
      'data': instance.data,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': _$SyncStatusEnumMap[instance.status]!,
      'retryCount': instance.retryCount,
      'error': instance.error,
    };

const _$SyncActionTypeEnumMap = {
  SyncActionType.create: 'create',
  SyncActionType.update: 'update',
  SyncActionType.delete: 'delete',
};

const _$SyncDataTypeEnumMap = {
  SyncDataType.workout: 'workout',
  SyncDataType.program: 'program',
  SyncDataType.nutrition: 'nutrition',
  SyncDataType.bodyProgress: 'bodyProgress',
  SyncDataType.nutritionTargets: 'nutritionTargets',
};

const _$SyncStatusEnumMap = {
  SyncStatus.pending: 'pending',
  SyncStatus.syncing: 'syncing',
  SyncStatus.completed: 'completed',
  SyncStatus.failed: 'failed',
};

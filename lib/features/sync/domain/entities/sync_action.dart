import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_action.freezed.dart';
part 'sync_action.g.dart';

/// Represents a sync action to be performed
@freezed
class SyncAction with _$SyncAction {
  const factory SyncAction({
    required String id,
    required SyncActionType type,
    required SyncDataType dataType,
    required String dataId,
    required Map<String, dynamic> data,
    required DateTime timestamp,
    required SyncStatus status,
    @Default(0) int retryCount,
    String? error,
  }) = _SyncAction;

  factory SyncAction.fromJson(Map<String, dynamic> json) =>
      _$SyncActionFromJson(json);
}

enum SyncActionType {
  create,
  update,
  delete,
}

enum SyncDataType {
  workout,
  program,
  nutrition,
  bodyProgress,
}

enum SyncStatus {
  pending,
  syncing,
  completed,
  failed,
}

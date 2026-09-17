import 'package:freezed_annotation/freezed_annotation.dart';

part 'sync_operation.freezed.dart';
part 'sync_operation.g.dart';

enum SyncOperationType {
  create,
  update,
  delete,
}

@freezed
class SyncOperation with _$SyncOperation {
  const factory SyncOperation({
    required String id,
    required SyncOperationType type,
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    required DateTime createdAt,
    required int retryCount,
  }) = _SyncOperation;

  factory SyncOperation.fromJson(Map<String, dynamic> json) =>
      _$SyncOperationFromJson(json);
}

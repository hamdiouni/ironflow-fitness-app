import '../../domain/entities/active_program.dart';
import '../../domain/repositories/active_program_repository.dart';
import '../../../sync/domain/entities/sync_action.dart';
import '../../../sync/domain/services/sync_service.dart';
import '../models/active_program_model.dart';

/// Adds an owner-scoped outbox to the local active-program repository.
class SyncedActiveProgramRepository implements ActiveProgramRepository {
  final ActiveProgramRepository _local;
  final SyncService _syncService;
  final String _userId;

  SyncedActiveProgramRepository({
    required ActiveProgramRepository local,
    required SyncService syncService,
    required String userId,
  })  : _local = local,
        _syncService = syncService,
        _userId = userId;

  @override
  Future<void> saveActiveProgram(ActiveProgram program) async {
    final existing = await _local.loadActiveProgram();
    await _local.saveActiveProgram(program);

    if (existing != null && existing.id != program.id) {
      // Keep a cloud state record for the previous program. A soft inactive
      // record lets other devices observe that it was replaced.
      await _queueProgram(
        existing.copyWith(isActive: false),
        SyncActionType.update,
        triggerSync: false,
      );
      await _queueProgram(program, SyncActionType.create);
      return;
    }

    await _queueProgram(
      program,
      existing == null ? SyncActionType.create : SyncActionType.update,
    );
  }

  @override
  Future<ActiveProgram?> loadActiveProgram() => _local.loadActiveProgram();

  @override
  Future<void> clearActiveProgram() async {
    final existing = await _local.loadActiveProgram();
    await _local.clearActiveProgram();
    if (existing != null) {
      await _queueProgram(existing.copyWith(isActive: false), SyncActionType.update);
    }
  }

  @override
  Future<void> updateActiveProgram(ActiveProgram program) async {
    await _local.updateActiveProgram(program);
    await _queueProgram(program, SyncActionType.update);
  }

  Future<void> _queueProgram(
    ActiveProgram program,
    SyncActionType type, {
    bool triggerSync = true,
  }) async {
    final model = ActiveProgramModel.fromEntity(program);
    final data = model.toJson()..['userId'] = _userId;
    await _syncService.queueAction(
      type: type,
      dataType: SyncDataType.program,
      dataId: program.id,
      data: data,
      triggerSync: triggerSync,
    );
  }
}

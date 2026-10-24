import 'package:hive/hive.dart';

import '../../domain/entities/active_program.dart';
import '../../domain/exceptions/workout_exceptions.dart';
import '../../domain/repositories/active_program_repository.dart';
import '../datasources/hive_active_program_datasource.dart';
import '../models/active_program_model.dart';

/// Implementation of [ActiveProgramRepository] using Hive for local storage.
/// 
/// This repository bridges the domain layer with the data layer, converting
/// between domain entities and data models while handling storage exceptions.
/// 
/// **Validates: Requirements 7.2, 10.1, Error handling**
class ActiveProgramRepositoryImpl implements ActiveProgramRepository {
  final HiveActiveProgramDataSource dataSource;

  /// Owner stamped onto programs that don't already carry one (Phase 1).
  /// Optional so existing single-argument constructions (tests) still work.
  final String? userId;

  /// Outbox hook (Phase 2): invoked with the stamped program after every
  /// successful local save/update so the composition root can enqueue a
  /// sync action. Errors are swallowed — sync must never break a local
  /// save. Optional; tests construct without it.
  final Future<void> Function(ActiveProgram program)? onProgramSaved;

  ActiveProgramRepositoryImpl(this.dataSource, {this.userId, this.onProgramSaved});

  /// Stamps userId onto the ActiveProgram and its embedded program when
  /// missing, so workouts started from it inherit a real owner, and bumps
  /// updatedAt (Phase 2 LWW key for program sync).
  ActiveProgram _stamp(ActiveProgram program) {
    var result = program.copyWith(updatedAt: DateTime.now());
    if (userId == null) return result;
    if (result.userId == null) {
      result = result.copyWith(userId: userId);
    }
    if (result.program.userId == null) {
      result = result.copyWith(
        program: result.program.copyWith(userId: userId),
      );
    }
    return result;
  }

  Future<void> _notifySaved(ActiveProgram program) async {
    final callback = onProgramSaved;
    if (callback == null) return;
    try {
      await callback(program);
    } catch (_) {
      // Outbox enqueue is best-effort relative to the local save, which
      // has already succeeded; the next save re-enqueues full state.
    }
  }

  @override
  Future<void> saveActiveProgram(ActiveProgram program) async {
    try {
      final stamped = _stamp(program);
      final model = ActiveProgramModel.fromEntity(stamped);
      await dataSource.saveActiveProgram(model, userId: userId);
      await _notifySaved(stamped);
    } on HiveError catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'Unable to save your workout program. Please try again.',
        cause: Exception(e.toString()),
        stackTrace: stackTrace,
      );
    } on FormatException catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'Your program data is corrupted. Please regenerate your program.',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'An unexpected error occurred while saving your program.',
        cause: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<ActiveProgram?> loadActiveProgram() async {
    try {
      final model = await dataSource.loadActiveProgram(userId: userId);
      return model?.toEntity();
    } on HiveError catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'Unable to load your workout program. Please try again.',
        cause: Exception(e.toString()),
        stackTrace: stackTrace,
      );
    } on FormatException catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'Your program data is corrupted. Please regenerate your program.',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'An unexpected error occurred while loading your program.',
        cause: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearActiveProgram() async {
    try {
      await dataSource.clearActiveProgram(userId: userId);
    } on HiveError catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'Unable to clear your workout program. Please try again.',
        cause: Exception(e.toString()),
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'An unexpected error occurred while clearing your program.',
        cause: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateActiveProgram(ActiveProgram program) async {
    try {
      final stamped = _stamp(program);
      final model = ActiveProgramModel.fromEntity(stamped);
      await dataSource.saveActiveProgram(model, userId: userId);
      await _notifySaved(stamped);
    } on HiveError catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'Unable to update your workout program. Please try again.',
        cause: Exception(e.toString()),
        stackTrace: stackTrace,
      );
    } on FormatException catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'Your program data is corrupted. Please regenerate your program.',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ActiveProgramException(
        message: 'An unexpected error occurred while updating your program.',
        cause: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> archiveCurrentProgram() async {
    try {
      await dataSource.archiveCurrentProgram(userId: userId);
    } catch (_) {}
  }

  @override
  Future<ActiveProgram?> restoreArchivedProgram() async {
    try {
      final model = await dataSource.restoreArchivedProgram(userId: userId);
      return model?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> hasArchivedProgram() async {
    try {
      return await dataSource.hasArchivedProgram(userId: userId);
    } catch (_) {
      return false;
    }
  }
}

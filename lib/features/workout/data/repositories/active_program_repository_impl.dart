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

  ActiveProgramRepositoryImpl(this.dataSource);

  @override
  Future<void> saveActiveProgram(ActiveProgram program) async {
    try {
      final model = ActiveProgramModel.fromEntity(program);
      await dataSource.saveActiveProgram(model);
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
      final model = await dataSource.loadActiveProgram();
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
      await dataSource.clearActiveProgram();
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
      final model = ActiveProgramModel.fromEntity(program);
      await dataSource.saveActiveProgram(model);
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
}

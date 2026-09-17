import 'package:hive/hive.dart';

import '../../domain/entities/diet_plan_state.dart';
import '../../domain/repositories/diet_plan_repository.dart';
import '../datasources/hive_diet_plan_datasource.dart';
import '../models/diet_plan_state_model.dart';
import '../../domain/exceptions/diet_plan_exceptions.dart';

/// Implementation of [DietPlanRepository] using Hive for local storage.
/// 
/// This repository bridges the domain layer with the data layer, converting
/// between domain entities and data models while handling storage exceptions.
/// 
/// **Validates: Requirements 7.2, 10.1, Error handling**
class DietPlanRepositoryImpl implements DietPlanRepository {
  final HiveDietPlanDataSource dataSource;

  DietPlanRepositoryImpl(this.dataSource);

  @override
  Future<void> saveDietPlan(DietPlanState planState) async {
    try {
      final model = DietPlanStateModel.fromEntity(planState);
      await dataSource.saveDietPlan(model);
    } on HiveError catch (e, stackTrace) {
      throw DietPlanException(
        message: 'Unable to save your diet plan. Please try again.',
        cause: Exception(e.toString()),
        stackTrace: stackTrace,
      );
    } on FormatException catch (e, stackTrace) {
      throw DietPlanException(
        message: 'Your diet plan data is corrupted. Please regenerate your plan.',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DietPlanException(
        message: 'An unexpected error occurred while saving your diet plan.',
        cause: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<DietPlanState?> loadDietPlan() async {
    try {
      final model = await dataSource.loadDietPlan();
      return model?.toEntity();
    } on HiveError catch (e, stackTrace) {
      throw DietPlanException(
        message: 'Unable to load your diet plan. Please try again.',
        cause: Exception(e.toString()),
        stackTrace: stackTrace,
      );
    } on FormatException catch (e, stackTrace) {
      throw DietPlanException(
        message: 'Your diet plan data is corrupted. Please regenerate your plan.',
        cause: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DietPlanException(
        message: 'An unexpected error occurred while loading your diet plan.',
        cause: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> clearDietPlan() async {
    try {
      await dataSource.clearDietPlan();
    } on HiveError catch (e, stackTrace) {
      throw DietPlanException(
        message: 'Unable to clear your diet plan. Please try again.',
        cause: Exception(e.toString()),
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw DietPlanException(
        message: 'An unexpected error occurred while clearing your diet plan.',
        cause: e is Exception ? e : Exception(e.toString()),
        stackTrace: stackTrace,
      );
    }
  }
}

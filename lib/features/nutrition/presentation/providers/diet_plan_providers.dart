import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/hive_diet_plan_datasource.dart';
import '../../data/repositories/diet_plan_repository_impl.dart';
import '../../domain/entities/diet_plan_state.dart';
import '../../domain/repositories/diet_plan_repository.dart';
import '../../domain/usecases/save_diet_plan_use_case.dart';
import '../../domain/usecases/swap_diet_meal_use_case.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

/// Provider for the DietPlanRepository.
/// 
/// This provider creates and manages the repository instance that handles
/// diet plan persistence using Hive local storage.
/// 
/// **Validates: Requirements 7.1, 9.1**
final dietPlanRepositoryProvider = Provider<DietPlanRepository>((ref) {
  final dataSource = HiveDietPlanDataSource();
  return DietPlanRepositoryImpl(dataSource);
});

// ---------------------------------------------------------------------------
// Use Case Providers
// ---------------------------------------------------------------------------

/// Provider for SaveDietPlanUseCase.
/// 
/// This use case saves a diet plan by creating a DietPlanState and persisting it.
/// 
/// **Validates: Requirements 7.2, 9.2**
final saveDietPlanUseCaseProvider = Provider<SaveDietPlanUseCase>((ref) {
  final repository = ref.watch(dietPlanRepositoryProvider);
  return SaveDietPlanUseCase(repository);
});

/// Provider for SwapDietMealUseCase.
/// 
/// This use case swaps a meal in the diet plan with an alternative.
/// 
/// **Validates: Requirements 7.2, 9.2**
final swapDietMealUseCaseProvider = Provider<SwapDietMealUseCase>((ref) {
  final repository = ref.watch(dietPlanRepositoryProvider);
  return SwapDietMealUseCase(repository);
});

// ---------------------------------------------------------------------------
// Diet Plan State Provider
// ---------------------------------------------------------------------------

/// FutureProvider for loading the active diet plan.
/// 
/// This provider loads the diet plan from persistent storage and returns
/// it as a DietPlanState. Returns null if no diet plan exists.
/// 
/// **Validates: Requirements 7.5, 9.3**
final dietPlanProvider = FutureProvider<DietPlanState?>((ref) async {
  final repository = ref.watch(dietPlanRepositoryProvider);
  return await repository.loadDietPlan();
});

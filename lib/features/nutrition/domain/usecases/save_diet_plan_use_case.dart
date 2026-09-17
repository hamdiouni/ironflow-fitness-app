import '../entities/diet_plan.dart';
import '../entities/diet_plan_state.dart';
import '../repositories/diet_plan_repository.dart';

/// Saves a diet plan by creating a DietPlanState and persisting it.
/// 
/// **Validates: Requirements 6.1, 15.1**
class SaveDietPlanUseCase {
  final DietPlanRepository repository;

  SaveDietPlanUseCase(this.repository);

  Future<void> call(DietPlan plan) async {
    final planState = DietPlanState(
      plan: plan,
      mealSwaps: {},
      lastUpdated: DateTime.now(),
    );
    
    await repository.saveDietPlan(planState);
  }
}

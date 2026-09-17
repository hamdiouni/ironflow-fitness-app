import '../entities/diet_plan.dart';
import '../repositories/diet_plan_repository.dart';

/// Swaps a meal in the diet plan with an alternative.
/// 
/// **Validates: Requirements 6.1, 15.1**
class SwapDietMealUseCase {
  final DietPlanRepository repository;

  SwapDietMealUseCase(this.repository);

  Future<void> call(String dayName, MealType mealType, DietMeal newMeal) async {
    final currentState = await repository.loadDietPlan();
    
    if (currentState == null) {
      throw StateError('No diet plan found. Please save a diet plan first.');
    }
    
    final updatedState = currentState.swapMeal(dayName, mealType, newMeal);
    await repository.saveDietPlan(updatedState);
  }
}

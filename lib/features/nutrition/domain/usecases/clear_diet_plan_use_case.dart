import '../repositories/diet_plan_repository.dart';

/// Clears the saved diet plan from persistent storage.
class ClearDietPlanUseCase {
  final DietPlanRepository repository;

  const ClearDietPlanUseCase(this.repository);

  Future<void> call() async {
    await repository.clearDietPlan();
  }
}

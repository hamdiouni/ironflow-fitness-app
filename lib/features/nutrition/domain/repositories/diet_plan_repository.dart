import '../entities/diet_plan_state.dart';

/// Repository interface for persisting and retrieving diet plan state.
/// 
/// **Validates: Requirements 6.1**
abstract class DietPlanRepository {
  /// Save the current diet plan state to persistent storage.
  Future<void> saveDietPlan(DietPlanState planState);

  /// Load the saved diet plan state from persistent storage.
  /// Returns null if no saved plan exists.
  Future<DietPlanState?> loadDietPlan();

  /// Clear the saved diet plan from persistent storage.
  Future<void> clearDietPlan();
}

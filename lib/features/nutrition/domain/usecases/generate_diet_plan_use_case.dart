import '../../../onboarding/domain/entities/user_profile.dart';
import '../entities/diet_plan.dart';
import 'build_suggested_meal_plan_use_case.dart';

/// Generates a personalized diet plan based on user profile.
/// Uses [BuildSuggestedMealPlanUseCase] with verified USDA foods.
class GenerateDietPlanUseCase {
  final BuildSuggestedMealPlanUseCase _builder;

  const GenerateDietPlanUseCase([this._builder = const BuildSuggestedMealPlanUseCase()]);

  DietPlan call(UserProfile profile) {
    return _builder(profile);
  }
}

import '../entities/entities.dart';
import '../repositories/nutrition_repository.dart';

/// Retrieves all meals for a given date and assembles a [DailyNutritionSummary]
/// with calculated totals and remaining macro budget.
///
/// Falls back to sensible defaults (150g protein / 200g carbs / 60g fats) when
/// the user has not yet configured a [MacroTarget].
class GetDailyNutritionSummaryUseCase {
  final NutritionRepository repository;

  GetDailyNutritionSummaryUseCase(this.repository);

  Future<DailyNutritionSummary> call(DateTime date) async {
    final meals = await repository.getMealsByDate(date);
    final target = await repository.getMacroTarget() ??
        const MacroTarget(protein: 150, carbs: 200, fats: 60);

    return DailyNutritionSummary(
      date: date,
      meals: meals,
      target: target,
    );
  }
}

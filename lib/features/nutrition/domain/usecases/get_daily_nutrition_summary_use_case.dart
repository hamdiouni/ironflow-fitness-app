import '../entities/entities.dart';
import '../repositories/nutrition_repository.dart';

/// Retrieves all meals for a given date and assembles a [DailyNutritionSummary]
/// with calculated totals and remaining macro budget.
///
/// If the user has not yet configured [NutritionTargets], the summary's target
/// is null and [DailyNutritionSummary.remainingMacros] reports zero.
class GetDailyNutritionSummaryUseCase {
  final NutritionRepository repository;

  GetDailyNutritionSummaryUseCase(this.repository);

  Future<DailyNutritionSummary> call(DateTime date) async {
    final meals = await repository.getMealsByDate(date);
    final target = await repository.getNutritionTargets();

    return DailyNutritionSummary(
      date: date,
      meals: meals,
      target: target,
    );
  }
}

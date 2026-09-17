import '../entities/entities.dart';
import '../repositories/nutrition_repository.dart';

/// Persists a meal entry to local storage.
class SaveMealUseCase {
  final NutritionRepository repository;

  SaveMealUseCase(this.repository);

  Future<void> call(Meal meal) async {
    await repository.saveMeal(meal);
  }
}

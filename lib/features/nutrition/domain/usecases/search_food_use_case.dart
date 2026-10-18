import '../../../onboarding/domain/entities/user_profile.dart' show BudgetLevel;
import '../entities/food_item.dart';
import '../../data/food_database.dart';

class SearchFoodUseCase {
  List<FoodItem> call({
    String? query,
    FoodCategory? category,
    BudgetLevel? budgetTier,
  }) {
    var results = FoodDatabase.foods;
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      results =
          results.where((f) => f.name.toLowerCase().contains(q)).toList();
    }
    if (category != null) {
      results = results.where((f) => f.category == category).toList();
    }
    if (budgetTier != null) {
      results = results.where((f) => f.budgetTier == budgetTier).toList();
    }
    return results;
  }
}

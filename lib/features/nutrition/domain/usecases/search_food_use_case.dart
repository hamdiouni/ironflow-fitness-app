import '../entities/food_item.dart';
import '../../data/food_database.dart';

class SearchFoodUseCase {
  List<FoodItem> call({String? query, FoodCategory? category}) {
    var results = FoodDatabase.foods;
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((f) => f.name.toLowerCase().contains(q)).toList();
    }
    if (category != null) {
      results = results.where((f) => f.category == category).toList();
    }
    return results;
  }
}

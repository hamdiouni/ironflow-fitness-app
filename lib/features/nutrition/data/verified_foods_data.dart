import '../domain/entities/food_item.dart';
import '../domain/services/food_catalog.dart';

/// Backward-compatible alias to [FoodCatalog.verifiedFoods] (Wave 3.3).
List<FoodItem> get verifiedFoodsList => FoodCatalog.verifiedFoods;

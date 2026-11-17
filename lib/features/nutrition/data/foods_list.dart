import '../domain/entities/food_item.dart';
import '../domain/services/food_catalog.dart';

/// Backward-compatible alias to [FoodCatalog.foods] (Wave 3.4).
List<FoodItem> get foodsList => FoodCatalog.foods;

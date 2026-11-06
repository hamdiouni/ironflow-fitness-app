import '../domain/entities/food_item.dart';
import '../domain/services/food_catalog.dart';

/// Backward-compatible alias to [kSupplementaryFoodsList] (Wave 3.4).
final List<FoodItem> foodsList = List<FoodItem>.from(kSupplementaryFoodsList);

/// A personalized diet plan generated based on user profile.
class DietPlan {
  const DietPlan({
    required this.name,
    required this.dailyCalories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.days,
    required this.tips,
  });

  final String name;
  final double dailyCalories;
  final double proteinG;
  final double carbsG;
  final double fatsG;
  final List<DietDay> days;
  final List<String> tips;
}

class DietDay {
  const DietDay({
    required this.dayName,
    required this.meals,
  });

  final String dayName;
  final List<DietMeal> meals;
}

class DietMeal {
  const DietMeal({
    required this.mealType,
    required this.name,
    required this.ingredients,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    this.prepTime,
    this.alternatives = const [],
  });

  final MealType mealType;
  final String name;
  final List<String> ingredients;
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatsG;
  final String? prepTime;
  final List<String> alternatives;
}

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  String get displayName => switch (this) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snack',
      };

  String get emoji => switch (this) {
        MealType.breakfast => '🌅',
        MealType.lunch => '☀️',
        MealType.dinner => '🌙',
        MealType.snack => '🍎',
      };
}

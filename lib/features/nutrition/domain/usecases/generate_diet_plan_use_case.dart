import '../../../onboarding/domain/entities/user_profile.dart';
import '../entities/diet_plan.dart';

/// Generates a personalized diet plan based on user profile.
/// Rule-based, no AI required.
class GenerateDietPlanUseCase {
  DietPlan call(UserProfile profile) {
    final calories = profile.dailyCalorieTarget;
    final protein = _proteinTarget(profile);
    final fats = _fatsTarget(calories);
    final carbs = _carbsTarget(calories, protein, fats);

    return DietPlan(
      name: _planName(profile),
      dailyCalories: calories,
      proteinG: protein,
      carbsG: carbs,
      fatsG: fats,
      days: _generateDays(profile, calories),
      tips: _tips(profile),
    );
  }

  double _proteinTarget(UserProfile profile) {
    // 1.6–2.2g per kg bodyweight for muscle gain, 1.2–1.6g for others
    final multiplier = switch (profile.goal) {
      FitnessGoal.gainMuscle => 2.0,
      FitnessGoal.loseWeight => 1.8,
      FitnessGoal.maintain => 1.5,
    };
    return profile.weightKg * multiplier;
  }

  double _fatsTarget(double calories) => (calories * 0.25) / 9;

  double _carbsTarget(double calories, double protein, double fats) {
    final remaining = calories - (protein * 4) - (fats * 9);
    return remaining / 4;
  }

  String _planName(UserProfile profile) => switch (profile.goal) {
        FitnessGoal.gainMuscle => 'Muscle Building Diet',
        FitnessGoal.loseWeight => 'Fat Loss Diet',
        FitnessGoal.maintain => 'Maintenance Diet',
      };

  List<DietDay> _generateDays(UserProfile profile, double calories) {
    final isLow = profile.budget == BudgetLevel.low;
    final isHigh = profile.budget == BudgetLevel.high;
    final isMuscle = profile.goal == FitnessGoal.gainMuscle;
    final isCut = profile.goal == FitnessGoal.loseWeight;

    // Generate 3 sample days
    return [
      DietDay(
        dayName: 'Day 1',
        meals: _day1Meals(isLow, isHigh, isMuscle, isCut, calories),
      ),
      DietDay(
        dayName: 'Day 2',
        meals: _day2Meals(isLow, isHigh, isMuscle, isCut, calories),
      ),
      DietDay(
        dayName: 'Day 3',
        meals: _day3Meals(isLow, isHigh, isMuscle, isCut, calories),
      ),
    ];
  }

  List<DietMeal> _day1Meals(bool isLow, bool isHigh, bool isMuscle, bool isCut, double calories) {
    return [
      DietMeal(
        mealType: MealType.breakfast,
        name: isHigh ? 'Greek Yogurt Protein Bowl' : 'Scrambled Eggs & Toast',
        ingredients: isHigh
            ? ['200g Greek yogurt', '1 scoop protein powder', '50g granola', '100g berries', '1 tbsp honey']
            : ['3 eggs', '2 slices whole wheat bread', '1 tbsp butter', 'Salt & pepper'],
        calories: isCut ? 350 : 450,
        proteinG: isHigh ? 40 : 25,
        carbsG: isHigh ? 45 : 35,
        fatsG: isHigh ? 8 : 15,
        prepTime: '10 min',
        alternatives: isLow ? ['Oats with milk', 'Bread with peanut butter'] : ['Protein pancakes', 'Overnight oats'],
      ),
      DietMeal(
        mealType: MealType.lunch,
        name: isLow ? 'Rice & Chicken' : 'Grilled Chicken & Quinoa',
        ingredients: isLow
            ? ['150g chicken breast', '200g cooked rice', '1 tbsp olive oil', 'Spices']
            : ['180g chicken breast', '150g quinoa', '100g broccoli', '1 tbsp olive oil', 'Lemon'],
        calories: isCut ? 450 : 600,
        proteinG: 40,
        carbsG: isLow ? 60 : 50,
        fatsG: 12,
        prepTime: '20 min',
        alternatives: ['Tuna with rice', 'Turkey sandwich'],
      ),
      if (isMuscle)
        DietMeal(
          mealType: MealType.snack,
          name: isHigh ? 'Protein Shake & Banana' : 'Cottage Cheese & Fruit',
          ingredients: isHigh
              ? ['1 scoop whey protein', '250ml milk', '1 banana']
              : ['200g cottage cheese', '1 apple', '10g almonds'],
          calories: 250,
          proteinG: 30,
          carbsG: 25,
          fatsG: 5,
          prepTime: '2 min',
          alternatives: ['Hard boiled eggs', 'Greek yogurt'],
        ),
      DietMeal(
        mealType: MealType.dinner,
        name: isLow ? 'Tuna Pasta' : 'Salmon & Sweet Potato',
        ingredients: isLow
            ? ['1 can tuna', '150g pasta', '1 tbsp olive oil', 'Garlic', 'Tomato sauce']
            : ['180g salmon fillet', '200g sweet potato', '100g green beans', '1 tbsp olive oil'],
        calories: isCut ? 400 : 550,
        proteinG: 35,
        carbsG: isLow ? 55 : 45,
        fatsG: isLow ? 10 : 18,
        prepTime: '25 min',
        alternatives: ['Beef stir fry', 'Lentil soup'],
      ),
    ];
  }

  List<DietMeal> _day2Meals(bool isLow, bool isHigh, bool isMuscle, bool isCut, double calories) {
    return [
      DietMeal(
        mealType: MealType.breakfast,
        name: 'Oatmeal with Protein',
        ingredients: isHigh
            ? ['80g oats', '1 scoop protein powder', '200ml almond milk', '1 banana', '1 tbsp peanut butter']
            : ['80g oats', '200ml milk', '1 banana', '1 tbsp honey'],
        calories: isCut ? 380 : 480,
        proteinG: isHigh ? 35 : 15,
        carbsG: 65,
        fatsG: 10,
        prepTime: '5 min',
        alternatives: ['Eggs & toast', 'Yogurt parfait'],
      ),
      DietMeal(
        mealType: MealType.lunch,
        name: isLow ? 'Egg Fried Rice' : 'Turkey & Veggie Wrap',
        ingredients: isLow
            ? ['3 eggs', '200g cooked rice', '1 tbsp soy sauce', 'Mixed vegetables', '1 tbsp oil']
            : ['150g turkey breast', '1 large wrap', '50g lettuce', '1 tomato', '30g hummus'],
        calories: isCut ? 420 : 550,
        proteinG: 30,
        carbsG: 55,
        fatsG: 14,
        prepTime: '15 min',
        alternatives: ['Chicken salad', 'Bean burrito'],
      ),
      if (isMuscle)
        DietMeal(
          mealType: MealType.snack,
          name: 'Nuts & Dried Fruit',
          ingredients: ['30g mixed nuts', '30g dried fruit', '1 glass milk'],
          calories: 280,
          proteinG: 10,
          carbsG: 30,
          fatsG: 15,
          prepTime: '1 min',
          alternatives: ['Rice cakes with peanut butter', 'Protein bar'],
        ),
      DietMeal(
        mealType: MealType.dinner,
        name: isLow ? 'Chicken & Vegetables' : 'Beef Stir Fry',
        ingredients: isLow
            ? ['200g chicken thigh', '200g mixed vegetables', '1 tbsp oil', 'Spices']
            : ['180g lean beef', '200g mixed vegetables', '100g noodles', '2 tbsp soy sauce', '1 tbsp sesame oil'],
        calories: isCut ? 380 : 520,
        proteinG: 38,
        carbsG: isLow ? 20 : 45,
        fatsG: isLow ? 15 : 16,
        prepTime: '20 min',
        alternatives: ['Grilled fish', 'Lentil curry'],
      ),
    ];
  }

  List<DietMeal> _day3Meals(bool isLow, bool isHigh, bool isMuscle, bool isCut, double calories) {
    return [
      DietMeal(
        mealType: MealType.breakfast,
        name: isLow ? 'Bread & Peanut Butter' : 'Avocado Toast & Eggs',
        ingredients: isLow
            ? ['3 slices bread', '2 tbsp peanut butter', '1 banana', '1 glass milk']
            : ['2 slices sourdough', '1 avocado', '2 poached eggs', 'Cherry tomatoes', 'Salt & pepper'],
        calories: isCut ? 360 : 460,
        proteinG: isLow ? 18 : 22,
        carbsG: isLow ? 55 : 40,
        fatsG: isLow ? 12 : 22,
        prepTime: '10 min',
        alternatives: ['Cereal with milk', 'Smoothie bowl'],
      ),
      DietMeal(
        mealType: MealType.lunch,
        name: 'Tuna Salad',
        ingredients: ['1 can tuna', '100g mixed greens', '1 tomato', '1 cucumber', '1 tbsp olive oil', 'Lemon juice'],
        calories: isCut ? 300 : 400,
        proteinG: 35,
        carbsG: 15,
        fatsG: 12,
        prepTime: '10 min',
        alternatives: ['Chicken Caesar salad', 'Egg salad sandwich'],
      ),
      if (isMuscle)
        DietMeal(
          mealType: MealType.snack,
          name: 'Rice Cakes & Peanut Butter',
          ingredients: ['4 rice cakes', '2 tbsp peanut butter', '1 glass milk'],
          calories: 300,
          proteinG: 12,
          carbsG: 35,
          fatsG: 14,
          prepTime: '2 min',
          alternatives: ['Protein shake', 'Banana & almonds'],
        ),
      DietMeal(
        mealType: MealType.dinner,
        name: isHigh ? 'Grilled Steak & Asparagus' : 'Baked Chicken & Rice',
        ingredients: isHigh
            ? ['200g sirloin steak', '200g asparagus', '150g sweet potato', '1 tbsp butter', 'Garlic']
            : ['200g chicken breast', '200g cooked rice', '100g broccoli', '1 tbsp olive oil', 'Spices'],
        calories: isCut ? 420 : 580,
        proteinG: 45,
        carbsG: isHigh ? 35 : 55,
        fatsG: isHigh ? 20 : 12,
        prepTime: '30 min',
        alternatives: ['Pork tenderloin', 'Tofu stir fry'],
      ),
    ];
  }

  List<String> _tips(UserProfile profile) {
    final tips = <String>[];
    switch (profile.goal) {
      case FitnessGoal.gainMuscle:
        tips.addAll([
          'Eat within 30 minutes after training for optimal recovery',
          'Aim for 0.8–1g of protein per pound of bodyweight',
          'Don\'t skip carbs — they fuel your workouts',
          'Eat in a slight calorie surplus (200–300 kcal above maintenance)',
        ]);
      case FitnessGoal.loseWeight:
        tips.addAll([
          'Prioritize protein to preserve muscle while cutting',
          'Drink 2–3L of water daily to reduce hunger',
          'Eat slowly and mindfully to avoid overeating',
          'Don\'t cut calories too aggressively — aim for 500 kcal deficit max',
        ]);
      case FitnessGoal.maintain:
        tips.addAll([
          'Track your weight weekly to stay on target',
          'Focus on food quality, not just quantity',
          'Include a variety of vegetables for micronutrients',
          'Allow yourself occasional treats to stay consistent',
        ]);
    }
    if (profile.budget == BudgetLevel.low) {
      tips.add('Buy in bulk: rice, oats, eggs, and canned tuna are cheap and nutritious');
      tips.add('Frozen vegetables are just as nutritious as fresh and much cheaper');
    }
    return tips;
  }
}

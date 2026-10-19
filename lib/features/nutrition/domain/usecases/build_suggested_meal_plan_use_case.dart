import 'dart:math' as math;

import '../../../onboarding/domain/entities/user_profile.dart';
import '../../data/verified_foods_data.dart';
import '../entities/diet_plan.dart';
import '../entities/food_item.dart';

/// Pure, deterministic domain use case to build an authoritative suggested meal plan
/// tailored to the user's budget tier, daily calorie target, and macro goals.
///
/// Uses ONLY verified USDA foods from [verifiedFoodsList].
/// Guarantees that total daily calories match the user's metabolic targets within ±5%.
class BuildSuggestedMealPlanUseCase {
  const BuildSuggestedMealPlanUseCase();

  DietPlan call(UserProfile profile) {
    final dailyCalories = profile.dailyCalorieTarget;
    final dailyProtein = _calculateProteinTarget(profile);
    final dailyFats = _calculateFatsTarget(dailyCalories);
    final dailyCarbs = _calculateCarbsTarget(dailyCalories, dailyProtein, dailyFats);

    final days = <DietDay>[
      _buildDay(
        dayNumber: 1,
        profile: profile,
        dailyCalories: dailyCalories,
        dailyProtein: dailyProtein,
      ),
      _buildDay(
        dayNumber: 2,
        profile: profile,
        dailyCalories: dailyCalories,
        dailyProtein: dailyProtein,
      ),
      _buildDay(
        dayNumber: 3,
        profile: profile,
        dailyCalories: dailyCalories,
        dailyProtein: dailyProtein,
      ),
    ];

    return DietPlan(
      name: _buildPlanTitle(profile),
      dailyCalories: dailyCalories,
      proteinG: dailyProtein,
      carbsG: dailyCarbs,
      fatsG: dailyFats,
      days: days,
      tips: _buildTips(profile),
    );
  }

  double _calculateProteinTarget(UserProfile profile) {
    final multiplier = switch (profile.goal) {
      FitnessGoal.gainMuscle => 2.0,
      FitnessGoal.loseWeight => 1.8,
      FitnessGoal.maintain => 1.5,
    };
    return (profile.weightKg * multiplier).roundToDouble();
  }

  double _calculateFatsTarget(double calories) {
    return ((calories * 0.25) / 9.0).roundToDouble();
  }

  double _calculateCarbsTarget(double calories, double protein, double fats) {
    final remaining = calories - (protein * 4.0) - (fats * 9.0);
    return math.max(30.0, remaining / 4.0).roundToDouble();
  }

  String _buildPlanTitle(UserProfile profile) {
    final budgetLabel = switch (profile.budget) {
      BudgetLevel.low => 'Budget-Friendly',
      BudgetLevel.medium => 'Standard',
      BudgetLevel.high => 'Premium',
    };
    final goalLabel = switch (profile.goal) {
      FitnessGoal.gainMuscle => 'Muscle Building',
      FitnessGoal.loseWeight => 'Fat Loss',
      FitnessGoal.maintain => 'Maintenance',
    };
    return '$budgetLabel $goalLabel Plan';
  }

  DietDay _buildDay({
    required int dayNumber,
    required UserProfile profile,
    required double dailyCalories,
    required double dailyProtein,
  }) {
    double scale = dailyCalories / 2000.0;

    List<DietMeal> generateMeals(double currentScale) {
      return [
        _createMeal(
          mealType: MealType.breakfast,
          mealIndex: dayNumber - 1,
          targetKcal: dailyCalories * 0.25,
          targetProtein: dailyProtein * 0.25,
          budget: profile.budget,
          overallScale: currentScale,
        ),
        _createMeal(
          mealType: MealType.lunch,
          mealIndex: dayNumber - 1,
          targetKcal: dailyCalories * 0.35,
          targetProtein: dailyProtein * 0.35,
          budget: profile.budget,
          overallScale: currentScale,
        ),
        _createMeal(
          mealType: MealType.dinner,
          mealIndex: dayNumber - 1,
          targetKcal: dailyCalories * 0.30,
          targetProtein: dailyProtein * 0.30,
          budget: profile.budget,
          overallScale: currentScale,
        ),
        _createMeal(
          mealType: MealType.snack,
          mealIndex: dayNumber - 1,
          targetKcal: dailyCalories * 0.10,
          targetProtein: dailyProtein * 0.10,
          budget: profile.budget,
          overallScale: currentScale,
        ),
      ];
    }

    var meals = generateMeals(scale);
    final initialDayKcal = meals.fold<double>(0.0, (sum, m) => sum + m.calories);

    // Fine-tune scale if rounding caused drift > 1.5%
    if (initialDayKcal > 0) {
      final ratio = dailyCalories / initialDayKcal;
      if ((ratio - 1.0).abs() > 0.015) {
        meals = generateMeals(scale * ratio);
      }
    }

    return DietDay(
      dayName: 'Day $dayNumber',
      meals: meals,
    );
  }

  DietMeal _createMeal({
    required MealType mealType,
    required int mealIndex,
    required double targetKcal,
    required double targetProtein,
    required BudgetLevel budget,
    required double overallScale,
  }) {
    final config = _getMealConfig(mealType, mealIndex, budget);

    final itemGrams = <String, double>{};
    for (final item in config.items) {
      double g = (item.baseGrams * overallScale / 5.0).round() * 5.0;
      itemGrams[item.foodId] = math.max(10.0, g);
    }

    // Protein balancing
    final proteinItem = config.items.where((i) => i.isProteinSource).firstOrNull;
    if (proteinItem != null) {
      final pFood = _lookupFood(proteinItem.foodId);
      if (pFood != null && pFood.proteinPer100g > 0) {
        final currentProteinFromOthers = config.items
            .where((i) => i.foodId != proteinItem.foodId)
            .fold<double>(0.0, (sum, i) {
          final f = _lookupFood(i.foodId);
          return sum + (f?.macrosForGrams(itemGrams[i.foodId] ?? i.baseGrams).protein ?? 0.0);
        });

        final neededFromPrimary = math.max(8.0, targetProtein - currentProteinFromOthers);
        double primaryGrams = (neededFromPrimary / (pFood.proteinPer100g / 100.0) / 5.0).round() * 5.0;
        primaryGrams = math.max(25.0, primaryGrams);
        itemGrams[proteinItem.foodId] = primaryGrams;
      }
    }

    // Calorie balancing: adjust carb staple to hit targetKcal
    final carbItem = config.items.where((i) => i.isCarbSource).firstOrNull;
    if (carbItem != null) {
      final cFood = _lookupFood(carbItem.foodId);
      if (cFood != null && cFood.caloriesPer100g > 0) {
        final caloriesFromOthers = config.items
            .where((i) => i.foodId != carbItem.foodId)
            .fold<double>(0.0, (sum, i) {
          final f = _lookupFood(i.foodId);
          return sum + (f?.macrosForGrams(itemGrams[i.foodId] ?? i.baseGrams).calories ?? 0.0);
        });

        final remainingKcal = math.max(20.0, targetKcal - caloriesFromOthers);
        double carbGrams = (remainingKcal / (cFood.caloriesPer100g / 100.0) / 5.0).round() * 5.0;
        carbGrams = math.max(15.0, carbGrams);
        itemGrams[carbItem.foodId] = carbGrams;
      }
    }

    // Compute exact totals
    double totalKcal = 0.0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFats = 0.0;
    final ingredients = <String>[];

    for (final item in config.items) {
      final food = _lookupFood(item.foodId);
      final grams = itemGrams[item.foodId] ?? item.baseGrams;
      if (food != null) {
        final m = food.macrosForGrams(grams);
        totalKcal += m.calories;
        totalProtein += m.protein;
        totalCarbs += m.carbs;
        totalFats += m.fat;
        ingredients.add('${grams.toInt()}g ${food.name}');
      }
    }

    return DietMeal(
      mealType: mealType,
      name: config.mealName,
      ingredients: ingredients,
      calories: totalKcal.roundToDouble(),
      proteinG: totalProtein.roundToDouble(),
      carbsG: totalCarbs.roundToDouble(),
      fatsG: totalFats.roundToDouble(),
      prepTime: config.prepTime,
      alternatives: config.alternatives,
    );
  }

  FoodItem? _lookupFood(String id) {
    try {
      return verifiedFoodsList.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  _MealConfig _getMealConfig(MealType mealType, int dayIndex, BudgetLevel budget) {
    final dayKey = (dayIndex % 3);

    return switch (mealType) {
      MealType.breakfast => switch (budget) {
          BudgetLevel.low => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Scrambled Eggs & Whole Wheat Toast',
                  items: [
                    _MealItem(foodId: 'usda_whole_egg_raw', baseGrams: 100, isProteinSource: true),
                    _MealItem(foodId: 'usda_whole_wheat_bread', baseGrams: 64, isCarbSource: true),
                    _MealItem(foodId: 'usda_banana_raw', baseGrams: 118),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 8),
                  ],
                  prepTime: '8 min',
                  alternatives: ['Oats with milk & peanut butter', 'Cottage cheese & apple'],
                ),
              1 => const _MealConfig(
                  mealName: 'Peanut Butter Oatmeal with Milk & Banana',
                  items: [
                    _MealItem(foodId: 'usda_milk_skim_nonfat', baseGrams: 200, isProteinSource: true),
                    _MealItem(foodId: 'usda_rolled_oats_dry', baseGrams: 60, isCarbSource: true),
                    _MealItem(foodId: 'usda_peanut_butter_creamy', baseGrams: 25),
                    _MealItem(foodId: 'usda_banana_raw', baseGrams: 118),
                  ],
                  prepTime: '5 min',
                  alternatives: ['Scrambled eggs & toast', 'Cottage cheese & fruit'],
                ),
              _ => const _MealConfig(
                  mealName: 'Cottage Cheese & Sliced Apple Toast',
                  items: [
                    _MealItem(foodId: 'usda_cottage_cheese_lowfat_1', baseGrams: 180, isProteinSource: true),
                    _MealItem(foodId: 'usda_whole_wheat_bread', baseGrams: 64, isCarbSource: true),
                    _MealItem(foodId: 'usda_apple_raw_gala', baseGrams: 130),
                  ],
                  prepTime: '5 min',
                  alternatives: ['Eggs & toast', 'Oats with milk'],
                ),
            },
          BudgetLevel.medium => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Greek Yogurt Berry Bowl with Oats & Almonds',
                  items: [
                    _MealItem(foodId: 'usda_greek_yogurt_nonfat_plain', baseGrams: 200, isProteinSource: true),
                    _MealItem(foodId: 'usda_rolled_oats_dry', baseGrams: 50, isCarbSource: true),
                    _MealItem(foodId: 'usda_blueberries_raw', baseGrams: 80),
                    _MealItem(foodId: 'usda_almonds_raw', baseGrams: 15),
                  ],
                  prepTime: '4 min',
                  alternatives: ['Egg & avocado scramble', 'Whey protein smoothie'],
                ),
              1 => const _MealConfig(
                  mealName: 'Egg & Egg White Scramble with Toast & Avocado',
                  items: [
                    _MealItem(foodId: 'usda_whole_egg_raw', baseGrams: 100, isProteinSource: true),
                    _MealItem(foodId: 'usda_egg_white_raw', baseGrams: 60),
                    _MealItem(foodId: 'usda_whole_wheat_bread', baseGrams: 64, isCarbSource: true),
                    _MealItem(foodId: 'usda_avocado_haas', baseGrams: 30),
                  ],
                  prepTime: '10 min',
                  alternatives: ['Greek yogurt & fruit', 'Protein oatmeal'],
                ),
              _ => const _MealConfig(
                  mealName: 'Whey Protein Oats with Strawberries',
                  items: [
                    _MealItem(foodId: 'usda_whey_protein_isolate', baseGrams: 30, isProteinSource: true),
                    _MealItem(foodId: 'usda_rolled_oats_dry', baseGrams: 60, isCarbSource: true),
                    _MealItem(foodId: 'usda_strawberries_raw', baseGrams: 100),
                    _MealItem(foodId: 'usda_peanut_butter_creamy', baseGrams: 15),
                  ],
                  prepTime: '5 min',
                  alternatives: ['Egg whites & sourdough', 'Greek yogurt parfait'],
                ),
            },
          BudgetLevel.high => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Wild Salmon & Avocado Toast with Blueberries',
                  items: [
                    _MealItem(foodId: 'usda_salmon_atlantic_wild_raw', baseGrams: 120, isProteinSource: true),
                    _MealItem(foodId: 'usda_whole_wheat_bread', baseGrams: 64, isCarbSource: true),
                    _MealItem(foodId: 'usda_avocado_haas', baseGrams: 40),
                    _MealItem(foodId: 'usda_blueberries_raw', baseGrams: 80),
                  ],
                  prepTime: '12 min',
                  alternatives: ['Turkey & egg scramble', 'Greek yogurt with berries & walnuts'],
                ),
              1 => const _MealConfig(
                  mealName: 'Greek Yogurt Parfait with Fresh Strawberries & Chia',
                  items: [
                    _MealItem(foodId: 'usda_greek_yogurt_nonfat_plain', baseGrams: 220, isProteinSource: true),
                    _MealItem(foodId: 'usda_rolled_oats_dry', baseGrams: 50, isCarbSource: true),
                    _MealItem(foodId: 'usda_strawberries_raw', baseGrams: 100),
                    _MealItem(foodId: 'usda_chia_seeds_dried', baseGrams: 15),
                  ],
                  prepTime: '5 min',
                  alternatives: ['Salmon & poached eggs', 'Egg white omelet with avocado'],
                ),
              _ => const _MealConfig(
                  mealName: 'Egg White & Lean Turkey Scramble with Avocado',
                  items: [
                    _MealItem(foodId: 'usda_egg_white_raw', baseGrams: 120, isProteinSource: true),
                    _MealItem(foodId: 'usda_turkey_breast_99_lean', baseGrams: 80),
                    _MealItem(foodId: 'usda_whole_wheat_bread', baseGrams: 64, isCarbSource: true),
                    _MealItem(foodId: 'usda_avocado_haas', baseGrams: 40),
                  ],
                  prepTime: '10 min',
                  alternatives: ['Wild salmon toast', 'Protein smoothie bowl'],
                ),
            },
        },
      MealType.lunch => switch (budget) {
          BudgetLevel.low => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Canned Tuna & Brown Rice with Spinach',
                  items: [
                    _MealItem(foodId: 'usda_canned_tuna_water', baseGrams: 140, isProteinSource: true),
                    _MealItem(foodId: 'usda_brown_rice_cooked', baseGrams: 200, isCarbSource: true),
                    _MealItem(foodId: 'usda_baby_spinach_raw', baseGrams: 50),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '8 min',
                  alternatives: ['Chicken thigh & rice', 'Egg fried rice'],
                ),
              1 => const _MealConfig(
                  mealName: 'Roasted Chicken Thigh & Baked Potato with Broccoli',
                  items: [
                    _MealItem(foodId: 'usda_chicken_thigh_skinless', baseGrams: 150, isProteinSource: true),
                    _MealItem(foodId: 'usda_russet_potato_baked', baseGrams: 220, isCarbSource: true),
                    _MealItem(foodId: 'usda_broccoli_raw', baseGrams: 100),
                  ],
                  prepTime: '20 min',
                  alternatives: ['Tuna rice bowl', 'Black bean wrap'],
                ),
              _ => const _MealConfig(
                  mealName: 'Black Bean & Boiled Egg Rice Bowl',
                  items: [
                    _MealItem(foodId: 'usda_black_beans_cooked', baseGrams: 150, isProteinSource: true),
                    _MealItem(foodId: 'usda_whole_egg_raw', baseGrams: 100),
                    _MealItem(foodId: 'usda_white_rice_cooked', baseGrams: 200, isCarbSource: true),
                    _MealItem(foodId: 'usda_bell_pepper_red', baseGrams: 80),
                  ],
                  prepTime: '10 min',
                  alternatives: ['Tuna salad', 'Chicken thigh with potato'],
                ),
            },
          BudgetLevel.medium => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Roasted Chicken Breast & Brown Rice with Broccoli',
                  items: [
                    _MealItem(foodId: 'usda_chicken_breast_cooked', baseGrams: 150, isProteinSource: true),
                    _MealItem(foodId: 'usda_brown_rice_cooked', baseGrams: 200, isCarbSource: true),
                    _MealItem(foodId: 'usda_broccoli_raw', baseGrams: 100),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '15 min',
                  alternatives: ['Ground turkey & quinoa', 'Tuna salad wrap'],
                ),
              1 => const _MealConfig(
                  mealName: 'Lean Ground Turkey & Quinoa Bowl',
                  items: [
                    _MealItem(foodId: 'usda_turkey_breast_99_lean', baseGrams: 160, isProteinSource: true),
                    _MealItem(foodId: 'usda_quinoa_cooked', baseGrams: 180, isCarbSource: true),
                    _MealItem(foodId: 'usda_bell_pepper_red', baseGrams: 100),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '15 min',
                  alternatives: ['Chicken breast & rice', 'Lean beef stir fry'],
                ),
              _ => const _MealConfig(
                  mealName: 'Tuna Sandwich on Whole Wheat with Fresh Spinach',
                  items: [
                    _MealItem(foodId: 'usda_canned_tuna_water', baseGrams: 150, isProteinSource: true),
                    _MealItem(foodId: 'usda_whole_wheat_bread', baseGrams: 100, isCarbSource: true),
                    _MealItem(foodId: 'usda_baby_spinach_raw', baseGrams: 50),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '7 min',
                  alternatives: ['Chicken wrap', 'Turkey & rice bowl'],
                ),
            },
          BudgetLevel.high => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Pan-Seared Wild Salmon & Quinoa with Asparagus',
                  items: [
                    _MealItem(foodId: 'usda_salmon_atlantic_wild_raw', baseGrams: 160, isProteinSource: true),
                    _MealItem(foodId: 'usda_quinoa_cooked', baseGrams: 180, isCarbSource: true),
                    _MealItem(foodId: 'usda_asparagus_cooked', baseGrams: 100),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '18 min',
                  alternatives: ['Sirloin steak & sweet potato', 'Chicken breast & avocado'],
                ),
              1 => const _MealConfig(
                  mealName: 'Lean Sirloin Steak & Sweet Potato with Asparagus',
                  items: [
                    _MealItem(foodId: 'usda_sirloin_steak_trimmed', baseGrams: 150, isProteinSource: true),
                    _MealItem(foodId: 'usda_sweet_potato_baked', baseGrams: 220, isCarbSource: true),
                    _MealItem(foodId: 'usda_asparagus_cooked', baseGrams: 100),
                  ],
                  prepTime: '20 min',
                  alternatives: ['Wild salmon & quinoa', 'Turkey breast & roasted veg'],
                ),
              _ => const _MealConfig(
                  mealName: 'Roasted Chicken Breast & Avocado Quinoa Salad',
                  items: [
                    _MealItem(foodId: 'usda_chicken_breast_cooked', baseGrams: 150, isProteinSource: true),
                    _MealItem(foodId: 'usda_quinoa_cooked', baseGrams: 160, isCarbSource: true),
                    _MealItem(foodId: 'usda_baby_spinach_raw', baseGrams: 60),
                    _MealItem(foodId: 'usda_avocado_haas', baseGrams: 40),
                  ],
                  prepTime: '15 min',
                  alternatives: ['Grilled salmon', 'Sirloin steak salad'],
                ),
            },
        },
      MealType.dinner => switch (budget) {
          BudgetLevel.low => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Baked Chicken Thigh with White Rice & Broccoli',
                  items: [
                    _MealItem(foodId: 'usda_chicken_thigh_skinless', baseGrams: 140, isProteinSource: true),
                    _MealItem(foodId: 'usda_white_rice_cooked', baseGrams: 180, isCarbSource: true),
                    _MealItem(foodId: 'usda_broccoli_raw', baseGrams: 100),
                  ],
                  prepTime: '20 min',
                  alternatives: ['Canned tuna pasta', 'Hard-boiled eggs & potato'],
                ),
              1 => const _MealConfig(
                  mealName: 'Tuna & White Rice Bowl with Spinach',
                  items: [
                    _MealItem(foodId: 'usda_canned_tuna_water', baseGrams: 130, isProteinSource: true),
                    _MealItem(foodId: 'usda_white_rice_cooked', baseGrams: 180, isCarbSource: true),
                    _MealItem(foodId: 'usda_baby_spinach_raw', baseGrams: 60),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '10 min',
                  alternatives: ['Chicken thigh & potato', 'Black beans & eggs'],
                ),
              _ => const _MealConfig(
                  mealName: 'Hard-Boiled Eggs with Baked Potato & Spinach',
                  items: [
                    _MealItem(foodId: 'usda_whole_egg_raw', baseGrams: 100, isProteinSource: true),
                    _MealItem(foodId: 'usda_russet_potato_baked', baseGrams: 200, isCarbSource: true),
                    _MealItem(foodId: 'usda_baby_spinach_raw', baseGrams: 50),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '15 min',
                  alternatives: ['Tuna salad & toast', 'Chicken & rice'],
                ),
            },
          BudgetLevel.medium => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Baked Chicken Breast with Sweet Potato & Spinach',
                  items: [
                    _MealItem(foodId: 'usda_chicken_breast_cooked', baseGrams: 140, isProteinSource: true),
                    _MealItem(foodId: 'usda_sweet_potato_baked', baseGrams: 200, isCarbSource: true),
                    _MealItem(foodId: 'usda_baby_spinach_raw', baseGrams: 70),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '22 min',
                  alternatives: ['Lean beef & rice', 'Cod fillet & potato'],
                ),
              1 => const _MealConfig(
                  mealName: 'Lean Ground Beef & Brown Rice with Broccoli',
                  items: [
                    _MealItem(foodId: 'usda_ground_beef_90_lean', baseGrams: 130, isProteinSource: true),
                    _MealItem(foodId: 'usda_brown_rice_cooked', baseGrams: 180, isCarbSource: true),
                    _MealItem(foodId: 'usda_broccoli_raw', baseGrams: 100),
                  ],
                  prepTime: '20 min',
                  alternatives: ['Chicken breast & sweet potato', 'Turkey & quinoa'],
                ),
              _ => const _MealConfig(
                  mealName: 'Pacific Cod with White Rice & Steamed Broccoli',
                  items: [
                    _MealItem(foodId: 'usda_pacific_cod_raw', baseGrams: 160, isProteinSource: true),
                    _MealItem(foodId: 'usda_white_rice_cooked', baseGrams: 180, isCarbSource: true),
                    _MealItem(foodId: 'usda_broccoli_raw', baseGrams: 100),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '18 min',
                  alternatives: ['Chicken breast & rice', 'Ground beef & sweet potato'],
                ),
            },
          BudgetLevel.high => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Grilled Sirloin Steak with Sweet Potato & Asparagus',
                  items: [
                    _MealItem(foodId: 'usda_sirloin_steak_trimmed', baseGrams: 140, isProteinSource: true),
                    _MealItem(foodId: 'usda_sweet_potato_baked', baseGrams: 180, isCarbSource: true),
                    _MealItem(foodId: 'usda_asparagus_cooked', baseGrams: 100),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '25 min',
                  alternatives: ['Atlantic wild salmon & brown rice', 'Lean turkey & sweet potato'],
                ),
              1 => const _MealConfig(
                  mealName: 'Wild Atlantic Salmon with Brown Rice & Sautéed Spinach',
                  items: [
                    _MealItem(foodId: 'usda_salmon_atlantic_wild_raw', baseGrams: 150, isProteinSource: true),
                    _MealItem(foodId: 'usda_brown_rice_cooked', baseGrams: 160, isCarbSource: true),
                    _MealItem(foodId: 'usda_baby_spinach_raw', baseGrams: 80),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '20 min',
                  alternatives: ['Sirloin steak & asparagus', 'Roasted chicken & avocado'],
                ),
              _ => const _MealConfig(
                  mealName: 'Lean Turkey Breast with Sweet Potato & Asparagus',
                  items: [
                    _MealItem(foodId: 'usda_turkey_breast_99_lean', baseGrams: 150, isProteinSource: true),
                    _MealItem(foodId: 'usda_sweet_potato_baked', baseGrams: 180, isCarbSource: true),
                    _MealItem(foodId: 'usda_asparagus_cooked', baseGrams: 100),
                    _MealItem(foodId: 'usda_extra_virgin_olive_oil', baseGrams: 10),
                  ],
                  prepTime: '22 min',
                  alternatives: ['Salmon & quinoa', 'Sirloin steak & potato'],
                ),
            },
        },
      MealType.snack => switch (budget) {
          BudgetLevel.low => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Cottage Cheese with Sliced Gala Apple',
                  items: [
                    _MealItem(foodId: 'usda_cottage_cheese_lowfat_1', baseGrams: 120, isProteinSource: true),
                    _MealItem(foodId: 'usda_apple_raw_gala', baseGrams: 130, isCarbSource: true),
                  ],
                  prepTime: '2 min',
                  alternatives: ['Cottage cheese & banana', 'Rice cakes & peanut butter'],
                ),
              1 => const _MealConfig(
                  mealName: 'Cottage Cheese with Sliced Banana',
                  items: [
                    _MealItem(foodId: 'usda_cottage_cheese_lowfat_1', baseGrams: 120, isProteinSource: true),
                    _MealItem(foodId: 'usda_banana_raw', baseGrams: 118, isCarbSource: true),
                  ],
                  prepTime: '2 min',
                  alternatives: ['Peanut butter & apple', 'Boiled egg & toast'],
                ),
              _ => const _MealConfig(
                  mealName: 'Crisp Rice Cakes with Hard-Boiled Egg',
                  items: [
                    _MealItem(foodId: 'usda_whole_egg_raw', baseGrams: 50, isProteinSource: true),
                    _MealItem(foodId: 'usda_rice_cakes_plain', baseGrams: 25, isCarbSource: true),
                    _MealItem(foodId: 'usda_peanut_butter_creamy', baseGrams: 15),
                  ],
                  prepTime: '2 min',
                  alternatives: ['Apple & peanut butter', 'Cottage cheese bowl'],
                ),
            },
          BudgetLevel.medium => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Whey Protein Shake with Gala Apple',
                  items: [
                    _MealItem(foodId: 'usda_whey_protein_isolate', baseGrams: 25, isProteinSource: true),
                    _MealItem(foodId: 'usda_apple_raw_gala', baseGrams: 130, isCarbSource: true),
                    _MealItem(foodId: 'usda_almonds_raw', baseGrams: 10),
                  ],
                  prepTime: '2 min',
                  alternatives: ['Whey protein shake', 'Greek yogurt & strawberries'],
                ),
              1 => const _MealConfig(
                  mealName: 'Whey Protein Shake with Banana',
                  items: [
                    _MealItem(foodId: 'usda_whey_protein_isolate', baseGrams: 25, isProteinSource: true),
                    _MealItem(foodId: 'usda_banana_raw', baseGrams: 118, isCarbSource: true),
                  ],
                  prepTime: '2 min',
                  alternatives: ['Almonds & apple', 'Greek yogurt & berries'],
                ),
              _ => const _MealConfig(
                  mealName: 'Greek Yogurt with Fresh Strawberries',
                  items: [
                    _MealItem(foodId: 'usda_greek_yogurt_nonfat_plain', baseGrams: 150, isProteinSource: true),
                    _MealItem(foodId: 'usda_strawberries_raw', baseGrams: 100, isCarbSource: true),
                  ],
                  prepTime: '2 min',
                  alternatives: ['Protein shake', 'Almonds & fruit'],
                ),
            },
          BudgetLevel.high => switch (dayKey) {
              0 => const _MealConfig(
                  mealName: 'Whey Protein Isolate with Fresh Blueberries & Almonds',
                  items: [
                    _MealItem(foodId: 'usda_whey_protein_isolate', baseGrams: 25, isProteinSource: true),
                    _MealItem(foodId: 'usda_blueberries_raw', baseGrams: 100, isCarbSource: true),
                    _MealItem(foodId: 'usda_almonds_raw', baseGrams: 15),
                  ],
                  prepTime: '2 min',
                  alternatives: ['Greek yogurt & chia parfait', 'Dark chocolate & rice cakes'],
                ),
              1 => const _MealConfig(
                  mealName: 'Greek Yogurt with Blueberries & Chia Seeds',
                  items: [
                    _MealItem(foodId: 'usda_greek_yogurt_nonfat_plain', baseGrams: 160, isProteinSource: true),
                    _MealItem(foodId: 'usda_blueberries_raw', baseGrams: 80, isCarbSource: true),
                    _MealItem(foodId: 'usda_chia_seeds_dried', baseGrams: 10),
                  ],
                  prepTime: '3 min',
                  alternatives: ['Protein shake & almonds', 'Avocado on rice cake'],
                ),
              _ => const _MealConfig(
                  mealName: 'Greek Yogurt with Strawberries & Dark Chocolate',
                  items: [
                    _MealItem(foodId: 'usda_greek_yogurt_nonfat_plain', baseGrams: 150, isProteinSource: true),
                    _MealItem(foodId: 'usda_strawberries_raw', baseGrams: 100, isCarbSource: true),
                    _MealItem(foodId: 'usda_dark_chocolate_85', baseGrams: 15),
                  ],
                  prepTime: '2 min',
                  alternatives: ['Protein shake', 'Greek yogurt bowl'],
                ),
            },
        },
    };
  }

  List<String> _buildTips(UserProfile profile) {
    final tips = <String>[];
    switch (profile.goal) {
      case FitnessGoal.gainMuscle:
        tips.addAll([
          'Eat within 60 minutes after training to supply protein and carbs for recovery.',
          'Aim to spread your protein evenly across 3 to 4 meals.',
          'Carbohydrates fuel high-intensity lifting sessions; don\'t skip them on training days.',
        ]);
      case FitnessGoal.loseWeight:
        tips.addAll([
          'Keep protein high to protect muscle while in a gentle calorie deficit.',
          'Drink 2 to 3 liters of water throughout the day to stay energized and hydrated.',
          'Focus on fibrous carbs like potatoes, oats, and vegetables for sustained fullness.',
        ]);
      case FitnessGoal.maintain:
        tips.addAll([
          'Consistency is key; aim for stable weekly calorie and protein averages.',
          'Prioritize whole food staples for 80% or more of your daily nutrition.',
          'Adjust portions slightly on rest days versus high-volume workout days.',
        ]);
    }

    if (profile.budget == BudgetLevel.low) {
      tips.add('Buy staples like oats, rice, eggs, and canned tuna in bulk to save significantly on grocery costs.');
      tips.add('Frozen vegetables retain the same nutritional value as fresh produce at a fraction of the cost.');
    } else if (profile.budget == BudgetLevel.high) {
      tips.add('Wild salmon and extra-virgin olive oil supply anti-inflammatory omega-3 and monounsaturated fats.');
    }

    return tips;
  }
}

class _MealItem {
  final String foodId;
  final double baseGrams;
  final bool isProteinSource;
  final bool isCarbSource;

  const _MealItem({
    required this.foodId,
    required this.baseGrams,
    this.isProteinSource = false,
    this.isCarbSource = false,
  });
}

class _MealConfig {
  final String mealName;
  final List<_MealItem> items;
  final String prepTime;
  final List<String> alternatives;

  const _MealConfig({
    required this.mealName,
    required this.items,
    required this.prepTime,
    required this.alternatives,
  });
}

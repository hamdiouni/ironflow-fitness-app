import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/diet_plan.dart';
import '../../domain/entities/diet_plan_state.dart';

part 'diet_plan_state_model.freezed.dart';
part 'diet_plan_state_model.g.dart';

@freezed
class DietPlanStateModel with _$DietPlanStateModel {
  const factory DietPlanStateModel({
    required DietPlanModel plan,
    @Default({}) Map<String, DietMealModel> mealSwaps,
    DateTime? lastUpdated,
  }) = _DietPlanStateModel;

  factory DietPlanStateModel.fromJson(Map<String, dynamic> json) =>
      _$DietPlanStateModelFromJson(json);

  factory DietPlanStateModel.fromEntity(DietPlanState state) {
    return DietPlanStateModel(
      plan: DietPlanModel.fromEntity(state.plan),
      mealSwaps: state.mealSwaps.map(
        (key, value) => MapEntry(key, DietMealModel.fromEntity(value)),
      ),
      lastUpdated: state.lastUpdated,
    );
  }
}

extension DietPlanStateModelX on DietPlanStateModel {
  DietPlanState toEntity() {
    return DietPlanState(
      plan: plan.toEntity(),
      mealSwaps: mealSwaps.map(
        (key, value) => MapEntry(key, value.toEntity()),
      ),
      lastUpdated: lastUpdated,
    );
  }
}

@freezed
class DietPlanModel with _$DietPlanModel {
  const factory DietPlanModel({
    required String name,
    required double dailyCalories,
    required double proteinG,
    required double carbsG,
    required double fatsG,
    required List<DietDayModel> days,
    required List<String> tips,
  }) = _DietPlanModel;

  factory DietPlanModel.fromJson(Map<String, dynamic> json) =>
      _$DietPlanModelFromJson(json);

  factory DietPlanModel.fromEntity(DietPlan plan) {
    return DietPlanModel(
      name: plan.name,
      dailyCalories: plan.dailyCalories,
      proteinG: plan.proteinG,
      carbsG: plan.carbsG,
      fatsG: plan.fatsG,
      days: plan.days.map((day) => DietDayModel.fromEntity(day)).toList(),
      tips: plan.tips,
    );
  }
}

extension DietPlanModelX on DietPlanModel {
  DietPlan toEntity() {
    return DietPlan(
      name: name,
      dailyCalories: dailyCalories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatsG: fatsG,
      days: days.map((day) => day.toEntity()).toList(),
      tips: tips,
    );
  }
}

@freezed
class DietDayModel with _$DietDayModel {
  const factory DietDayModel({
    required String dayName,
    required List<DietMealModel> meals,
  }) = _DietDayModel;

  factory DietDayModel.fromJson(Map<String, dynamic> json) =>
      _$DietDayModelFromJson(json);

  factory DietDayModel.fromEntity(DietDay day) {
    return DietDayModel(
      dayName: day.dayName,
      meals: day.meals.map((meal) => DietMealModel.fromEntity(meal)).toList(),
    );
  }
}

extension DietDayModelX on DietDayModel {
  DietDay toEntity() {
    return DietDay(
      dayName: dayName,
      meals: meals.map((meal) => meal.toEntity()).toList(),
    );
  }
}

@freezed
class DietMealModel with _$DietMealModel {
  const factory DietMealModel({
    required MealType mealType,
    required String name,
    required List<String> ingredients,
    required double calories,
    required double proteinG,
    required double carbsG,
    required double fatsG,
    String? prepTime,
    @Default([]) List<String> alternatives,
  }) = _DietMealModel;

  factory DietMealModel.fromJson(Map<String, dynamic> json) =>
      _$DietMealModelFromJson(json);

  factory DietMealModel.fromEntity(DietMeal meal) {
    return DietMealModel(
      mealType: meal.mealType,
      name: meal.name,
      ingredients: meal.ingredients,
      calories: meal.calories,
      proteinG: meal.proteinG,
      carbsG: meal.carbsG,
      fatsG: meal.fatsG,
      prepTime: meal.prepTime,
      alternatives: meal.alternatives,
    );
  }
}

extension DietMealModelX on DietMealModel {
  DietMeal toEntity() {
    return DietMeal(
      mealType: mealType,
      name: name,
      ingredients: ingredients,
      calories: calories,
      proteinG: proteinG,
      carbsG: carbsG,
      fatsG: fatsG,
      prepTime: prepTime,
      alternatives: alternatives,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diet_plan_state_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DietPlanStateModelImpl _$$DietPlanStateModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$DietPlanStateModelImpl', json, ($checkedConvert) {
  final val = _$DietPlanStateModelImpl(
    plan: $checkedConvert(
      'plan',
      (v) => DietPlanModel.fromJson(v as Map<String, dynamic>),
    ),
    mealSwaps: $checkedConvert(
      'mealSwaps',
      (v) =>
          (v as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, DietMealModel.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    ),
    lastUpdated: $checkedConvert(
      'lastUpdated',
      (v) => v == null ? null : DateTime.parse(v as String),
    ),
  );
  return val;
});

Map<String, dynamic> _$$DietPlanStateModelImplToJson(
  _$DietPlanStateModelImpl instance,
) => <String, dynamic>{
  'plan': instance.plan.toJson(),
  'mealSwaps': instance.mealSwaps.map((k, e) => MapEntry(k, e.toJson())),
  'lastUpdated': instance.lastUpdated?.toIso8601String(),
};

_$DietPlanModelImpl _$$DietPlanModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$DietPlanModelImpl', json, ($checkedConvert) {
      final val = _$DietPlanModelImpl(
        name: $checkedConvert('name', (v) => v as String),
        dailyCalories: $checkedConvert(
          'dailyCalories',
          (v) => (v as num).toDouble(),
        ),
        proteinG: $checkedConvert('proteinG', (v) => (v as num).toDouble()),
        carbsG: $checkedConvert('carbsG', (v) => (v as num).toDouble()),
        fatsG: $checkedConvert('fatsG', (v) => (v as num).toDouble()),
        days: $checkedConvert(
          'days',
          (v) => (v as List<dynamic>)
              .map((e) => DietDayModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        tips: $checkedConvert(
          'tips',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$$DietPlanModelImplToJson(_$DietPlanModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'dailyCalories': instance.dailyCalories,
      'proteinG': instance.proteinG,
      'carbsG': instance.carbsG,
      'fatsG': instance.fatsG,
      'days': instance.days.map((e) => e.toJson()).toList(),
      'tips': instance.tips,
    };

_$DietDayModelImpl _$$DietDayModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$DietDayModelImpl', json, ($checkedConvert) {
      final val = _$DietDayModelImpl(
        dayName: $checkedConvert('dayName', (v) => v as String),
        meals: $checkedConvert(
          'meals',
          (v) => (v as List<dynamic>)
              .map((e) => DietMealModel.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$$DietDayModelImplToJson(_$DietDayModelImpl instance) =>
    <String, dynamic>{
      'dayName': instance.dayName,
      'meals': instance.meals.map((e) => e.toJson()).toList(),
    };

_$DietMealModelImpl _$$DietMealModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$DietMealModelImpl', json, ($checkedConvert) {
      final val = _$DietMealModelImpl(
        mealType: $checkedConvert(
          'mealType',
          (v) => $enumDecode(_$MealTypeEnumMap, v),
        ),
        name: $checkedConvert('name', (v) => v as String),
        ingredients: $checkedConvert(
          'ingredients',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        calories: $checkedConvert('calories', (v) => (v as num).toDouble()),
        proteinG: $checkedConvert('proteinG', (v) => (v as num).toDouble()),
        carbsG: $checkedConvert('carbsG', (v) => (v as num).toDouble()),
        fatsG: $checkedConvert('fatsG', (v) => (v as num).toDouble()),
        prepTime: $checkedConvert('prepTime', (v) => v as String?),
        alternatives: $checkedConvert(
          'alternatives',
          (v) =>
              (v as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
        ),
      );
      return val;
    });

Map<String, dynamic> _$$DietMealModelImplToJson(_$DietMealModelImpl instance) =>
    <String, dynamic>{
      'mealType': _$MealTypeEnumMap[instance.mealType]!,
      'name': instance.name,
      'ingredients': instance.ingredients,
      'calories': instance.calories,
      'proteinG': instance.proteinG,
      'carbsG': instance.carbsG,
      'fatsG': instance.fatsG,
      'prepTime': instance.prepTime,
      'alternatives': instance.alternatives,
    };

const _$MealTypeEnumMap = {
  MealType.breakfast: 'breakfast',
  MealType.lunch: 'lunch',
  MealType.dinner: 'dinner',
  MealType.snack: 'snack',
};

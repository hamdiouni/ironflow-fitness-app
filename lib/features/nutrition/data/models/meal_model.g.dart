// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MealMacrosModelImpl _$$MealMacrosModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$MealMacrosModelImpl', json, ($checkedConvert) {
  final val = _$MealMacrosModelImpl(
    calories: $checkedConvert('calories', (v) => (v as num).toDouble()),
    protein: $checkedConvert('protein', (v) => (v as num).toDouble()),
    carbs: $checkedConvert('carbs', (v) => (v as num).toDouble()),
    fats: $checkedConvert('fats', (v) => (v as num).toDouble()),
  );
  return val;
});

Map<String, dynamic> _$$MealMacrosModelImplToJson(
  _$MealMacrosModelImpl instance,
) => <String, dynamic>{
  'calories': instance.calories,
  'protein': instance.protein,
  'carbs': instance.carbs,
  'fats': instance.fats,
};

_$MealMicrosModelImpl _$$MealMicrosModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$MealMicrosModelImpl', json, ($checkedConvert) {
  final val = _$MealMicrosModelImpl(
    fiber: $checkedConvert('fiber', (v) => (v as num).toDouble()),
    sugar: $checkedConvert('sugar', (v) => (v as num).toDouble()),
    sodium: $checkedConvert('sodium', (v) => (v as num).toDouble()),
    potassium: $checkedConvert('potassium', (v) => (v as num).toDouble()),
  );
  return val;
});

Map<String, dynamic> _$$MealMicrosModelImplToJson(
  _$MealMicrosModelImpl instance,
) => <String, dynamic>{
  'fiber': instance.fiber,
  'sugar': instance.sugar,
  'sodium': instance.sodium,
  'potassium': instance.potassium,
};

_$MealVitaminsModelImpl _$$MealVitaminsModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$MealVitaminsModelImpl', json, ($checkedConvert) {
  final val = _$MealVitaminsModelImpl(
    vitaminA: $checkedConvert('vitaminA', (v) => (v as num).toDouble()),
    vitaminB: $checkedConvert('vitaminB', (v) => (v as num).toDouble()),
    vitaminC: $checkedConvert('vitaminC', (v) => (v as num).toDouble()),
    vitaminD: $checkedConvert('vitaminD', (v) => (v as num).toDouble()),
    vitaminE: $checkedConvert('vitaminE', (v) => (v as num).toDouble()),
  );
  return val;
});

Map<String, dynamic> _$$MealVitaminsModelImplToJson(
  _$MealVitaminsModelImpl instance,
) => <String, dynamic>{
  'vitaminA': instance.vitaminA,
  'vitaminB': instance.vitaminB,
  'vitaminC': instance.vitaminC,
  'vitaminD': instance.vitaminD,
  'vitaminE': instance.vitaminE,
};

_$MealMineralsModelImpl _$$MealMineralsModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$MealMineralsModelImpl', json, ($checkedConvert) {
  final val = _$MealMineralsModelImpl(
    calcium: $checkedConvert('calcium', (v) => (v as num).toDouble()),
    iron: $checkedConvert('iron', (v) => (v as num).toDouble()),
    magnesium: $checkedConvert('magnesium', (v) => (v as num).toDouble()),
    zinc: $checkedConvert('zinc', (v) => (v as num).toDouble()),
  );
  return val;
});

Map<String, dynamic> _$$MealMineralsModelImplToJson(
  _$MealMineralsModelImpl instance,
) => <String, dynamic>{
  'calcium': instance.calcium,
  'iron': instance.iron,
  'magnesium': instance.magnesium,
  'zinc': instance.zinc,
};

_$MealModelImpl _$$MealModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$MealModelImpl', json, ($checkedConvert) {
      final val = _$MealModelImpl(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        macros: $checkedConvert(
          'macros',
          (v) => MealMacrosModel.fromJson(v as Map<String, dynamic>),
        ),
        micros: $checkedConvert(
          'micros',
          (v) => MealMicrosModel.fromJson(v as Map<String, dynamic>),
        ),
        vitamins: $checkedConvert(
          'vitamins',
          (v) => MealVitaminsModel.fromJson(v as Map<String, dynamic>),
        ),
        minerals: $checkedConvert(
          'minerals',
          (v) => MealMineralsModel.fromJson(v as Map<String, dynamic>),
        ),
        timestamp: $checkedConvert('timestamp', (v) => v as String),
        userId: $checkedConvert('userId', (v) => v as String?),
        foodItemId: $checkedConvert('foodItemId', (v) => v as String?),
        updatedAt: $checkedConvert('updatedAt', (v) => v as String?),
        deletedAt: $checkedConvert('deletedAt', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$$MealModelImplToJson(_$MealModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'macros': instance.macros.toJson(),
      'micros': instance.micros.toJson(),
      'vitamins': instance.vitamins.toJson(),
      'minerals': instance.minerals.toJson(),
      'timestamp': instance.timestamp,
      'userId': instance.userId,
      'foodItemId': instance.foodItemId,
      'updatedAt': instance.updatedAt,
      'deletedAt': instance.deletedAt,
    };

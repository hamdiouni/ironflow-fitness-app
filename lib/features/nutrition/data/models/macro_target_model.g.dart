// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macro_target_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MacroTargetModelImpl _$$MacroTargetModelImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$MacroTargetModelImpl', json, ($checkedConvert) {
  final val = _$MacroTargetModelImpl(
    protein: $checkedConvert('protein', (v) => (v as num).toDouble()),
    carbs: $checkedConvert('carbs', (v) => (v as num).toDouble()),
    fats: $checkedConvert('fats', (v) => (v as num).toDouble()),
  );
  return val;
});

Map<String, dynamic> _$$MacroTargetModelImplToJson(
  _$MacroTargetModelImpl instance,
) => <String, dynamic>{
  'protein': instance.protein,
  'carbs': instance.carbs,
  'fats': instance.fats,
};

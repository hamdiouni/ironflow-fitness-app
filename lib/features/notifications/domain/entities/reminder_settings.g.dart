// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReminderSettingsImpl _$$ReminderSettingsImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$ReminderSettingsImpl', json, ($checkedConvert) {
  final val = _$ReminderSettingsImpl(
    workoutRemindersEnabled: $checkedConvert(
      'workoutRemindersEnabled',
      (v) => v as bool? ?? false,
    ),
    workoutReminderTime: $checkedConvert(
      'workoutReminderTime',
      (v) => v == null
          ? const TimeOfDayModel(hour: 18, minute: 0)
          : TimeOfDayModel.fromJson(v as Map<String, dynamic>),
    ),
    mealRemindersEnabled: $checkedConvert(
      'mealRemindersEnabled',
      (v) => v as bool? ?? false,
    ),
    breakfastTime: $checkedConvert(
      'breakfastTime',
      (v) => v == null
          ? const TimeOfDayModel(hour: 8, minute: 0)
          : TimeOfDayModel.fromJson(v as Map<String, dynamic>),
    ),
    lunchTime: $checkedConvert(
      'lunchTime',
      (v) => v == null
          ? const TimeOfDayModel(hour: 12, minute: 0)
          : TimeOfDayModel.fromJson(v as Map<String, dynamic>),
    ),
    dinnerTime: $checkedConvert(
      'dinnerTime',
      (v) => v == null
          ? const TimeOfDayModel(hour: 19, minute: 0)
          : TimeOfDayModel.fromJson(v as Map<String, dynamic>),
    ),
    streakRemindersEnabled: $checkedConvert(
      'streakRemindersEnabled',
      (v) => v as bool? ?? false,
    ),
    streakReminderTime: $checkedConvert(
      'streakReminderTime',
      (v) => v == null
          ? const TimeOfDayModel(hour: 20, minute: 0)
          : TimeOfDayModel.fromJson(v as Map<String, dynamic>),
    ),
    soundEnabled: $checkedConvert('soundEnabled', (v) => v as bool? ?? true),
    vibrationEnabled: $checkedConvert(
      'vibrationEnabled',
      (v) => v as bool? ?? true,
    ),
  );
  return val;
});

Map<String, dynamic> _$$ReminderSettingsImplToJson(
  _$ReminderSettingsImpl instance,
) => <String, dynamic>{
  'workoutRemindersEnabled': instance.workoutRemindersEnabled,
  'workoutReminderTime': instance.workoutReminderTime.toJson(),
  'mealRemindersEnabled': instance.mealRemindersEnabled,
  'breakfastTime': instance.breakfastTime.toJson(),
  'lunchTime': instance.lunchTime.toJson(),
  'dinnerTime': instance.dinnerTime.toJson(),
  'streakRemindersEnabled': instance.streakRemindersEnabled,
  'streakReminderTime': instance.streakReminderTime.toJson(),
  'soundEnabled': instance.soundEnabled,
  'vibrationEnabled': instance.vibrationEnabled,
};

_$TimeOfDayModelImpl _$$TimeOfDayModelImplFromJson(Map<String, dynamic> json) =>
    $checkedCreate(r'_$TimeOfDayModelImpl', json, ($checkedConvert) {
      final val = _$TimeOfDayModelImpl(
        hour: $checkedConvert('hour', (v) => (v as num).toInt()),
        minute: $checkedConvert('minute', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$$TimeOfDayModelImplToJson(
  _$TimeOfDayModelImpl instance,
) => <String, dynamic>{'hour': instance.hour, 'minute': instance.minute};

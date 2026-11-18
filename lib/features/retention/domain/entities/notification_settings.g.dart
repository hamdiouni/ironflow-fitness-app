// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationSettingsImpl _$$NotificationSettingsImplFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(r'_$NotificationSettingsImpl', json, ($checkedConvert) {
  final val = _$NotificationSettingsImpl(
    isEnabled: $checkedConvert('isEnabled', (v) => v as bool),
    reminderHour: $checkedConvert('reminderHour', (v) => (v as num).toInt()),
    reminderMinute: $checkedConvert(
      'reminderMinute',
      (v) => (v as num).toInt(),
    ),
    showAchievements: $checkedConvert('showAchievements', (v) => v as bool),
    showStreakReminders: $checkedConvert(
      'showStreakReminders',
      (v) => v as bool,
    ),
  );
  return val;
});

Map<String, dynamic> _$$NotificationSettingsImplToJson(
  _$NotificationSettingsImpl instance,
) => <String, dynamic>{
  'isEnabled': instance.isEnabled,
  'reminderHour': instance.reminderHour,
  'reminderMinute': instance.reminderMinute,
  'showAchievements': instance.showAchievements,
  'showStreakReminders': instance.showStreakReminders,
};

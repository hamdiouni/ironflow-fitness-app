import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder_settings.freezed.dart';
part 'reminder_settings.g.dart';

/// User's reminder preferences
@freezed
class ReminderSettings with _$ReminderSettings {
  const factory ReminderSettings({
    // Workout reminders
    @Default(false) bool workoutRemindersEnabled,
    @Default(TimeOfDayModel(hour: 18, minute: 0)) TimeOfDayModel workoutReminderTime,
    
    // Meal reminders
    @Default(false) bool mealRemindersEnabled,
    @Default(TimeOfDayModel(hour: 8, minute: 0)) TimeOfDayModel breakfastTime,
    @Default(TimeOfDayModel(hour: 12, minute: 0)) TimeOfDayModel lunchTime,
    @Default(TimeOfDayModel(hour: 19, minute: 0)) TimeOfDayModel dinnerTime,
    
    // Streak reminders
    @Default(false) bool streakRemindersEnabled,
    @Default(TimeOfDayModel(hour: 20, minute: 0)) TimeOfDayModel streakReminderTime,
    
    // General settings
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
  }) = _ReminderSettings;

  factory ReminderSettings.fromJson(Map<String, dynamic> json) =>
      _$ReminderSettingsFromJson(json);
}

/// Time of day model (since TimeOfDay is not serializable)
@freezed
class TimeOfDayModel with _$TimeOfDayModel {
  const factory TimeOfDayModel({
    required int hour,
    required int minute,
  }) = _TimeOfDayModel;

  factory TimeOfDayModel.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayModelFromJson(json);
}

extension TimeOfDayModelX on TimeOfDayModel {
  String toDisplayString() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }
}

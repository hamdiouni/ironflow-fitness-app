import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Use case for scheduling meal reminders.
class ScheduleMealReminderUseCase {
  final FlutterLocalNotificationsPlugin _notifications;

  ScheduleMealReminderUseCase(this._notifications);

  /// Schedules multiple daily meal reminders.
  ///
  /// [mealTimes] - Map of meal name to time of day
  /// [macroTargets] - Optional macro targets to show in notification
  /// [enabled] - Whether reminders are enabled
  ///
  /// Returns true if scheduling was successful.
  Future<bool> call({
    required Map<String, TimeOfDay> mealTimes,
    Map<String, double>? macroTargets,
    required bool enabled,
  }) async {
    if (!enabled) {
      await cancelAll();
      return true;
    }

    try {
      int notificationId = 100; // Start from 100 to avoid conflicts

      for (final entry in mealTimes.entries) {
        final mealName = entry.key;
        final time = entry.value;

        String body = 'Time for your $mealName!';
        if (macroTargets != null) {
          body += '\nTargets: ${macroTargets['protein']?.toStringAsFixed(0)}g P, '
              '${macroTargets['carbs']?.toStringAsFixed(0)}g C, '
              '${macroTargets['fats']?.toStringAsFixed(0)}g F';
        }

        await _notifications.zonedSchedule(
          notificationId++,
          'Meal Reminder: $mealName 🍽️',
          body,
          _nextInstanceOfTime(time),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'meal_reminders',
              'Meal Reminders',
              channelDescription: 'Daily meal reminder notifications',
              importance: Importance.high,
              priority: Priority.high,
              icon: 'app_icon',
              styleInformation: BigTextStyleInformation(body),
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
              subtitle: body,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Schedules a single meal reminder.
  ///
  /// [mealName] - Name of the meal (e.g., "Breakfast", "Lunch")
  /// [time] - Time of day to send the reminder
  /// [macroTargets] - Optional macro targets to show
  ///
  /// Returns true if scheduling was successful.
  Future<bool> scheduleSingle({
    required String mealName,
    required TimeOfDay time,
    Map<String, double>? macroTargets,
  }) async {
    return await call(
      mealTimes: {mealName: time},
      macroTargets: macroTargets,
      enabled: true,
    );
  }

  /// Cancels all meal reminders.
  Future<void> cancelAll() async {
    // Cancel notification IDs 100-110 (meal reminders range)
    for (int i = 100; i <= 110; i++) {
      await _notifications.cancel(i);
    }
  }

  /// Cancels a specific meal reminder.
  ///
  /// [notificationId] - ID of the notification to cancel
  Future<void> cancel(int notificationId) async {
    await _notifications.cancel(notificationId);
  }

  /// Gets default meal times.
  static Map<String, TimeOfDay> getDefaultMealTimes() {
    return {
      'Breakfast': const TimeOfDay(hour: 8, minute: 0),
      'Lunch': const TimeOfDay(hour: 12, minute: 30),
      'Dinner': const TimeOfDay(hour: 18, minute: 30),
      'Snack': const TimeOfDay(hour: 15, minute: 0),
    };
  }

  TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final now = TZDateTime.now(local);
    var scheduledDate = TZDateTime(
      local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}

// Placeholder classes - should be imported from proper packages
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});
}

class TZDateTime extends DateTime {
  TZDateTime(dynamic location, int year, [int month = 1, int day = 1, int hour = 0, int minute = 0])
      : super(year, month, day, hour, minute);

  static TZDateTime now(dynamic location) => TZDateTime(location, DateTime.now().year);
}

const local = null;

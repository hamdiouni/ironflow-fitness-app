import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Use case for scheduling workout reminders.
class ScheduleWorkoutReminderUseCase {
  final FlutterLocalNotificationsPlugin _notifications;

  ScheduleWorkoutReminderUseCase(this._notifications);

  /// Schedules a daily workout reminder.
  ///
  /// [time] - Time of day to send the reminder
  /// [enabled] - Whether the reminder is enabled
  ///
  /// Returns true if scheduling was successful.
  Future<bool> call({
    required TimeOfDay time,
    required bool enabled,
  }) async {
    if (!enabled) {
      await cancel();
      return true;
    }

    try {
      await _notifications.zonedSchedule(
        0, // Notification ID
        'Time to Workout! 💪',
        'Your body is ready. Let\'s crush this workout!',
        _nextInstanceOfTime(time),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'workout_reminders',
            'Workout Reminders',
            channelDescription: 'Daily workout reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'app_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Cancels the workout reminder.
  Future<void> cancel() async {
    await _notifications.cancel(0);
  }

  /// Snoozes the reminder for a specified duration.
  ///
  /// [minutes] - Number of minutes to snooze (default: 15)
  Future<void> snooze({int minutes = 15}) async {
    await _notifications.zonedSchedule(
      1, // Snooze notification ID
      'Workout Reminder (Snoozed)',
      'Ready to workout now?',
      TZDateTime.now(local).add(Duration(minutes: minutes)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_reminders',
          'Workout Reminders',
          channelDescription: 'Daily workout reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
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

// Placeholder for timezone - should be imported from timezone package
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

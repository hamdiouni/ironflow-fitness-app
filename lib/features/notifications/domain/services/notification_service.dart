import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../entities/reminder_settings.dart';

/// Real notification service using flutter_local_notifications
/// Note: Notifications are only supported on mobile platforms (Android/iOS)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Function(String?)? _onNotificationTap;

  // Notification IDs
  static const int workoutReminderId = 1;
  static const int breakfastReminderId = 2;
  static const int lunchReminderId = 3;
  static const int dinnerReminderId = 4;
  static const int streakReminderId = 5;

  /// Initialize notification service
  Future<void> initialize({
    required Function(String?) onNotificationTap,
  }) async {
    if (_initialized) return;

    // Notifications not supported on Web
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Not supported on Web platform');
      }
      _initialized = true;
      return;
    }

    _onNotificationTap = onNotificationTap;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();
      
      if (kDebugMode) {
        print('✓ [Notifications] Timezone initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Timezone initialization failed: $e');
      }
    }

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      // Initialize plugin
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (details) {
          _onNotificationTap?.call(details.payload);
        },
      );

      _initialized = true;
      
      if (kDebugMode) {
        print('✓ [Notifications] Service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    // Not supported on Web
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Permissions not needed on Web');
      }
      return false;
    }

    if (!_initialized) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Service not initialized. Call initialize() first.');
      }
      return false;
    }

    try {
      // Request permissions on Android 13+
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final granted = await androidPlugin.requestNotificationsPermission();
        if (kDebugMode) {
          print('✓ [Notifications] Android permissions: ${granted ?? false}');
        }
        return granted ?? false;
      }

      // Request permissions on iOS
      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      
      if (iosPlugin != null) {
        final granted = await iosPlugin.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        if (kDebugMode) {
          print('✓ [Notifications] iOS permissions: ${granted ?? false}');
        }
        return granted ?? false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Permission request failed: $e');
      }
      return false;
    }
  }

  /// Request exact alarm permission (Android 12+)
  /// This is required for notifications to be delivered at exact times
  Future<bool> requestExactAlarmPermission() async {
    if (kIsWeb) return false;
    if (!_initialized) return false;

    try {
      // On Android 12+, we need to request exact alarm permission
      if (Platform.isAndroid) {
        final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidPlugin != null) {
          // Check if exact alarms are allowed
          final canScheduleExactAlarms = await androidPlugin.canScheduleExactNotifications();
          
          if (kDebugMode) {
            print('📊 [Notifications] Can schedule exact alarms: $canScheduleExactAlarms');
          }
          
          if (canScheduleExactAlarms == null || !canScheduleExactAlarms) {
            if (kDebugMode) {
              print('⚠️ [Notifications] Requesting exact alarm permission...');
            }
            
            // Request permission by opening settings
            await androidPlugin.requestExactAlarmsPermission();
            
            // Check again after user returns
            final granted = await androidPlugin.canScheduleExactNotifications();
            
            if (kDebugMode) {
              print('✓ [Notifications] Exact alarm permission granted: ${granted ?? false}');
            }
            
            return granted ?? false;
          }
          
          return true;
        }
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Failed to request exact alarm permission: $e');
      }
      return false;
    }
  }

  /// Schedule daily workout reminder
  Future<void> scheduleWorkoutReminder(TimeOfDayModel time, {bool enabled = true}) async {
    // Not supported on Web
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Scheduling not supported on Web');
      }
      return;
    }

    if (!_initialized) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Service not initialized');
      }
      return;
    }

    if (!enabled) {
      await cancelWorkoutReminder();
      return;
    }

    try {
      final scheduledDate = _nextInstanceOfTime(time.hour, time.minute);

      await _notifications.zonedSchedule(
        workoutReminderId,
        '💪 Time to Train!',
        'Your workout is waiting. Let\'s get stronger today!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'workout_reminders',
            'Workout Reminders',
            channelDescription: 'Daily reminders for your workouts',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
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
        payload: 'workout',
      );
      
      if (kDebugMode) {
        print('✓ [Notifications] Workout reminder scheduled for ${time.hour}:${time.minute}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Failed to schedule workout reminder: $e');
      }
    }
  }

  /// Schedule meal reminders
  Future<void> scheduleMealReminders({
    required TimeOfDayModel breakfast,
    required TimeOfDayModel lunch,
    required TimeOfDayModel dinner,
    required bool enabled,
  }) async {
    // Not supported on Web
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Scheduling not supported on Web');
      }
      return;
    }

    if (!_initialized) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Service not initialized');
      }
      return;
    }

    if (!enabled) {
      await cancelMealReminders();
      return;
    }

    try {
      // Schedule breakfast reminder
      await _notifications.zonedSchedule(
        breakfastReminderId,
        '🍳 Breakfast Time!',
        'Log your breakfast to track your nutrition',
        _nextInstanceOfTime(breakfast.hour, breakfast.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Meal Reminders',
            channelDescription: 'Reminders to log your meals',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
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
        payload: 'meal_breakfast',
      );

      // Schedule lunch reminder
      await _notifications.zonedSchedule(
        lunchReminderId,
        '🍱 Lunch Time!',
        'Log your lunch to track your nutrition',
        _nextInstanceOfTime(lunch.hour, lunch.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Meal Reminders',
            channelDescription: 'Reminders to log your meals',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
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
        payload: 'meal_lunch',
      );

      // Schedule dinner reminder
      await _notifications.zonedSchedule(
        dinnerReminderId,
        '🍽️ Dinner Time!',
        'Log your dinner to track your nutrition',
        _nextInstanceOfTime(dinner.hour, dinner.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminders',
            'Meal Reminders',
            channelDescription: 'Reminders to log your meals',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
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
        payload: 'meal_dinner',
      );
      
      if (kDebugMode) {
        print('✓ [Notifications] Meal reminders scheduled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Failed to schedule meal reminders: $e');
      }
    }
  }

  /// Schedule streak reminder
  Future<void> scheduleStreakReminder(TimeOfDayModel time, {bool enabled = true}) async {
    // Not supported on Web
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Scheduling not supported on Web');
      }
      return;
    }

    if (!_initialized) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Service not initialized');
      }
      return;
    }

    if (!enabled) {
      await cancelStreakReminder();
      return;
    }

    try {
      final scheduledDate = _nextInstanceOfTime(time.hour, time.minute);

      await _notifications.zonedSchedule(
        streakReminderId,
        '🔥 Keep Your Streak!',
        'Don\'t break your workout streak. Train today!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'streak_reminders',
            'Streak Reminders',
            channelDescription: 'Reminders to maintain your workout streak',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
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
        payload: 'streak',
      );
      
      if (kDebugMode) {
        print('✓ [Notifications] Streak reminder scheduled for ${time.hour}:${time.minute}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Failed to schedule streak reminder: $e');
      }
    }
  }

  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Not supported on Web
    if (kIsWeb) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Show notification not supported on Web');
      }
      return;
    }

    if (!_initialized) {
      if (kDebugMode) {
        print('⚠️ [Notifications] Service not initialized');
      }
      return;
    }

    try {
      await _notifications.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'general',
            'General Notifications',
            channelDescription: 'General app notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Failed to show notification: $e');
      }
    }
  }

  /// Cancel workout reminder
  Future<void> cancelWorkoutReminder() async {
    if (kIsWeb) return;
    if (!_initialized) return;
    
    try {
      await _notifications.cancel(workoutReminderId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Failed to cancel workout reminder: $e');
      }
    }
  }

  /// Cancel meal reminders
  Future<void> cancelMealReminders() async {
    if (kIsWeb) return;
    if (!_initialized) return;
    
    try {
      await _notifications.cancel(breakfastReminderId);
      await _notifications.cancel(lunchReminderId);
      await _notifications.cancel(dinnerReminderId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Failed to cancel meal reminders: $e');
      }
    }
  }

  /// Cancel streak reminder
  Future<void> cancelStreakReminder() async {
    if (kIsWeb) return;
    if (!_initialized) return;
    
    try {
      await _notifications.cancel(streakReminderId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Failed to cancel streak reminder: $e');
      }
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb) return;
    if (!_initialized) return;
    
    try {
      await _notifications.cancelAll();
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Failed to cancel all notifications: $e');
      }
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return false;
    if (!_initialized) return false;

    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        final enabled = await androidPlugin.areNotificationsEnabled();
        return enabled ?? false;
      }

      return true; // Assume enabled on other platforms
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Notifications] Failed to check notification status: $e');
      }
      return false;
    }
  }

  /// Calculate next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:progression_tracker/features/retention/domain/usecases/schedule_workout_reminder_use_case.dart';
import 'package:progression_tracker/features/retention/domain/usecases/schedule_meal_reminder_use_case.dart';

/// Screen for configuring workout and meal reminders.
///
/// **Validates: Requirements 6.1, 6.2**
class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState
    extends ConsumerState<ReminderSettingsScreen> {
  bool _workoutRemindersEnabled = false;
  TimeOfDay _workoutReminderTime = const TimeOfDay(hour: 18, minute: 0);

  bool _mealRemindersEnabled = false;
  final Map<String, TimeOfDay> _mealReminderTimes = {
    'Breakfast': const TimeOfDay(hour: 8, minute: 0),
    'Lunch': const TimeOfDay(hour: 12, minute: 30),
    'Dinner': const TimeOfDay(hour: 18, minute: 30),
  };

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _workoutRemindersEnabled =
          prefs.getBool('workout_reminders_enabled') ?? false;
      final workoutHour = prefs.getInt('workout_reminder_hour') ?? 18;
      final workoutMinute = prefs.getInt('workout_reminder_minute') ?? 0;
      _workoutReminderTime = TimeOfDay(hour: workoutHour, minute: workoutMinute);

      _mealRemindersEnabled = prefs.getBool('meal_reminders_enabled') ?? false;

      // Load meal times
      for (final meal in _mealReminderTimes.keys) {
        final hour = prefs.getInt('meal_${meal.toLowerCase()}_hour');
        final minute = prefs.getInt('meal_${meal.toLowerCase()}_minute');
        if (hour != null && minute != null) {
          _mealReminderTimes[meal] = TimeOfDay(hour: hour, minute: minute);
        }
      }

      _isLoading = false;
    });
  }

  Future<void> _saveWorkoutReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('workout_reminders_enabled', _workoutRemindersEnabled);
    await prefs.setInt('workout_reminder_hour', _workoutReminderTime.hour);
    await prefs.setInt('workout_reminder_minute', _workoutReminderTime.minute);

    // Schedule or cancel reminder
    final notifications = FlutterLocalNotificationsPlugin();
    final useCase = ScheduleWorkoutReminderUseCase(notifications);
    await useCase(
      time: _workoutReminderTime,
      enabled: _workoutRemindersEnabled,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout reminder settings saved')),
      );
    }
  }

  Future<void> _saveMealReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('meal_reminders_enabled', _mealRemindersEnabled);

    // Save meal times
    for (final entry in _mealReminderTimes.entries) {
      await prefs.setInt('meal_${entry.key.toLowerCase()}_hour', entry.value.hour);
      await prefs.setInt('meal_${entry.key.toLowerCase()}_minute', entry.value.minute);
    }

    // Schedule or cancel reminders
    final notifications = FlutterLocalNotificationsPlugin();
    final useCase = ScheduleMealReminderUseCase(notifications);
    await useCase(
      mealTimes: _mealReminderTimes,
      enabled: _mealRemindersEnabled,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal reminder settings saved')),
      );
    }
  }

  Future<void> _selectWorkoutTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _workoutReminderTime,
    );

    if (picked != null && picked != _workoutReminderTime) {
      setState(() {
        _workoutReminderTime = picked;
      });
      await _saveWorkoutReminderSettings();
    }
  }

  Future<void> _selectMealTime(String mealName) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _mealReminderTimes[mealName]!,
    );

    if (picked != null && picked != _mealReminderTimes[mealName]) {
      setState(() {
        _mealReminderTimes[mealName] = picked;
      });
      await _saveMealReminderSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reminder Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        children: [
          _buildWorkoutRemindersSection(),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildMealRemindersSection(),
          const SizedBox(height: AppTheme.spacingLarge),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildWorkoutRemindersSection() {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workout Reminders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Get notified when it\'s time to work out',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _workoutRemindersEnabled,
                onChanged: (value) async {
                  setState(() {
                    _workoutRemindersEnabled = value;
                  });
                  await _saveWorkoutReminderSettings();
                },
              ),
            ],
          ),
          if (_workoutRemindersEnabled) ...[
            const SizedBox(height: AppTheme.spacingMedium),
            const Divider(),
            const SizedBox(height: AppTheme.spacingMedium),
            ListTile(
              leading: const Icon(Icons.access_time, color: AppTheme.primaryColor),
              title: const Text('Reminder Time'),
              subtitle: Text(_formatTime(_workoutReminderTime)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectWorkoutTime,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealRemindersSection() {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: AppTheme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meal Reminders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Get notified to log your meals',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _mealRemindersEnabled,
                onChanged: (value) async {
                  setState(() {
                    _mealRemindersEnabled = value;
                  });
                  await _saveMealReminderSettings();
                },
              ),
            ],
          ),
          if (_mealRemindersEnabled) ...[
            const SizedBox(height: AppTheme.spacingMedium),
            const Divider(),
            const SizedBox(height: AppTheme.spacingMedium),
            ..._mealReminderTimes.entries.map((entry) {
              return ListTile(
                leading: Icon(
                  _getMealIcon(entry.key),
                  color: AppTheme.accentColor,
                ),
                title: Text(entry.key),
                subtitle: Text(_formatTime(entry.value)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectMealTime(entry.key),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return AppTheme.glassmorphicCard(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.primaryColor.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Reminders help you stay consistent with your fitness goals. '
              'You can snooze or disable them anytime.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  IconData _getMealIcon(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/reminder_settings.dart';
import '../providers/notification_providers.dart';

/// Screen for configuring reminder settings
class ReminderSettingsScreen extends ConsumerWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(reminderSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () async {
              try {
                final notificationService = ref.read(notificationServiceProvider);
                
                // First check if notifications are enabled
                final enabled = await notificationService.areNotificationsEnabled();
                
                if (!enabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Notifications are disabled in system settings'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 4),
                    ),
                  );
                  return;
                }
                
                // Show immediate test notification
                await notificationService.showNotification(
                  id: 999,
                  title: '🔔 Test Notification',
                  body: 'Time: ${DateTime.now().toString().substring(11, 16)} - Check your notification panel!',
                  payload: 'test',
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Test notification sent! Check your notification panel.'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error: $e'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
            tooltip: 'Test Notification Now',
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(reminderSettingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (settings) => _buildSettingsList(context, ref, settings),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref, ReminderSettings settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Workout Reminders Section
        _buildSectionHeader('Workout Reminders'),
        _buildSwitchTile(
          context: context,
          title: 'Workout Reminders',
          subtitle: 'Get reminded to complete your daily workout',
          value: settings.workoutRemindersEnabled,
          onChanged: (value) {
            ref.read(reminderSettingsProvider.notifier).updateWorkoutReminder(enabled: value);
          },
        ),
        if (settings.workoutRemindersEnabled)
          _buildTimeTile(
            context: context,
            title: 'Workout Time',
            time: settings.workoutReminderTime,
            onTimeSelected: (time) {
              ref.read(reminderSettingsProvider.notifier).updateWorkoutReminder(time: time);
            },
          ),
        const Divider(height: 32),

        // Meal Reminders Section
        _buildSectionHeader('Meal Reminders'),
        _buildSwitchTile(
          context: context,
          title: 'Meal Reminders',
          subtitle: 'Get reminded to log your meals',
          value: settings.mealRemindersEnabled,
          onChanged: (value) {
            ref.read(reminderSettingsProvider.notifier).updateMealReminders(enabled: value);
          },
        ),
        if (settings.mealRemindersEnabled) ...[
          _buildTimeTile(
            context: context,
            title: 'Breakfast Time',
            time: settings.breakfastTime,
            onTimeSelected: (time) {
              ref.read(reminderSettingsProvider.notifier).updateMealReminders(breakfastTime: time);
            },
          ),
          _buildTimeTile(
            context: context,
            title: 'Lunch Time',
            time: settings.lunchTime,
            onTimeSelected: (time) {
              ref.read(reminderSettingsProvider.notifier).updateMealReminders(lunchTime: time);
            },
          ),
          _buildTimeTile(
            context: context,
            title: 'Dinner Time',
            time: settings.dinnerTime,
            onTimeSelected: (time) {
              ref.read(reminderSettingsProvider.notifier).updateMealReminders(dinnerTime: time);
            },
          ),
        ],
        const Divider(height: 32),

        // Streak Reminders Section
        _buildSectionHeader('Streak Reminders'),
        _buildSwitchTile(
          context: context,
          title: 'Streak Reminders',
          subtitle: 'Get reminded to maintain your workout streak',
          value: settings.streakRemindersEnabled,
          onChanged: (value) {
            ref.read(reminderSettingsProvider.notifier).updateStreakReminder(enabled: value);
          },
        ),
        if (settings.streakRemindersEnabled)
          _buildTimeTile(
            context: context,
            title: 'Streak Reminder Time',
            time: settings.streakReminderTime,
            onTimeSelected: (time) {
              ref.read(reminderSettingsProvider.notifier).updateStreakReminder(time: time);
            },
          ),
        const Divider(height: 32),

        // Notification Settings Section
        _buildSectionHeader('Notification Settings'),
        _buildSwitchTile(
          context: context,
          title: 'Sound',
          subtitle: 'Play sound for notifications',
          value: settings.soundEnabled,
          onChanged: (value) {
            ref.read(reminderSettingsProvider.notifier).updateSoundAndVibration(soundEnabled: value);
          },
        ),
        _buildSwitchTile(
          context: context,
          title: 'Vibration',
          subtitle: 'Vibrate for notifications',
          value: settings.vibrationEnabled,
          onChanged: (value) {
            ref.read(reminderSettingsProvider.notifier).updateSoundAndVibration(vibrationEnabled: value);
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildTimeTile({
    required BuildContext context,
    required String title,
    required TimeOfDayModel time,
    required ValueChanged<TimeOfDayModel> onTimeSelected,
  }) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time.toDisplayString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.access_time),
        ],
      ),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
        );

        if (picked != null) {
          onTimeSelected(TimeOfDayModel(hour: picked.hour, minute: picked.minute));
        }
      },
    );
  }
}

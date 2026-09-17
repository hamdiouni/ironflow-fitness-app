import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../providers/notification_settings_provider.dart';

/// Screen for managing notification preferences.
///
/// Allows users to:
/// - Enable/disable notifications
/// - Set reminder time
/// - Toggle achievement notifications
/// - Toggle streak reminders
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: settingsAsync.when(
        data: (settings) => _SettingsContent(settings: settings),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading settings: $error'),
        ),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  final dynamic settings;

  const _SettingsContent({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      children: [
        // Enable/Disable notifications
        AppTheme.glassmorphicCard(
          padding: const EdgeInsets.all(AppTheme.spacingMedium),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settings.isEnabled ? 'Enabled' : 'Disabled',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Switch(
                value: settings.isEnabled,
                onChanged: (value) {
                  ref
                      .read(notificationSettingsNotifierProvider.notifier)
                      .toggleNotifications();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppTheme.spacingMedium),

        // Reminder time
        if (settings.isEnabled) ...[
          AppTheme.glassmorphicCard(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reminder Time',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TimePickerField(
                        label: 'Hour',
                        value: settings.reminderHour,
                        onChanged: (hour) {
                          ref
                              .read(
                                  notificationSettingsNotifierProvider.notifier)
                              .setReminderTime(hour, settings.reminderMinute);
                        },
                        max: 23,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSmall),
                    Expanded(
                      child: _TimePickerField(
                        label: 'Minute',
                        value: settings.reminderMinute,
                        onChanged: (minute) {
                          ref
                              .read(
                                  notificationSettingsNotifierProvider.notifier)
                              .setReminderTime(settings.reminderHour, minute);
                        },
                        max: 59,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Achievement notifications
          AppTheme.glassmorphicCard(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Achievement Notifications',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: settings.showAchievements,
                  onChanged: (value) {
                    ref
                        .read(
                            notificationSettingsNotifierProvider.notifier)
                        .toggleAchievementNotifications();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Streak reminders
          AppTheme.glassmorphicCard(
            padding: const EdgeInsets.all(AppTheme.spacingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Streak Reminders',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Switch(
                  value: settings.showStreakReminders,
                  onChanged: (value) {
                    ref
                        .read(
                            notificationSettingsNotifierProvider.notifier)
                        .toggleStreakReminders();
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TimePickerField extends StatelessWidget {
  final String label;
  final int value;
  final Function(int) onChanged;
  final int max;

  const _TimePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: value.toString().padLeft(2, '0')),
          keyboardType: TextInputType.number,
          maxLength: 2,
          onChanged: (text) {
            final intValue = int.tryParse(text) ?? 0;
            if (intValue >= 0 && intValue <= max) {
              onChanged(intValue);
            }
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSmall,
              vertical: AppTheme.spacingSmall,
            ),
            counterText: '',
          ),
        ),
      ],
    );
  }
}

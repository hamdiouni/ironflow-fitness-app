import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/reminder_settings.dart';
import '../providers/notification_providers.dart';

/// Monolithic Sci-Fi screen for configuring reminder settings
class ReminderSettingsScreen extends ConsumerWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = AppThemeTokens.of(context);
    final settingsAsync = ref.watch(reminderSettingsProvider);

    return Scaffold(
      backgroundColor: tokens.canvas,
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'REMINDER SETTINGS',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'NOTIFICATION MATRIX',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: tokens.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: BorderRadius.circular(tokens.radiusSm),
                border: Border.all(color: tokens.borderSubtle, width: 1),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_active_rounded,
                  color: tokens.kineticAccent,
                  size: 20,
                ),
                tooltip: 'Test Notification Telemetry',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                onPressed: () async {
                  try {
                    final notificationService =
                        ref.read(notificationServiceProvider);

                    final enabled =
                        await notificationService.areNotificationsEnabled();

                    if (!enabled && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              '❌ Notifications disabled in system settings'),
                          backgroundColor: tokens.error,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                      return;
                    }

                    await notificationService.showNotification(
                      id: 999,
                      title: '⚡ TELEMETRY PING',
                      body:
                          'Time: ${DateTime.now().toString().substring(11, 16)} — IronFlow notification pipeline active.',
                      payload: 'test',
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              '✅ Test notification dispatched to notification shade'),
                          backgroundColor: tokens.panel,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: tokens.error,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: settingsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: tokens.kineticAccent),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 48, color: tokens.error),
                const SizedBox(height: 16),
                Text(
                  'TELEMETRY ERROR: $error',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    color: tokens.error,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => ref.invalidate(reminderSettingsProvider),
                  child: Text(
                    'RETRY SYNC',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      color: tokens.kineticAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (settings) => _buildSettingsList(context, ref, settings, tokens),
      ),
    );
  }

  Widget _buildSettingsList(
    BuildContext context,
    WidgetRef ref,
    ReminderSettings settings,
    AppThemeTokens tokens,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
      children: [
        // Workout Reminders Section
        _buildSectionHeader('WORKOUT DIRECTIVES', tokens),
        Container(
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(color: tokens.borderSubtle, width: 1),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                title: 'Workout Reminders',
                subtitle: 'Scheduled prompt to complete assigned session',
                value: settings.workoutRemindersEnabled,
                tokens: tokens,
                onChanged: (value) {
                  ref
                      .read(reminderSettingsProvider.notifier)
                      .updateWorkoutReminder(enabled: value);
                },
              ),
              if (settings.workoutRemindersEnabled) ...[
                Divider(color: tokens.borderSubtle, height: 1),
                _buildTimeTile(
                  context: context,
                  title: 'Daily Workout Time',
                  time: settings.workoutReminderTime,
                  tokens: tokens,
                  onTimeSelected: (time) {
                    ref
                        .read(reminderSettingsProvider.notifier)
                        .updateWorkoutReminder(time: time);
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Meal Reminders Section
        _buildSectionHeader('NUTRITION DIRECTIVES', tokens),
        Container(
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(color: tokens.borderSubtle, width: 1),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                title: 'Meal Reminders',
                subtitle: 'Scheduled prompts to log fuel intake & macros',
                value: settings.mealRemindersEnabled,
                tokens: tokens,
                onChanged: (value) {
                  ref
                      .read(reminderSettingsProvider.notifier)
                      .updateMealReminders(enabled: value);
                },
              ),
              if (settings.mealRemindersEnabled) ...[
                Divider(color: tokens.borderSubtle, height: 1),
                _buildTimeTile(
                  context: context,
                  title: 'Breakfast Window',
                  time: settings.breakfastTime,
                  tokens: tokens,
                  onTimeSelected: (time) {
                    ref
                        .read(reminderSettingsProvider.notifier)
                        .updateMealReminders(breakfastTime: time);
                  },
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _buildTimeTile(
                  context: context,
                  title: 'Lunch Window',
                  time: settings.lunchTime,
                  tokens: tokens,
                  onTimeSelected: (time) {
                    ref
                        .read(reminderSettingsProvider.notifier)
                        .updateMealReminders(lunchTime: time);
                  },
                ),
                Divider(color: tokens.borderSubtle, height: 1),
                _buildTimeTile(
                  context: context,
                  title: 'Dinner Window',
                  time: settings.dinnerTime,
                  tokens: tokens,
                  onTimeSelected: (time) {
                    ref
                        .read(reminderSettingsProvider.notifier)
                        .updateMealReminders(dinnerTime: time);
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Streak Reminders Section
        _buildSectionHeader('STREAK CONTINUITY', tokens),
        Container(
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(color: tokens.borderSubtle, width: 1),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                title: 'Streak Warning',
                subtitle: 'Notice to preserve current active consistency streak',
                value: settings.streakRemindersEnabled,
                tokens: tokens,
                onChanged: (value) {
                  ref
                      .read(reminderSettingsProvider.notifier)
                      .updateStreakReminder(enabled: value);
                },
              ),
              if (settings.streakRemindersEnabled) ...[
                Divider(color: tokens.borderSubtle, height: 1),
                _buildTimeTile(
                  context: context,
                  title: 'Streak Warning Time',
                  time: settings.streakReminderTime,
                  tokens: tokens,
                  onTimeSelected: (time) {
                    ref
                        .read(reminderSettingsProvider.notifier)
                        .updateStreakReminder(time: time);
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Notification Settings Section
        _buildSectionHeader('HAPTIC & AUDIO PROTOCOL', tokens),
        Container(
          decoration: BoxDecoration(
            color: tokens.panel,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(color: tokens.borderSubtle, width: 1),
          ),
          child: Column(
            children: [
              _buildSwitchTile(
                title: 'Audio Chime',
                subtitle: 'Auditory alert tone upon dispatch',
                value: settings.soundEnabled,
                tokens: tokens,
                onChanged: (value) {
                  ref
                      .read(reminderSettingsProvider.notifier)
                      .updateSoundAndVibration(soundEnabled: value);
                },
              ),
              Divider(color: tokens.borderSubtle, height: 1),
              _buildSwitchTile(
                title: 'Haptic Feedback',
                subtitle: 'Vibratory impulse upon notification delivery',
                value: settings.vibrationEnabled,
                tokens: tokens,
                onChanged: (value) {
                  ref
                      .read(reminderSettingsProvider.notifier)
                      .updateSoundAndVibration(vibrationEnabled: value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, AppThemeTokens tokens) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: AppTypography.displayFontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: tokens.textMuted,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required AppThemeTokens tokens,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: tokens.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 12,
          color: tokens.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: tokens.kineticAccent,
    );
  }

  Widget _buildTimeTile({
    required BuildContext context,
    required String title,
    required TimeOfDayModel time,
    required ValueChanged<TimeOfDayModel> onTimeSelected,
    required AppThemeTokens tokens,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: AppTypography.bodyFontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: tokens.textPrimary,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: tokens.card,
          borderRadius: BorderRadius.circular(tokens.radiusSm),
          border: Border.all(color: tokens.borderSubtle, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time.toDisplayString(),
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: tokens.kineticAccent,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.access_time_rounded,
                size: 14, color: tokens.kineticAccent),
          ],
        ),
      ),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: tokens.kineticAccent,
                      surface: tokens.panel,
                    ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          onTimeSelected(
              TimeOfDayModel(hour: picked.hour, minute: picked.minute));
        }
      },
    );
  }
}

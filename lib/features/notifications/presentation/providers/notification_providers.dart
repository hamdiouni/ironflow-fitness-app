import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/hive_reminder_settings_datasource.dart';
import '../../data/repositories/reminder_settings_repository_impl.dart';
import '../../domain/entities/reminder_settings.dart';
import '../../domain/repositories/reminder_settings_repository.dart';
import '../../domain/services/notification_service.dart';
import '../notifiers/reminder_settings_notifier.dart';

/// Provider for Hive datasource
final hiveReminderSettingsDatasourceProvider = Provider<HiveReminderSettingsDatasource>((ref) {
  return HiveReminderSettingsDatasource();
});

/// Provider for reminder settings repository
final reminderSettingsRepositoryProvider = Provider<ReminderSettingsRepository>((ref) {
  final datasource = ref.watch(hiveReminderSettingsDatasourceProvider);
  return ReminderSettingsRepositoryImpl(datasource);
});

/// Provider for notification service singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for reminder settings state
final reminderSettingsProvider = StateNotifierProvider<ReminderSettingsNotifier, AsyncValue<ReminderSettings>>((ref) {
  final repository = ref.watch(reminderSettingsRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return ReminderSettingsNotifier(repository, notificationService);
});

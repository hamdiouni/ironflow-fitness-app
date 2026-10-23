import 'package:progression_tracker/core/utils/app_logger.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/secure_storage_manager.dart';
import '../../../notifications/domain/services/notification_service.dart';

/// Service responsible for wiping user-scoped data across local storage.
///
/// Guaranteed isolation: Never touches bundled food datasets, exercise libraries,
/// or another account's boxes on the same device.
class LocalDataWiper {
  final SecureStorageManager _secureStorage;
  final NotificationService _notificationService;
  final Directory? _privateDocumentsDir;

  LocalDataWiper({
    SecureStorageManager? secureStorage,
    NotificationService? notificationService,
    Directory? privateDocumentsDir,
  })  : _secureStorage = secureStorage ?? SecureStorageManager(),
        _notificationService = notificationService ?? NotificationService(),
        _privateDocumentsDir = privateDocumentsDir;

  /// User-scoped Hive boxes that store user training, nutrition, biometrics, and telemetry.
  /// Keep in sync with HiveManager's box inventory (DATABASE_AND_SYNC_AUDIT F-04):
  /// 'active_program', 'diet_plan', 'active_workout_state' were previously missing,
  /// leaking the previous account's program/diet/in-progress workout after a wipe.
  static const List<String> _userScopedBoxNames = [
    'workouts',
    'nutrition',
    'programs',
    'user',
    'settings',
    'sync_queue',
    'body_entries',
    'streak',
    'notification_settings',
    'meals',
    'macro_targets',
    'insight_cache',
    'user_profile',
    'ai_chat_history',
    'active_program',
    'diet_plan',
    'food_items_full',
    'active_workout_state',
  ];

  /// Core bundled dataset boxes that MUST NEVER BE CLEARED OR DELETED.
  static const Set<String> _protectedDatasetBoxes = {
    'foods',
    'food_items',
    'exercises',
  };

  /// Completely wipes all user-scoped data from this device for [userId].
  ///
  /// If [keepAuthSession] is true (used by "Delete Local Data" action),
  /// the user's login session and auth tokens are preserved so they remain signed in.
  /// If [keepAuthSession] is false (used by "Delete Account" action),
  /// session storage and secure storage tokens are also eradicated.
  Future<void> wipeAllUserData(String userId, {bool keepAuthSession = false}) async {
    if (kDebugMode) {
      AppLogger.debug('🗑️ [LocalDataWiper] Starting local user wipe for: $userId (keepAuth: $keepAuthSession)');
    }

    // 1. Wipe user-scoped Hive boxes
    await _wipeHiveBoxes(userId, keepAuthSession);

    // 2. Wipe user-scoped files (snapshots, exports, progress photos)
    await _wipeUserFiles();

    // 3. Cancel all scheduled notifications
    await _cancelScheduledNotifications();

    // 4. Wipe secure storage tokens if full account deletion
    if (!keepAuthSession) {
      await _wipeSecureStorage();
    }

    // 5. Wipe user-scoped SharedPreferences flags
    await _wipeUserPreferences(keepAuthSession);

    if (kDebugMode) {
      AppLogger.debug('✅ [LocalDataWiper] Local user wipe complete for: $userId');
    }
  }

  Future<void> _wipeHiveBoxes(String userId, bool keepAuthSession) async {
    for (final boxName in _userScopedBoxNames) {
      // Critical check: Never clear protected bundled datasets
      if (_protectedDatasetBoxes.contains(boxName)) {
        continue;
      }
      try {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        } else {
          final box = await Hive.openBox(boxName);
          await box.clear();
        }
      } catch (e) {
        if (kDebugMode) {
          AppLogger.debug('⚠️ [LocalDataWiper] Could not clear box $boxName: $e');
        }
      }
    }

    // User-specific keyed profile box (e.g. user_profile_box_${userId})
    if (userId.isNotEmpty) {
      final userSpecificBoxName = 'user_profile_box_$userId';
      try {
        if (Hive.isBoxOpen(userSpecificBoxName)) {
          final box = Hive.box(userSpecificBoxName);
          await box.clear();
        } else {
          final box = await Hive.openBox(userSpecificBoxName);
          await box.clear();
        }
      } catch (e) {
        if (kDebugMode) {
          AppLogger.debug('⚠️ [LocalDataWiper] Could not clear $userSpecificBoxName: $e');
        }
      }
    }

    // App state box keys (active_workout_state, active_program)
    try {
      if (Hive.isBoxOpen('app_state')) {
        await Hive.box('app_state').clear();
      }
    } catch (_) {}

    // Auth session box if full account deletion
    if (!keepAuthSession) {
      try {
        if (Hive.isBoxOpen('auth_session')) {
          await Hive.box('auth_session').clear();
        } else {
          final box = await Hive.openBox('auth_session');
          await box.clear();
        }
      } catch (_) {}
    }
  }

  Future<void> _wipeUserFiles() async {
    try {
      Directory? baseDir;
      if (_privateDocumentsDir != null) {
        baseDir = _privateDocumentsDir;
      } else {
        try {
          baseDir = await getApplicationDocumentsDirectory();
        } catch (_) {
          baseDir = null;
        }
      }

      if (baseDir == null || !await baseDir.exists()) return;

      // 1. Wipe safety snapshots directory
      final snapshotsDir = Directory('${baseDir.path}/safety_snapshots');
      if (await snapshotsDir.exists()) {
        final files = snapshotsDir.listSync().whereType<File>();
        for (final f in files) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }

      // 2. Wipe progress photos directory
      final photosDir = Directory('${baseDir.path}/progress_photos');
      if (await photosDir.exists()) {
        final files = photosDir.listSync().whereType<File>();
        for (final f in files) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }

      // 3. Wipe export files (.json and .csv) in documents directory
      final rootFiles = baseDir.listSync().whereType<File>();
      for (final f in rootFiles) {
        final name = f.path.toLowerCase();
        if (name.contains('backup') ||
            name.contains('export') ||
            name.contains('snapshot') ||
            name.endsWith('.csv') ||
            name.endsWith('.json')) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [LocalDataWiper] File wipe note: $e');
      }
    }
  }

  Future<void> _cancelScheduledNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [LocalDataWiper] Could not cancel notifications: $e');
      }
    }
  }

  Future<void> _wipeSecureStorage() async {
    try {
      await _secureStorage.clearAll();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [LocalDataWiper] Secure storage clear note: $e');
      }
    }
  }

  Future<void> _wipeUserPreferences(bool keepAuthSession) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // User-specific keys to purge
      final userPrefKeys = [
        'onboarding_completed',
        'ai_personalization_consent',
        'analytics_enabled',
        'crash_reporting_enabled',
        'data_sharing_enabled',
        'active_workout_backup',
        'last_active_workout_id',
        'last_sync_timestamp',
        'current_user_profile',
      ];

      for (final key in userPrefKeys) {
        await prefs.remove(key);
      }

      if (!keepAuthSession) {
        await prefs.remove('current_user_id');
        await prefs.remove('user_email');
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [LocalDataWiper] SharedPreferences wipe note: $e');
      }
    }
  }
}

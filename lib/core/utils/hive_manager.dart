import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:progression_tracker/core/services/hive_encryption_service.dart';
import 'package:progression_tracker/core/utils/app_logger.dart';

/// Central Hive lifecycle manager for IronFlow (Wave 3.1 / 3.2).
///
/// - **Tier-1 critical boot boxes** (`auth_session`, `user_profile`,
///   `app_settings`, `active_workout_state`) open concurrently in [initialize]
///   before `runApp`.
/// - **Tier-2 feature boxes** open lazily on first access through [ensureOpen]
///   with single-flight coalescing and encryption policy enforcement.
/// - Static catalog boxes (`exercises`, `foods`) are never cleared by
///   [clearAll].
class HiveManager {
  static const String workoutsBox = 'workouts';
  static const String nutritionBox = 'nutrition';
  static const String programsBox = 'programs';
  static const String userBox = 'user';
  static const String settingsBox = 'settings';
  static const String syncQueueBox = 'sync_queue';
  static const String exercisesBox = 'exercises';
  static const String foodsBox = 'foods';
  static const String customFoodsBox = 'custom_foods';
  static const String bodyEntriesBox = 'body_entries';
  static const String streakBox = 'streak';
  static const String notificationSettingsBox = 'notification_settings';
  static const String mealsBox = 'meals';
  static const String macroTargetsBox = 'macro_targets';
  static const String appSettingsBox = 'app_settings';
  static const String authSessionBox = 'auth_session';
  static const String insightCacheBox = 'insight_cache';
  static const String userProfileBox = 'user_profile';
  static const String aiChatHistoryBox = 'ai_chat_history';
  static const String activeProgramBox = 'active_program';
  static const String dietPlanBox = 'diet_plan';
  static const String foodItemsFullBox = 'food_items_full';
  static const String activeWorkoutStateBox = 'active_workout_state';

  static const Set<String> tier1Boxes = {
    authSessionBox,
    userProfileBox,
    appSettingsBox,
    activeWorkoutStateBox,
  };

  static const Set<String> protectedCatalogBoxes = {
    exercisesBox,
    foodsBox,
  };

  /// Active encryption service (reassignable in unit tests via [resetForTest]).
  static HiveEncryptionService encryptionService = HiveEncryptionService();
  static final Map<String, Future<Box<dynamic>>> _inFlightOpens = {};

  /// Resets in-memory test state between test cases.
  @visibleForTesting
  static void resetForTest() {
    _inFlightOpens.clear();
    encryptionService = HiveEncryptionService();
  }

  static Future<Box<E>> _openBoxWithPolicy<E>(String boxName) async {
    if (HiveEncryptionService.sensitiveBoxes.contains(boxName)) {
      return encryptionService.openEncryptedBox<E>(boxName);
    }
    return Hive.openBox<E>(boxName);
  }

  /// Initializes Hive with Flutter paths and opens all Tier-1 boxes
  /// concurrently before `runApp`. Tier-2 boxes stay closed until accessed via
  /// [ensureOpen].
  static Future<void> initialize() async {
    try {
      AppLogger.debug('📊 [Hive] Initializing Hive...');
      await Hive.initFlutter();
      AppLogger.debug('✅ [Hive] Hive initialized successfully');
      await _openTier1BoxesConcurrently();
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Hive] Failed to initialize: $e');
      AppLogger.debug('🔍 [Hive] Stack trace: $stackTrace');
      throw Exception('Failed to initialize Hive: $e');
    }
  }

  /// Test-friendly initialization for an explicit filesystem [directoryPath].
  @visibleForTesting
  static Future<void> initializeForDirectory(String directoryPath) async {
    Hive.init(directoryPath);
    await _openTier1BoxesConcurrently();
  }

  static Future<void> _openTier1BoxesConcurrently() async {
    await encryptionService.warmCache();
    await Future.wait([
      ensureOpen<dynamic>(authSessionBox),
      ensureOpen<dynamic>(userProfileBox),
      ensureOpen<String>(appSettingsBox),
      ensureOpen<dynamic>(activeWorkoutStateBox),
    ]);
    AppLogger.debug('✅ [Hive] All Tier-1 boxes opened concurrently');
  }

  /// Ensures [boxName] is open using single-flight coalescing and encryption
  /// policy. Safe to call concurrently from multiple datasources.
  static Future<Box<E>> ensureOpen<E>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<E>(boxName);
    }
    if (!kIsWeb) {
      try {
        if ((Hive as dynamic).homePath == null) {
          throw HiveError(
            'Hive is not initialized; cannot open box "$boxName".',
          );
        }
      } on HiveError {
        rethrow;
      } catch (_) {}
    }
    final existingFuture = _inFlightOpens[boxName];
    if (existingFuture != null) {
      await existingFuture;
      return Hive.box<E>(boxName);
    }

    final future = _openBoxWithPolicy<E>(boxName);
    _inFlightOpens[boxName] = future;
    try {
      return await future;
    } finally {
      _inFlightOpens.remove(boxName);
    }
  }

  static Box<E> _requireOpenBox<E>(String boxName) {
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError(
        'Hive box "$boxName" is not open. Call HiveManager.ensureOpen("$boxName") first.',
      );
    }
    return Hive.box<E>(boxName);
  }

  // --- Typed async ensure helpers for Tier-1 & Tier-2 callers ---

  static Future<Box<Map>> ensureWorkoutBox() => ensureOpen<Map>(workoutsBox);
  static Future<Box<Map>> ensureNutritionBox() => ensureOpen<Map>(nutritionBox);
  static Future<Box<Map>> ensureProgramBox() => ensureOpen<Map>(programsBox);
  static Future<Box<Map>> ensureUserBox() => ensureOpen<Map>(userBox);
  static Future<Box<Map>> ensureSettingsBox() => ensureOpen<Map>(settingsBox);
  static Future<Box<Map>> ensureSyncQueueBox() => ensureOpen<Map>(syncQueueBox);
  static Future<Box<Map>> ensureExercisesBox() => ensureOpen<Map>(exercisesBox);
  static Future<Box<dynamic>> ensureFoodsBox() => ensureOpen<dynamic>(foodsBox);
  static Future<Box<dynamic>> ensureCustomFoodsBox() =>
      ensureOpen<dynamic>(customFoodsBox);
  static Future<Box<Map>> ensureBodyEntriesBox() =>
      ensureOpen<Map>(bodyEntriesBox);
  static Future<Box<Map>> ensureStreakBox() => ensureOpen<Map>(streakBox);
  static Future<Box<Map>> ensureNotificationSettingsBox() =>
      ensureOpen<Map>(notificationSettingsBox);
  static Future<Box<Map>> ensureMealsBox() => ensureOpen<Map>(mealsBox);
  static Future<Box<Map>> ensureMacroTargetsBox() =>
      ensureOpen<Map>(macroTargetsBox);
  static Future<Box<String>> ensureAppSettingsBox() =>
      ensureOpen<String>(appSettingsBox);
  static Future<Box<dynamic>> ensureAuthSessionBox() =>
      ensureOpen<dynamic>(authSessionBox);
  static Future<Box<Map>> ensureInsightCacheBox() =>
      ensureOpen<Map>(insightCacheBox);
  static Future<Box<dynamic>> ensureUserProfileBox() =>
      ensureOpen<dynamic>(userProfileBox);
  static Future<Box<dynamic>> ensureAIChatHistoryBox() =>
      ensureOpen<dynamic>(aiChatHistoryBox);
  static Future<Box<Map>> ensureActiveProgramBox() =>
      ensureOpen<Map>(activeProgramBox);
  static Future<Box<Map>> ensureDietPlanBox() => ensureOpen<Map>(dietPlanBox);
  static Future<Box<Map>> ensureFoodItemsFullBox() =>
      ensureOpen<Map>(foodItemsFullBox);
  static Future<Box<dynamic>> ensureActiveWorkoutStateBox() =>
      ensureOpen<dynamic>(activeWorkoutStateBox);

  // --- Synchronous getters (strictly guarded — never silently auto-open unencrypted) ---

  static Box<Map> getWorkoutBox() => _requireOpenBox<Map>(workoutsBox);
  static Box<Map> getNutritionBox() => _requireOpenBox<Map>(nutritionBox);
  static Box<Map> getProgramBox() => _requireOpenBox<Map>(programsBox);
  static Box<Map> getUserBox() => _requireOpenBox<Map>(userBox);
  static Box<Map> getSettingsBox() => _requireOpenBox<Map>(settingsBox);
  static Box<Map> getSyncQueueBox() => _requireOpenBox<Map>(syncQueueBox);
  static Box<Map> getExercisesBox() => _requireOpenBox<Map>(exercisesBox);
  static Box<dynamic> getFoodsBox() => _requireOpenBox<dynamic>(foodsBox);
  static Box<dynamic> getCustomFoodsBox() =>
      _requireOpenBox<dynamic>(customFoodsBox);
  static Box<Map> getBodyEntriesBox() => _requireOpenBox<Map>(bodyEntriesBox);
  static Box<Map> getStreakBox() => _requireOpenBox<Map>(streakBox);
  static Box<Map> getNotificationSettingsBox() =>
      _requireOpenBox<Map>(notificationSettingsBox);
  static Box<Map> getMealsBox() => _requireOpenBox<Map>(mealsBox);
  static Box<Map> getMacroTargetsBox() => _requireOpenBox<Map>(macroTargetsBox);
  static Box<String> getAppSettingsBox() =>
      _requireOpenBox<String>(appSettingsBox);
  static Box<dynamic> getAuthSessionBox() =>
      _requireOpenBox<dynamic>(authSessionBox);
  static Box<Map> getInsightCacheBox() => _requireOpenBox<Map>(insightCacheBox);

  /// Returns an already-open box (regardless of element type) or opens it
  /// through encryption policy if its file exists on disk. Returns null if the
  /// box is neither open nor stored locally (avoids eagerly materializing
  /// unopened Tier-2 boxes during a wipe).
  static Future<BoxBase<dynamic>?> ensureExistingBoxForWipe(
    String boxName,
  ) async {
    if (Hive.isBoxOpen(boxName)) {
      try {
        return Hive.box<dynamic>(boxName);
      } catch (_) {}
      try {
        return Hive.box<Map>(boxName);
      } catch (_) {}
      try {
        return Hive.box<String>(boxName);
      } catch (_) {}
      return null;
    }
    if (await Hive.boxExists(boxName)) {
      return ensureOpen<dynamic>(boxName);
    }
    return null;
  }
  static Box<dynamic> getUserProfileBox() =>
      _requireOpenBox<dynamic>(userProfileBox);
  static Box<dynamic> getAIChatHistoryBox() =>
      _requireOpenBox<dynamic>(aiChatHistoryBox);

  /// Clears all user and state boxes while preserving static catalog boxes
  /// (`exercises` and `foods`).
  static Future<void> clearAll() async {
    try {
      AppLogger.debug('📊 [Hive] Clearing user boxes (preserving catalogs)...');

      const mapUserBoxes = [
        workoutsBox,
        nutritionBox,
        programsBox,
        userBox,
        settingsBox,
        syncQueueBox,
        bodyEntriesBox,
        streakBox,
        notificationSettingsBox,
        mealsBox,
        macroTargetsBox,
        insightCacheBox,
        activeProgramBox,
        dietPlanBox,
        foodItemsFullBox,
      ];
      const dynamicUserBoxes = [
        customFoodsBox,
        activeWorkoutStateBox,
        authSessionBox,
        userProfileBox,
        aiChatHistoryBox,
      ];

      for (final boxName in mapUserBoxes) {
        if (protectedCatalogBoxes.contains(boxName)) continue;
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box<Map>(boxName).clear();
        } else if (await Hive.boxExists(boxName)) {
          final box = await ensureOpen<Map>(boxName);
          await box.clear();
        }
      }

      for (final boxName in dynamicUserBoxes) {
        if (protectedCatalogBoxes.contains(boxName)) continue;
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box<dynamic>(boxName).clear();
        } else if (await Hive.boxExists(boxName)) {
          final box = await ensureOpen<dynamic>(boxName);
          await box.clear();
        }
      }

      if (Hive.isBoxOpen(appSettingsBox)) {
        await Hive.box<String>(appSettingsBox).clear();
      } else if (await Hive.boxExists(appSettingsBox)) {
        final box = await ensureAppSettingsBox();
        await box.clear();
      }

      AppLogger.debug('✅ [Hive] All user boxes cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Hive] Failed to clear boxes: $e');
      AppLogger.debug('🔍 [Hive] Stack trace: $stackTrace');
      throw Exception('Failed to clear Hive boxes: $e');
    }
  }

  /// Close all open boxes.
  static Future<void> closeAll() async {
    try {
      AppLogger.debug('📊 [Hive] Closing all boxes...');
      _inFlightOpens.clear();
      await Hive.close();
      AppLogger.debug('✅ [Hive] All boxes closed successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Hive] Failed to close Hive: $e');
      AppLogger.debug('🔍 [Hive] Stack trace: $stackTrace');
      throw Exception('Failed to close Hive: $e');
    }
  }
}

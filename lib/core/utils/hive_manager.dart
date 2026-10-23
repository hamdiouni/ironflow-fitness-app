import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveManager {
  static const String _workoutBox = 'workouts';
  static const String _nutritionBox = 'nutrition';
  static const String _programBox = 'programs';
  static const String _userBox = 'user';
  static const String _settingsBox = 'settings';
  static const String _syncQueueBox = 'sync_queue';
  static const String _exercisesBox = 'exercises';
  static const String _foodsBox = 'foods';
  static const String _bodyEntriesBox = 'body_entries';
  static const String _streakBox = 'streak';
  static const String _notificationSettingsBox = 'notification_settings';
  static const String _mealsBox = 'meals';
  static const String _macroTargetsBox = 'macro_targets';
  static const String _appSettingsBox = 'app_settings';
  static const String _authSessionBox = 'auth_session';
  static const String _insightCacheBox = 'insight_cache';
  static const String _userProfileBox = 'user_profile';
  static const String _aiChatHistoryBox = 'ai_chat_history';
  // Boxes previously opened lazily by datasources and therefore missed by
  // clearAll()/data-wipe inventories (DATABASE_AND_SYNC_AUDIT F-04).
  static const String _activeProgramBox = 'active_program';
  static const String _dietPlanBox = 'diet_plan';
  static const String _foodItemsFullBox = 'food_items_full';
  static const String _activeWorkoutStateBox = 'active_workout_state';

  /// Initialize Hive
  static Future<void> initialize() async {
    try {
      AppLogger.debug('📊 [Hive] Initializing Hive...');
      await Hive.initFlutter();
      AppLogger.debug('✅ [Hive] Hive initialized successfully');
      
      // Open boxes with Map type to match datasource expectations
      final mapBoxes = [
        _workoutBox,
        _nutritionBox,
        _programBox,
        _userBox,
        _settingsBox,
        _syncQueueBox,
        _exercisesBox,
        _bodyEntriesBox,
        _streakBox,
        _notificationSettingsBox,
        _mealsBox,
        _macroTargetsBox,
        _insightCacheBox,
        _activeProgramBox,
        _dietPlanBox,
        _foodItemsFullBox,
      ];
      
      for (final boxName in mapBoxes) {
        AppLogger.debug('📊 [Hive] Opening box: $boxName...');
        await Hive.openBox<Map>(boxName);
        AppLogger.debug('✅ [Hive] Box opened: $boxName');
      }

      // Open foods box (stores heterogeneous items: List, String, int)
      AppLogger.debug('📊 [Hive] Opening box: $_foodsBox...');
      await Hive.openBox(_foodsBox);
      AppLogger.debug('✅ [Hive] Box opened: $_foodsBox');
      
      // Open app settings box separately (String type)
      AppLogger.debug('📊 [Hive] Opening box: $_appSettingsBox...');
      await Hive.openBox<String>(_appSettingsBox);
      AppLogger.debug('✅ [Hive] Box opened: $_appSettingsBox');
      
      // Open auth session box (dynamic type for flexibility)
      AppLogger.debug('📊 [Hive] Opening box: $_authSessionBox...');
      await Hive.openBox(_authSessionBox);
      AppLogger.debug('✅ [Hive] Box opened: $_authSessionBox');

      // Open user profile box (dynamic type for profile JSON and onboarded flag)
      AppLogger.debug('📊 [Hive] Opening box: $_userProfileBox...');
      await Hive.openBox(_userProfileBox);
      AppLogger.debug('✅ [Hive] Box opened: $_userProfileBox');

      // Open AI chat history box (dynamic type for persisted messages)
      AppLogger.debug('📊 [Hive] Opening box: $_aiChatHistoryBox...');
      await Hive.openBox(_aiChatHistoryBox);
      AppLogger.debug('✅ [Hive] Box opened: $_aiChatHistoryBox');

      // Open active workout state box (dynamic type, matches
      // WorkoutStateManager's openBox<dynamic> expectation)
      AppLogger.debug('📊 [Hive] Opening box: $_activeWorkoutStateBox...');
      await Hive.openBox<dynamic>(_activeWorkoutStateBox);
      AppLogger.debug('✅ [Hive] Box opened: $_activeWorkoutStateBox');
      
      AppLogger.debug('✅ [Hive] All boxes opened successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Hive] Failed to initialize: $e');
      AppLogger.debug('🔍 [Hive] Stack trace: $stackTrace');
      throw Exception('Failed to initialize Hive: $e');
    }
  }

  /// Get workout box
  static Box<Map> getWorkoutBox() {
    AppLogger.debug('📊 [Hive] Getting workout box...');
    final box = Hive.box<Map>(_workoutBox);
    AppLogger.debug('✅ [Hive] Workout box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get nutrition box
  static Box<Map> getNutritionBox() {
    AppLogger.debug('📊 [Hive] Getting nutrition box...');
    final box = Hive.box<Map>(_nutritionBox);
    AppLogger.debug('✅ [Hive] Nutrition box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get program box
  static Box<Map> getProgramBox() {
    AppLogger.debug('📊 [Hive] Getting program box...');
    final box = Hive.box<Map>(_programBox);
    AppLogger.debug('✅ [Hive] Program box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get user box
  static Box<Map> getUserBox() {
    AppLogger.debug('📊 [Hive] Getting user box...');
    final box = Hive.box<Map>(_userBox);
    AppLogger.debug('✅ [Hive] User box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get settings box
  static Box<Map> getSettingsBox() {
    AppLogger.debug('📊 [Hive] Getting settings box...');
    final box = Hive.box<Map>(_settingsBox);
    AppLogger.debug('✅ [Hive] Settings box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get sync queue box
  static Box<Map> getSyncQueueBox() {
    AppLogger.debug('📊 [Hive] Getting sync queue box...');
    final box = Hive.box<Map>(_syncQueueBox);
    AppLogger.debug('✅ [Hive] Sync queue box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get exercises box
  static Box<Map> getExercisesBox() {
    AppLogger.debug('📊 [Hive] Getting exercises box...');
    final box = Hive.box<Map>(_exercisesBox);
    AppLogger.debug('✅ [Hive] Exercises box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get foods box
  static Box getFoodsBox() {
    AppLogger.debug('📊 [Hive] Getting foods box...');
    final box = Hive.box(_foodsBox);
    AppLogger.debug('✅ [Hive] Foods box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get body entries box
  static Box<Map> getBodyEntriesBox() {
    AppLogger.debug('📊 [Hive] Getting body entries box...');
    final box = Hive.box<Map>(_bodyEntriesBox);
    AppLogger.debug('✅ [Hive] Body entries box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get streak box
  static Box<Map> getStreakBox() {
    AppLogger.debug('📊 [Hive] Getting streak box...');
    final box = Hive.box<Map>(_streakBox);
    AppLogger.debug('✅ [Hive] Streak box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get notification settings box
  static Box<Map> getNotificationSettingsBox() {
    AppLogger.debug('📊 [Hive] Getting notification settings box...');
    final box = Hive.box<Map>(_notificationSettingsBox);
    AppLogger.debug('✅ [Hive] Notification settings box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get meals box
  static Box<Map> getMealsBox() {
    AppLogger.debug('📊 [Hive] Getting meals box...');
    final box = Hive.box<Map>(_mealsBox);
    AppLogger.debug('✅ [Hive] Meals box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get macro targets box
  static Box<Map> getMacroTargetsBox() {
    AppLogger.debug('📊 [Hive] Getting macro targets box...');
    final box = Hive.box<Map>(_macroTargetsBox);
    AppLogger.debug('✅ [Hive] Macro targets box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get app settings box
  static Box<String> getAppSettingsBox() {
    AppLogger.debug('📊 [Hive] Getting app settings box...');
    final box = Hive.box<String>(_appSettingsBox);
    AppLogger.debug('✅ [Hive] App settings box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get insight cache box
  static Box<Map> getInsightCacheBox() {
    AppLogger.debug('📊 [Hive] Getting insight cache box...');
    final box = Hive.box<Map>(_insightCacheBox);
    AppLogger.debug('✅ [Hive] Insight cache box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get user profile box
  static Box getUserProfileBox() {
    AppLogger.debug('📊 [Hive] Getting user profile box...');
    final box = Hive.box(_userProfileBox);
    AppLogger.debug('✅ [Hive] User profile box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get AI chat history box
  static Box getAIChatHistoryBox() {
    AppLogger.debug('📊 [Hive] Getting AI chat history box...');
    final box = Hive.box(_aiChatHistoryBox);
    AppLogger.debug('✅ [Hive] AI chat history box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Clear all boxes
  static Future<void> clearAll() async {
    try {
      AppLogger.debug('📊 [Hive] Clearing all boxes...');
      
      final boxNames = [
        _workoutBox,
        _nutritionBox,
        _programBox,
        _userBox,
        _settingsBox,
        _syncQueueBox,
        _exercisesBox,
        _foodsBox,
        _bodyEntriesBox,
        _streakBox,
        _notificationSettingsBox,
        _mealsBox,
        _macroTargetsBox,
      ];
      
      for (final boxName in boxNames) {
        AppLogger.debug('📊 [Hive] Clearing box: $boxName...');
      }
      AppLogger.debug('📊 [Hive] Clearing box: $_appSettingsBox...');
      
      await Future.wait([
        Hive.box<Map>(_workoutBox).clear(),
        Hive.box<Map>(_nutritionBox).clear(),
        Hive.box<Map>(_programBox).clear(),
        Hive.box<Map>(_userBox).clear(),
        Hive.box<Map>(_settingsBox).clear(),
        Hive.box<Map>(_syncQueueBox).clear(),
        Hive.box<Map>(_exercisesBox).clear(),
        Hive.box(_foodsBox).clear(),
        Hive.box<Map>(_bodyEntriesBox).clear(),
        Hive.box<Map>(_streakBox).clear(),
        Hive.box<Map>(_notificationSettingsBox).clear(),
        Hive.box<Map>(_mealsBox).clear(),
        Hive.box<Map>(_macroTargetsBox).clear(),
        Hive.box<String>(_appSettingsBox).clear(),
        Hive.box<Map>(_insightCacheBox).clear(),
        Hive.box<Map>(_activeProgramBox).clear(),
        Hive.box<Map>(_dietPlanBox).clear(),
        Hive.box<Map>(_foodItemsFullBox).clear(),
        Hive.box<dynamic>(_activeWorkoutStateBox).clear(),
        Hive.box(_authSessionBox).clear(),
        Hive.box(_userProfileBox).clear(),
        Hive.box(_aiChatHistoryBox).clear(),
      ]);
      
      AppLogger.debug('✅ [Hive] All boxes cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Hive] Failed to clear boxes: $e');
      AppLogger.debug('🔍 [Hive] Stack trace: $stackTrace');
      throw Exception('Failed to clear Hive boxes: $e');
    }
  }

  /// Close all boxes
  static Future<void> closeAll() async {
    try {
      AppLogger.debug('📊 [Hive] Closing all boxes...');
      await Hive.close();
      AppLogger.debug('✅ [Hive] All boxes closed successfully');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Hive] Failed to close Hive: $e');
      AppLogger.debug('🔍 [Hive] Stack trace: $stackTrace');
      throw Exception('Failed to close Hive: $e');
    }
  }
}

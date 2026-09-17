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

  /// Initialize Hive
  static Future<void> initialize() async {
    try {
      print('📊 [Hive] Initializing Hive...');
      await Hive.initFlutter();
      print('✅ [Hive] Hive initialized successfully');
      
      // Open boxes with Map type to match datasource expectations
      final boxes = [
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
        _insightCacheBox,
      ];
      
      for (final boxName in boxes) {
        print('📊 [Hive] Opening box: $boxName...');
        await Hive.openBox<Map<dynamic, dynamic>>(boxName);
        print('✅ [Hive] Box opened: $boxName');
      }
      
      // Open app settings box separately (String type)
      print('📊 [Hive] Opening box: $_appSettingsBox...');
      await Hive.openBox<String>(_appSettingsBox);
      print('✅ [Hive] Box opened: $_appSettingsBox');
      
      // Open auth session box (dynamic type for flexibility)
      print('📊 [Hive] Opening box: $_authSessionBox...');
      await Hive.openBox(_authSessionBox);
      print('✅ [Hive] Box opened: $_authSessionBox');
      
      print('✅ [Hive] All boxes opened successfully');
    } catch (e, stackTrace) {
      print('❌ [Hive] Failed to initialize: $e');
      print('🔍 [Hive] Stack trace: $stackTrace');
      throw Exception('Failed to initialize Hive: $e');
    }
  }

  /// Get workout box
  static Box getWorkoutBox() {
    print('📊 [Hive] Getting workout box...');
    final box = Hive.box(_workoutBox);
    print('✅ [Hive] Workout box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get nutrition box
  static Box getNutritionBox() {
    print('📊 [Hive] Getting nutrition box...');
    final box = Hive.box(_nutritionBox);
    print('✅ [Hive] Nutrition box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get program box
  static Box getProgramBox() {
    print('📊 [Hive] Getting program box...');
    final box = Hive.box(_programBox);
    print('✅ [Hive] Program box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get user box
  static Box getUserBox() {
    print('📊 [Hive] Getting user box...');
    final box = Hive.box(_userBox);
    print('✅ [Hive] User box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get settings box
  static Box getSettingsBox() {
    print('📊 [Hive] Getting settings box...');
    final box = Hive.box(_settingsBox);
    print('✅ [Hive] Settings box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get sync queue box
  static Box getSyncQueueBox() {
    print('📊 [Hive] Getting sync queue box...');
    final box = Hive.box(_syncQueueBox);
    print('✅ [Hive] Sync queue box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get exercises box
  static Box getExercisesBox() {
    print('📊 [Hive] Getting exercises box...');
    final box = Hive.box(_exercisesBox);
    print('✅ [Hive] Exercises box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get foods box
  static Box getFoodsBox() {
    print('📊 [Hive] Getting foods box...');
    final box = Hive.box(_foodsBox);
    print('✅ [Hive] Foods box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get body entries box
  static Box getBodyEntriesBox() {
    print('📊 [Hive] Getting body entries box...');
    final box = Hive.box(_bodyEntriesBox);
    print('✅ [Hive] Body entries box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get streak box
  static Box getStreakBox() {
    print('📊 [Hive] Getting streak box...');
    final box = Hive.box(_streakBox);
    print('✅ [Hive] Streak box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get notification settings box
  static Box<Map<dynamic, dynamic>> getNotificationSettingsBox() {
    print('📊 [Hive] Getting notification settings box...');
    final box = Hive.box<Map<dynamic, dynamic>>(_notificationSettingsBox);
    print('✅ [Hive] Notification settings box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get meals box
  static Box getMealsBox() {
    print('📊 [Hive] Getting meals box...');
    final box = Hive.box(_mealsBox);
    print('✅ [Hive] Meals box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get macro targets box
  static Box getMacroTargetsBox() {
    print('📊 [Hive] Getting macro targets box...');
    final box = Hive.box(_macroTargetsBox);
    print('✅ [Hive] Macro targets box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get app settings box
  static Box<String> getAppSettingsBox() {
    print('📊 [Hive] Getting app settings box...');
    final box = Hive.box<String>(_appSettingsBox);
    print('✅ [Hive] App settings box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Get insight cache box
  static Box<Map<dynamic, dynamic>> getInsightCacheBox() {
    print('📊 [Hive] Getting insight cache box...');
    final box = Hive.box<Map<dynamic, dynamic>>(_insightCacheBox);
    print('✅ [Hive] Insight cache box retrieved (isOpen: ${box.isOpen})');
    return box;
  }

  /// Clear all boxes
  static Future<void> clearAll() async {
    try {
      print('📊 [Hive] Clearing all boxes...');
      
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
        print('📊 [Hive] Clearing box: $boxName...');
      }
      print('📊 [Hive] Clearing box: $_appSettingsBox...');
      
      await Future.wait([
        Hive.box(_workoutBox).clear(),
        Hive.box(_nutritionBox).clear(),
        Hive.box(_programBox).clear(),
        Hive.box(_userBox).clear(),
        Hive.box(_settingsBox).clear(),
        Hive.box(_syncQueueBox).clear(),
        Hive.box(_exercisesBox).clear(),
        Hive.box(_foodsBox).clear(),
        Hive.box(_bodyEntriesBox).clear(),
        Hive.box(_streakBox).clear(),
        Hive.box(_notificationSettingsBox).clear(),
        Hive.box(_mealsBox).clear(),
        Hive.box(_macroTargetsBox).clear(),
        Hive.box<String>(_appSettingsBox).clear(),
        Hive.box(_insightCacheBox).clear(),
      ]);
      
      print('✅ [Hive] All boxes cleared successfully');
    } catch (e, stackTrace) {
      print('❌ [Hive] Failed to clear boxes: $e');
      print('🔍 [Hive] Stack trace: $stackTrace');
      throw Exception('Failed to clear Hive boxes: $e');
    }
  }

  /// Close all boxes
  static Future<void> closeAll() async {
    try {
      print('📊 [Hive] Closing all boxes...');
      await Hive.close();
      print('✅ [Hive] All boxes closed successfully');
    } catch (e, stackTrace) {
      print('❌ [Hive] Failed to close Hive: $e');
      print('🔍 [Hive] Stack trace: $stackTrace');
      throw Exception('Failed to close Hive: $e');
    }
  }
}

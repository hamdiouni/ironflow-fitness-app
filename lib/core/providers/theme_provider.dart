import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../constants/app_theme.dart';
import '../utils/hive_manager.dart';

/// Provider for managing app theme (dark/light mode).
///
/// Persists theme preference to Hive storage.
final themeProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);

/// Notifier for managing theme state (Wave 3.2).
class ThemeNotifier extends Notifier<ThemeMode> {
  static const String _boxName = HiveManager.appSettingsBox;
  static const String _themeKey = 'theme_mode';
  bool _disposed = false;

  @override
  ThemeMode build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    if (Hive.isBoxOpen(_boxName)) {
      final box = HiveManager.getAppSettingsBox();
      final themeStr = box.get(_themeKey, defaultValue: 'dark');
      return themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
    }
    _loadTheme();
    return ThemeMode.dark;
  }

  /// Loads theme preference from Hive storage when app_settings was not yet
  /// opened synchronously at build time.
  Future<void> _loadTheme() async {
    try {
      AppLogger.debug('📊 [Theme] Loading theme from Hive...');
      final box = await HiveManager.ensureAppSettingsBox();
      if (_disposed) return;

      final themeStr = box.get(_themeKey, defaultValue: 'dark');
      final theme = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
      state = theme;
      AppLogger.debug('✅ [Theme] Theme loaded from Hive: $themeStr');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Theme] Failed to load theme: $e');
      AppLogger.debug('🔍 [Theme] Stack trace: $stackTrace');
      if (!_disposed) {
        state = ThemeMode.dark;
      }
    }
  }

  /// Toggles between dark and light mode.
  Future<void> toggleTheme() async {
    try {
      AppLogger.debug('📊 [Theme] Toggling theme...');
      AppLogger.debug('🔍 [Theme] Current theme: ${state.name}');
      
      final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      AppLogger.debug('🔍 [Theme] New theme will be: ${newTheme.name}');
      
      await setTheme(newTheme);
      
      AppLogger.debug('✅ [Theme] Theme toggled successfully to: ${newTheme.name}');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Theme] Failed to toggle theme: $e');
      AppLogger.debug('🔍 [Theme] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sets the theme to a specific mode.
  Future<void> setTheme(ThemeMode theme) async {
    try {
      AppLogger.debug('📊 [Theme] Setting theme...');
      AppLogger.debug('🔍 [Theme] Old theme: ${state.name}');
      AppLogger.debug('🔍 [Theme] New theme: ${theme.name}');
      
      state = theme;
      AppLogger.debug('✅ [Theme] State updated to: ${state.name}');
      
      final box = await HiveManager.ensureAppSettingsBox();
      final themeStr = theme == ThemeMode.light ? 'light' : 'dark';

      AppLogger.debug('📊 [Theme] Saving theme to Hive: $themeStr');
      await box.put(_themeKey, themeStr);
      
      AppLogger.debug('✅ [Theme] Theme saved to Hive successfully: $themeStr');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Theme] Failed to save theme: $e');
      AppLogger.debug('🔍 [Theme] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Gets the current ThemeData based on the theme mode.
  ThemeData getThemeData() {
    return state == ThemeMode.light ? AppTheme.lightTheme : AppTheme.darkTheme;
  }
}

/// Provider for getting the current ThemeData.
final currentThemeProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeProvider);
  return themeMode == ThemeMode.light ? AppTheme.lightTheme : AppTheme.darkTheme;
});

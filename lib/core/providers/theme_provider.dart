import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../constants/app_theme.dart';

/// Provider for managing app theme (dark/light mode).
///
/// Persists theme preference to Hive storage.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Notifier for managing theme state.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _boxName = 'app_settings';
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  /// Loads theme preference from Hive storage.
  Future<void> _loadTheme() async {
    try {
      AppLogger.debug('📊 [Theme] Loading theme from Hive...');
      
      // Wait for Hive to be fully initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      AppLogger.debug('🔍 [Theme] Checking if box is open: $_boxName');
      if (!Hive.isBoxOpen(_boxName)) {
        AppLogger.debug('⚠️ [Theme] Box $_boxName is not open yet, using default theme');
        state = ThemeMode.dark;
        AppLogger.debug('🔍 [Theme] Default theme set: ${state.name}');
        return;
      }
      
      AppLogger.debug('✅ [Theme] Box is open: $_boxName');
      final box = Hive.box<String>(_boxName);
      final themeStr = box.get(_themeKey, defaultValue: 'dark');
      
      AppLogger.debug('✅ [Theme] Theme loaded from Hive: $themeStr');
      AppLogger.debug('🔍 [Theme] Current state before update: ${state.name}');
      
      final theme = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
      state = theme;
      
      AppLogger.debug('✅ [Theme] Theme state updated to: ${state.name}');
    } catch (e, stackTrace) {
      AppLogger.debug('❌ [Theme] Failed to load theme: $e');
      AppLogger.debug('🔍 [Theme] Stack trace: $stackTrace');
      state = ThemeMode.dark;
      AppLogger.debug('🔍 [Theme] Fallback theme set: ${state.name}');
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
      
      AppLogger.debug('🔍 [Theme] Checking if box is open: $_boxName');
      if (!Hive.isBoxOpen(_boxName)) {
        AppLogger.debug('⚠️ [Theme] Box $_boxName is not open, cannot save theme');
        return;
      }
      
      AppLogger.debug('✅ [Theme] Box is open: $_boxName');
      final box = Hive.box<String>(_boxName);
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

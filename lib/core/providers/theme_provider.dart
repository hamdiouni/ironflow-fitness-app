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
      print('📊 [Theme] Loading theme from Hive...');
      
      // Wait for Hive to be fully initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      print('🔍 [Theme] Checking if box is open: $_boxName');
      if (!Hive.isBoxOpen(_boxName)) {
        print('⚠️ [Theme] Box $_boxName is not open yet, using default theme');
        state = ThemeMode.dark;
        print('🔍 [Theme] Default theme set: ${state.name}');
        return;
      }
      
      print('✅ [Theme] Box is open: $_boxName');
      final box = Hive.box<String>(_boxName);
      final themeStr = box.get(_themeKey, defaultValue: 'dark');
      
      print('✅ [Theme] Theme loaded from Hive: $themeStr');
      print('🔍 [Theme] Current state before update: ${state.name}');
      
      final theme = themeStr == 'light' ? ThemeMode.light : ThemeMode.dark;
      state = theme;
      
      print('✅ [Theme] Theme state updated to: ${state.name}');
    } catch (e, stackTrace) {
      print('❌ [Theme] Failed to load theme: $e');
      print('🔍 [Theme] Stack trace: $stackTrace');
      state = ThemeMode.dark;
      print('🔍 [Theme] Fallback theme set: ${state.name}');
    }
  }

  /// Toggles between dark and light mode.
  Future<void> toggleTheme() async {
    try {
      print('📊 [Theme] Toggling theme...');
      print('🔍 [Theme] Current theme: ${state.name}');
      
      final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      print('🔍 [Theme] New theme will be: ${newTheme.name}');
      
      await setTheme(newTheme);
      
      print('✅ [Theme] Theme toggled successfully to: ${newTheme.name}');
    } catch (e, stackTrace) {
      print('❌ [Theme] Failed to toggle theme: $e');
      print('🔍 [Theme] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Sets the theme to a specific mode.
  Future<void> setTheme(ThemeMode theme) async {
    try {
      print('📊 [Theme] Setting theme...');
      print('🔍 [Theme] Old theme: ${state.name}');
      print('🔍 [Theme] New theme: ${theme.name}');
      
      state = theme;
      print('✅ [Theme] State updated to: ${state.name}');
      
      print('🔍 [Theme] Checking if box is open: $_boxName');
      if (!Hive.isBoxOpen(_boxName)) {
        print('⚠️ [Theme] Box $_boxName is not open, cannot save theme');
        return;
      }
      
      print('✅ [Theme] Box is open: $_boxName');
      final box = Hive.box<String>(_boxName);
      final themeStr = theme == ThemeMode.light ? 'light' : 'dark';
      
      print('📊 [Theme] Saving theme to Hive: $themeStr');
      await box.put(_themeKey, themeStr);
      
      print('✅ [Theme] Theme saved to Hive successfully: $themeStr');
    } catch (e, stackTrace) {
      print('❌ [Theme] Failed to save theme: $e');
      print('🔍 [Theme] Stack trace: $stackTrace');
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

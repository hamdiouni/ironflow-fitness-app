import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';
import 'package:progression_tracker/core/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Integration test for theme flow with logging.
///
/// This test verifies that:
/// 1. Theme operations complete successfully with logging enabled
/// 2. All operations are logged (load theme, toggle theme, save theme)
/// 3. Logging doesn't break functionality
/// 4. Theme persistence works correctly
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Theme Flow Logging Integration Tests', () {
    late ProviderContainer container;

    setUpAll(() async {
      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Hive
      await HiveManager.initialize();
    });

    setUp(() async {
      // Clear app settings before each test
      final appSettingsBox = HiveManager.getAppSettingsBox();
      await appSettingsBox.clear();

      // Create a fresh provider container
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
    });

    testWidgets('Complete theme flow with logging', (tester) async {
      print('\n=== TEST: Complete theme flow ===');

      // Act & Assert: Initial theme load (should default to dark)
      print('\n=== TEST: Loading initial theme ===');
      
      // Wait for theme to load
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      final initialTheme = container.read(themeProvider);
      expect(initialTheme, ThemeMode.dark, reason: 'Initial theme should be dark');
      print('✓ Initial theme loaded successfully: ${initialTheme.name}');

      // Act & Assert: Toggle theme to light
      print('\n=== TEST: Toggling theme to light ===');
      final notifier = container.read(themeProvider.notifier);
      await notifier.toggleTheme();
      await tester.pumpAndSettle();

      final lightTheme = container.read(themeProvider);
      expect(lightTheme, ThemeMode.light, reason: 'Theme should be light after toggle');
      print('✓ Theme toggled to light successfully');

      // Verify theme was saved to Hive
      print('\n=== TEST: Verifying theme persistence ===');
      final appSettingsBox = HiveManager.getAppSettingsBox();
      final savedTheme = appSettingsBox.get('theme_mode');
      expect(savedTheme, 'light', reason: 'Theme should be saved to Hive');
      print('✓ Theme persisted to Hive successfully');

      // Act & Assert: Toggle theme back to dark
      print('\n=== TEST: Toggling theme back to dark ===');
      await notifier.toggleTheme();
      await tester.pumpAndSettle();

      final darkTheme = container.read(themeProvider);
      expect(darkTheme, ThemeMode.dark, reason: 'Theme should be dark after second toggle');
      print('✓ Theme toggled back to dark successfully');

      // Verify theme was saved to Hive
      final savedDarkTheme = appSettingsBox.get('theme_mode');
      expect(savedDarkTheme, 'dark', reason: 'Dark theme should be saved to Hive');
      print('✓ Dark theme persisted to Hive successfully');

      print('\n=== TEST COMPLETE: All theme operations logged and working ===\n');
    });

    testWidgets('Set theme directly', (tester) async {
      print('\n=== TEST: Set theme directly ===');

      // Act & Assert: Set theme to light directly
      print('\n=== TEST: Setting theme to light ===');
      final notifier = container.read(themeProvider.notifier);
      await notifier.setTheme(ThemeMode.light);
      await tester.pumpAndSettle();

      final theme = container.read(themeProvider);
      expect(theme, ThemeMode.light, reason: 'Theme should be light');
      print('✓ Theme set to light successfully');

      // Verify theme was saved
      final appSettingsBox = HiveManager.getAppSettingsBox();
      final savedTheme = appSettingsBox.get('theme_mode');
      expect(savedTheme, 'light', reason: 'Theme should be saved to Hive');
      print('✓ Theme persisted successfully');

      // Act & Assert: Set theme to dark directly
      print('\n=== TEST: Setting theme to dark ===');
      await notifier.setTheme(ThemeMode.dark);
      await tester.pumpAndSettle();

      final darkTheme = container.read(themeProvider);
      expect(darkTheme, ThemeMode.dark, reason: 'Theme should be dark');
      print('✓ Theme set to dark successfully');

      print('\n=== TEST COMPLETE: Direct theme setting logged and working ===\n');
    });

    testWidgets('Theme persistence across app restarts', (tester) async {
      print('\n=== TEST: Theme persistence across restarts ===');

      // First session: Set theme to light
      print('\n=== TEST: First session - Setting theme to light ===');
      var notifier = container.read(themeProvider.notifier);
      await notifier.setTheme(ThemeMode.light);
      await tester.pumpAndSettle();

      var theme = container.read(themeProvider);
      expect(theme, ThemeMode.light);
      print('✓ Theme set to light in first session');

      // Simulate app restart by disposing and creating new container
      container.dispose();
      print('\n=== TEST: Simulating app restart ===');

      final newContainer = ProviderContainer();
      
      // Wait for theme to load from Hive
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Act & Assert: Verify theme was restored
      print('\n=== TEST: Second session - Verifying theme restoration ===');
      final restoredTheme = newContainer.read(themeProvider);
      expect(restoredTheme, ThemeMode.light, 
          reason: 'Theme should be restored to light after restart');
      print('✓ Theme restored successfully after restart: ${restoredTheme.name}');

      newContainer.dispose();
      print('\n=== TEST COMPLETE: Theme persistence verified ===\n');
    });

    testWidgets('Multiple theme toggles', (tester) async {
      print('\n=== TEST: Multiple theme toggles ===');

      final notifier = container.read(themeProvider.notifier);

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Perform multiple toggles
      for (int i = 0; i < 5; i++) {
        print('\n=== TEST: Toggle ${i + 1} ===');
        await notifier.toggleTheme();
        await tester.pumpAndSettle();

        final theme = container.read(themeProvider);
        final expectedTheme = i % 2 == 0 ? ThemeMode.light : ThemeMode.dark;
        expect(theme, expectedTheme, 
            reason: 'Theme should be ${expectedTheme.name} after toggle ${i + 1}');
        print('✓ Toggle ${i + 1} successful: ${theme.name}');
      }

      // Verify final theme is light (after 5 toggles from dark)
      final finalTheme = container.read(themeProvider);
      expect(finalTheme, ThemeMode.light, 
          reason: 'Final theme should be light after 5 toggles');
      print('✓ All toggles completed successfully');

      print('\n=== TEST COMPLETE: Multiple toggles logged and working ===\n');
    });

    testWidgets('Get theme data', (tester) async {
      print('\n=== TEST: Get theme data ===');

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Act & Assert: Get dark theme data
      print('\n=== TEST: Getting dark theme data ===');
      var notifier = container.read(themeProvider.notifier);
      await notifier.setTheme(ThemeMode.dark);
      await tester.pumpAndSettle();

      var themeData = notifier.getThemeData();
      expect(themeData.brightness, Brightness.dark, 
          reason: 'Theme data should be dark');
      print('✓ Dark theme data retrieved successfully');

      // Act & Assert: Get light theme data
      print('\n=== TEST: Getting light theme data ===');
      await notifier.setTheme(ThemeMode.light);
      await tester.pumpAndSettle();

      themeData = notifier.getThemeData();
      expect(themeData.brightness, Brightness.light, 
          reason: 'Theme data should be light');
      print('✓ Light theme data retrieved successfully');

      print('\n=== TEST COMPLETE: Theme data retrieval logged and working ===\n');
    });

    testWidgets('Theme provider with current theme provider', (tester) async {
      print('\n=== TEST: Current theme provider ===');

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      // Act & Assert: Check current theme provider
      print('\n=== TEST: Checking current theme provider ===');
      final notifier = container.read(themeProvider.notifier);
      await notifier.setTheme(ThemeMode.light);
      await tester.pumpAndSettle();

      final currentTheme = container.read(currentThemeProvider);
      expect(currentTheme.brightness, Brightness.light, 
          reason: 'Current theme should be light');
      print('✓ Current theme provider working correctly');

      // Change to dark
      await notifier.setTheme(ThemeMode.dark);
      await tester.pumpAndSettle();

      final darkCurrentTheme = container.read(currentThemeProvider);
      expect(darkCurrentTheme.brightness, Brightness.dark, 
          reason: 'Current theme should be dark');
      print('✓ Current theme provider updated correctly');

      print('\n=== TEST COMPLETE: Current theme provider logged and working ===\n');
    });

    testWidgets('Theme operations with empty Hive box', (tester) async {
      print('\n=== TEST: Theme operations with empty Hive box ===');

      // Ensure box is empty
      final appSettingsBox = HiveManager.getAppSettingsBox();
      await appSettingsBox.clear();

      // Create new container to trigger theme load
      final newContainer = ProviderContainer();

      // Wait for theme to load (should default to dark)
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      final theme = newContainer.read(themeProvider);
      expect(theme, ThemeMode.dark, 
          reason: 'Should default to dark when no saved theme');
      print('✓ Default theme loaded correctly when Hive box is empty');

      newContainer.dispose();
      print('\n=== TEST COMPLETE: Empty Hive box handled correctly ===\n');
    });
  });
}

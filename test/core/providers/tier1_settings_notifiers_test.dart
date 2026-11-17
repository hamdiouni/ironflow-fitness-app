import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/providers/language_provider.dart';
import 'package:progression_tracker/core/providers/theme_provider.dart';
import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/core/utils/hive_manager.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('tier1_notifiers_test_');
    Hive.init(tempDir.path);
    final box = await Hive.openBox<String>('app_settings');
    await box.put('theme_mode', 'light');
    await box.put('language_code', 'fr');
    await box.put('units_system', 'imperial');
  });

  tearDown(() async {
    await Hive.close();
    HiveManager.resetForTest();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('ThemeNotifier, LanguageNotifier, and UnitsNotifier read Tier-1 app_settings immediately without 500ms delay', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Must resolve synchronously in build() without requiring Future.delayed(500ms)
    expect(container.read(themeProvider), ThemeMode.light);
    expect(container.read(languageProvider), const Locale('fr'));
    expect(container.read(unitsProvider), UnitsSystem.imperial);

    await container.read(themeProvider.notifier).setTheme(ThemeMode.dark);
    await container.read(languageProvider.notifier).setLanguage(const Locale('es'));
    await container.read(unitsProvider.notifier).setUnits(UnitsSystem.metric);

    expect(container.read(themeProvider), ThemeMode.dark);
    expect(container.read(languageProvider), const Locale('es'));
    expect(container.read(unitsProvider), UnitsSystem.metric);
  });
}

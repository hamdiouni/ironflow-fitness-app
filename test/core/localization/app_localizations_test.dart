import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/l10n/app_localizations.dart';
import 'package:progression_tracker/main.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('l10n_wiring_test_');
    Hive.init(tempDir.path);
    final settings = await Hive.openBox<String>('app_settings');
    await settings.put('language_code', 'es');
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('generated localizations expose all supported locales', () {
    expect(
      AppLocalizations.supportedLocales.map((l) => l.languageCode),
      containsAll(<String>['en', 'es', 'fr', 'de', 'pt', 'ja', 'zh']),
    );
    expect(lookupAppLocalizations(const Locale('es')).home, 'Inicio');
    expect(lookupAppLocalizations(const Locale('fr')).workouts, 'Entraînements');
  });

  testWidgets('MainApp wires localization delegates and saved locale',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Text(AppLocalizations.of(context)!.home),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          routerProvider.overrideWithValue(router),
        ],
        child: const MainApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Inicio'), findsOneWidget);
  });
}

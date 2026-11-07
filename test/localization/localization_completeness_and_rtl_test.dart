import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/body/presentation/providers/body_map_providers.dart';
import 'package:progression_tracker/features/body/presentation/widgets/body_map/body_map_view.dart';
import 'package:progression_tracker/features/workout/presentation/providers/workout_providers.dart';
import 'package:progression_tracker/l10n/app_localizations.dart';

void main() {
  group('Wave 5.5 Localization & Language Resilience Suite', () {
    test('1. ARB Parity: all 7 locales provide 100% of defined keys', () {
      final arbFiles = [
        'lib/l10n/app_en.arb',
        'lib/l10n/app_de.arb',
        'lib/l10n/app_es.arb',
        'lib/l10n/app_fr.arb',
        'lib/l10n/app_ja.arb',
        'lib/l10n/app_pt.arb',
        'lib/l10n/app_zh.arb',
      ];

      final Map<String, Set<String>> keysByLocale = {};

      for (final path in arbFiles) {
        final file = File(path);
        expect(file.existsSync(), isTrue, reason: 'Missing ARB file: $path');
        final content = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final stringKeys = content.keys.where((k) => !k.startsWith('@')).toSet();
        keysByLocale[path] = stringKeys;
      }

      final englishKeys = keysByLocale['lib/l10n/app_en.arb']!;
      expect(englishKeys.isNotEmpty, isTrue);

      for (final entry in keysByLocale.entries) {
        if (entry.key == 'lib/l10n/app_en.arb') continue;
        final missing = englishKeys.difference(entry.value);
        expect(
          missing,
          isEmpty,
          reason: '${entry.key} is missing translations for: $missing',
        );
      }
    });

    test('2. Supported Locales: AppLocalizations delegates initialize all 7 locales', () {
      const locales = [
        Locale('en'),
        Locale('de'),
        Locale('es'),
        Locale('fr'),
        Locale('ja'),
        Locale('pt'),
        Locale('zh'),
      ];

      for (final locale in locales) {
        final localizations = lookupAppLocalizations(locale);
        expect(localizations.appTitle.isNotEmpty, isTrue);
        expect(localizations.home.isNotEmpty, isTrue);
        expect(localizations.workouts.isNotEmpty, isTrue);
        expect(localizations.settings.isNotEmpty, isTrue);
      }
    });

    testWidgets('3. RTL Layout: BodyMapView renders cleanly in Right-To-Left directionality',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutsStreamProvider.overrideWith((ref) => Stream.value([])),
            manualSorenessProvider.overrideWith(() => _FakeSorenessNotifier()),
          ],
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData.dark().copyWith(
              extensions: [AppThemeTokens.dark],
            ),
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: BodyMapView(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Zero layout overflow or directionality crashes
      expect(tester.takeException(), isNull);
      expect(find.byType(BodyMapView), findsOneWidget);
      expect(find.text('FRONT'), findsOneWidget);
      expect(find.text('BACK'), findsOneWidget);
    });

    testWidgets('4. RTL Accessible List: mirrors directional alignment cleanly',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            workoutsStreamProvider.overrideWith((ref) => Stream.value([])),
            manualSorenessProvider.overrideWith(() => _FakeSorenessNotifier()),
          ],
          child: MaterialApp(
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData.dark().copyWith(
              extensions: [AppThemeTokens.dark],
            ),
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: Scaffold(
                body: BodyMapView(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to list view mode
      final listButton = find.byKey(const Key('body_map_list_mode_button'));
      await tester.tap(listButton);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Chest'), findsOneWidget);
    });
  });
}

class _FakeSorenessNotifier extends ManualSorenessNotifier {
  @override
  Set<String> build() => const {};
}


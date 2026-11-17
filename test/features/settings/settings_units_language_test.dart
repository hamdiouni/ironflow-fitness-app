import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/language_provider.dart';
import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/ai_provider.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestUnitsNotifier extends UnitsNotifier {
  @override
  UnitsSystem build() => UnitsSystem.metric;

  @override
  Future<void> setUnits(UnitsSystem units) async {
    state = units;
  }
}

class _TestLanguageNotifier extends LanguageNotifier {
  @override
  Locale build() => const Locale('en');

  @override
  Future<void> setLanguage(Locale locale) async {
    if (!LanguageNotifier.supportedLocales.contains(locale)) return;
    state = locale;
  }
}

class _TestHapticsNotifier extends HapticsNotifier {
  @override
  bool build() => false;
}

class _TestAiConsentNotifier extends AIPersonalizationConsentNotifier {
  @override
  bool build() => false;
}

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(isAuthenticated: false);
}

void main() {
  setUp(() {
    AppHaptics.shared = AppHaptics(isEnabled: false);
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen switches units between KG and LBS and updates language',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final container = ProviderContainer(
      overrides: [
        unitsProvider.overrideWith(_TestUnitsNotifier.new),
        languageProvider.overrideWith(_TestLanguageNotifier.new),
        hapticsEnabledProvider.overrideWith(_TestHapticsNotifier.new),
        aiPersonalizationConsentProvider.overrideWith(_TestAiConsentNotifier.new),
        authNotifierProvider.overrideWith(_TestAuthNotifier.new),
        userProfileProvider.overrideWith((ref) => Future.value(null)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Metric (kg, cm)'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('settings_units_imperial_btn')));
    await tester.tap(find.byKey(const Key('settings_units_imperial_btn')));
    await tester.pumpAndSettle();

    expect(container.read(unitsProvider), UnitsSystem.imperial);
    expect(find.text('Imperial (lbs, in)'), findsOneWidget);

    // Open language selector and pick Spanish.
    await tester.ensureVisible(find.byKey(const Key('settings_language_tile')));
    await tester.tap(find.byKey(const Key('settings_language_tile')));
    await tester.pumpAndSettle();

    expect(find.text('LANGUAGE'), findsOneWidget);
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(container.read(languageProvider), const Locale('es'));
    expect(find.text('Español (ES)'), findsOneWidget);

    // Reopen language dialog and dismiss via CLOSE button.
    await tester.tap(find.byKey(const Key('settings_language_tile')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CLOSE'));
    await tester.pumpAndSettle();
    expect(find.text('LANGUAGE'), findsNothing);

    // Scroll to About section and verify application metadata card renders.
    final buildDateFinder = find.text('BUILD DATE');
    await tester.scrollUntilVisible(
      buildDateFinder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('PROGRESSION TRACKER'), findsOneWidget);
    expect(buildDateFinder, findsOneWidget);
  });
}

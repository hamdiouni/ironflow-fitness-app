import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/providers/language_provider.dart';
import 'package:progression_tracker/core/providers/theme_provider.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/main.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FixedThemeNotifier extends ThemeNotifier {
  @override
  ThemeMode build() => ThemeMode.dark;
}

class _FixedLanguageNotifier extends LanguageNotifier {
  @override
  Locale build() => const Locale('en');
}

GoRouter _buildTestShellRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const Scaffold(body: Text('TODAY TAB')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.workout,
                builder: (_, _) => const Scaffold(body: Text('TRAIN TAB')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.nutrition,
                builder: (_, _) => const Scaffold(body: Text('FUEL TAB')),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (_, _) => const Scaffold(body: Text('PROGRESS TAB')),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

void main() {
  setUp(() {
    AppHaptics.shared = AppHaptics(isEnabled: false);
  });

  group('Wave 2.2 — MainApp & MainScaffold Responsive Navigation Characterization',
      () {
    testWidgets('renders BottomNavigationBar on mobile viewport and switches branches',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'telemetry_consent_prompt_shown': true,
      });
      await tester.binding.setSurfaceSize(const Size(430, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final router = _buildTestShellRouter();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routerProvider.overrideWithValue(router),
            themeProvider.overrideWith(_FixedThemeNotifier.new),
            languageProvider.overrideWith(_FixedLanguageNotifier.new),
          ],
          child: const MainApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('TODAY TAB'), findsOneWidget);

      await tester.tap(find.text('TRAIN'));
      await tester.pumpAndSettle();
      expect(find.text('TRAIN TAB'), findsOneWidget);

      await tester.tap(find.text('FUEL'));
      await tester.pumpAndSettle();
      expect(find.text('FUEL TAB'), findsOneWidget);
    });

    testWidgets('renders NavigationRail on wide viewport (>= 900px) and shows telemetry consent dialog when unconfigured',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'telemetry_consent_prompt_shown': false,
      });
      await tester.binding.setSurfaceSize(const Size(1100, 800));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final router = _buildTestShellRouter();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            routerProvider.overrideWithValue(router),
            themeProvider.overrideWith(_FixedThemeNotifier.new),
            languageProvider.overrideWith(_FixedLanguageNotifier.new),
          ],
          child: const MainApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(find.text('Privacy & Diagnostics Consent'), findsOneWidget);
    });
  });
}

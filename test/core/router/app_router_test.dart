import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/auth/data/datasources/auth_session_storage.dart';
import 'package:progression_tracker/features/onboarding/data/user_profile_storage.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_router_test_');
    Hive.init(tempDir.path);

    final mapBoxes = [
      'workouts',
      'nutrition',
      'programs',
      'user',
      'settings',
      'sync_queue',
      'exercises',
      'body_entries',
      'streak',
      'notification_settings',
      'meals',
      'macro_targets',
      'insight_cache',
    ];
    for (final b in mapBoxes) {
      await Hive.openBox<Map>(b);
    }
    await Hive.openBox('foods');
    await Hive.openBox<String>('app_settings');
    await Hive.openBox('auth_session');
    await Hive.openBox('user_profile');
  });

  setUp(() async {
    await AuthSessionStorage().clearSession();
    await UserProfileStorage().resetOnboarding();
  });

  tearDown(() async {
    await AuthSessionStorage().clearSession();
    await UserProfileStorage().resetOnboarding();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('AppRouter 4-Tab Navigation Shell Tests', () {
    test('Router configuration contains 4-tab StatefulShellRoute', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      final shellRoute = router.configuration.routes
          .whereType<StatefulShellRoute>()
          .firstOrNull;

      expect(shellRoute, isNotNull,
          reason: 'Router must use StatefulShellRoute for persistent tabs');
      expect(shellRoute!.branches.length, equals(4),
          reason: 'Shell must have exactly 4 branches: Today, Train, Fuel, Progress');

      // Verify branch routes
      expect((shellRoute.branches[0].routes.first as GoRoute).path,
          equals(AppRoutes.home));
      expect((shellRoute.branches[1].routes.first as GoRoute).path,
          equals(AppRoutes.workout));
      expect((shellRoute.branches[2].routes.first as GoRoute).path,
          equals(AppRoutes.nutrition));
      expect((shellRoute.branches[3].routes.first as GoRoute).path,
          equals(AppRoutes.progress));
    });

    test('Profile and Settings are registered as pushed routes outside shell', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      final topLevelRoutes =
          router.configuration.routes.whereType<GoRoute>().toList();

      final profileRoute =
          topLevelRoutes.where((r) => r.path == AppRoutes.profile).firstOrNull;
      expect(profileRoute, isNotNull,
          reason: 'Profile must be registered as a top-level route');

      final settingsRoute =
          topLevelRoutes.where((r) => r.path == AppRoutes.settings).firstOrNull;
      expect(settingsRoute, isNotNull,
          reason: 'Settings must be registered as a top-level route');
    });

    test('Analytics route exists with redirect to /progress?tab=lifts', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      final topLevelRoutes =
          router.configuration.routes.whereType<GoRoute>().toList();

      final analyticsRoute =
          topLevelRoutes.where((r) => r.path == AppRoutes.analytics).firstOrNull;
      expect(analyticsRoute, isNotNull);
      expect(analyticsRoute!.redirect, isNotNull);
    });

    testWidgets('Authenticated router navigates to all 4 tabs and redirects /analytics',
        (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('[core/no-app]')) {
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Authenticate & Mark Onboarded
      await tester.runAsync(() async {
        await container.read(authNotifierProvider.notifier).signInWithEmail(
              email: 'demo@ironflow.com',
              password: 'password123',
            );
        await UserProfileStorage().markOnboarded();
      });

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Today tab is displayed
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.text('TRAIN'), findsOneWidget);
      expect(find.text('FUEL'), findsOneWidget);
      expect(find.text('PROGRESS'), findsOneWidget);

      // Navigate to /workout (Train)
      router.go(AppRoutes.workout);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.workout),
      );

      // Navigate to /nutrition (Fuel)
      router.go(AppRoutes.nutrition);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.nutrition),
      );

      // Navigate to /analytics -> should redirect to /progress?tab=lifts
      router.go(AppRoutes.analytics);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final redirectedUri =
          router.routerDelegate.currentConfiguration.uri.toString();
      expect(redirectedUri, equals('${AppRoutes.progress}?tab=lifts'));

      // Navigate to /settings
      router.go(AppRoutes.settings);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.settings),
      );

      // Navigate to /profile
      router.go(AppRoutes.profile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.profile),
      );

      // Drain any pending animation or delayed execution timers
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('PopScope in 4-tab shell navigates to Today when on non-home tab',
        (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('[core/no-app]')) {
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Authenticate & Mark Onboarded
      await tester.runAsync(() async {
        await container.read(authNotifierProvider.notifier).signInWithEmail(
              email: 'demo@ironflow.com',
              password: 'password123',
            );
        await UserProfileStorage().markOnboarded();
      });

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Go to Train tab
      router.go(AppRoutes.workout);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.workout),
      );

      // Find PopScope using widget predicate
      final popScopeFinder = find.byWidgetPredicate((w) => w is PopScope);
      expect(popScopeFinder, findsWidgets);

      final popScope = tester.widget<PopScope>(popScopeFinder.first);
      expect(popScope.canPop, isFalse,
          reason: 'When on non-zero tab, PopScope cannot pop immediately');

      // Trigger pop
      popScope.onPopInvokedWithResult?.call(false, null);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Current location is now Today (/home)
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.home),
      );

      // Drain any remaining timers
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Authenticated user who has not completed onboarding is redirected from splash to /onboarding',
        (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('[core/no-app]')) {
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.runAsync(() async {
        await container.read(authNotifierProvider.notifier).signInWithEmail(
              email: 'demo@ironflow.com',
              password: 'password123',
            );
      });

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.onboarding),
      );

      await tester.pump(const Duration(seconds: 3));
    });

    test('AppRoutes.resolvePostAuthRedirect validates internal return paths safely', () {
      expect(AppRoutes.resolvePostAuthRedirect(null), equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect(''), equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect('https://evil.example/phish'),
          equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect('//evil.example/phish'),
          equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect(AppRoutes.login),
          equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect(AppRoutes.signup),
          equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect(AppRoutes.onboarding),
          equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect('/workout'),
          equals('/workout'));
      expect(AppRoutes.resolvePostAuthRedirect('/progress?tab=lifts'),
          equals('/progress?tab=lifts'));
      expect(
        AppRoutes.resolvePostAuthRedirect('/workout/summary?workoutId=w-42'),
        equals('/workout/summary?workoutId=w-42'),
      );
    });

    testWidgets('Unauthenticated deep link preserves ?from= and restores target route on login',
        (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('[core/no-app]')) {
          return;
        }
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      // Attempt to access a protected route while unauthenticated
      router.go('/progress?tab=lifts');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final loginUri = router.routerDelegate.currentConfiguration.uri;
      expect(loginUri.path, equals(AppRoutes.login));
      expect(loginUri.queryParameters['from'], equals('/progress?tab=lifts'));

      // Authenticate and mark onboarded, then trigger redirect from /login?from=...
      await tester.runAsync(() async {
        await container.read(authNotifierProvider.notifier).signInWithEmail(
              email: 'demo@ironflow.com',
              password: 'password123',
            );
        await UserProfileStorage().markOnboarded();
      });

      router.go(loginUri.toString());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals('/progress?tab=lifts'),
      );

      await tester.pump(const Duration(seconds: 3));
    });
  });
}

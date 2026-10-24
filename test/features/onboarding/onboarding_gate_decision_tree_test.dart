import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/auth/data/datasources/auth_session_storage.dart';
import 'package:progression_tracker/features/onboarding/data/user_profile_storage.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_gate_test_');
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

  group('Onboarding Gate & Launch Decision Tree Tests', () {
    testWidgets('Unauthenticated user navigating to /home is redirected to /login',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Attempt to navigate to /home
      router.go(AppRoutes.home);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.login),
      );

      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Fresh signup (User A) is authenticated but un-onboarded, redirected to /onboarding',
        (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('[core/no-app]')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Authenticate with sign-in using registered demo account
      await tester.runAsync(() async {
        await container.read(authNotifierProvider.notifier).signInWithEmail(
              email: 'demo@ironflow.com',
              password: 'password123',
            );
        // Ensure onboarding is reset for this user
        final user = container.read(authNotifierProvider).user;
        await UserProfileStorage().resetOnboarding(userId: user?.id);
      });

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
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

    testWidgets('Deep-link bypass attempt by un-onboarded user is redirected to /onboarding',
        (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('[core/no-app]')) return;
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
        final user = container.read(authNotifierProvider).user;
        await UserProfileStorage().resetOnboarding(userId: user?.id);
      });

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Attempt deep-link to /workout
      router.go(AppRoutes.workout);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.onboarding),
      );

      // Attempt deep-link to /nutrition
      router.go(AppRoutes.nutrition);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.onboarding),
      );

      // Attempt deep-link to /progress
      router.go(AppRoutes.progress);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.onboarding),
      );

      await tester.pump(const Duration(seconds: 3));
    });

    test('Second signup on same device hypothesis: User B is NOT marked onboarded when User A completed it',
        () async {
      final storage = UserProfileStorage();

      const userAId = 'user_alpha_111';
      const userBId = 'user_beta_222';

      // 1. User A completes onboarding
      await storage.markOnboarded(userId: userAId);
      expect(storage.isOnboardedSync(userId: userAId), isTrue);

      // 2. User B arrives on the same device
      // User B must NOT be considered onboarded!
      expect(storage.isOnboardedSync(userId: userBId), isFalse);
      expect(await storage.isOnboarded(userId: userBId), isFalse);

      // 3. User B completes onboarding
      await storage.markOnboarded(userId: userBId);
      expect(storage.isOnboardedSync(userId: userBId), isTrue);

      // 4. Resetting User B does not reset User A
      await storage.resetOnboarding(userId: userBId);
      expect(storage.isOnboardedSync(userId: userBId), isFalse);
      expect(storage.isOnboardedSync(userId: userAId), isTrue);
    });

    test('Draft resumption per user account', () async {
      final storage = UserProfileStorage();
      const userAId = 'user_alpha_111';
      const userBId = 'user_beta_222';

      // Save draft for user A at step 3
      await storage.saveDraft(
        step: 3,
        userId: userAId,
        data: {'goal': 'gainMuscle', 'daysPerWeek': 5},
      );

      // Save draft for user B at step 1
      await storage.saveDraft(
        step: 1,
        userId: userBId,
        data: {'goal': 'loseWeight'},
      );

      // Retrieve User A draft
      final draftA = await storage.getDraft(userId: userAId);
      expect(draftA, isNotNull);
      expect(draftA!['draft_step'], equals(3));
      expect(draftA['goal'], equals('gainMuscle'));
      expect(draftA['daysPerWeek'], equals(5));

      // Retrieve User B draft
      final draftB = await storage.getDraft(userId: userBId);
      expect(draftB, isNotNull);
      expect(draftB!['draft_step'], equals(1));
      expect(draftB['goal'], equals('loseWeight'));

      // Clearing User B draft leaves User A draft intact
      await storage.clearDraft(userId: userBId);
      expect(await storage.getDraft(userId: userBId), isNull);
      expect(await storage.getDraft(userId: userAId), isNotNull);
    });

    test('Saved onboarding profile is loaded only for its own account',
        () async {
      final storage = UserProfileStorage();
      const userAId = 'user_alpha_111';
      const userBId = 'user_beta_222';

      await storage.saveProfile(
        const UserProfile(
          goal: FitnessGoal.gainMuscle,
          age: 31,
          weightKg: 88,
          heightCm: 182,
          fitnessLevel: FitnessLevel.advanced,
          equipment: EquipmentType.gym,
          workoutDaysPerWeek: 5,
          budget: BudgetLevel.high,
        ),
        userId: userAId,
      );

      final loadedA = await storage.loadProfile(userId: userAId);
      expect(loadedA?.age, 31);
      expect(loadedA?.weightKg, 88);

      // The legacy global profile must not make User A's data appear
      // as User B's profile on the same device.
      expect(await storage.loadProfile(userId: userBId), isNull);
    });

    testWidgets('Returning complete user (User A) is sent to /home and cannot visit /onboarding',
        (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('[core/no-app]')) return;
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
        final user = container.read(authNotifierProvider).user;
        await UserProfileStorage().markOnboarded(userId: user?.id);
      });

      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.home),
      );

      // Try navigating to /onboarding -> should redirect back to /home
      router.go(AppRoutes.onboarding);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        router.routerDelegate.currentConfiguration.uri.toString(),
        equals(AppRoutes.home),
      );

      await tester.pump(const Duration(seconds: 3));
    });
  });
}

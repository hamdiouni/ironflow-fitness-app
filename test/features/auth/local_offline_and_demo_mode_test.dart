import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/auth/data/datasources/auth_session_storage.dart';
import 'package:progression_tracker/features/auth/data/services/local_sample_data_seeder.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/auth/presentation/widgets/offline_access_section.dart';
import 'package:progression_tracker/features/ai/data/services/insight_cache_service_impl.dart';
import 'package:progression_tracker/features/nutrition/data/datasources/hive_diet_plan_datasource.dart';
import 'package:progression_tracker/features/sync/data/datasources/hive_sync_queue_datasource.dart';
import 'package:progression_tracker/features/workout/presentation/managers/workout_state_manager.dart';

class _ThrowingGoogleAuthRepository implements AuthRepository {
  _ThrowingGoogleAuthRepository(this.googleError);

  final Object googleError;

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<User> signInWithGoogle() async {
    throw googleError;
  }

  @override
  Future<User> signInWithApple() async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<void> reauthenticateWithPassword(String password) async {}

  @override
  Future<void> reauthenticateWithGoogle() async {}

  @override
  Future<UserProfile?> getUserProfile(String userId) async => null;

  @override
  Future<void> saveUserProfile(UserProfile profile) async {}

  @override
  Future<void> updateUserProfile(UserProfile profile) async {}

  @override
  Stream<User?> get authStateChanges => const Stream.empty();
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_local_offline_test_');
    Hive.init(tempDir.path);
    await Hive.openBox('auth_session');
    await Hive.openBox('user_profile');
  });

  setUp(() async {
    await AuthSessionStorage().clearSession();
    await Hive.box('user_profile').clear();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Offline-First Local Mode & Demo Showcase', () {
    test('isLocalOnlyUserId identifies local guest and demo showcase IDs strictly', () {
      expect(isLocalOnlyUserId(kLocalGuestUserId), isTrue);
      expect(isLocalOnlyUserId(kLocalDemoUserId), isTrue);
      expect(isLocalOnlyUserId(null), isFalse);
      expect(isLocalOnlyUserId(''), isFalse);
      expect(isLocalOnlyUserId('firebase_uid_9912'), isFalse);
    });

    test('signInAsLocalGuest authenticates locally and persists session in Hive', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).signInAsLocalGuest();

      final state = container.read(authNotifierProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.user?.id, equals(kLocalGuestUserId));
      expect(AuthSessionStorage().getUserId(), equals(kLocalGuestUserId));
    });

    test('signInAsDemoShowcase authenticates and marks demo profile onboarded', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(authNotifierProvider.notifier)
          .signInAsDemoShowcase();

      final state = container.read(authNotifierProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);
      expect(state.user?.id, equals(kLocalDemoUserId));
      expect(state.user?.displayName, equals('Alex Rivera'));
      expect(AuthSessionStorage().getUserId(), equals(kLocalDemoUserId));
    });

    test('signInWithGoogle surfaces non-cancel errors even when message contains "user"', () async {
      final repo = _ThrowingGoogleAuthRepository(
        Exception('Google Sign-In unauthorized-domain for user origin'),
      );
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(
            () => AuthNotifier(
              signUpUseCase: SignUpUseCase(repo),
              signInUseCase: SignInUseCase(repo),
              signOutUseCase: SignOutUseCase(repo),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await expectLater(
        container.read(authNotifierProvider.notifier).signInWithGoogle(),
        throwsException,
      );

      final state = container.read(authNotifierProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.error, isNotNull);
      expect(state.error, contains('Authorized Domains'));
    });

    test('signInWithGoogle treats popup-closed-by-user as clean cancellation without error', () async {
      final repo = _ThrowingGoogleAuthRepository(
        Exception('[firebase_auth/popup-closed-by-user] Popup closed'),
      );
      final container = ProviderContainer(
        overrides: [
          authNotifierProvider.overrideWith(
            () => AuthNotifier(
              signUpUseCase: SignUpUseCase(repo),
              signInUseCase: SignInUseCase(repo),
              signOutUseCase: SignOutUseCase(repo),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authNotifierProvider.notifier).signInWithGoogle();

      final state = container.read(authNotifierProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.error, isNull);
    });

    testWidgets('OfflineAccessSection renders cleanly on 390x844 mobile viewport', (
      WidgetTester tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: OfflineAccessSection(
                  postAuthRouteResolver: () => '/home',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OFFLINE-FIRST LOCAL ACCESS'), findsOneWidget);
      expect(find.text('Continue Offline (Local Mode)'), findsOneWidget);
      expect(find.text('Explore Live Demo (Sample Data)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('encrypted Hive boxes opened by HiveManager never crash WorkoutStateManager or datasources', () async {
      final cipher = HiveAesCipher(Hive.generateSecureKey());
      await Hive.openBox<dynamic>(
        'active_workout_state',
        encryptionCipher: cipher,
      );
      await Hive.openBox<Map>('diet_plan', encryptionCipher: cipher);
      await Hive.openBox<Map>('insight_cache', encryptionCipher: cipher);
      await Hive.openBox<Map>('sync_queue', encryptionCipher: cipher);

      // Must reuse already-open encrypted boxes without throwing cipher mismatch
      final stateManager = WorkoutStateManager();
      await stateManager.init();
      expect(stateManager.hasSavedState, isFalse);

      final dietDs = HiveDietPlanDataSource();
      expect(await dietDs.loadDietPlan(userId: kLocalDemoUserId), isNull);

      final insightCache = InsightCacheServiceImpl(userId: kLocalDemoUserId);
      await insightCache.init();

      final syncDs = HiveSyncQueueDataSourceImpl();
      expect(await syncDs.getPendingActions(), isEmpty);
    });
  });
}

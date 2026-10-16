import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/auth/data/datasources/auth_session_storage.dart';

/// Regression test suite for Logout Flow.
///
/// Verifies:
/// 1. Sign out completes quickly (well within 3 seconds).
/// 2. Auth state cleanly transitions through loading to unauthenticated.
/// 3. Auth session storage in Hive is cleared completely.
/// 4. Loading state is never stuck after completion or failure.
void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_logout_regression_');
    Hive.init(tempDir.path);
    await Hive.openBox('auth_session');
  });

  setUp(() async {
    await AuthSessionStorage().clearSession();
  });

  tearDown(() async {
    await AuthSessionStorage().clearSession();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Logout Flow Regression Tests', () {
    test('Logout successfully clears authentication and session state', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Sign in with demo account
      await container.read(authNotifierProvider.notifier).signInWithEmail(
            email: 'demo@ironflow.com',
            password: 'password123',
          );

      // Verify authenticated
      var authState = container.read(authNotifierProvider);
      expect(authState.isAuthenticated, isTrue);
      expect(authState.user, isNotNull);
      expect(authState.isLoading, isFalse);

      final stateTransitions = <AuthState>[];
      container.listen(
        authNotifierProvider,
        (previous, next) => stateTransitions.add(next),
      );

      final stopwatch = Stopwatch()..start();
      await container.read(authNotifierProvider.notifier).signOut();
      stopwatch.stop();

      // 1. Completion time must be within 3 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));

      // 2. Final state must be unauthenticated and not loading
      final finalState = container.read(authNotifierProvider);
      expect(finalState.isAuthenticated, isFalse);
      expect(finalState.user, isNull);
      expect(finalState.isLoading, isFalse);
      expect(finalState.error, isNull);

      // 3. State transitions must include loading -> unauthenticated
      expect(stateTransitions, isNotEmpty);
      expect(
        stateTransitions.any((s) => s.isLoading),
        isTrue,
        reason: 'Should transition through loading state during sign out',
      );
      expect(
        finalState.isLoading,
        isFalse,
        reason: 'Final state must not be stuck in loading',
      );

      // 4. Session in storage must be cleared
      final savedUser = await AuthSessionStorage().loadSession();
      expect(savedUser, isNull, reason: 'Session must be cleared from storage');
    });

    test('Repeated sign out calls complete safely without sticking', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Calling signOut when already unauthenticated should complete cleanly
      await container.read(authNotifierProvider.notifier).signOut();

      final state = container.read(authNotifierProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.isLoading, isFalse);
      expect(state.user, isNull);
    });
  });
}

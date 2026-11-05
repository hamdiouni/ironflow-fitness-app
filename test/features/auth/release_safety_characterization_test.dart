import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('Release Safety Characterization & Regression Suite (Wave 1 Step 2)', () {
    test('characterization: in default test/debug environment without prod flavor, authRepositoryProvider resolves', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final repo = container.read(authRepositoryProvider);
      expect(repo, isNotNull);
    });

    test('shouldUseFirebaseAuth ALWAYS enforces real Firebase Auth in release mode or prod/staging flavors (SEC-02)', () {
      // Release mode NEVER allows mock auth, even if flavor=dev and flag=false
      expect(
        shouldUseFirebaseAuth(
          isReleaseMode: true,
          flavor: 'dev',
          useFirebaseAuthFlag: false,
        ),
        isTrue,
      );
      expect(
        shouldUseFirebaseAuth(
          isReleaseMode: true,
          flavor: 'prod',
          useFirebaseAuthFlag: false,
        ),
        isTrue,
      );

      // Prod and staging flavors ALWAYS use real Firebase Auth even in debug mode
      expect(
        shouldUseFirebaseAuth(
          isReleaseMode: false,
          flavor: 'prod',
          useFirebaseAuthFlag: false,
        ),
        isTrue,
      );
      expect(
        shouldUseFirebaseAuth(
          isReleaseMode: false,
          flavor: 'production',
          useFirebaseAuthFlag: false,
        ),
        isTrue,
      );
      expect(
        shouldUseFirebaseAuth(
          isReleaseMode: false,
          flavor: 'staging',
          useFirebaseAuthFlag: false,
        ),
        isTrue,
      );

      // Dev flavor in debug mode respects USE_FIREBASE_AUTH flag
      expect(
        shouldUseFirebaseAuth(
          isReleaseMode: false,
          flavor: 'dev',
          useFirebaseAuthFlag: false,
        ),
        isFalse,
      );
      expect(
        shouldUseFirebaseAuth(
          isReleaseMode: false,
          flavor: 'dev',
          useFirebaseAuthFlag: true,
        ),
        isTrue,
      );
    });

    test('buildAppRoutes excludes /design-preview, /design-gallery, and /ai-test when includeDebugRoutes is false (SEC-05)', () {
      final releaseRoutes = buildAppRoutes(includeDebugRoutes: false)
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toSet();

      expect(releaseRoutes.contains(AppRoutes.designPreview), isFalse);
      expect(releaseRoutes.contains(AppRoutes.designGallery), isFalse);
      expect(releaseRoutes.contains(AppRoutes.aiTest), isFalse);

      // Core production routes remain present
      expect(releaseRoutes.contains(AppRoutes.login), isTrue);
      expect(releaseRoutes.contains(AppRoutes.settings), isTrue);
      expect(releaseRoutes.contains(AppRoutes.aiChat), isTrue);

      // Debug routes are present when includeDebugRoutes is true
      final debugRoutes = buildAppRoutes(includeDebugRoutes: true)
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toSet();
      expect(debugRoutes.contains(AppRoutes.designPreview), isTrue);
      expect(debugRoutes.contains(AppRoutes.designGallery), isTrue);
      expect(debugRoutes.contains(AppRoutes.aiTest), isTrue);
    });

    test('AppRoutes.resolvePostAuthRedirect blocks auth routes, external URLs, and dev/preview routes (SEC-06)', () {
      expect(AppRoutes.resolvePostAuthRedirect(null), equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect(AppRoutes.login), equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect('https://evil.com'), equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect(AppRoutes.designPreview), equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect(AppRoutes.designGallery), equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect(AppRoutes.aiTest), equals(AppRoutes.home));
      expect(AppRoutes.resolvePostAuthRedirect('/workout'), equals('/workout'));
    });

    test('characterization: in debug mode router registers core 4-tab shell', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      final shell = router.configuration.routes.whereType<StatefulShellRoute>().firstOrNull;
      expect(shell, isNotNull);
      expect(shell!.branches.length, equals(4));
    });
  });
}

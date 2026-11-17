import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/router/app_router.dart';

void main() {
  group('Debug & Retired Route Gate Tests', () {
    test('retired /ai-test route is absent and dev routes match kDebugMode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      final paths = router.configuration.routes
          .whereType<GoRoute>()
          .map((route) => route.path)
          .toSet();

      expect(paths.contains('/ai-test'), isFalse);
      expect(paths.contains(AppRoutes.designGallery), equals(kDebugMode));
      expect(paths.contains(AppRoutes.designPreview), equals(kDebugMode));
    });

    test('debug routes are never registered when includeDebugRoutes is false', () {
      final releaseRoutes = buildAppRoutes(includeDebugRoutes: false)
          .whereType<GoRoute>()
          .map((route) => route.path)
          .toSet();
      expect(releaseRoutes.contains('/ai-test'), isFalse);
      expect(releaseRoutes.contains(AppRoutes.designGallery), isFalse);
      expect(releaseRoutes.contains(AppRoutes.designPreview), isFalse);

      final debugRoutes = buildAppRoutes(includeDebugRoutes: true)
          .whereType<GoRoute>()
          .map((route) => route.path)
          .toSet();
      expect(debugRoutes.contains('/ai-test'), isFalse);
      expect(debugRoutes.contains(AppRoutes.designGallery), isTrue);
      expect(debugRoutes.contains(AppRoutes.designPreview), isTrue);
    });
  });
}

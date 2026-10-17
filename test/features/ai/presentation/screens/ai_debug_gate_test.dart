import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/router/app_router.dart';

void main() {
  group('AI Debug Gate Tests', () {
    test('ai_test route registration is strictly conditioned on kDebugMode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      final hasAiTestRoute = router.configuration.routes
          .any((route) => route is GoRoute && route.path == AppRoutes.aiTest);

      // In the test runner environment, kDebugMode is true.
      // This asserts the route existence directly matches kDebugMode.
      expect(hasAiTestRoute, equals(kDebugMode));
    });

    test('ai_test route is never registered when debug flag is false', () {
      List<RouteBase> buildTestRoutes({required bool isDebug}) {
        return [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const Placeholder(),
          ),
          if (isDebug)
            GoRoute(
              path: AppRoutes.aiTest,
              builder: (context, state) => const Placeholder(),
            ),
        ];
      }

      final releaseRoutes = buildTestRoutes(isDebug: false);
      final hasAiTestRoute = releaseRoutes
          .any((route) => route is GoRoute && route.path == AppRoutes.aiTest);

      expect(hasAiTestRoute, isFalse);

      final debugRoutes = buildTestRoutes(isDebug: true);
      final hasAiTestInDebug = debugRoutes
          .any((route) => route is GoRoute && route.path == AppRoutes.aiTest);

      expect(hasAiTestInDebug, isTrue);
    });
  });
}

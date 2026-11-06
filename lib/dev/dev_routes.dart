import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_router.dart';
import '../features/ai/presentation/screens/ai_test_screen.dart';
import '../features/design_system/presentation/screens/design_gallery_screen.dart';
import 'design_lab/main_design_lab.dart';

/// Developer-only routes gated out of release builds (Wave 3.5 / SEC-05).
List<RouteBase> buildDebugRoutes() {
  if (kReleaseMode) {
    return const <RouteBase>[];
  }
  return <RouteBase>[
    GoRoute(
      path: AppRoutes.designPreview,
      builder: (context, state) => const DesignLabScreen(),
    ),
    GoRoute(
      path: AppRoutes.designGallery,
      builder: (context, state) => const DesignGalleryScreen(),
    ),
    GoRoute(
      path: AppRoutes.aiTest,
      builder: (context, state) => const AITestScreen(),
    ),
  ];
}


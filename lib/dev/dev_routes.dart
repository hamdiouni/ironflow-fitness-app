import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../core/router/app_router.dart';
import '../features/design_system/presentation/screens/design_gallery_screen.dart';

/// Developer-only routes gated out of release builds (Wave 3.5 / SEC-05).
List<RouteBase> buildDebugRoutes() {
  if (kReleaseMode) {
    return const <RouteBase>[];
  }
  return <RouteBase>[
    GoRoute(
      path: AppRoutes.designPreview,
      builder: (context, state) => const DesignGalleryScreen(),
    ),
    GoRoute(
      path: AppRoutes.designGallery,
      builder: (context, state) => const DesignGalleryScreen(),
    ),
  ];
}

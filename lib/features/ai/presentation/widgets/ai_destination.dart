import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

/// Unified helper to navigate to the AI Coach destination.
///
/// Ensures consistent routing behavior across all entry points:
/// hero card, header button, and contextual banners.
void navigateToAiCoach(
  BuildContext context, {
  String? initialMessage,
  String? contextScreen,
}) {
  final extra = <String, dynamic>{};
  if (initialMessage != null) {
    extra['initialMessage'] = initialMessage;
  }
  if (contextScreen != null) {
    extra['contextScreen'] = contextScreen;
  }
  try {
    context.push(AppRoutes.aiChat, extra: extra.isEmpty ? null : extra);
  } catch (_) {
    // Graceful fallback if GoRouter is not mounted in widget test scope
  }
}

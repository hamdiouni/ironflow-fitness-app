import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

/// Unified helper to navigate to the AI Coach destination.
///
/// Ensures consistent routing behavior across all entry points:
/// hero card, header button, and contextual banners.
void navigateToAiCoach(BuildContext context, {String? initialMessage}) {
  final extra = <String, dynamic>{};
  if (initialMessage != null) {
    extra['initialMessage'] = initialMessage;
  }
  context.push(AppRoutes.aiChat, extra: extra.isEmpty ? null : extra);
}

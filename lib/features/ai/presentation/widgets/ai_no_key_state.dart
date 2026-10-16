import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';

/// Reusable state widget shown when AI API keys are not configured.
///
/// Explains that AI coaching features are unavailable in the current
/// build without crashing and without disclosing any partial secrets or tokens.
class AiNoKeyState extends StatelessWidget {
  const AiNoKeyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final secondary = theme.colorScheme.onSurfaceVariant;

    return Semantics(
      label:
          'AI features currently unavailable. Configuration required.',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingMedium,
          horizontal: AppTheme.spacingSmall,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: secondary.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Icon(
                    Icons.key_off_outlined,
                    color: secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                Expanded(
                  child: Text(
                    'AI Coach Unavailable',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Personalized AI insights and conversational coaching are currently unavailable. Please verify API configuration in your environment.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: secondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/progression_suggestion.dart';
import '../../domain/usecases/get_progression_suggestion_use_case.dart';

class ProgressionSuggestionCard extends StatelessWidget {
  final ProgressionSuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  const ProgressionSuggestionCard({
    required this.suggestion,
    required this.onAccept,
    required this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppTheme.glassmorphicCard(
      margin: const EdgeInsets.all(AppTheme.spacingMedium),
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSmall),
                decoration: BoxDecoration(
                  color: _getColor().withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (suggestion.message != null)
                      Text(
                        suggestion.message!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMedium),

          // Suggested values
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Suggested Weight:'),
                Text(
                  '${suggestion.suggestedWeight.toStringAsFixed(1)} kg',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Suggested Reps:'),
                Text(
                  '${suggestion.suggestedReps}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDismiss,
                  child: const Text('Dismiss'),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    if (suggestion.isStagnant) {
      return 'Deload Recommended';
    }
    return 'Progression Suggestion';
  }

  IconData _getIcon() {
    if (suggestion.isStagnant) {
      return Icons.trending_down;
    }
    return Icons.trending_up;
  }

  Color _getColor() {
    if (suggestion.isStagnant) {
      return Colors.red;
    }
    return Colors.green;
  }
}

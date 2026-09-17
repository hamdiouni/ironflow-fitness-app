import 'package:flutter/material.dart';

import '../../../../core/constants/app_theme.dart';
import '../../domain/entities/achievement.dart';

/// Displays a single achievement badge.
///
/// Shows locked/unlocked state with progress indicator.
class AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onTap;

  const AchievementBadge({
    required this.achievement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: achievement.isUnlocked
                      ? Colors.amber.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  border: Border.all(
                    color: achievement.isUnlocked
                        ? Colors.amber
                        : Colors.grey.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),

              // Progress ring
              if (!achievement.isUnlocked)
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: achievement.progress,
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.amber.withValues(alpha: 0.5),
                    ),
                  ),
                ),

              // Icon
              Text(
                achievement.icon,
                style: const TextStyle(fontSize: 32),
              ),

              // Lock icon if not unlocked
              if (!achievement.isUnlocked)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Text(
                  achievement.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!achievement.isUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${(achievement.progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

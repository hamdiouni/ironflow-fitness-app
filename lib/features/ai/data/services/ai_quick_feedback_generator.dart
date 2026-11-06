import 'package:progression_tracker/features/ai/data/services/ai_insight_metrics_calculator.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';

/// Celebratory post-workout quick feedback generator for [AIInsightsEngineImpl].
class AIQuickFeedbackGenerator {
  const AIQuickFeedbackGenerator(this._calc);

  final AIInsightMetricsCalculator _calc;

  Future<Insight> generateQuickFeedback(
    Workout completedWorkout,
    List<Workout> history,
  ) async {
    // Combine completed workout with history for analysis
    final allWorkouts = [completedWorkout, ...history];
    
    // Detect PR achievements
    final prDetails = _calc.getPRDetails(allWorkouts);
    final hasPR = prDetails.isNotEmpty;
    
    // Detect volume records (10%+ increase)
    final currentVolume = _calc.calculateVolume(completedWorkout);
    final hasVolumeRecord = _detectVolumeRecord(completedWorkout, history);
    final volumeIncrease = _calculateVolumeIncrease(completedWorkout, history);
    
    // Detect consistency milestones
    final consistencyStreak = _calculateConsistencyStreak(allWorkouts);
    final hasConsistencyMilestone = _isConsistencyMilestone(consistencyStreak);
    
    // Prioritize achievements and create celebratory feedback
    if (hasPR) {
      return _createPRFeedback(prDetails, currentVolume);
    } else if (hasVolumeRecord) {
      return _createVolumeRecordFeedback(currentVolume, volumeIncrease);
    } else if (hasConsistencyMilestone) {
      return _createConsistencyMilestoneFeedback(consistencyStreak);
    } else {
      return _createGeneralEncouragementFeedback(currentVolume, consistencyStreak);
    }
  }

  /// Detect if current workout achieved a volume record (10%+ increase)
  ///
  /// **Requirements:**
  /// - 10.5: Celebrate Progressive Overload (10%+ volume increase)
  bool _detectVolumeRecord(Workout currentWorkout, List<Workout> history) {
    if (history.isEmpty) return false;
    
    final currentVolume = _calc.calculateVolume(currentWorkout);
    
    // Calculate average volume from recent workouts (last 4 workouts or all if less)
    final recentWorkouts = history.take(4).toList();
    if (recentWorkouts.isEmpty) return false;
    
    final totalRecentVolume = recentWorkouts
        .map((w) => _calc.calculateVolume(w))
        .fold<double>(0.0, (sum, volume) => sum + volume);
    final averageRecentVolume = totalRecentVolume / recentWorkouts.length;
    
    if (averageRecentVolume == 0) return false;
    
    // Check if current volume is 10%+ higher than recent average
    final increasePercentage = ((currentVolume - averageRecentVolume) / averageRecentVolume) * 100;
    return increasePercentage >= 10.0;
  }
  
  /// Calculate volume increase percentage compared to recent average
  double _calculateVolumeIncrease(Workout currentWorkout, List<Workout> history) {
    if (history.isEmpty) return 0.0;
    
    final currentVolume = _calc.calculateVolume(currentWorkout);
    
    // Calculate average volume from recent workouts (last 4 workouts or all if less)
    final recentWorkouts = history.take(4).toList();
    if (recentWorkouts.isEmpty) return 0.0;
    
    final totalRecentVolume = recentWorkouts
        .map((w) => _calc.calculateVolume(w))
        .fold<double>(0.0, (sum, volume) => sum + volume);
    final averageRecentVolume = totalRecentVolume / recentWorkouts.length;
    
    if (averageRecentVolume == 0) return 0.0;
    
    return ((currentVolume - averageRecentVolume) / averageRecentVolume) * 100;
  }
  
  /// Calculate consistency streak (consecutive workout days)
  ///
  /// **Requirements:**
  /// - 10.3: Highlight consistency milestones
  int _calculateConsistencyStreak(List<Workout> workouts) {
    if (workouts.isEmpty) return 0;
    
    // Sort workouts by date (most recent first)
    final sortedWorkouts = List<Workout>.from(workouts)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 1; // Start with 1 for the current workout
    
    // Check for consecutive days working backwards from today
    for (int i = 1; i < sortedWorkouts.length; i++) {
      final currentWorkout = sortedWorkouts[i - 1];
      final previousWorkout = sortedWorkouts[i];
      
      // Calculate days between workouts
      final daysBetween = currentWorkout.date.difference(previousWorkout.date).inDays;
      
      // If workouts are 1-2 days apart (allowing for rest days), continue streak
      if (daysBetween <= 2) {
        streak++;
      } else {
        break; // Streak broken
      }
    }
    
    return streak;
  }
  
  /// Check if current streak represents a milestone worth celebrating
  ///
  /// **Requirements:**
  /// - 10.3: Highlight consistency milestones
  bool _isConsistencyMilestone(int streak) {
    // Celebrate milestones at 3, 5, 7, 10, 14, 21, 30 days
    const milestones = [3, 5, 7, 10, 14, 21, 30];
    return milestones.contains(streak);
  }
  
  /// Create PR achievement feedback
  ///
  /// **Requirements:**
  /// - 10.4: Display specific exercise and weight for PRs
  /// - 10.8: Use celebratory language and emojis
  Insight _createPRFeedback(Map<String, double> prDetails, double currentVolume) {
    final prEntry = prDetails.entries.first; // Take the first PR for simplicity
    final exerciseName = prEntry.key;
    final prWeight = prEntry.value;
    
    return Insight(
      id: 'pr_feedback_${DateTime.now().millisecondsSinceEpoch}',
      context: InsightContext.workout,
      title: '🎉 New Personal Record!',
      message: 'Congratulations! You just hit a new PR on $exerciseName with ${_calc.formatNumber(prWeight)}kg! Your total workout volume was ${_calc.formatNumber(currentVolume)}kg. Keep pushing those limits!',
      icon: '🏆',
      priority: InsightPriority.high,
      generatedAt: DateTime.now(),
      metadata: {
        'type': 'pr_achievement',
        'exercise': exerciseName,
        'weight': prWeight,
        'volume': currentVolume,
        'pr_count': prDetails.length,
      },
    );
  }
  
  /// Create volume record feedback
  ///
  /// **Requirements:**
  /// - 10.5: Celebrate Progressive Overload (10%+ volume increase)
  /// - 10.8: Use celebratory language and emojis
  Insight _createVolumeRecordFeedback(double currentVolume, double volumeIncrease) {
    return Insight(
      id: 'volume_record_${DateTime.now().millisecondsSinceEpoch}',
      context: InsightContext.workout,
      title: '💪 Volume Record Smashed!',
      message: 'Amazing work! You lifted ${_calc.formatNumber(currentVolume)}kg total volume today - that\'s ${_calc.formatNumber(volumeIncrease)}% higher than your recent average! This is progressive overload in action!',
      icon: '📈',
      priority: InsightPriority.high,
      generatedAt: DateTime.now(),
      metadata: {
        'type': 'volume_record',
        'volume': currentVolume,
        'increase_percentage': volumeIncrease,
      },
    );
  }
  
  /// Create consistency milestone feedback
  ///
  /// **Requirements:**
  /// - 10.3: Highlight consistency milestones
  /// - 10.8: Use celebratory language and emojis
  Insight _createConsistencyMilestoneFeedback(int streak) {
    String title;
    String message;
    String icon;
    
    if (streak >= 30) {
      title = '🔥 30-Day Streak Champion!';
      message = 'Incredible! You\'ve maintained a $streak-day workout streak! You\'re building unstoppable momentum and creating lasting habits. This is what dedication looks like!';
      icon = '👑';
    } else if (streak >= 21) {
      title = '🌟 3-Week Streak Master!';
      message = 'Outstanding! $streak days of consistent training! You\'re officially in habit-building territory. Your future self will thank you for this dedication!';
      icon = '⭐';
    } else if (streak >= 14) {
      title = '🚀 2-Week Streak Superstar!';
      message = 'Fantastic! You\'ve hit a $streak-day streak! You\'re building serious momentum and proving that consistency beats perfection every time!';
      icon = '🚀';
    } else if (streak >= 10) {
      title = '💎 Double Digit Streak!';
      message = 'Excellent! $streak days in a row! You\'re developing an unbreakable routine. Keep this momentum going - you\'re on fire!';
      icon = '💎';
    } else if (streak >= 7) {
      title = '🔥 One Week Strong!';
      message = 'Great job! You\'ve completed $streak days of training! You\'re building a solid foundation of consistency. The hardest part is behind you!';
      icon = '🔥';
    } else if (streak >= 5) {
      title = '⚡ 5-Day Streak!';
      message = 'Nice work! $streak days of consistent training! You\'re developing great habits. Keep the momentum rolling!';
      icon = '⚡';
    } else {
      title = '🎯 Building Momentum!';
      message = 'Great start! $streak days of training! Consistency is the key to success. You\'re on the right track!';
      icon = '🎯';
    }
    
    return Insight(
      id: 'consistency_milestone_${DateTime.now().millisecondsSinceEpoch}',
      context: InsightContext.workout,
      title: title,
      message: message,
      icon: icon,
      priority: InsightPriority.high,
      generatedAt: DateTime.now(),
      metadata: {
        'type': 'consistency_milestone',
        'streak': streak,
      },
    );
  }
  
  /// Create general encouragement feedback when no specific achievements
  ///
  /// **Requirements:**
  /// - 10.8: Use celebratory language and emojis
  Insight _createGeneralEncouragementFeedback(double currentVolume, int streak) {
    return Insight(
      id: 'general_encouragement_${DateTime.now().millisecondsSinceEpoch}',
      context: InsightContext.workout,
      title: '💪 Great Workout!',
      message: 'Nice work today! You lifted ${_calc.formatNumber(currentVolume)}kg total volume and you\'re on a $streak-day streak. Every workout counts towards your goals. Keep it up!',
      icon: '💪',
      priority: InsightPriority.medium,
      generatedAt: DateTime.now(),
      metadata: {
        'type': 'general_encouragement',
        'volume': currentVolume,
        'streak': streak,
      },
    );
  }
}

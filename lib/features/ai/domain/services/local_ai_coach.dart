import 'package:progression_tracker/features/workout/domain/entities/entities.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/entities.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';

/// Local AI Coach - Simple logic-based fitness assistant
/// 
/// Provides coaching feedback based on user data without external API calls.
class LocalAICoach {
  /// Generate coaching response based on user data
  String generateResponse(String userMessage, {
    UserProfile? profile,
    List<Workout>? recentWorkouts,
    List<DailyNutritionSummary>? nutritionHistory,
    NutritionTargets? nutritionTargets,
    List<BodyEntry>? bodyEntries,
  }) {
    final message = userMessage.toLowerCase();
    
    // Analyze what the user is asking about
    if (_isAboutWorkout(message)) {
      return _generateWorkoutAdvice(recentWorkouts, profile);
    } else if (_isAboutNutrition(message)) {
      return _generateNutritionAdvice(nutritionHistory, nutritionTargets, profile);
    } else if (_isAboutProgress(message)) {
      return _generateProgressAnalysis(recentWorkouts, bodyEntries, nutritionHistory);
    } else if (_isAboutMotivation(message)) {
      return _generateMotivation(recentWorkouts, bodyEntries);
    } else {
      return _generateGeneralAdvice(recentWorkouts, nutritionHistory, bodyEntries, profile);
    }
  }
  
  bool _isAboutWorkout(String message) {
    return message.contains('workout') ||
        message.contains('train') ||
        message.contains('exercise') ||
        message.contains('lift') ||
        message.contains('program') ||
        message.contains('routine');
  }
  
  bool _isAboutNutrition(String message) {
    return message.contains('diet') ||
        message.contains('nutrition') ||
        message.contains('food') ||
        message.contains('eat') ||
        message.contains('protein') ||
        message.contains('calorie') ||
        message.contains('macro');
  }
  
  bool _isAboutProgress(String message) {
    return message.contains('progress') ||
        message.contains('result') ||
        message.contains('improve') ||
        message.contains('gain') ||
        message.contains('lose') ||
        message.contains('change');
  }
  
  bool _isAboutMotivation(String message) {
    return message.contains('motivat') ||
        message.contains('inspire') ||
        message.contains('encourage') ||
        message.contains('help') ||
        message.contains('stuck');
  }
  
  String _generateWorkoutAdvice(List<Workout>? workouts, UserProfile? profile) {
    if (workouts == null || workouts.isEmpty) {
      return "No workouts logged yet. Start logging your sessions to track strength gains over time.\n\n**Next Step:** Tap the Workout tab and start your first session today.";
    }

    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    final recent = workouts.where((w) => w.date.isAfter(lastWeek)).toList();
    final count = recent.length;

    final buffer = StringBuffer();
    if (count >= 3) {
      buffer.writeln("Great consistency—you logged $count workouts this week.");
    } else if (count > 0) {
      buffer.writeln("Good start with $count workout${count > 1 ? 's' : ''} this week.");
    } else {
      buffer.writeln("No workouts logged this week yet.");
    }
    buffer.writeln("Aim for progressive overload: add 1 rep or small weight to your main lift.");
    buffer.write("\n**Next Step:** Choose your next workout routine and schedule your session.");
    return buffer.toString();
  }

  String _generateNutritionAdvice(
    List<DailyNutritionSummary>? nutritionHistory,
    NutritionTargets? targets,
    UserProfile? profile,
  ) {
    if (nutritionHistory == null || nutritionHistory.isEmpty) {
      return "No meals logged yet. Tracking meals helps you hit your daily protein and calorie goals consistently.\n\n**Next Step:** Go to the Fuel tab and log your breakfast or lunch.";
    }

    final avgCal = nutritionHistory.fold<double>(0, (sum, day) => sum + day.totalCalories) /
        nutritionHistory.length;
    final avgPro = nutritionHistory.fold<double>(0, (sum, day) => sum + day.totalProtein) /
        nutritionHistory.length;

    final buffer = StringBuffer();
    buffer.writeln("Daily averages over ${nutritionHistory.length} tracked days:");
    buffer.writeln("• Calories: ${avgCal.toStringAsFixed(0)} kcal");
    buffer.writeln("• Protein: ${avgPro.toStringAsFixed(0)}g");

    if (targets != null && avgPro < targets.macros.protein - 10) {
      buffer.writeln("• Target: ${targets.macros.protein.toStringAsFixed(0)}g protein");
      buffer.write("\n**Next Step:** Add a high-protein food like chicken, eggs, or Greek yogurt to your next meal.");
    } else {
      buffer.write("\n**Next Step:** Keep hydration high and plan your evening meal.");
    }
    return buffer.toString();
  }

  String _generateProgressAnalysis(
    List<Workout>? workouts,
    List<BodyEntry>? bodyEntries,
    List<DailyNutritionSummary>? nutrition,
  ) {
    final buffer = StringBuffer("Here is your recent progress summary:\n\n");
    final count = workouts?.length ?? 0;
    buffer.writeln("• Workouts: $count sessions logged");

    if (bodyEntries != null && bodyEntries.length >= 2) {
      final change = bodyEntries.first.weight - bodyEntries.last.weight;
      final sign = change >= 0 ? '+' : '';
      buffer.writeln("• Weight trend: $sign${change.toStringAsFixed(1)} change");
    } else if (bodyEntries != null && bodyEntries.isNotEmpty) {
      buffer.writeln("• Current weight: ${bodyEntries.first.weight.toStringAsFixed(1)}");
    }

    final nutCount = nutrition?.length ?? 0;
    buffer.writeln("• Nutrition: $nutCount days tracked");

    buffer.write("\n**Next Step:** Log today's workout or weigh-in to keep your data current.");
    return buffer.toString();
  }

  String _generateMotivation(List<Workout>? workouts, List<BodyEntry>? bodyEntries) {
    return "Consistency beats intensity every time. Showing up today moves you closer to your fitness goals than waiting for motivation.\n\n**Next Step:** Put on your workout clothes and complete a 5-minute warmup.";
  }

  String _generateGeneralAdvice(
    List<Workout>? workouts,
    List<DailyNutritionSummary>? nutrition,
    List<BodyEntry>? bodyEntries,
    UserProfile? profile,
  ) {
    return "I am your IronFlow fitness assistant. I can help with:\n\n• Workout planning and exercise form\n• Nutrition and protein targets\n• Breaking strength plateaus\n\n**Next Step:** Select a question chip above or ask me anything.";
  }
}

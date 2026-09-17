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
      return "I don't see any recent workouts logged. Let's get started! "
          "Start by logging your first workout to track your progress.";
    }
    
    final lastWeek = DateTime.now().subtract(const Duration(days: 7));
    final recentWorkouts = workouts.where((w) => w.date.isAfter(lastWeek)).toList();
    final workoutCount = recentWorkouts.length;
    
    final buffer = StringBuffer();
    
    // Consistency feedback
    if (workoutCount >= 4) {
      buffer.writeln("💪 Excellent consistency! You trained $workoutCount times this week.");
    } else if (workoutCount >= 2) {
      buffer.writeln("👍 Good work! You trained $workoutCount times this week.");
      // Note: UserProfile doesn't have workoutDaysPerWeek, so we skip this check
    } else if (workoutCount == 1) {
      buffer.writeln("You trained once this week. Let's aim for more consistency!");
    } else {
      buffer.writeln("You haven't trained this week yet. Time to get back at it!");
    }
    
    // Volume analysis
    if (recentWorkouts.isNotEmpty) {
      final totalVolume = recentWorkouts.fold<double>(0, (sum, w) => sum + w.totalVolume);
      final avgVolume = totalVolume / recentWorkouts.length;
      buffer.writeln("\n📊 Average volume: ${avgVolume.toStringAsFixed(0)} lbs per workout");
      
      // Check for progressive overload
      if (recentWorkouts.length >= 2) {
        final firstHalf = recentWorkouts.take(recentWorkouts.length ~/ 2).toList();
        final secondHalf = recentWorkouts.skip(recentWorkouts.length ~/ 2).toList();
        
        final firstAvg = firstHalf.fold<double>(0, (sum, w) => sum + w.totalVolume) / firstHalf.length;
        final secondAvg = secondHalf.fold<double>(0, (sum, w) => sum + w.totalVolume) / secondHalf.length;
        
        if (secondAvg > firstAvg * 1.05) {
          buffer.writeln("\n🚀 Great! Your volume is increasing - that's progressive overload!");
        } else if (secondAvg < firstAvg * 0.95) {
          buffer.writeln("\n⚠️ Your volume is decreasing. Make sure you're recovering properly.");
        }
      }
    }
    
    // Exercise variety check
    final allExercises = <String>{};
    for (final workout in recentWorkouts) {
      for (final exercise in workout.exercises) {
        allExercises.add(exercise.name.toLowerCase());
      }
    }
    
    // Check for missing muscle groups
    final hasLegWork = allExercises.any((e) => 
        e.contains('squat') || e.contains('leg') || e.contains('deadlift'));
    final hasPushWork = allExercises.any((e) => 
        e.contains('bench') || e.contains('press') || e.contains('push'));
    final hasPullWork = allExercises.any((e) => 
        e.contains('row') || e.contains('pull') || e.contains('chin'));
    
    if (!hasLegWork) {
      buffer.writeln("\n🦵 Don't skip leg day! Add squats or deadlifts to your routine.");
    }
    if (!hasPushWork) {
      buffer.writeln("\n💪 Include some pushing exercises like bench press or overhead press.");
    }
    if (!hasPullWork) {
      buffer.writeln("\n🔙 Add pulling exercises like rows or pull-ups for balanced development.");
    }
    
    return buffer.toString().trim();
  }
  
  String _generateNutritionAdvice(
    List<DailyNutritionSummary>? nutritionHistory,
    NutritionTargets? targets,
    UserProfile? profile,
  ) {
    if (nutritionHistory == null || nutritionHistory.isEmpty) {
      return "I don't see any nutrition data logged yet. "
          "Start tracking your meals to get personalized nutrition advice!";
    }
    
    final buffer = StringBuffer();
    
    // Calculate averages
    final avgCalories = nutritionHistory.fold<double>(0, (sum, day) => sum + day.totalCalories) / nutritionHistory.length;
    final avgProtein = nutritionHistory.fold<double>(0, (sum, day) => sum + day.totalProtein) / nutritionHistory.length;
    final avgCarbs = nutritionHistory.fold<double>(0, (sum, day) => sum + day.totalCarbs) / nutritionHistory.length;
    final avgFats = nutritionHistory.fold<double>(0, (sum, day) => sum + day.totalFats) / nutritionHistory.length;
    
    buffer.writeln("📊 Your nutrition (last ${nutritionHistory.length} days):");
    buffer.writeln("• Calories: ${avgCalories.toStringAsFixed(0)} kcal/day");
    buffer.writeln("• Protein: ${avgProtein.toStringAsFixed(0)}g/day");
    buffer.writeln("• Carbs: ${avgCarbs.toStringAsFixed(0)}g/day");
    buffer.writeln("• Fats: ${avgFats.toStringAsFixed(0)}g/day");
    
    if (targets != null) {
      buffer.writeln("\n🎯 Target Analysis:");
      
      // Protein check
      final proteinDiff = avgProtein - targets.macros.protein;
      if (proteinDiff < -20) {
        buffer.writeln("⚠️ Protein is too low! Aim for ${targets.macros.protein.toStringAsFixed(0)}g/day.");
        buffer.writeln("   Add: chicken, fish, eggs, protein shakes");
      } else if (proteinDiff < 0) {
        buffer.writeln("📈 Increase protein by ${(-proteinDiff).toStringAsFixed(0)}g to hit your target.");
      } else {
        buffer.writeln("✅ Protein intake is on track!");
      }
      
      // Calorie check
      final calorieDiff = avgCalories - targets.macros.calories;
      if (calorieDiff.abs() > 200) {
        if (calorieDiff > 0) {
          buffer.writeln("⚠️ You're eating ${calorieDiff.toStringAsFixed(0)} kcal above target.");
        } else {
          buffer.writeln("⚠️ You're eating ${(-calorieDiff).toStringAsFixed(0)} kcal below target.");
        }
      }
    } else {
      // General advice without targets
      // Note: UserProfile doesn't have weightKg, so we use a default calculation
      final minProtein = 150.0; // Default minimum protein for muscle building
      
      if (avgProtein < minProtein) {
        buffer.writeln("\n⚠️ Protein is too low for muscle building!");
        buffer.writeln("   Aim for at least ${minProtein.toStringAsFixed(0)}g/day");
      } else {
        buffer.writeln("\n✅ Protein intake looks good!");
      }
    }
    
    return buffer.toString().trim();
  }
  
  String _generateProgressAnalysis(
    List<Workout>? workouts,
    List<BodyEntry>? bodyEntries,
    List<DailyNutritionSummary>? nutrition,
  ) {
    final buffer = StringBuffer("📈 Progress Analysis:\n\n");
    
    // Workout progress
    if (workouts != null && workouts.isNotEmpty) {
      final lastMonth = DateTime.now().subtract(const Duration(days: 30));
      final recentWorkouts = workouts.where((w) => w.date.isAfter(lastMonth)).toList();
      
      buffer.writeln("💪 Workouts:");
      buffer.writeln("• ${recentWorkouts.length} workouts in the last 30 days");
      
      if (recentWorkouts.length >= 8) {
        buffer.writeln("• Excellent consistency! 🔥");
      } else if (recentWorkouts.length >= 4) {
        buffer.writeln("• Good consistency, keep it up!");
      } else {
        buffer.writeln("• Try to train more consistently");
      }
      
      // Calculate PRs
      final exerciseMaxes = <String, double>{};
      int prCount = 0;
      
      for (final workout in recentWorkouts) {
        for (final exercise in workout.exercises) {
          final maxWeight = exercise.sets.fold<double>(0, (max, set) => 
              set.weight > max ? set.weight : max);
          
          if (maxWeight > 0) {
            final currentMax = exerciseMaxes[exercise.name] ?? 0;
            if (maxWeight > currentMax) {
              prCount++;
              exerciseMaxes[exercise.name] = maxWeight;
            }
          }
        }
      }
      
      if (prCount > 0) {
        buffer.writeln("• $prCount personal records this month! 🎉");
      }
    }
    
    // Body weight progress
    if (bodyEntries != null && bodyEntries.length >= 2) {
      final latest = bodyEntries.first.weight;
      final oldest = bodyEntries.last.weight;
      final change = latest - oldest;
      
      buffer.writeln("\n⚖️ Body Weight:");
      buffer.writeln("• Current: ${latest.toStringAsFixed(1)} lbs");
      
      if (change.abs() >= 2) {
        if (change > 0) {
          buffer.writeln("• Up ${change.toStringAsFixed(1)} lbs");
        } else {
          buffer.writeln("• Down ${(-change).toStringAsFixed(1)} lbs");
        }
      } else {
        buffer.writeln("• Stable (±${change.abs().toStringAsFixed(1)} lbs)");
      }
    }
    
    // Nutrition consistency
    if (nutrition != null && nutrition.isNotEmpty) {
      buffer.writeln("\n🍽️ Nutrition:");
      buffer.writeln("• ${nutrition.length} days tracked");
      
      if (nutrition.length >= 7) {
        buffer.writeln("• Great tracking consistency!");
      } else {
        buffer.writeln("• Track more days for better insights");
      }
    }
    
    buffer.writeln("\n💡 Keep pushing forward! Consistency is key.");
    
    return buffer.toString().trim();
  }
  
  String _generateMotivation(List<Workout>? workouts, List<BodyEntry>? bodyEntries) {
    final motivationalQuotes = [
      "💪 Every workout counts! You're building the body you want, one rep at a time.",
      "🔥 The pain you feel today will be the strength you feel tomorrow.",
      "🎯 Success is the sum of small efforts repeated day in and day out.",
      "💯 Your only limit is you. Push harder than yesterday!",
      "⚡ The hardest lift is lifting yourself off the couch. You've got this!",
      "🏆 Champions are made in the gym. Keep grinding!",
      "🚀 Progress, not perfection. Every workout is a step forward.",
    ];
    
    final buffer = StringBuffer();
    
    // Add a motivational quote
    buffer.writeln(motivationalQuotes[DateTime.now().millisecond % motivationalQuotes.length]);
    
    // Add personalized encouragement
    if (workouts != null && workouts.isNotEmpty) {
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final recentCount = workouts.where((w) => w.date.isAfter(lastWeek)).length;
      
      if (recentCount >= 4) {
        buffer.writeln("\nYou've been crushing it with $recentCount workouts this week! 🔥");
      } else if (recentCount >= 2) {
        buffer.writeln("\nYou're making progress with $recentCount workouts this week. Keep going!");
      } else {
        buffer.writeln("\nTime to get back in the gym! Your future self will thank you.");
      }
    }
    
    buffer.writeln("\nRemember: The best workout is the one you actually do. Let's make today count! 💪");
    
    return buffer.toString().trim();
  }
  
  String _generateGeneralAdvice(
    List<Workout>? workouts,
    List<DailyNutritionSummary>? nutrition,
    List<BodyEntry>? bodyEntries,
    UserProfile? profile,
  ) {
    final buffer = StringBuffer("👋 Hey! I'm your IronFlow AI Coach.\n\n");
    
    // Overall status
    final hasWorkouts = workouts != null && workouts.isNotEmpty;
    final hasNutrition = nutrition != null && nutrition.isNotEmpty;
    final hasBodyData = bodyEntries != null && bodyEntries.isNotEmpty;
    
    if (!hasWorkouts && !hasNutrition && !hasBodyData) {
      buffer.writeln("Let's get started on your fitness journey!");
      buffer.writeln("\n📝 Here's what you can do:");
      buffer.writeln("• Log your first workout");
      buffer.writeln("• Track your meals");
      buffer.writeln("• Record your body weight");
      buffer.writeln("\nOnce you have some data, I can give you personalized advice!");
      return buffer.toString().trim();
    }
    
    buffer.writeln("Here's a quick overview:\n");
    
    // Workout summary
    if (hasWorkouts) {
      final lastWeek = DateTime.now().subtract(const Duration(days: 7));
      final recentCount = workouts!.where((w) => w.date.isAfter(lastWeek)).length;
      buffer.writeln("💪 Workouts: $recentCount this week");
    } else {
      buffer.writeln("💪 Workouts: No recent data");
    }
    
    // Nutrition summary
    if (hasNutrition) {
      final avgCalories = nutrition!.fold<double>(0, (sum, day) => sum + day.totalCalories) / nutrition.length;
      buffer.writeln("🍽️ Nutrition: ${avgCalories.toStringAsFixed(0)} kcal/day avg");
    } else {
      buffer.writeln("🍽️ Nutrition: No recent data");
    }
    
    // Body weight summary
    if (hasBodyData) {
      final latest = bodyEntries!.first.weight;
      buffer.writeln("⚖️ Weight: ${latest.toStringAsFixed(1)} lbs");
    } else {
      buffer.writeln("⚖️ Weight: No recent data");
    }
    
    buffer.writeln("\n💡 Ask me about:");
    buffer.writeln("• Your workout progress");
    buffer.writeln("• Nutrition advice");
    buffer.writeln("• What to focus on next");
    
    return buffer.toString().trim();
  }
}

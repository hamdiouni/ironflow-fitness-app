import 'package:progression_tracker/core/providers/units_provider.dart';
import 'package:progression_tracker/core/utils/workout_streak_calculator.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/services/muscle_recovery_calculator.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/entities.dart';
import 'package:progression_tracker/features/workout/domain/entities/entities.dart';

/// Builds the AI Coach system prompt with privacy-first consent gating,
/// unit preferences (`kg` vs `lbs`), workout streaks, and muscle recovery
/// readiness scores (Wave 7.2).
class AiChatPromptBuilder {
  const AiChatPromptBuilder._();

  static String buildSystemPrompt({
    bool hasConsent = false,
    UnitsSystem units = UnitsSystem.metric,
    UserProfile? profile,
    List<Workout> recentWorkouts = const [],
    List<DailyNutritionSummary> nutritionHistory = const [],
    NutritionTargets? nutritionTargets,
    List<BodyEntry> bodyEntries = const [],
  }) {
    final buffer = StringBuffer();
    final unitLabel = units == UnitsSystem.imperial ? 'lbs' : 'kg';

    buffer.writeln(
      'You are a knowledgeable, supportive fitness and nutrition coach.',
    );
    buffer.writeln(
      'Your role is to provide short, accurate, evidence-based fitness and nutrition answers in plain English.',
    );
    buffer.writeln();
    buffer.writeln('STRICT RESPONSE RULES (CRITICAL):');
    buffer.writeln(
      '1. Under 80 words: Keep your entire response under 80 words. Be direct, clear, and concise.',
    );
    buffer.writeln(
      '2. Maximum 3 bullets: If you list items or recommendations, use at most 3 bullet points.',
    );
    buffer.writeln(
      '3. Exactly 1 next step: Always conclude your response with a clear heading or line "**Next Step:**" followed by exactly 1 practical action the user should take right now.',
    );
    buffer.writeln(
      '4. Simple English: Speak like an encouraging, knowledgeable human coach. Do NOT use sci-fi, military, or robotic jargon (avoid words like "operator", "directive", "protocol", "telemetry", "cipher", "heuristic", "neural core").',
    );
    buffer.writeln(
      '5. Units: Always express weights and load increments in $unitLabel (${units.name}).',
    );
    buffer.writeln();
    buffer.writeln('SAFETY AND MEDICAL GUARDRAILS (CRITICAL):');
    buffer.writeln('- You are a fitness coach, NOT a physician or doctor.');
    buffer.writeln(
      '- NEVER provide clinical medical diagnoses or prescribe medications.',
    );
    buffer.writeln(
      '- If the user asks about chest pain, joint injury, acute dizziness, or sharp pain, instruct them to stop exercising immediately and consult a doctor.',
    );
    buffer.writeln(
      '- Remind users to adhere to proper warmup and progressive overload.',
    );
    buffer.writeln();

    if (hasConsent && profile != null) {
      buffer.writeln('USER PROFILE:');
      buffer.writeln('- Name: ${profile.name ?? "User"}');
      buffer.writeln('- Preferred Units: $unitLabel (${units.name})');
      if (profile.goals != null && (profile.goals as List).isNotEmpty) {
        buffer.writeln('- Goals: ${(profile.goals as List).join(", ")}');
      }
      if (profile.fitnessLevel != null) {
        buffer.writeln('- Fitness Level: ${profile.fitnessLevel}');
      }
      if (profile.equipment != null && (profile.equipment as List).isNotEmpty) {
        buffer.writeln(
          '- Available Equipment: ${(profile.equipment as List).join(", ")}',
        );
      }
      buffer.writeln();
    } else if (!hasConsent) {
      buffer.writeln('USER PRIVACY:');
      buffer.writeln('- Preferred Units: $unitLabel (${units.name})');
      buffer.writeln(
        '- Detailed profile, workout and nutrition sharing is disabled for privacy.',
      );
      buffer.writeln(
        '- Provide general evidence-based training advice and ask clarifying questions if specifics are needed.',
      );
      buffer.writeln();
    }

    if (hasConsent && recentWorkouts.isNotEmpty) {
      final streak = WorkoutStreakCalculator.calculateFromDates(
        recentWorkouts.map((w) => w.date),
      );
      final recoveryMap = const MuscleRecoveryCalculator().calculate(
        workouts: recentWorkouts,
      );
      final freshRegions = recoveryMap.values
          .where((r) => r.score >= 0.85)
          .map((r) => r.region.displayName)
          .take(4)
          .join(', ');
      final fatiguedRegions = recoveryMap.values
          .where((r) => r.score < 0.55)
          .map((r) => r.region.displayName)
          .take(4)
          .join(', ');

      buffer.writeln('RECENT ACTIVITY & RECOVERY:');
      buffer.writeln('- ${recentWorkouts.length} workouts in last 30 days');
      buffer.writeln(
        '- Current Streak: ${streak.currentStreak} days (Longest: ${streak.longestStreak} days)',
      );
      if (freshRegions.isNotEmpty) {
        buffer.writeln('- Fresh Muscle Groups (>=85% est.): $freshRegions');
      }
      if (fatiguedRegions.isNotEmpty) {
        buffer.writeln(
          '- Recovering/Fatigued Groups (<55% est.): $fatiguedRegions',
        );
      }
      buffer.writeln();
    }

    if (hasConsent && nutritionHistory.isNotEmpty) {
      buffer.writeln('NUTRITION:');
      buffer.writeln('- Tracking nutrition for ${nutritionHistory.length} days');
      if (nutritionTargets != null) {
        buffer.writeln(
          '- Daily Target: ${nutritionTargets.macros.calories.round()} kcal, ${nutritionTargets.macros.protein.round()}g protein',
        );
      }
      buffer.writeln();
    }

    if (hasConsent && bodyEntries.isNotEmpty) {
      buffer.writeln('PROGRESS TRACKING:');
      buffer.writeln('- ${bodyEntries.length} body measurements logged');
      buffer.writeln();
    }

    return buffer.toString();
  }

  static String buildFallbackMealPhotoEstimate(String? mealHint) {
    final name = (mealHint != null && mealHint.trim().isNotEmpty)
        ? mealHint.trim()
        : 'Balanced Protein Plate';
    return 'Estimated macros for **$name** (photo processed transiently in memory and never stored). Verify portion weights before logging.\n\n'
        '```json\n'
        '{\n'
        '  "type": "log_meal",\n'
        '  "id": "meal_est_${DateTime.now().millisecondsSinceEpoch}",\n'
        '  "mealName": "$name",\n'
        '  "calories": 520,\n'
        '  "proteinG": 42,\n'
        '  "carbsG": 48,\n'
        '  "fatsG": 16,\n'
        '  "isEstimate": true\n'
        '}\n'
        '```\n\n'
        '**Next Step:** Review the estimated macros on the card below and tap Apply to log this meal.';
  }
}

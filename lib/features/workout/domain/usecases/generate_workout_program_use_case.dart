import 'package:progression_tracker/core/utils/app_logger.dart';
import '../../../onboarding/domain/entities/user_profile.dart';
import '../entities/workout_program.dart';
import '../splits/entities/split.dart';
import '../splits/services/split_catalog.dart';
import '../splits/services/split_schedule_builder.dart';

/// Generates a personalized workout program based on user profile and split choice.
/// Data-driven, fully deterministic, rule-based.
class GenerateWorkoutProgramUseCase {
  const GenerateWorkoutProgramUseCase({
    this.scheduleBuilder = const SplitScheduleBuilder(),
  });

  final SplitScheduleBuilder scheduleBuilder;

  WorkoutProgram call({
    required UserProfile userProfile,
    String? splitType,
    Split? split,
    int? overrideDays,
  }) {
    final effectiveDays = (overrideDays ?? userProfile.workoutDaysPerWeek).clamp(1, 7);

    AppLogger.debug('🎯 Generating workout program:');
    AppLogger.debug('   - Goal: ${userProfile.goal}');
    AppLogger.debug('   - Days/week: $effectiveDays (stored: ${userProfile.workoutDaysPerWeek})');
    AppLogger.debug('   - Split: ${split?.name ?? splitType ?? "auto"}');
    AppLogger.debug('   - Fitness level: ${userProfile.fitnessLevel}');
    AppLogger.debug('   - Equipment: ${userProfile.equipment}');

    // 1. Direct split instance supplied
    if (split != null) {
      return scheduleBuilder.buildProgram(
        split: split,
        daysPerWeek: effectiveDays,
        profile: userProfile,
      );
    }

    // 2. Split ID / name string supplied
    if (splitType != null) {
      final catalogSplit = SplitCatalog.findById(splitType);
      if (catalogSplit != null) {
        return scheduleBuilder.buildProgram(
          split: catalogSplit,
          daysPerWeek: effectiveDays,
          profile: userProfile,
        );
      }
    }

    // 3. Fallback auto recommendation based on effective days
    final recommendedSplit = switch (effectiveDays) {
      <= 3 => SplitCatalog.fullBody,
      4 => SplitCatalog.upperLower,
      5 => SplitCatalog.pplXUpperLower(),
      _ => SplitCatalog.pushPullLegs,
    };

    return scheduleBuilder.buildProgram(
      split: recommendedSplit,
      daysPerWeek: effectiveDays,
      profile: userProfile,
    );
  }
}

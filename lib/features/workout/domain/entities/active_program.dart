import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout_program.dart';

part 'active_program.freezed.dart';

/// Represents the currently active workout program with state tracking.
/// This is the single source of truth for workout sessions.
@freezed
class ActiveProgram with _$ActiveProgram {
  const factory ActiveProgram({
    required String id,
    required WorkoutProgram program,
    required int currentDayIndex,  // 0-based index into program.days
    required bool isActive,
    DateTime? lastWorkoutDate,
    @Default({}) Map<int, DateTime> completedDays,  // dayIndex -> completionDate
  }) = _ActiveProgram;
  
  const ActiveProgram._();
  
  /// Get the current program day based on currentDayIndex
  ProgramDay get currentDay {
    if (currentDayIndex >= program.days.length) {
      return program.days.first;  // Wrap around to day 1
    }
    return program.days[currentDayIndex];
  }
  
  /// Check if the current day is a rest day
  bool get isRestDay => currentDay.isRestDay;
  
  /// Get the next workout day index (skipping rest days)
  int get nextWorkoutDayIndex {
    int nextIndex = (currentDayIndex + 1) % program.days.length;
    int attempts = 0;
    
    // Keep searching for a non-rest day, wrapping around if needed
    while (attempts < program.days.length) {
      if (!program.days[nextIndex].isRestDay) {
        return nextIndex;
      }
      nextIndex = (nextIndex + 1) % program.days.length;
      attempts++;
    }
    
    // If all days are rest days (edge case), return 0
    return 0;
  }
  
  /// Calculate completion percentage for current week
  double get weekCompletionPercentage {
    final daysInWeek = 7;
    final completedThisWeek = completedDays.values
        .where((date) => DateTime.now().difference(date).inDays < 7)
        .length;
    return (completedThisWeek / daysInWeek).clamp(0.0, 1.0);
  }
  
  /// Mark current day as complete and advance to next day
  ActiveProgram completeCurrentDay() {
    final now = DateTime.now();
    final updatedCompletedDays = Map<int, DateTime>.from(completedDays);
    updatedCompletedDays[currentDayIndex] = now;
    
    return copyWith(
      currentDayIndex: nextWorkoutDayIndex,
      lastWorkoutDate: now,
      completedDays: updatedCompletedDays,
    );
  }
  
  /// Update the underlying workout program (for editing)
  ActiveProgram updateProgram(WorkoutProgram updatedProgram) {
    return copyWith(program: updatedProgram);
  }
  
  /// Check if the program is complete (all days have been completed)
  bool get isProgramComplete {
    // A program is complete when we've cycled through all days at least once
    // This is detected when currentDayIndex wraps back to 0 after completing the last day
    // We track this by checking if we've completed the last day
    final lastDayIndex = program.days.length - 1;
    return completedDays.containsKey(lastDayIndex) && 
           currentDayIndex == 0 && 
           completedDays.length >= program.days.length;
  }
  
  /// Restart the program by resetting to day 0 and clearing completed days
  ActiveProgram restart() {
    return copyWith(
      currentDayIndex: 0,
      completedDays: {},
      lastWorkoutDate: null,
    );
  }
}

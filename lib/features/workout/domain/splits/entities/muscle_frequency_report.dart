import '../../entities/exercise_definition.dart';
import 'day_template.dart';

/// Computed report showing weekly training frequency per muscle group.
class MuscleFrequencyReport {
  const MuscleFrequencyReport({
    required this.frequencies,
    required this.totalWorkoutsPerWeek,
    required this.cycleLength,
    this.notes = const [],
  });

  /// Muscle group mapped to weekly training frequency (e.g. 2.0 = trained twice a week).
  final Map<MuscleGroup, double> frequencies;

  /// Number of active training workouts scheduled per week.
  final int totalWorkoutsPerWeek;

  /// Cycle length of the underlying split.
  final int cycleLength;

  /// Informational notes or warnings about frequency distribution.
  final List<String> notes;

  /// Computes the weekly muscle frequency from a sequence of day templates and weekly frequency.
  factory MuscleFrequencyReport.compute({
    required List<DayTemplate> activeDays,
    required int daysPerWeek,
  }) {
    if (activeDays.isEmpty || daysPerWeek <= 0) {
      return const MuscleFrequencyReport(
        frequencies: {},
        totalWorkoutsPerWeek: 0,
        cycleLength: 0,
      );
    }

    final rawScores = <MuscleGroup, double>{};
    for (final muscle in MuscleGroup.values) {
      rawScores[muscle] = 0.0;
    }

    for (final day in activeDays) {
      for (final p in day.primaryMuscles) {
        rawScores[p] = (rawScores[p] ?? 0.0) + 1.0;
      }
      for (final s in day.secondaryMuscles) {
        rawScores[s] = (rawScores[s] ?? 0.0) + 0.5;
      }
    }

    // Scale scores to per-week frequency: (rawScoreInActiveDays / activeDays.length) * daysPerWeek
    final normalized = <MuscleGroup, double>{};
    final scale = daysPerWeek / activeDays.length;

    for (final entry in rawScores.entries) {
      final weeklyRate = (entry.value * scale * 10).round() / 10;
      if (weeklyRate > 0) {
        normalized[entry.key] = weeklyRate;
      }
    }

    final advisoryNotes = <String>[];
    // Check key major muscle groups: chest, back, legs, shoulders
    const majorMuscles = [
      MuscleGroup.chest,
      MuscleGroup.back,
      MuscleGroup.legs,
      MuscleGroup.shoulders,
    ];

    for (final m in majorMuscles) {
      final freq = normalized[m] ?? 0.0;
      if (freq < 1.0 && daysPerWeek >= 2) {
        advisoryNotes.add('${m.displayName} frequency is low ($freq×/wk) on this schedule.');
      } else if (freq > 3.0) {
        advisoryNotes.add('${m.displayName} frequency is high ($freq×/wk); monitor recovery.');
      }
    }

    return MuscleFrequencyReport(
      frequencies: normalized,
      totalWorkoutsPerWeek: daysPerWeek,
      cycleLength: activeDays.length,
      notes: advisoryNotes,
    );
  }

  int get totalTrainingSessionsPerWeek => totalWorkoutsPerWeek;

  double getFrequency(MuscleGroup group) => frequencies[group] ?? 0.0;

  FrequencyStatus getStatus(MuscleGroup group) {
    final freq = frequencies[group] ?? 0.0;
    if (freq <= 0.0) return FrequencyStatus.none;
    if (freq < 1.5) return FrequencyStatus.low;
    if (freq > 3.2) return FrequencyStatus.high;
    return FrequencyStatus.optimal;
  }
}

/// Frequency rating status for telemetry badges.
enum FrequencyStatus {
  optimal,
  low,
  high,
  none,
}

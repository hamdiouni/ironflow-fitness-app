import '../../../../onboarding/domain/entities/user_profile.dart';
import 'day_template.dart';

/// Base specification for a training split architecture.
class Split {
  const Split({
    required this.id,
    required this.name,
    required this.description,
    required this.cycleDays,
    this.supportedDayCounts = const [1, 2, 3, 4, 5, 6, 7],
    this.defaultDays = 4,
    this.minRecommendedDays = 3,
    this.maxRecommendedDays = 5,
    this.notes,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String description;
  final List<DayTemplate> cycleDays;
  final List<int> supportedDayCounts;
  final int defaultDays;
  final int minRecommendedDays;
  final int maxRecommendedDays;
  final String? notes;
  final bool isCustom;

  bool get isHybrid => false;

  /// Returns guidance or non-blocking advice for the chosen days and user level.
  String? getScheduleGuidance(int daysPerWeek, FitnessLevel level) {
    if (level == FitnessLevel.beginner && daysPerWeek >= 6) {
      return '6+ training days requires substantial recovery capacity. Beginners typically achieve optimal progress with 3–4 days.';
    }
    if (daysPerWeek < minRecommendedDays) {
      return '$name with $daysPerWeek day${daysPerWeek == 1 ? '' : 's'}/week yields lower frequency per muscle group. The cycle will roll across multiple weeks.';
    }
    if (daysPerWeek > maxRecommendedDays) {
      if (daysPerWeek == 7) {
        return 'Training 7 days/week eliminates passive recovery days. Ensure adequate sleep and nutritional surplus.';
      }
    }
    return null;
  }
}

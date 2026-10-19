import 'day_template.dart';
import 'split.dart';

/// Mode of hybrid split composition.
enum HybridMode {
  /// Day templates of both splits combined into a single unified cycle.
  /// (e.g. PPL + Upper/Lower = Push, Pull, Legs, Upper, Lower)
  combinedCycle,

  /// Alternates entire split architectures across weeks.
  /// (e.g. Week A: Split 1, Week B: Split 2)
  alternateWeeks,
}

extension HybridModeX on HybridMode {
  String get displayName => switch (this) {
        HybridMode.combinedCycle => 'Combined Cycle',
        HybridMode.alternateWeeks => 'Alternate Weeks',
      };

  String get description => switch (this) {
        HybridMode.combinedCycle =>
          'Combines all sessions from both splits into one continuous multi-day cycle.',
        HybridMode.alternateWeeks =>
          'Rotates between split architectures every week (Week A / Week B).',
      };
}

/// A composite split combining two distinct split architectures.
class HybridSplit extends Split {
  HybridSplit({
    required super.id,
    required super.name,
    required super.description,
    required this.splitA,
    required this.splitB,
    required this.mode,
    List<DayTemplate>? customCycleDays,
    super.defaultDays = 5,
    super.minRecommendedDays = 4,
    super.maxRecommendedDays = 6,
    super.notes,
  }) : super(
          cycleDays: customCycleDays ?? _buildCombinedCycle(splitA, splitB),
          supportedDayCounts: const [1, 2, 3, 4, 5, 6, 7],
        );

  final Split splitA;
  final Split splitB;
  final HybridMode mode;

  @override
  bool get isHybrid => true;

  /// Returns the day templates for a specific week (relevant in alternateWeeks mode).
  List<DayTemplate> getCycleDaysForWeek(int weekIndex) {
    if (mode == HybridMode.alternateWeeks) {
      // Even weeks (0, 2, 4...) -> splitA; Odd weeks (1, 3, 5...) -> splitB
      return weekIndex % 2 == 0 ? splitA.cycleDays : splitB.cycleDays;
    }
    return cycleDays;
  }

  static List<DayTemplate> _buildCombinedCycle(Split a, Split b) {
    return [...a.cycleDays, ...b.cycleDays];
  }

  HybridSplit copyWith({
    String? id,
    String? name,
    String? description,
    Split? splitA,
    Split? splitB,
    HybridMode? mode,
    List<DayTemplate>? customCycleDays,
  }) {
    return HybridSplit(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      splitA: splitA ?? this.splitA,
      splitB: splitB ?? this.splitB,
      mode: mode ?? this.mode,
      customCycleDays: customCycleDays ?? cycleDays,
      defaultDays: defaultDays,
      minRecommendedDays: minRecommendedDays,
      maxRecommendedDays: maxRecommendedDays,
      notes: notes,
    );
  }
}

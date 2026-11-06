import 'muscle_region.dart';

/// Categorical recovery state of an anatomical muscle region.
enum RecoveryTier {
  /// 90% - 100% recovered. Primed for heavy compound or high-volume load.
  fresh,

  /// 50% - 89% recovered. Partially recovered; light load or active rest.
  recovering,

  /// < 50% recovered. High recent fatigue load; needs rest to supercompensate.
  fatigued,

  /// User flagged acute delayed-onset muscle soreness (DOMS).
  sore;

  String get label => switch (this) {
        RecoveryTier.fresh => 'Fresh',
        RecoveryTier.recovering => 'Recovering',
        RecoveryTier.fatigued => 'Needs Rest',
        RecoveryTier.sore => 'Sore',
      };
}

/// Recovery telemetry, volume load, and training history for a single muscle region.
class MuscleRecoveryData {
  const MuscleRecoveryData({
    required this.region,
    required this.score,
    required this.tier,
    required this.hoursSinceTrained,
    required this.estimatedHoursRemaining,
    required this.lastTrainedDate,
    required this.volumeLoad7Days,
    required this.sets7Days,
    required this.volumeLoad30Days,
    required this.sets30Days,
    required this.isManuallyMarkedSore,
    required this.recentExercises,
  });

  /// The anatomical muscle region.
  final MuscleRegion region;

  /// Fractional recovery readiness score (0.0 = completely depleted, 1.0 = 100% fresh).
  final double score;

  /// Discrete recovery tier driving UI badges, highlights, and guidance.
  final RecoveryTier tier;

  /// Decimal hours elapsed since the end of the most recent session targeting this region.
  /// Null if no workout targeting this region exists in local history.
  final double? hoursSinceTrained;

  /// Hours remaining until the region reaches 100% baseline recovery.
  /// 0 if already fresh.
  final int estimatedHoursRemaining;

  /// Timestamp of the most recent workout that engaged this muscle.
  final DateTime? lastTrainedDate;

  /// Cumulative volume load (kg x reps) targeting this region in the last 7 days.
  final double volumeLoad7Days;

  /// Total working sets performed for this region in the last 7 days.
  final int sets7Days;

  /// Cumulative volume load in the last 30 days.
  final double volumeLoad30Days;

  /// Total working sets performed in the last 30 days.
  final int sets30Days;

  /// Whether the user manually toggled DOMS soreness on this region.
  final bool isManuallyMarkedSore;

  /// Names of recent exercises logged that engaged this region (up to 5).
  final List<String> recentExercises;

  /// Convenience factory for a completely fresh, untrained region.
  factory MuscleRecoveryData.fresh(MuscleRegion region) {
    return MuscleRecoveryData(
      region: region,
      score: 1.0,
      tier: RecoveryTier.fresh,
      hoursSinceTrained: null,
      estimatedHoursRemaining: 0,
      lastTrainedDate: null,
      volumeLoad7Days: 0,
      sets7Days: 0,
      volumeLoad30Days: 0,
      sets30Days: 0,
      isManuallyMarkedSore: false,
      recentExercises: const [],
    );
  }

  MuscleRecoveryData copyWith({
    MuscleRegion? region,
    double? score,
    RecoveryTier? tier,
    double? hoursSinceTrained,
    int? estimatedHoursRemaining,
    DateTime? lastTrainedDate,
    double? volumeLoad7Days,
    int? sets7Days,
    double? volumeLoad30Days,
    int? sets30Days,
    bool? isManuallyMarkedSore,
    List<String>? recentExercises,
  }) {
    return MuscleRecoveryData(
      region: region ?? this.region,
      score: score ?? this.score,
      tier: tier ?? this.tier,
      hoursSinceTrained: hoursSinceTrained ?? this.hoursSinceTrained,
      estimatedHoursRemaining:
          estimatedHoursRemaining ?? this.estimatedHoursRemaining,
      lastTrainedDate: lastTrainedDate ?? this.lastTrainedDate,
      volumeLoad7Days: volumeLoad7Days ?? this.volumeLoad7Days,
      sets7Days: sets7Days ?? this.sets7Days,
      volumeLoad30Days: volumeLoad30Days ?? this.volumeLoad30Days,
      sets30Days: sets30Days ?? this.sets30Days,
      isManuallyMarkedSore: isManuallyMarkedSore ?? this.isManuallyMarkedSore,
      recentExercises: recentExercises ?? this.recentExercises,
    );
  }
}


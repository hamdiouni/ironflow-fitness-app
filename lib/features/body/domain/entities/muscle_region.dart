import 'package:progression_tracker/features/workout/domain/entities/exercise_definition.dart';

/// Canonical anatomical muscle regions supported by the IronFlow Body Map (Wave 4).
///
/// Each region has a stable ID matching [ExerciseDefinition.primaryRegions] and
/// [ExerciseDefinition.secondaryRegions], a display name, an anatomical title,
/// a coarse [MuscleGroup] mapping, and a baseline recovery duration in hours.
enum MuscleRegion {
  // ── Front View Regions ───────────────────────────────────────────────────
  chest(
    id: 'chest',
    displayName: 'Chest',
    anatomicalName: 'Pectoralis Major & Minor',
    coarseGroup: MuscleGroup.chest,
    isFront: true,
    isBack: false,
    baseRecoveryHours: 72,
  ),
  frontDelts(
    id: 'front_delts',
    displayName: 'Front Deltoids',
    anatomicalName: 'Anterior Deltoids',
    coarseGroup: MuscleGroup.shoulders,
    isFront: true,
    isBack: false,
    baseRecoveryHours: 48,
  ),
  sideDelts(
    id: 'side_delts',
    displayName: 'Side Deltoids',
    anatomicalName: 'Lateral Deltoids',
    coarseGroup: MuscleGroup.shoulders,
    isFront: true,
    isBack: false,
    baseRecoveryHours: 48,
  ),
  biceps(
    id: 'biceps',
    displayName: 'Biceps',
    anatomicalName: 'Biceps Brachii & Brachialis',
    coarseGroup: MuscleGroup.arms,
    isFront: true,
    isBack: false,
    baseRecoveryHours: 48,
  ),
  forearms(
    id: 'forearms',
    displayName: 'Forearms',
    anatomicalName: 'Brachioradialis & Wrist Flexors',
    coarseGroup: MuscleGroup.arms,
    isFront: true,
    isBack: true,
    baseRecoveryHours: 36,
  ),
  upperAbs(
    id: 'upper_abs',
    displayName: 'Upper Abs',
    anatomicalName: 'Upper Rectus Abdominis',
    coarseGroup: MuscleGroup.abs,
    isFront: true,
    isBack: false,
    baseRecoveryHours: 48,
  ),
  lowerAbs(
    id: 'lower_abs',
    displayName: 'Lower Abs',
    anatomicalName: 'Lower Rectus Abdominis',
    coarseGroup: MuscleGroup.abs,
    isFront: true,
    isBack: false,
    baseRecoveryHours: 48,
  ),
  obliques(
    id: 'obliques',
    displayName: 'Obliques',
    anatomicalName: 'Internal & External Obliques',
    coarseGroup: MuscleGroup.abs,
    isFront: true,
    isBack: false,
    baseRecoveryHours: 48,
  ),
  quads(
    id: 'quads',
    displayName: 'Quadriceps',
    anatomicalName: 'Rectus Femoris & Vasti',
    coarseGroup: MuscleGroup.legs,
    isFront: true,
    isBack: false,
    baseRecoveryHours: 72,
  ),
  adductors(
    id: 'adductors',
    displayName: 'Adductors',
    anatomicalName: 'Adductor Magnus & Longus',
    coarseGroup: MuscleGroup.legs,
    isFront: true,
    isBack: false,
    baseRecoveryHours: 60,
  ),
  calves(
    id: 'calves',
    displayName: 'Calves',
    anatomicalName: 'Gastrocnemius, Soleus & Tibialis',
    coarseGroup: MuscleGroup.legs,
    isFront: true,
    isBack: true,
    baseRecoveryHours: 48,
  ),

  // ── Back View Regions ────────────────────────────────────────────────────
  upperTraps(
    id: 'upper_traps',
    displayName: 'Upper Trapezius',
    anatomicalName: 'Trapezius (Superior)',
    coarseGroup: MuscleGroup.shoulders,
    isFront: true,
    isBack: true,
    baseRecoveryHours: 48,
  ),
  middleBack(
    id: 'middle_back',
    displayName: 'Middle Back & Rhomboids',
    anatomicalName: 'Rhomboids & Mid Trapezius',
    coarseGroup: MuscleGroup.back,
    isFront: false,
    isBack: true,
    baseRecoveryHours: 60,
  ),
  lats(
    id: 'lats',
    displayName: 'Lats',
    anatomicalName: 'Latissimus Dorsi',
    coarseGroup: MuscleGroup.back,
    isFront: false,
    isBack: true,
    baseRecoveryHours: 72,
  ),
  rearDelts(
    id: 'rear_delts',
    displayName: 'Rear Deltoids',
    anatomicalName: 'Posterior Deltoids',
    coarseGroup: MuscleGroup.shoulders,
    isFront: false,
    isBack: true,
    baseRecoveryHours: 48,
  ),
  triceps(
    id: 'triceps',
    displayName: 'Triceps',
    anatomicalName: 'Triceps Brachii',
    coarseGroup: MuscleGroup.arms,
    isFront: false,
    isBack: true,
    baseRecoveryHours: 48,
  ),
  lowerBack(
    id: 'lower_back',
    displayName: 'Lower Back',
    anatomicalName: 'Erector Spinae & Thoracolumbar',
    coarseGroup: MuscleGroup.back,
    isFront: false,
    isBack: true,
    baseRecoveryHours: 72,
  ),
  glutes(
    id: 'glutes',
    displayName: 'Glutes',
    anatomicalName: 'Gluteus Maximus & Medius',
    coarseGroup: MuscleGroup.glutes,
    isFront: false,
    isBack: true,
    baseRecoveryHours: 72,
  ),
  hamstrings(
    id: 'hamstrings',
    displayName: 'Hamstrings',
    anatomicalName: 'Biceps Femoris & Semitendinosus',
    coarseGroup: MuscleGroup.legs,
    isFront: false,
    isBack: true,
    baseRecoveryHours: 72,
  ),
  abductors(
    id: 'abductors',
    displayName: 'Abductors',
    anatomicalName: 'Gluteus Medius & Tensor Fasciae Latae',
    coarseGroup: MuscleGroup.glutes,
    isFront: false,
    isBack: true,
    baseRecoveryHours: 48,
  );

  const MuscleRegion({
    required this.id,
    required this.displayName,
    required this.anatomicalName,
    required this.coarseGroup,
    required this.isFront,
    required this.isBack,
    required this.baseRecoveryHours,
  });

  final String id;
  final String displayName;
  final String anatomicalName;
  final MuscleGroup coarseGroup;
  final bool isFront;
  final bool isBack;
  final int baseRecoveryHours;

  /// Fast lookup by region id string.
  static MuscleRegion? fromId(String? id) {
    if (id == null || id.trim().isEmpty) return null;
    final rawLower = id.toLowerCase().trim();
    final stripped = rawLower.replaceAll('_', '').replaceAll('-', '');

    for (final region in MuscleRegion.values) {
      if (region.id == id || region.id == rawLower) return region;
      if (region.id.replaceAll('_', '').toLowerCase() == stripped) return region;
      if (region.name.toLowerCase() == stripped) return region;
    }

    return switch (stripped) {
      'pecs' || 'pectoralis' || 'pectorals' || 'chestupper' || 'chestlower' => MuscleRegion.chest,
      'shoulders' || 'anteriordeltoid' || 'deltoidsfront' => MuscleRegion.frontDelts,
      'lateraldeltoid' || 'deltoidsside' => MuscleRegion.sideDelts,
      'posteriordeltoid' || 'deltoidsrear' => MuscleRegion.rearDelts,
      'traps' || 'trapezius' => MuscleRegion.upperTraps,
      'latissimus' || 'lats' => MuscleRegion.lats,
      'rhomboids' => MuscleRegion.middleBack,
      'erectorspinae' || 'lumbar' => MuscleRegion.lowerBack,
      'butt' || 'gluteusmaximus' || 'gluteusmedius' => MuscleRegion.glutes,
      'quadriceps' => MuscleRegion.quads,
      'abs' || 'core' || 'rectusabdominis' => MuscleRegion.upperAbs,
      _ => null,
    };
  }

  /// Front-visible muscle regions.
  static List<MuscleRegion> get frontRegions =>
      MuscleRegion.values.where((r) => r.isFront).toList();

  /// Back-visible muscle regions.
  static List<MuscleRegion> get backRegions =>
      MuscleRegion.values.where((r) => r.isBack).toList();
}

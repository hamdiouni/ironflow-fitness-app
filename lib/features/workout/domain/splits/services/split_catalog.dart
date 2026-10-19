import '../../entities/exercise_definition.dart';
import '../entities/day_template.dart';
import '../entities/hybrid_split.dart';
import '../entities/movement_pattern.dart';
import '../entities/split.dart';

/// Registry of all built-in split architectures and hybrid constructors.
class SplitCatalog {
  SplitCatalog._();

  // ═══════════════════════════════════════════════════════════════════════════
  // DAY TEMPLATES
  // ═══════════════════════════════════════════════════════════════════════════

  // ── Full Body Templates ────────────────────────────────────────────────────
  static const dayFullBodyA = DayTemplate(
    id: 'fb_day_a',
    name: 'Full Body – Foundation',
    shortName: 'FB-A',
    focus: 'Quads, Chest, Upper Back',
    primaryMuscles: [MuscleGroup.legs, MuscleGroup.chest, MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.abs],
    slots: [
      SlotDefinition(
        id: 'fb_a_1',
        name: 'Knee-Dominant Compound',
        pattern: MovementPattern.kneeDominant,
        primaryMuscle: MuscleGroup.legs,
      ),
      SlotDefinition(
        id: 'fb_a_2',
        name: 'Horizontal Push Compound',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
        secondaryMuscles: [MuscleGroup.arms, MuscleGroup.shoulders],
      ),
      SlotDefinition(
        id: 'fb_a_3',
        name: 'Horizontal Pull Compound',
        pattern: MovementPattern.horizontalPull,
        primaryMuscle: MuscleGroup.back,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'fb_a_4',
        name: 'Overhead Press',
        pattern: MovementPattern.verticalPush,
        primaryMuscle: MuscleGroup.shoulders,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'fb_a_5',
        name: 'Core Stability',
        pattern: MovementPattern.core,
        primaryMuscle: MuscleGroup.abs,
        isCompound: false,
      ),
    ],
  );

  static const dayFullBodyB = DayTemplate(
    id: 'fb_day_b',
    name: 'Full Body – Posterior & Pull',
    shortName: 'FB-B',
    focus: 'Hamstrings, Shoulders, Lats, Arms',
    primaryMuscles: [MuscleGroup.legs, MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.chest, MuscleGroup.arms],
    slots: [
      SlotDefinition(
        id: 'fb_b_1',
        name: 'Hip-Hinge Compound',
        pattern: MovementPattern.hipHinge,
        primaryMuscle: MuscleGroup.legs,
        secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.back],
      ),
      SlotDefinition(
        id: 'fb_b_2',
        name: 'Incline Push Compound',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
        secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'fb_b_3',
        name: 'Vertical Pull Compound',
        pattern: MovementPattern.verticalPull,
        primaryMuscle: MuscleGroup.back,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'fb_b_4',
        name: 'Biceps Hypertrophy',
        pattern: MovementPattern.bicepIsolation,
        primaryMuscle: MuscleGroup.arms,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'fb_b_5',
        name: 'Triceps Extension',
        pattern: MovementPattern.tricepIsolation,
        primaryMuscle: MuscleGroup.arms,
        isCompound: false,
      ),
    ],
  );

  static const dayFullBodyC = DayTemplate(
    id: 'fb_day_c',
    name: 'Full Body – Density & Hypertrophy',
    shortName: 'FB-C',
    focus: 'Legs, Chest, Back, Calves',
    primaryMuscles: [MuscleGroup.legs, MuscleGroup.chest, MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.abs],
    slots: [
      SlotDefinition(
        id: 'fb_c_1',
        name: 'Unilateral Knee-Dominant',
        pattern: MovementPattern.kneeDominant,
        primaryMuscle: MuscleGroup.legs,
      ),
      SlotDefinition(
        id: 'fb_c_2',
        name: 'Chest Hypertrophy',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'fb_c_3',
        name: 'Row Variation',
        pattern: MovementPattern.horizontalPull,
        primaryMuscle: MuscleGroup.back,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'fb_c_4',
        name: 'Lateral Deltoids',
        pattern: MovementPattern.deltoidIsolation,
        primaryMuscle: MuscleGroup.shoulders,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'fb_c_5',
        name: 'Abdominal / Core Flexion',
        pattern: MovementPattern.core,
        primaryMuscle: MuscleGroup.abs,
        isCompound: false,
      ),
    ],
  );

  // ── Upper / Lower Templates ────────────────────────────────────────────────
  static const dayUpperA = DayTemplate(
    id: 'ul_upper_a',
    name: 'Upper Body – Power',
    shortName: 'Upper-A',
    focus: 'Chest, Back, Shoulders, Arms',
    primaryMuscles: [MuscleGroup.chest, MuscleGroup.back, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.arms],
    slots: [
      SlotDefinition(
        id: 'ul_u_1',
        name: 'Flat Horizontal Press',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
        secondaryMuscles: [MuscleGroup.arms, MuscleGroup.shoulders],
      ),
      SlotDefinition(
        id: 'ul_u_2',
        name: 'Horizontal Row Compound',
        pattern: MovementPattern.horizontalPull,
        primaryMuscle: MuscleGroup.back,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'ul_u_3',
        name: 'Vertical Push',
        pattern: MovementPattern.verticalPush,
        primaryMuscle: MuscleGroup.shoulders,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'ul_u_4',
        name: 'Vertical Pull Compound',
        pattern: MovementPattern.verticalPull,
        primaryMuscle: MuscleGroup.back,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'ul_u_5',
        name: 'Biceps Isolation',
        pattern: MovementPattern.bicepIsolation,
        primaryMuscle: MuscleGroup.arms,
        isCompound: false,
      ),
    ],
  );

  static const dayLowerA = DayTemplate(
    id: 'ul_lower_a',
    name: 'Lower Body – Power',
    shortName: 'Lower-A',
    focus: 'Quads, Hamstrings, Glutes, Calves',
    primaryMuscles: [MuscleGroup.legs],
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.abs],
    slots: [
      SlotDefinition(
        id: 'ul_l_1',
        name: 'Bilateral Squat Compound',
        pattern: MovementPattern.kneeDominant,
        primaryMuscle: MuscleGroup.legs,
      ),
      SlotDefinition(
        id: 'ul_l_2',
        name: 'Hip Hinge / Posterior Chain',
        pattern: MovementPattern.hipHinge,
        primaryMuscle: MuscleGroup.legs,
        secondaryMuscles: [MuscleGroup.glutes],
      ),
      SlotDefinition(
        id: 'ul_l_3',
        name: 'Quad Hypertrophy / Leg Press',
        pattern: MovementPattern.kneeDominant,
        primaryMuscle: MuscleGroup.legs,
      ),
      SlotDefinition(
        id: 'ul_l_4',
        name: 'Hamstrings Isolation',
        pattern: MovementPattern.hipHinge,
        primaryMuscle: MuscleGroup.legs,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'ul_l_5',
        name: 'Calf Raises',
        pattern: MovementPattern.calfIsolation,
        primaryMuscle: MuscleGroup.legs,
        isCompound: false,
      ),
    ],
  );

  static const dayUpperB = DayTemplate(
    id: 'ul_upper_b',
    name: 'Upper Body – Hypertrophy',
    shortName: 'Upper-B',
    focus: 'Incline Chest, Lats, Delts, Arms',
    primaryMuscles: [MuscleGroup.chest, MuscleGroup.back, MuscleGroup.arms],
    secondaryMuscles: [MuscleGroup.shoulders],
    slots: [
      SlotDefinition(
        id: 'ul_ub_1',
        name: 'Incline Push Compound',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
        secondaryMuscles: [MuscleGroup.shoulders],
      ),
      SlotDefinition(
        id: 'ul_ub_2',
        name: 'Lat Pulldown / Vertical Pull',
        pattern: MovementPattern.verticalPull,
        primaryMuscle: MuscleGroup.back,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'ul_ub_3',
        name: 'Pectoral Fly Isolation',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'ul_ub_4',
        name: 'Rear Deltoid / Face Pull',
        pattern: MovementPattern.deltoidIsolation,
        primaryMuscle: MuscleGroup.shoulders,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'ul_ub_5',
        name: 'Arm Antagonist Superset A (Triceps)',
        pattern: MovementPattern.tricepIsolation,
        primaryMuscle: MuscleGroup.arms,
        isCompound: false,
      ),
    ],
  );

  static const dayLowerB = DayTemplate(
    id: 'ul_lower_b',
    name: 'Lower Body – Hypertrophy',
    shortName: 'Lower-B',
    focus: 'Quads, Glutes, Calves, Core',
    primaryMuscles: [MuscleGroup.legs],
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.abs],
    slots: [
      SlotDefinition(
        id: 'ul_lb_1',
        name: 'Secondary Squat Pattern',
        pattern: MovementPattern.kneeDominant,
        primaryMuscle: MuscleGroup.legs,
      ),
      SlotDefinition(
        id: 'ul_lb_2',
        name: 'Glute Bridge / Hip Thrust',
        pattern: MovementPattern.hipHinge,
        primaryMuscle: MuscleGroup.glutes,
        secondaryMuscles: [MuscleGroup.legs],
      ),
      SlotDefinition(
        id: 'ul_lb_3',
        name: 'Unilateral Quad Movement',
        pattern: MovementPattern.kneeDominant,
        primaryMuscle: MuscleGroup.legs,
      ),
      SlotDefinition(
        id: 'ul_lb_4',
        name: 'Calf Hypertrophy',
        pattern: MovementPattern.calfIsolation,
        primaryMuscle: MuscleGroup.legs,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'ul_lb_5',
        name: 'Abdominal Circuit',
        pattern: MovementPattern.core,
        primaryMuscle: MuscleGroup.abs,
        isCompound: false,
      ),
    ],
  );

  // ── Push / Pull / Legs Templates ───────────────────────────────────────────
  static const dayPplPush = DayTemplate(
    id: 'ppl_push',
    name: 'Push – Chest, Shoulders, Triceps',
    shortName: 'Push',
    focus: 'Chest, Anterior/Lateral Delts, Triceps',
    primaryMuscles: [MuscleGroup.chest, MuscleGroup.shoulders],
    secondaryMuscles: [MuscleGroup.arms],
    slots: [
      SlotDefinition(
        id: 'ppl_pu_1',
        name: 'Primary Chest Press',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
        secondaryMuscles: [MuscleGroup.arms, MuscleGroup.shoulders],
      ),
      SlotDefinition(
        id: 'ppl_pu_2',
        name: 'Incline Chest Press',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
        secondaryMuscles: [MuscleGroup.shoulders],
      ),
      SlotDefinition(
        id: 'ppl_pu_3',
        name: 'Overhead Pressing Movement',
        pattern: MovementPattern.verticalPush,
        primaryMuscle: MuscleGroup.shoulders,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'ppl_pu_4',
        name: 'Lateral Deltoids',
        pattern: MovementPattern.deltoidIsolation,
        primaryMuscle: MuscleGroup.shoulders,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'ppl_pu_5',
        name: 'Triceps Isolation',
        pattern: MovementPattern.tricepIsolation,
        primaryMuscle: MuscleGroup.arms,
        isCompound: false,
      ),
    ],
  );

  static const dayPplPull = DayTemplate(
    id: 'ppl_pull',
    name: 'Pull – Back, Rear Delts, Biceps',
    shortName: 'Pull',
    focus: 'Upper Back, Lats, Rear Delts, Biceps',
    primaryMuscles: [MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.shoulders, MuscleGroup.arms],
    slots: [
      SlotDefinition(
        id: 'ppl_pl_1',
        name: 'Heavy Horizontal Row',
        pattern: MovementPattern.horizontalPull,
        primaryMuscle: MuscleGroup.back,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'ppl_pl_2',
        name: 'Vertical Pull (Pull-Up/Pulldown)',
        pattern: MovementPattern.verticalPull,
        primaryMuscle: MuscleGroup.back,
        secondaryMuscles: [MuscleGroup.arms],
      ),
      SlotDefinition(
        id: 'ppl_pl_3',
        name: 'Secondary Cable / Dumbbell Row',
        pattern: MovementPattern.horizontalPull,
        primaryMuscle: MuscleGroup.back,
      ),
      SlotDefinition(
        id: 'ppl_pl_4',
        name: 'Rear Deltoid Fly / Face Pull',
        pattern: MovementPattern.deltoidIsolation,
        primaryMuscle: MuscleGroup.shoulders,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'ppl_pl_5',
        name: 'Biceps Curl Hypertrophy',
        pattern: MovementPattern.bicepIsolation,
        primaryMuscle: MuscleGroup.arms,
        isCompound: false,
      ),
    ],
  );

  static const dayPplLegs = DayTemplate(
    id: 'ppl_legs',
    name: 'Legs – Quads, Hamstrings, Calves',
    shortName: 'Legs',
    focus: 'Quadriceps, Hamstrings, Glutes, Calves',
    primaryMuscles: [MuscleGroup.legs],
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.abs],
    slots: [
      SlotDefinition(
        id: 'ppl_lg_1',
        name: 'Knee-Dominant Squat / Press',
        pattern: MovementPattern.kneeDominant,
        primaryMuscle: MuscleGroup.legs,
      ),
      SlotDefinition(
        id: 'ppl_lg_2',
        name: 'Romanian Deadlift / Hinge',
        pattern: MovementPattern.hipHinge,
        primaryMuscle: MuscleGroup.legs,
        secondaryMuscles: [MuscleGroup.glutes],
      ),
      SlotDefinition(
        id: 'ppl_lg_3',
        name: 'Unilateral Lunge / Leg Press',
        pattern: MovementPattern.kneeDominant,
        primaryMuscle: MuscleGroup.legs,
      ),
      SlotDefinition(
        id: 'ppl_lg_4',
        name: 'Hamstrings Curl / Posterior',
        pattern: MovementPattern.hipHinge,
        primaryMuscle: MuscleGroup.legs,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'ppl_lg_5',
        name: 'Calf Raise / Plantarflexion',
        pattern: MovementPattern.calfIsolation,
        primaryMuscle: MuscleGroup.legs,
        isCompound: false,
      ),
    ],
  );

  // ── Arnold Split Templates ─────────────────────────────────────────────────
  static const dayArnoldChestBack = DayTemplate(
    id: 'arnold_chest_back',
    name: 'Chest & Back – Antagonist Power',
    shortName: 'Chest/Back',
    focus: 'Pectorals, Lats, Upper Back Antagonist Pairing',
    primaryMuscles: [MuscleGroup.chest, MuscleGroup.back],
    secondaryMuscles: [MuscleGroup.arms],
    slots: [
      SlotDefinition(
        id: 'arn_cb_1',
        name: 'Barbell Flat Bench Press',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
      ),
      SlotDefinition(
        id: 'arn_cb_2',
        name: 'Barbell Row Antagonist',
        pattern: MovementPattern.horizontalPull,
        primaryMuscle: MuscleGroup.back,
      ),
      SlotDefinition(
        id: 'arn_cb_3',
        name: 'Incline Dumbbell Bench',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
      ),
      SlotDefinition(
        id: 'arn_cb_4',
        name: 'Vertical Pull / Lat Pulldown',
        pattern: MovementPattern.verticalPull,
        primaryMuscle: MuscleGroup.back,
      ),
      SlotDefinition(
        id: 'arn_cb_5',
        name: 'Pectoral Fly Isolation',
        pattern: MovementPattern.horizontalPush,
        primaryMuscle: MuscleGroup.chest,
        isCompound: false,
      ),
    ],
  );

  static const dayArnoldShouldersArms = DayTemplate(
    id: 'arnold_shoulders_arms',
    name: 'Shoulders & Arms – Classic Armor',
    shortName: 'Shldr/Arms',
    focus: 'Deltoids, Biceps, Triceps, Forearms',
    primaryMuscles: [MuscleGroup.shoulders, MuscleGroup.arms],
    secondaryMuscles: [],
    slots: [
      SlotDefinition(
        id: 'arn_sa_1',
        name: 'Shoulder Overhead Press',
        pattern: MovementPattern.verticalPush,
        primaryMuscle: MuscleGroup.shoulders,
      ),
      SlotDefinition(
        id: 'arn_sa_2',
        name: 'Lateral Raise Finisher',
        pattern: MovementPattern.deltoidIsolation,
        primaryMuscle: MuscleGroup.shoulders,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'arn_sa_3',
        name: 'Supinated Bicep Curl',
        pattern: MovementPattern.bicepIsolation,
        primaryMuscle: MuscleGroup.arms,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'arn_sa_4',
        name: 'Triceps Extension',
        pattern: MovementPattern.tricepIsolation,
        primaryMuscle: MuscleGroup.arms,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'arn_sa_5',
        name: 'Neutral Grip Hammer Curl',
        pattern: MovementPattern.bicepIsolation,
        primaryMuscle: MuscleGroup.arms,
        isCompound: false,
      ),
    ],
  );

  static const dayArnoldLegs = DayTemplate(
    id: 'arnold_legs',
    name: 'Legs & Abs – High Volume',
    shortName: 'Legs/Abs',
    focus: 'Quads, Hamstrings, Calves, Abdominals',
    primaryMuscles: [MuscleGroup.legs],
    secondaryMuscles: [MuscleGroup.glutes, MuscleGroup.abs],
    slots: [
      SlotDefinition(
        id: 'arn_lg_1',
        name: 'Barbell Back Squat',
        pattern: MovementPattern.kneeDominant,
        primaryMuscle: MuscleGroup.legs,
      ),
      SlotDefinition(
        id: 'arn_lg_2',
        name: 'Romanian Deadlift',
        pattern: MovementPattern.hipHinge,
        primaryMuscle: MuscleGroup.legs,
        secondaryMuscles: [MuscleGroup.glutes],
      ),
      SlotDefinition(
        id: 'arn_lg_3',
        name: 'Lunges / Leg Extension',
        pattern: MovementPattern.kneeDominant,
        primaryMuscle: MuscleGroup.legs,
      ),
      SlotDefinition(
        id: 'arn_lg_4',
        name: 'Calf Raise Progression',
        pattern: MovementPattern.calfIsolation,
        primaryMuscle: MuscleGroup.legs,
        isCompound: false,
      ),
      SlotDefinition(
        id: 'arn_lg_5',
        name: 'Abdominal Crunch / Leg Raise',
        pattern: MovementPattern.core,
        primaryMuscle: MuscleGroup.abs,
        isCompound: false,
      ),
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILT-IN SPLITS
  // ═══════════════════════════════════════════════════════════════════════════

  static const fullBody = Split(
    id: 'full_body',
    name: 'Full Body',
    description: 'Whole-body stimulus across alternating A/B/C sessions. Superior frequency for foundational strength and recovery.',
    cycleDays: [dayFullBodyA, dayFullBodyB, dayFullBodyC],
    defaultDays: 3,
    minRecommendedDays: 2,
    maxRecommendedDays: 4,
    notes: 'Consecutive training days rotate primary movement slots to minimize local muscular overlap.',
  );

  static const upperLower = Split(
    id: 'upper_lower',
    name: 'Upper / Lower',
    description: 'Separates kinetic chains into upper torso and lower extremities. Balances heavy loading and joint recovery.',
    cycleDays: [dayUpperA, dayLowerA, dayUpperB, dayLowerB],
    defaultDays: 4,
    minRecommendedDays: 3,
    maxRecommendedDays: 5,
    notes: 'The classic 4-day cadence trains each muscle group twice weekly.',
  );

  static const pushPullLegs = Split(
    id: 'push_pull_legs',
    name: 'Push / Pull / Legs',
    description: 'Isolates pushing mechanics, pulling mechanics, and lower body. Eliminates overlap between antagonistic muscles.',
    cycleDays: [dayPplPush, dayPplPull, dayPplLegs],
    defaultDays: 6,
    minRecommendedDays: 3,
    maxRecommendedDays: 6,
    notes: 'Runs as a 3-day single pass or 6-day double cycle for advanced volume capacity.',
  );

  static const arnoldSplit = Split(
    id: 'arnold_split',
    name: 'Arnold Split',
    description: 'Chest & Back agonist-antagonist pairings, dedicated Shoulder & Arm day, and high-volume Leg day.',
    cycleDays: [dayArnoldChestBack, dayArnoldShouldersArms, dayArnoldLegs],
    defaultDays: 6,
    minRecommendedDays: 3,
    maxRecommendedDays: 6,
    notes: 'Delivers legendary antagonistic muscle pumps and dedicated shoulder/arm focus.',
  );

  static const mixCustom = Split(
    id: 'mix_custom',
    name: 'Mix / Custom',
    description: 'Fully bespoke configuration. Assemble your own day focuses or assign specific muscle groups to each training day.',
    cycleDays: [dayUpperA, dayLowerA, dayFullBodyA],
    defaultDays: 4,
    minRecommendedDays: 1,
    maxRecommendedDays: 7,
    isCustom: true,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILT-IN HYBRIDS
  // ═══════════════════════════════════════════════════════════════════════════

  /// PPL x Upper/Lower:
  /// Mode 1 (Combined Cycle): 5-day cycle: Push, Pull, Legs, Upper, Lower.
  static HybridSplit pplXUpperLower({HybridMode mode = HybridMode.combinedCycle}) =>
      HybridSplit(
        id: 'hybrid_ppl_upper_lower',
        name: 'PPL x Upper / Lower',
        description: 'Combines the targeted precision of PPL with the comprehensive recovery balance of Upper/Lower.',
        splitA: pushPullLegs,
        splitB: upperLower,
        mode: mode,
        customCycleDays: mode == HybridMode.combinedCycle
            ? [dayPplPush, dayPplPull, dayPplLegs, dayUpperA, dayLowerA]
            : null,
        defaultDays: 5,
        minRecommendedDays: 4,
        maxRecommendedDays: 6,
        notes: '5-Day Combined Cycle trains Upper and Lower body twice with distinct rep ranges.',
      );

  /// Arnold x Upper/Lower:
  /// Mode 1 (Combined Cycle): 5-day cycle: Chest & Back, Shoulders & Arms, Legs, Upper, Lower.
  static HybridSplit arnoldXUpperLower({HybridMode mode = HybridMode.combinedCycle}) =>
      HybridSplit(
        id: 'hybrid_arnold_upper_lower',
        name: 'Arnold x Upper / Lower',
        description: 'Blends Arnold antagonistic chest/back pumps and arm isolation with high-yield Upper/Lower days.',
        splitA: arnoldSplit,
        splitB: upperLower,
        mode: mode,
        customCycleDays: mode == HybridMode.combinedCycle
            ? [dayArnoldChestBack, dayArnoldShouldersArms, dayArnoldLegs, dayUpperA, dayLowerA]
            : null,
        defaultDays: 5,
        minRecommendedDays: 4,
        maxRecommendedDays: 6,
        notes: '5-Day Combined Cycle provides unmatched arm volume while maintaining lower body progression.',
      );

  /// PPL x Arnold:
  /// Mode 1 (Combined Cycle): 6-day cycle: Push, Pull, Legs, Chest & Back, Shoulders & Arms, Legs.
  static HybridSplit pplXArnold({HybridMode mode = HybridMode.combinedCycle}) =>
      HybridSplit(
        id: 'hybrid_ppl_arnold',
        name: 'PPL x Arnold',
        description: 'The ultimate 6-day hypertrophy protocol. First pass runs Push/Pull/Legs; second pass runs Arnold Split.',
        splitA: pushPullLegs,
        splitB: arnoldSplit,
        mode: mode,
        customCycleDays: mode == HybridMode.combinedCycle
            ? [
                dayPplPush,
                dayPplPull,
                dayPplLegs,
                dayArnoldChestBack,
                dayArnoldShouldersArms,
                dayArnoldLegs,
              ]
            : null,
        defaultDays: 6,
        minRecommendedDays: 5,
        maxRecommendedDays: 6,
        notes: '6-Day Combined Cycle pairs movement-pattern mechanics with antagonist supersets.',
      );

  /// Creates a dynamic hybrid of any two splits in the given mode.
  static HybridSplit createDynamicHybrid({
    required Split splitA,
    required Split splitB,
    required HybridMode mode,
  }) {
    return HybridSplit(
      id: 'hybrid_${splitA.id}_${splitB.id}_${mode.name}',
      name: '${splitA.name} x ${splitB.name}',
      description: 'Custom hybrid combination of ${splitA.name} and ${splitB.name} (${mode.displayName}).',
      splitA: splitA,
      splitB: splitB,
      mode: mode,
      customCycleDays: mode == HybridMode.combinedCycle
          ? [...splitA.cycleDays, ...splitB.cycleDays]
          : null,
    );
  }

  /// List of all standard selectable splits (built-in + primary hybrids).
  static List<Split> get allSelectableSplits => [
        fullBody,
        upperLower,
        pushPullLegs,
        arnoldSplit,
        pplXUpperLower(),
        arnoldXUpperLower(),
        pplXArnold(),
        mixCustom,
      ];

  /// Find a split by its unique ID.
  static Split? findById(String id) {
    if (id == fullBody.id) return fullBody;
    if (id == upperLower.id) return upperLower;
    if (id == pushPullLegs.id) return pushPullLegs;
    if (id == arnoldSplit.id) return arnoldSplit;
    if (id == mixCustom.id) return mixCustom;
    if (id.startsWith('hybrid_ppl_upper_lower')) return pplXUpperLower();
    if (id.startsWith('hybrid_arnold_upper_lower')) return arnoldXUpperLower();
    if (id.startsWith('hybrid_ppl_arnold')) return pplXArnold();
    return null;
  }

  /// Returns the recommended split for the given days per week.
  static Split getRecommendedSplitForDays(int days) {
    if (days <= 3) return fullBody;
    if (days == 4) return upperLower;
    if (days == 5) return pplXUpperLower();
    return pushPullLegs;
  }
}

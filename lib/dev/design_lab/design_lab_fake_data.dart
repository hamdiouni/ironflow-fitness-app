/// Realistic static fake gym data used exclusively by the debug Design Lab
/// (`lib/dev/design_lab/`). Zero Hive, network, or provider side-effects.
class LabFakeData {
  const LabFakeData._();

  static const String greeting = 'Ready to train';
  static const String programTitle = 'Upper / Lower Split (Day 1 of 4)';
  static const String todayWorkoutName = 'Upper Body — Power';
  static const String todayWorkoutMeta = '5 exercises • ~50 min • 18 target sets';
  static const int streakDays = 6;
  static const int weeklyGoalTarget = 4;
  static const int weeklyCompleted = 3;
  static const int readinessPercent = 82;
  static const String readinessSummary =
      'Chest and back look fresh. Triceps are still recovering from Tuesday.';

  static const String coachTitle = 'Steady Pressing Progress';
  static const String coachMessage =
      'You hit 3 sessions this week and added 5 kg to your bench press over the last two weeks. Aim for 8 clean reps on your top set today.';

  static const double caloriesConsumed = 1840;
  static const double caloriesTarget = 2750;
  static const double proteinG = 148;
  static const double proteinTargetG = 185;
  static const double carbsG = 205;
  static const double carbsTargetG = 310;
  static const double fatsG = 52;
  static const double fatsTargetG = 80;

  static const int catalogExerciseCount = 129;
  static const int catalogFoodCount = 282;

  static const List<LabSetRow> activeSets = [
    LabSetRow(
      number: 1,
      typeLabel: 'W',
      previous: '60 kg × 10',
      weight: '60',
      reps: '10',
      completed: true,
    ),
    LabSetRow(
      number: 2,
      typeLabel: 'N',
      previous: '80 kg × 8',
      weight: '82.5',
      reps: '8',
      completed: true,
    ),
    LabSetRow(
      number: 3,
      typeLabel: 'N',
      previous: '80 kg × 8',
      weight: '82.5',
      reps: '8',
      completed: false,
      isActiveRow: true,
    ),
    LabSetRow(
      number: 4,
      typeLabel: 'N',
      previous: '77.5 kg × 8',
      weight: '80',
      reps: '8',
      completed: false,
    ),
  ];

  static const List<LabActiveExercise> activeExercises = [
    LabActiveExercise(
      name: 'Barbell Bench Press',
      muscle: 'Chest',
      targetSummary: '4 sets × 6–8 reps • 2m rest',
      sets: activeSets,
    ),
    LabActiveExercise(
      name: 'Barbell Row',
      muscle: 'Upper Back',
      targetSummary: '4 sets × 8–10 reps • 90s rest',
      sets: [
        LabSetRow(
          number: 1,
          typeLabel: 'N',
          previous: '75 kg × 8',
          weight: '75',
          reps: '8',
          completed: true,
        ),
        LabSetRow(
          number: 2,
          typeLabel: 'N',
          previous: '75 kg × 8',
          weight: '77.5',
          reps: '8',
          completed: false,
        ),
      ],
    ),
  ];

  static const List<LabMealEntry> meals = [
    LabMealEntry(
      name: 'Greek Yogurt & Whey Bowl',
      timing: 'Breakfast • 280 g',
      kcal: 540,
      proteinG: 52,
      carbsG: 48,
      fatsG: 14,
      isCustom: false,
    ),
    LabMealEntry(
      name: 'Chicken Breast, Rice & Avocado',
      timing: 'Lunch • 440 g',
      kcal: 790,
      proteinG: 58,
      carbsG: 86,
      fatsG: 22,
      isCustom: false,
    ),
    LabMealEntry(
      name: 'Homemade Overnight Oats',
      timing: 'My Custom Foods • 320 g',
      kcal: 510,
      proteinG: 38,
      carbsG: 71,
      fatsG: 16,
      isCustom: true,
    ),
  ];

  static const List<LabWeeklyPoint> weeklyVolume = [
    LabWeeklyPoint(label: 'W1', volumeKg: 11200, sessions: 3),
    LabWeeklyPoint(label: 'W2', volumeKg: 12450, sessions: 3),
    LabWeeklyPoint(label: 'W3', volumeKg: 13100, sessions: 4),
    LabWeeklyPoint(label: 'W4', volumeKg: 12800, sessions: 3),
    LabWeeklyPoint(label: 'W5', volumeKg: 14350, sessions: 4),
    LabWeeklyPoint(label: 'W6', volumeKg: 15280, sessions: 4),
  ];

  static const List<LabLiftPr> topLifts = [
    LabLiftPr(
      exercise: 'Barbell Squat',
      estimated1Rm: '132.5 kg',
      delta: '+5.0 kg (30d)',
    ),
    LabLiftPr(
      exercise: 'Barbell Bench Press',
      estimated1Rm: '97.5 kg',
      delta: '+2.5 kg (30d)',
    ),
    LabLiftPr(
      exercise: 'Romanian Deadlift',
      estimated1Rm: '140.0 kg',
      delta: '+7.5 kg (30d)',
    ),
  ];
}

class LabSetRow {
  const LabSetRow({
    required this.number,
    required this.typeLabel,
    required this.previous,
    required this.weight,
    required this.reps,
    required this.completed,
    this.isActiveRow = false,
  });

  final int number;
  final String typeLabel;
  final String previous;
  final String weight;
  final String reps;
  final bool completed;
  final bool isActiveRow;
}

class LabActiveExercise {
  const LabActiveExercise({
    required this.name,
    required this.muscle,
    required this.targetSummary,
    required this.sets,
  });

  final String name;
  final String muscle;
  final String targetSummary;
  final List<LabSetRow> sets;
}

class LabMealEntry {
  const LabMealEntry({
    required this.name,
    required this.timing,
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.isCustom,
  });

  final String name;
  final String timing;
  final int kcal;
  final int proteinG;
  final int carbsG;
  final int fatsG;
  final bool isCustom;
}

class LabWeeklyPoint {
  const LabWeeklyPoint({
    required this.label,
    required this.volumeKg,
    required this.sessions,
  });

  final String label;
  final double volumeKg;
  final int sessions;
}

class LabLiftPr {
  const LabLiftPr({
    required this.exercise,
    required this.estimated1Rm,
    required this.delta,
  });

  final String exercise;
  final String estimated1Rm;
  final String delta;
}

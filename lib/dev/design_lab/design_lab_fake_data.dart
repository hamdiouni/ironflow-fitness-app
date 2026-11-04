class FakeData {
  // Today / Home
  static const int readinessScore = 92;
  static const int currentStreak = 14;
  static const String nextWorkoutTitle = 'Upper Body Strength';
  static const String nextWorkoutSplit = 'Push Protocol • 45 min';
  static const int nextWorkoutExercisesCount = 5;

  // Active Workout
  static const String activeExerciseName = 'Barbell Bench Press';
  static const String activeMuscleGroup = 'Chest • Triceps';
  static const int currentSetIndex = 3;
  static const int totalSets = 4;
  static const double activeWeightKg = 100.0;
  static const int activeReps = 8;
  static const int targetReps = 8;
  static const String restTimerDisplay = '01:30';

  // Workout Summary
  static const String summaryDuration = '48:15';
  static const String summaryVolume = '14,250 kg';
  static const int summarySetsCompleted = 18;
  static const int summaryPRCount = 2;
  static const List<String> summaryPRs = [
    'Bench Press: 100 kg × 8 reps (+5 kg)',
    'Incline Dumbbell: 36 kg × 10 reps (+2 reps)',
  ];

  // Fuel / Nutrition
  static const int calorieGoal = 2600;
  static const int caloriesConsumed = 1840;
  static const int caloriesRemaining = 760;
  static const double proteinConsumed = 152.0;
  static const double proteinTarget = 180.0;
  static const double carbsConsumed = 195.0;
  static const double carbsTarget = 260.0;
  static const double fatConsumed = 54.0;
  static const double fatTarget = 70.0;

  static const List<Map<String, dynamic>> mealsTimeline = [
    {
      'title': 'Breakfast',
      'time': '08:30 AM',
      'items': 'Oatmeal & Whey Protein',
      'calories': 520,
      'protein': 42.0,
      'carbs': 68.0,
      'fat': 10.0,
    },
    {
      'title': 'Lunch',
      'time': '01:15 PM',
      'items': 'Grilled Chicken & Brown Rice',
      'calories': 740,
      'protein': 58.0,
      'carbs': 84.0,
      'fat': 16.0,
    },
    {
      'title': 'Post-Workout Snack',
      'time': '05:00 PM',
      'items': 'Greek Yogurt & Blueberries',
      'calories': 280,
      'protein': 28.0,
      'carbs': 32.0,
      'fat': 4.0,
    },
    {
      'title': 'Dinner',
      'time': '08:00 PM',
      'items': 'Salmon Fillet & Roasted Asparagus',
      'calories': 600,
      'protein': 48.0,
      'carbs': 18.0,
      'fat': 32.0,
    },
  ];

  // Food Item for Sheet
  static const String selectedFoodName = 'Grilled Chicken Breast';
  static const double defaultGrams = 150.0;
  static const int foodCaloriesPer100g = 165;
  static const double foodProteinPer100g = 31.0;
  static const double foodCarbsPer100g = 0.0;
  static const double foodFatPer100g = 3.6;

  // Recipe
  static const String recipeTitle = 'High-Protein Salmon Bowl';
  static const String recipePrepTime = '20 min';
  static const int recipeCalories = 580;
  static const int recipeProtein = 45;
  static const List<String> recipeSteps = [
    'Season salmon with olive oil, salt, and black pepper.',
    'Pan sear for 4 minutes per side until golden.',
    'Warm brown rice and steam fresh broccoli florets.',
    'Assemble in a bowl and drizzle with low-sodium soy sauce.',
  ];

  // Exercises
  static const List<Map<String, String>> exerciseCatalog = [
    {'name': 'Barbell Bench Press', 'muscle': 'Chest', 'equipment': 'Barbell', 'level': 'Intermediate'},
    {'name': 'Incline Dumbbell Press', 'muscle': 'Upper Chest', 'equipment': 'Dumbbells', 'level': 'Intermediate'},
    {'name': 'Cable Chest Flye', 'muscle': 'Chest', 'equipment': 'Cable Machine', 'level': 'Beginner'},
    {'name': 'Overhead Shoulder Press', 'muscle': 'Shoulders', 'equipment': 'Barbell', 'level': 'Intermediate'},
    {'name': 'Lateral Dumbbell Raise', 'muscle': 'Side Delts', 'equipment': 'Dumbbells', 'level': 'Beginner'},
    {'name': 'Tricep Rope Pushdown', 'muscle': 'Triceps', 'equipment': 'Cable Machine', 'level': 'Beginner'},
  ];

  // Progress Data Points
  static const List<double> weightTrend = [82.4, 82.0, 81.6, 81.2, 80.8, 80.2, 79.8];
  static const List<String> weightDates = ['Oct 01', 'Oct 05', 'Oct 10', 'Oct 15', 'Oct 20', 'Oct 25', 'Oct 30'];

  // Onboarding Step
  static const String onboardingStepTitle = 'What is your primary fitness goal?';
  static const String onboardingStepSubtitle = 'Select the focus for your customized workout and nutrition plan.';
  static const List<Map<String, String>> onboardingGoals = [
    {'title': 'Build Muscle', 'desc': 'Hypertrophy-focused volume with progressive overload.'},
    {'title': 'Gain Strength', 'desc': 'Heavy compound lifting with focused recovery.'},
    {'title': 'Lose Fat & Tone', 'desc': 'High-density sessions with calorie-optimized targets.'},
    {'title': 'General Longevity', 'desc': 'Balanced athletic conditioning and joint health.'},
  ];
}


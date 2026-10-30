import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/providers/connectivity_provider.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/ai/domain/entities/insight.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/ai/presentation/widgets/ai_coach_hero_card.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout_program.dart';
import 'package:progression_tracker/features/workout/presentation/providers/active_program_providers.dart';
import 'package:progression_tracker/features/workout/presentation/providers/home_workout_provider.dart';
import 'package:progression_tracker/features/workout/presentation/screens/home_screen.dart';
import 'package:progression_tracker/shared/presentation/components/app_card.dart';

import '../../../ai/integration/screen_integration_test.dart';

class _FakeActiveProgramNotifier
    extends StateNotifier<AsyncValue<ActiveProgram?>>
    implements ActiveProgramNotifier {
  _FakeActiveProgramNotifier(ActiveProgram? program)
      : super(AsyncValue.data(program));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDailyNutritionNotifier
    extends StateNotifier<AsyncValue<DailyNutritionSummary>>
    implements DailyNutritionNotifier {
  _FakeDailyNutritionNotifier(DailyNutritionSummary summary)
      : super(AsyncValue.data(summary));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final now = DateTime.now();

  ActiveProgram buildActiveProgram() {
    return ActiveProgram(
      id: 'active-home-1',
      program: WorkoutProgram(
        id: 'prog-home-1',
        name: 'Slate Teal Protocol',
        description: 'Frame-light verification program',
        difficulty: 'Intermediate',
        durationWeeks: 8,
        days: const [
          ProgramDay(
            dayNumber: 1,
            name: 'Upper Power',
            focus: 'Chest & Back',
            exercises: [
              ProgramExercise(
                exerciseName: 'Barbell Bench Press',
                sets: 4,
                reps: '6-8',
                restSeconds: 120,
              ),
            ],
            isRestDay: false,
          ),
        ],
      ),
      currentDayIndex: 0,
      isActive: true,
      lastWorkoutDate: null,
      completedDays: const {},
    );
  }

  Widget buildHomeSubject({
    required List<Workout> workouts,
    int workoutDaysPerWeek = 3,
  }) {
    final todayKey = todayNutritionDayKey();
    final aiState = GlobalAIState(
      insights: {
        InsightContext.home: [
          Insight(
            id: 'insight-1',
            context: InsightContext.home,
            title: 'Ready to Train',
            message: 'Recovery metrics look strong for Upper Power.',
            icon: '⚡',
            priority: InsightPriority.high,
            generatedAt: now,
          ),
        ],
      },
      isLoading: const {InsightContext.home: false},
    );

    return ProviderScope(
      overrides: [
        globalAIProvider.overrideWith((ref) => FakeGlobalAINotifier(aiState)),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        homeWorkoutDataProvider.overrideWith((ref) async => workouts),
        activeProgramProvider.overrideWith(
          (ref) => _FakeActiveProgramNotifier(buildActiveProgram()),
        ),
        dailyNutritionSummaryProvider(todayKey).overrideWith(
          (ref) => _FakeDailyNutritionNotifier(
            DailyNutritionSummary(
              date: DateTime(now.year, now.month, now.day),
              meals: const [],
              target: null,
            ),
          ),
        ),
        userProfileProvider.overrideWith(
          (ref) async => UserProfile(
            goal: FitnessGoal.gainMuscle,
            age: 28,
            weightKg: 80.0,
            heightCm: 180.0,
            fitnessLevel: FitnessLevel.intermediate,
            equipment: EquipmentType.gym,
            workoutDaysPerWeek: workoutDaysPerWeek,
            budget: BudgetLevel.medium,
          ),
        ),
      ],
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData.dark().copyWith(
          extensions: [AppThemeTokens.dark],
        ),
        home: const HomeScreen(),
      ),
    );
  }

  group('HomeScreen Frame-Light & Emphasis Rules (Wave 2)', () {
    testWidgets(
      'uses AppCard surfaces without nested AppCards, and AI hero never glows against weekly goal',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 1400));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        // 3 workouts in last 7 days meets the 3-day weekly goal -> 1 glowing card
        final workouts = List.generate(
          3,
          (i) => Workout(
            id: 'w-$i',
            date: now.subtract(Duration(days: i)),
            exercises: const [],
            duration: const Duration(minutes: 45),
            totalVolume: 5000,
          ),
        );

        await tester.pumpWidget(
          buildHomeSubject(workouts: workouts, workoutDaysPerWeek: 3),
        );
        await tester.pumpAndSettle();

        final appCards = tester.widgetList<AppCard>(find.byType(AppCard)).toList();
        expect(appCards.length, greaterThanOrEqualTo(5));

        // At most one accent glow across the entire Home screen
        final glowingCards = appCards.where((c) => c.isGlowing).toList();
        expect(glowingCards.length, lessThanOrEqualTo(1));

        // AI Coach hero card specifically must not glow
        final aiHeroCard = tester.widget<AppCard>(
          find.descendant(
            of: find.byType(AiCoachHeroCard),
            matching: find.byType(AppCard),
          ),
        );
        expect(aiHeroCard.isGlowing, isFalse);

        // No nested AppCard inside another AppCard
        for (final cardElement in find.byType(AppCard).evaluate()) {
          final nested = find.descendant(
            of: find.byElementPredicate((el) => el == cardElement),
            matching: find.byType(AppCard),
          );
          expect(nested, findsNothing);
        }

        // 1-tap start workout CTA is directly visible on Home
        expect(find.text("START TODAY'S WORKOUT"), findsOneWidget);
      },
    );
  });
}


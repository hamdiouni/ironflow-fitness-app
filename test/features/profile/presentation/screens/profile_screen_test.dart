import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_provider.dart';
import 'package:progression_tracker/features/ai/presentation/providers/global_ai_state.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/profile/presentation/screens/profile_screen.dart';

import '../../../ai/integration/screen_integration_test.dart';

void main() {
  const testProfile = UserProfile(
    goal: FitnessGoal.gainMuscle,
    age: 26,
    weightKg: 82.5,
    heightCm: 180,
    fitnessLevel: FitnessLevel.intermediate,
    equipment: EquipmentType.gym,
    workoutDaysPerWeek: 4,
    budget: BudgetLevel.medium,
  );

  Widget createWidgetUnderTest({
    UserProfile? profile = testProfile,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return ProviderScope(
      overrides: [
        globalAIProvider.overrideWith((ref) => FakeGlobalAINotifier(
              const GlobalAIState(),
            )),
        userProfileProvider.overrideWith((ref) async => profile),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: [AppThemeTokens.light],
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          extensions: [AppThemeTokens.dark],
        ),
        home: const ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen Widget Tests (Monolithic Sci-Fi)', () {
    testWidgets('renders telemetry header, stats row, protocols, and settings',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('PROFILE'), findsOneWidget);
      expect(find.text('PROFILE & WORKOUT PLAN'), findsOneWidget);
      expect(find.text('GAIN MUSCLE'), findsOneWidget);
      expect(find.text('4 DAYS / WEEK PROTOCOL'), findsOneWidget);

      // Stats row
      expect(find.text('AGE'), findsOneWidget);
      expect(find.text('26'), findsOneWidget);
      expect(find.text('WEIGHT'), findsOneWidget);
      expect(find.text('82.5'), findsOneWidget);
      expect(find.text('HEIGHT'), findsOneWidget);
      expect(find.text('180'), findsOneWidget);
      expect(find.text('BMI'), findsOneWidget);

      // Cards
      expect(find.text('WORKOUT PROGRAM'), findsOneWidget);
      expect(find.text('ACTIVE PROTOCOL'), findsOneWidget);
      expect(find.text('NUTRITION PROTOCOL'), findsOneWidget);
    });

    testWidgets('renders empty state when userProfile is null', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest(profile: null));
      await tester.pumpAndSettle();

      expect(find.text('NO PROFILE FOUND'), findsOneWidget);
      expect(find.text('START SETUP'), findsOneWidget);
    });
  });
}

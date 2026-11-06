import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progression_tracker/core/providers/theme_provider.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/settings/presentation/screens/settings_screen.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState(
        isAuthenticated: true,
        user: User(
          id: 'user-1',
          email: 'athlete@ironflow.app',
          displayName: 'Alex Athlete',
          photoUrl: null,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );
}

class _FakeThemeNotifier extends ThemeNotifier {
  @override
  ThemeMode build() => ThemeMode.dark;
}

class _FakeHapticsNotifier extends HapticsNotifier {
  @override
  bool build() => true;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SettingsScreen renders account and configuration sections',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
          themeProvider.overrideWith(_FakeThemeNotifier.new),
          hapticsEnabledProvider.overrideWith(_FakeHapticsNotifier.new),
          userProfileProvider.overrideWith(
            (ref) async => const UserProfile(
              goal: FitnessGoal.gainMuscle,
              age: 28,
              weightKg: 80,
              heightCm: 180,
              fitnessLevel: FitnessLevel.intermediate,
              equipment: EquipmentType.gym,
              workoutDaysPerWeek: 4,
              budget: BudgetLevel.medium,
            ),
          ),
        ],
        child: MaterialApp(
          theme: ThemeData.dark().copyWith(
            extensions: [AppThemeTokens.dark],
          ),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('SYSTEM CONFIGURATION'), findsOneWidget);
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('ALEX ATHLETE'), findsOneWidget);
  });
}

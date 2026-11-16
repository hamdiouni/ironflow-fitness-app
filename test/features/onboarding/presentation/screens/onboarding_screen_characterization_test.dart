import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/onboarding/data/user_profile_storage.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState();
}

class _FakeUserProfileStorage extends UserProfileStorage {
  _FakeUserProfileStorage({this.storedProfile});

  final UserProfile? storedProfile;

  @override
  Future<Map<String, dynamic>?> getDraft({String? userId}) async => null;

  @override
  Future<UserProfile?> loadProfile({String? userId}) async => storedProfile;

  @override
  Future<bool> isOnboarded({String? userId}) async => storedProfile != null;

  @override
  Future<void> saveDraft({
    required int step,
    required Map<String, dynamic> data,
    String? userId,
  }) async {}
}

class _FakeHapticsNotifier extends HapticsNotifier {
  @override
  bool build() => false;
}

void main() {
  testWidgets('OnboardingScreen renders Step 1 Goal and advances to Step 2',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
          userProfileStorageProvider.overrideWithValue(_FakeUserProfileStorage()),
          hapticsEnabledProvider.overrideWith(_FakeHapticsNotifier.new),
        ],
        child: MaterialApp(
          theme: ThemeData.dark().copyWith(
            extensions: [AppThemeTokens.dark],
          ),
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('SET UP YOUR PROFILE'), findsOneWidget);
  });

  testWidgets('OnboardingScreen in edit mode loads existing UserProfile stats (Wave 1.7f)',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const existing = UserProfile(
      goal: FitnessGoal.loseWeight,
      age: 34,
      weightKg: 88.5,
      heightCm: 182.0,
      fitnessLevel: FitnessLevel.intermediate,
      equipment: EquipmentType.home,
      workoutDaysPerWeek: 5,
      budget: BudgetLevel.high,
      sex: BiologicalSex.male,
      targetWeightKg: 80.0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(_FakeAuthNotifier.new),
          userProfileStorageProvider.overrideWithValue(
            _FakeUserProfileStorage(storedProfile: existing),
          ),
          hapticsEnabledProvider.overrideWith(_FakeHapticsNotifier.new),
        ],
        child: MaterialApp(
          theme: ThemeData.dark().copyWith(
            extensions: [AppThemeTokens.dark],
          ),
          home: const OnboardingScreen(isEditMode: true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('UPDATE YOUR PROFILE'), findsOneWidget);
    // Advance to Step 2 (About You) and verify loaded age '34' is pre-populated
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();
    expect(find.textContaining('34'), findsWidgets);
  });
}

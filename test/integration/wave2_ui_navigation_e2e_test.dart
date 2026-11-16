import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/config/flavor_config.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/providers/analytics_provider.dart';
import 'package:progression_tracker/core/providers/language_provider.dart';
import 'package:progression_tracker/core/providers/theme_provider.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/core/services/analytics_service.dart';
import 'package:progression_tracker/core/services/telemetry_preferences.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:progression_tracker/features/auth/presentation/screens/signup_screen.dart';
import 'package:progression_tracker/features/onboarding/data/user_profile_storage.dart';
import 'package:progression_tracker/features/onboarding/domain/entities/user_profile.dart'
    as onboarding;
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/main.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _InMemoryAuthRepository implements AuthRepository {
  User? currentUser;

  @override
  Future<User?> getCurrentUser() async => currentUser;

  @override
  Future<bool> isAuthenticated() async => currentUser != null;

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    currentUser = User(
      id: 'ui-e2e-user-1',
      email: email,
      displayName: displayName ?? email.split('@').first,
      photoUrl: null,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    return currentUser!;
  }

  @override
  Future<void> signOut() async {
    currentUser = null;
  }

  @override
  Stream<User?> get authStateChanges => Stream.value(currentUser);

  @override
  Future<UserProfile?> getUserProfile(String userId) async => null;

  @override
  Future<void> saveUserProfile(UserProfile profile) async {}

  @override
  Future<void> updateUserProfile(UserProfile profile) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _InMemoryProfileStorage extends UserProfileStorage {
  bool onboarded = false;

  @override
  Future<bool> isOnboarded({String? userId}) async => onboarded;

  @override
  Future<onboarding.UserProfile?> loadProfile({String? userId}) async => null;
}

class _MemoryAuthNotifier extends AuthNotifier {
  _MemoryAuthNotifier(this.repo)
      : super(
          signUpUseCase: SignUpUseCase(repo),
          signInUseCase: SignInUseCase(repo),
          signOutUseCase: SignOutUseCase(repo),
        );
  final _InMemoryAuthRepository repo;
}

class _StaticThemeNotifier extends ThemeNotifier {
  @override
  ThemeMode build() => ThemeMode.dark;
}

class _StaticLanguageNotifier extends LanguageNotifier {
  @override
  Locale build() => const Locale('en');
}

void main() {
  setUp(() {
    AppHaptics.shared = AppHaptics(isEnabled: false);
    SharedPreferences.setMockInitialValues({});
  });

  group('Wave 2.4 — UI Navigation E2E & Flavor Banner Verification', () {
    testWidgets(
        'UI Journey: unauthenticated /home -> /login -> /signup -> /onboarding, then /home -> opt-in telemetry consent saved',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final authRepo = _InMemoryAuthRepository();
      final storage = _InMemoryProfileStorage();

      late GoRouter router;
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          authNotifierProvider.overrideWith(() => _MemoryAuthNotifier(authRepo)),
          userProfileStorageProvider.overrideWithValue(storage),
          analyticsServiceProvider.overrideWithValue(
            AnalyticsService.forTesting(isAnalyticsEnabled: () async => false),
          ),
          themeProvider.overrideWith(_StaticThemeNotifier.new),
          languageProvider.overrideWith(_StaticLanguageNotifier.new),
        ],
      );
      addTearDown(container.dispose);

      router = GoRouter(
        initialLocation: AppRoutes.home,
        redirect: (context, state) {
          final authState = container.read(authNotifierProvider);
          final loc = state.matchedLocation;
          final isAuthRoute = loc == AppRoutes.login || loc == AppRoutes.signup;
          if (!authState.isAuthenticated) {
            return isAuthRoute ? null : AppRoutes.login;
          }
          if (!storage.onboarded && loc != AppRoutes.onboarding) {
            return AppRoutes.onboarding;
          }
          return null;
        },
        routes: [
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) => Scaffold(
              body: TextButton(
                onPressed: () => context.go(AppRoutes.signup),
                child: const Text('GO SIGNUP'),
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.signup,
            builder: (context, state) => const SignupScreen(),
          ),
          GoRoute(
            path: AppRoutes.onboarding,
            builder: (context, state) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  storage.onboarded = true;
                  context.go(AppRoutes.home);
                },
                child: const Text('FINISH ONBOARDING'),
              ),
            ),
          ),
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                MainScaffold(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (_, _) => const Scaffold(body: Text('HOME READY')),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: AppRoutes.workout,
                  builder: (_, _) => const Scaffold(body: Text('TRAIN READY')),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: AppRoutes.nutrition,
                  builder: (_, _) => const Scaffold(body: Text('FUEL READY')),
                ),
              ]),
              StatefulShellBranch(routes: [
                GoRoute(
                  path: AppRoutes.progress,
                  builder: (_, _) =>
                      const Scaffold(body: Text('PROGRESS READY')),
                ),
              ]),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: ThemeData.dark().copyWith(extensions: [AppThemeTokens.dark]),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Redirected from /home -> /login; navigate to /signup.
      expect(find.text('GO SIGNUP'), findsOneWidget);
      await tester.tap(find.text('GO SIGNUP'));
      await tester.pumpAndSettle();
      expect(find.text('Start Your Journey'), findsOneWidget);

      // Step 2: Sign up with name + email -> arrives at /onboarding.
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Jordan Lifter');
      await tester.enterText(fields.at(1), 'jordan@ironflow.test');
      await tester.enterText(fields.at(2), 'Password123!');
      await tester.enterText(fields.at(3), 'Password123!');
      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(find.text('FINISH ONBOARDING'), findsOneWidget);

      // Step 3: Finish onboarding -> lands on /home inside MainScaffold -> telemetry modal opens OFF by default.
      await tester.tap(find.text('FINISH ONBOARDING'));
      await tester.pumpAndSettle();
      expect(find.text('HOME READY'), findsOneWidget);
      expect(find.text('Privacy & Diagnostics Consent'), findsOneWidget);
      expect(await TelemetryPreferences.analyticsEnabled(), isFalse);
      expect(await TelemetryPreferences.crashReportingEnabled(), isFalse);

      // Decline keeps both telemetry toggles false and persists prompt decision.
      await tester.tap(find.text('KEEP ALL OFF'));
      await tester.pumpAndSettle();
      expect(await TelemetryPreferences.hasShownConsentPrompt(), isTrue);
      expect(await TelemetryPreferences.analyticsEnabled(), isFalse);
      expect(await TelemetryPreferences.crashReportingEnabled(), isFalse);
    });

    testWidgets(
        'MainApp shows visible flavor badge in dev/staging and hides it in production',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'telemetry_consent_prompt_shown': true,
      });

      GoRouter stubRouter() => GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (_, _) => const Scaffold(body: Text('ROOT')),
              ),
            ],
          );

      // Dev flavor renders visible DEV banner and dev title.
      final devFlavor = FlavorConfig.resolve(
        rawFlavor: 'dev',
        isReleaseMode: false,
      );
      await tester.pumpWidget(
        ProviderScope(
          key: const ValueKey('dev-flavor'),
          overrides: [
            routerProvider.overrideWithValue(stubRouter()),
            themeProvider.overrideWith(_StaticThemeNotifier.new),
            languageProvider.overrideWith(_StaticLanguageNotifier.new),
          ],
          child: MainApp(flavorConfig: devFlavor),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Banner), findsOneWidget);
      final devMaterialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(devMaterialApp.title, 'IronFlow Dev');

      // Production flavor shows NO banner and uses production appName.
      final prodFlavor = FlavorConfig.resolve(
        rawFlavor: 'production',
        isReleaseMode: true,
      );
      await tester.pumpWidget(
        ProviderScope(
          key: const ValueKey('prod-flavor'),
          overrides: [
            routerProvider.overrideWithValue(stubRouter()),
            themeProvider.overrideWith(_StaticThemeNotifier.new),
            languageProvider.overrideWith(_StaticLanguageNotifier.new),
          ],
          child: MainApp(flavorConfig: prodFlavor),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Banner), findsNothing);
      final prodMaterialApp =
          tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(prodMaterialApp.title, 'IronFlow');
    });
  });
}

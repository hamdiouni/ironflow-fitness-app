import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/main.dart';

import '../../features/body/presentation/screens/progress_screen.dart'
    as body_progress;
import '../../features/workout/presentation/screens/active_workout_screen.dart'
    as active_workout;
import '../../features/workout/presentation/screens/exercise_detail_screen.dart'
    as exercise_detail;
import '../../features/nutrition/presentation/screens/nutrition_screen.dart'
    as nutrition;
import '../../features/nutrition/presentation/screens/nutrition_history_screen.dart'
    as nutrition_history;
import '../../features/workout/presentation/screens/home_screen.dart';
import '../../features/workout/presentation/screens/workout_screen.dart';
import '../../features/workout/presentation/screens/workout_history_screen.dart'
    as workout_history;
import '../../features/workout/presentation/screens/workout_summary_screen.dart';
import '../../features/workout/presentation/screens/exercise_catalog_screen.dart';
import '../../features/workout/presentation/screens/program_editor_screen.dart';
import '../../features/workout/presentation/screens/exercise_picker_screen.dart';
import '../../features/workout/presentation/screens/program_selection_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/onboarding/data/user_profile_storage.dart';
import '../../features/notifications/presentation/screens/reminder_settings_screen.dart';
import '../../features/ai/presentation/screens/ai_chat_screen.dart';
import '../../features/ai/presentation/screens/ai_test_screen.dart';
import '../../features/design_system/presentation/screens/design_gallery_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/export_settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_settings_screen.dart';
import '../../features/workout/domain/entities/exercise.dart';
import '../../features/workout/domain/entities/exercise_definition.dart';
import '../../features/tools/presentation/screens/tools_hub_screen.dart';

// ---------------------------------------------------------------------------
// Route path constants
// ---------------------------------------------------------------------------

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String workout = '/workout';
  static const String workoutActive = '/workout/active';
  static const String workoutSummary = '/workout/summary';
  static const String workoutHistory = '/workout/history';
  static const String workoutExercise = '/workout/exercise/:name';
  static const String workoutCatalog = '/workout/catalog';
  static const String workoutEditor = '/workout/editor';
  static const String exercisePicker = '/exercise-picker';
  static const String workoutProgramSelection = '/workout/program-selection';
  static const String progress = '/progress';
  static const String analytics = '/analytics';
  static const String nutrition = '/nutrition';
  static const String nutritionHistory = '/nutrition/history';
  static const String profile = '/profile';
  static const String reminderSettings = '/profile/reminder-settings';
  static const String settings = '/settings';
  static const String exportSettings = '/settings/export';
  static const String privacySettings = '/settings/privacy';
  static const String aiChat = '/ai-chat';
  static const String aiTest = '/ai-test';
  static const String designGallery = '/design-gallery';
  static const String tools = '/tools';

  /// Validates a `?from=` return path so only internal non-auth routes are used.
  static String resolvePostAuthRedirect(String? from) {
    if (from == null || from.trim().isEmpty) {
      return home;
    }
    final trimmed = from.trim();
    if (!trimmed.startsWith('/') || trimmed.startsWith('//')) {
      return home;
    }
    final parsed = Uri.tryParse(trimmed);
    final path = parsed?.path ?? trimmed;
    if (path == login ||
        path == signup ||
        path == splash ||
        path == onboarding) {
      return home;
    }
    return trimmed;
  }
}

// ---------------------------------------------------------------------------
// Router provider
// ---------------------------------------------------------------------------

final routerProvider = Provider<GoRouter>((ref) {
  // DON'T watch auth state here - it causes router to rebuild on auth changes
  // Instead, read it directly inside the redirect function
  
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      // Read auth state directly here (not watched in provider)
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated = authState.isAuthenticated;
      final userId = authState.user?.id;
      final isOnboarded = UserProfileStorage().isOnboardedSync(userId: userId);

      final loc = state.matchedLocation;
      final isAuthRoute = loc == AppRoutes.login ||
          loc == AppRoutes.signup ||
          loc == AppRoutes.splash;
      final isOnboarding = loc == AppRoutes.onboarding;

      if (kDebugMode) {
        AppLogger.debug('🔍 [Router] Redirect check:');
        AppLogger.debug('  - Location: $loc');
        AppLogger.debug('  - Authenticated: $isAuthenticated');
        AppLogger.debug('  - UserId: $userId');
        AppLogger.debug('  - Onboarded: $isOnboarded');
        AppLogger.debug('  - Is auth route: $isAuthRoute');
        AppLogger.debug('  - Is onboarding: $isOnboarding');
      }

      // Case 1: Unauthenticated user
      if (!isAuthenticated) {
        if (isAuthRoute) {
          // Allow splash, login, and signup
          return null;
        }
        if (kDebugMode) {
          AppLogger.debug('⚠️ [Router] Not authenticated, redirecting to login');
        }
        final targetUri = state.uri.toString();
        if (targetUri.isNotEmpty &&
            loc != AppRoutes.home &&
            targetUri != AppRoutes.home) {
          return Uri(
            path: AppRoutes.login,
            queryParameters: {'from': targetUri},
          ).toString();
        }
        return AppRoutes.login;
      }

      // Case 2: Authenticated user who has NOT completed onboarding
      if (!isOnboarded) {
        if (!isOnboarding) {
          if (kDebugMode) {
            AppLogger.debug('📊 [Router] Authenticated user needs onboarding -> /onboarding');
          }
          return AppRoutes.onboarding;
        }
        return null;
      }

      // Case 3: Authenticated AND onboarded user accessing auth or onboarding routes
      if (isAuthRoute || isOnboarding) {
        final destination =
            AppRoutes.resolvePostAuthRedirect(state.uri.queryParameters['from']);
        if (kDebugMode) {
          AppLogger.debug(
              '⚠️ [Router] Already authenticated and onboarded, redirecting to $destination');
        }
        return destination;
      }

      if (kDebugMode) {
        AppLogger.debug('✅ [Router] No redirect needed');
      }
      return null;
    },
    // REMOVED: refreshListenable - this was causing the router to rebuild
    // and interrupt navigation when auth state changed
    // refreshListenable: _GoRouterRefreshStream(ref.watch(authNotifierProvider.notifier).stream),
    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login screen
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Signup screen
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),

      // Onboarding screen
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // StatefulShellRoute wraps the 4 primary tabs with MainScaffold
      // preserving each tab's state in an IndexedStack
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainScaffold(navigationShell: navigationShell),
        branches: [
          // Tab 0: TODAY
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Tab 1: TRAIN
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.workout,
                builder: (context, state) => const WorkoutScreen(),
                routes: [
                  GoRoute(
                    path: 'active',
                    builder: (context, state) =>
                        const active_workout.ActiveWorkoutScreen(),
                  ),
                  GoRoute(
                    path: 'summary',
                    builder: (context, state) {
                      final extra =
                          state.extra as Map<String, dynamic>? ?? {};
                      final workoutId =
                          state.uri.queryParameters['workoutId'] ??
                              state.uri.queryParameters['id'] ??
                              extra['workoutId'] as String?;
                      return WorkoutSummaryScreen(
                        workoutId: workoutId,
                        exercises: extra['exercises'] as List<Exercise>? ?? const [],
                        totalSets: extra['totalSets'] as int? ?? 0,
                        totalVolume: extra['totalVolume'] as double? ?? 0.0,
                        duration: extra['duration'] as Duration? ??
                            Duration.zero,
                        prCount: extra['prCount'] as int? ?? 0,
                        exerciseNames: extra['exerciseNames'] as List<String>? ?? [],
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':workoutId',
                        builder: (context, state) {
                          final extra =
                              state.extra as Map<String, dynamic>? ?? {};
                          final workoutId =
                              state.pathParameters['workoutId'] ??
                                  extra['workoutId'] as String?;
                          return WorkoutSummaryScreen(
                            workoutId: workoutId,
                            exercises:
                                extra['exercises'] as List<Exercise>? ?? const [],
                            totalSets: extra['totalSets'] as int? ?? 0,
                            totalVolume:
                                extra['totalVolume'] as double? ?? 0.0,
                            duration: extra['duration'] as Duration? ??
                                Duration.zero,
                            prCount: extra['prCount'] as int? ?? 0,
                            exerciseNames:
                                extra['exerciseNames'] as List<String>? ?? [],
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'history',
                    builder: (context, state) =>
                        const workout_history.WorkoutHistoryScreen(),
                  ),
                  GoRoute(
                    path: 'exercise/:name',
                    builder: (context, state) {
                      final name = state.pathParameters['name'] ?? '';
                      return exercise_detail.ExerciseDetailScreen(name: name);
                    },
                  ),
                  GoRoute(
                    path: 'catalog',
                    builder: (context, state) => const ExerciseCatalogScreen(),
                  ),
                  GoRoute(
                    path: 'editor',
                    builder: (context, state) => const ProgramEditorScreen(),
                  ),
                  GoRoute(
                    path: 'program-selection',
                    builder: (context, state) => const ProgramSelectionScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Tab 2: FUEL
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.nutrition,
                builder: (context, state) =>
                    const nutrition.NutritionScreen(),
                routes: [
                  GoRoute(
                    path: 'history',
                    builder: (context, state) =>
                        const nutrition_history.NutritionHistoryScreen(),
                  ),
                ],
              ),
            ],
          ),
          // Tab 3: PROGRESS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progress,
                builder: (context, state) {
                  final initialTab = state.uri.queryParameters['tab'];
                  return body_progress.ProgressScreen(initialTab: initialTab);
                },
              ),
            ],
          ),
        ],
      ),

      // Pushed route: Profile (outside bottom dock shell)
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'reminder-settings',
            builder: (context, state) => const ReminderSettingsScreen(),
          ),
        ],
      ),

      // Pushed route: Settings (outside bottom dock shell)
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: 'export',
            builder: (context, state) => const ExportSettingsScreen(),
          ),
          GoRoute(
            path: 'privacy',
            builder: (context, state) => const PrivacySettingsScreen(),
          ),
        ],
      ),

      // Redirect route: /analytics -> /progress (selects Lifts & Volume tab)
      GoRoute(
        path: AppRoutes.analytics,
        redirect: (context, state) => '${AppRoutes.progress}?tab=lifts',
      ),
      // AI Chat route (outside shell - full screen)
      GoRoute(
        path: AppRoutes.aiChat,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AIChatScreen(
            initialMessage: extra?['initialMessage'] as String?,
            contextScreen: extra?['contextScreen'] as String?,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.tools,
        builder: (context, state) => const ToolsHubScreen(),
      ),
      GoRoute(
        path: AppRoutes.exercisePicker,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ExercisePickerScreen(
            initialMuscleGroup: extra['muscleGroup'] as MuscleGroup?,
          );
        },
      ),
      if (kDebugMode) ...[
        GoRoute(
          path: AppRoutes.aiTest,
          builder: (context, state) => const AITestScreen(),
        ),
        GoRoute(
          path: AppRoutes.designGallery,
          builder: (context, state) => const DesignGalleryScreen(),
        ),
      ],
    ],
  );
});

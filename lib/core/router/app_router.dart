import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import '../../features/onboarding/presentation/providers/onboarding_provider.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/notifications/presentation/screens/reminder_settings_screen.dart';
import '../../features/ai/presentation/screens/ai_chat_screen.dart';

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
  static const String aiChat = '/ai-chat';
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
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup ||
          state.matchedLocation == AppRoutes.splash;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (kDebugMode) {
        print('🔍 [Router] Redirect check:');
        print('  - Location: ${state.matchedLocation}');
        print('  - Authenticated: $isAuthenticated');
        print('  - Is auth route: $isAuthRoute');
        print('  - Is onboarding: $isOnboarding');
      }

      // Allow onboarding for both authenticated and unauthenticated users
      if (isOnboarding) {
        if (kDebugMode) {
          print('✅ [Router] Allowing onboarding access');
        }
        return null;
      }

      // If authenticated and trying to access auth routes, redirect to home
      // This prevents the router from allowing authenticated users to stay on login/signup
      if (isAuthenticated && isAuthRoute) {
        if (kDebugMode) {
          print('⚠️ [Router] Already authenticated, redirecting away from auth route to /home');
        }
        return AppRoutes.home;
      }

      // If not authenticated and trying to access auth routes, allow it
      if (!isAuthenticated && isAuthRoute) {
        if (kDebugMode) {
          print('✅ [Router] Allowing auth route access');
        }
        return null;
      }

      // If not authenticated and trying to access protected routes, redirect to login
      if (!isAuthenticated) {
        if (kDebugMode) {
          print('⚠️ [Router] Not authenticated, redirecting to login');
        }
        return AppRoutes.login;
      }

      if (kDebugMode) {
        print('✅ [Router] No redirect needed');
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

      // ShellRoute wraps the 5 top-level tabs with MainScaffold
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
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
                  return WorkoutSummaryScreen(
                    totalSets: extra['totalSets'] as int? ?? 0,
                    totalVolume: extra['totalVolume'] as double? ?? 0.0,
                    duration: extra['duration'] as Duration? ??
                        Duration.zero,
                    prCount: extra['prCount'] as int? ?? 0,
                    exerciseNames: extra['exerciseNames'] as List<String>? ?? [],
                  );
                },
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
          GoRoute(
            path: AppRoutes.progress,
            builder: (context, state) =>
                const body_progress.ProgressScreen(),
          ),
          GoRoute(
            path: AppRoutes.analytics,
            builder: (context, state) => const AnalyticsScreen(),
          ),
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
        ],
      ),
      // AI Chat route (outside shell - full screen)
      GoRoute(
        path: AppRoutes.aiChat,
        builder: (context, state) => const AIChatScreen(),
      ),
      GoRoute(
        path: AppRoutes.exercisePicker,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ExercisePickerScreen(
            initialMuscleGroup: extra['muscleGroup'] as dynamic?,
          );
        },
      ),
    ],
  );
});

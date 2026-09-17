import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/utils/hive_manager.dart';
import 'features/workout/presentation/managers/workout_state_manager.dart';
import 'features/workout/presentation/providers/workout_providers.dart';
import 'features/notifications/domain/services/notification_service.dart';
import 'features/notifications/presentation/providers/notification_providers.dart';
import 'features/ai/presentation/providers/global_ai_provider.dart';

void main() async {
  // Run app in error zone to catch all errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables
    await dotenv.load(fileName: ".env");
    if (kDebugMode) {
      print('✓ Environment variables loaded');
    }

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Firebase Crashlytics (Mobile only - not supported on web)
    if (!kIsWeb) {
      // Only enable in release mode to avoid noise during development
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
      
      // Pass all uncaught Flutter errors to Crashlytics
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      
      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
      
      if (kDebugMode) {
        print('✓ Firebase Crashlytics initialized (mobile only)');
      }
    } else {
      if (kDebugMode) {
        print('ℹ️ Firebase Crashlytics skipped (not supported on web)');
      }
    }

    if (kDebugMode) {
      print('✓ Firebase Crashlytics initialized (disabled in debug mode)');
    }

    // Initialize Firebase Analytics
    final analytics = FirebaseAnalytics.instance;
    await analytics.setAnalyticsCollectionEnabled(!kDebugMode);
    
    if (kDebugMode) {
      print('✓ Firebase Analytics initialized (disabled in debug mode)');
    }

    // Initialize Hive
    await HiveManager.initialize();

    // Initialize Notification Service
    final notificationService = NotificationService();
    await notificationService.initialize(
      onNotificationTap: (payload) {
        // Handle notification tap
        if (kDebugMode) {
          print('Notification tapped with payload: $payload');
        }
        // TODO: Navigate to appropriate screen based on payload
      },
    );

    // Request notification permissions
    await notificationService.requestPermissions();

    // Skip food database initialization on web for faster startup
    // Food data will be loaded from local Hive database instead
    if (kDebugMode) {
      print('✓ Skipping Firestore food upload for faster startup');
      print('✓ Food data will be loaded from local Hive database');
    }

    // Pre-initialise the WorkoutStateManager so the Hive box is open before
    // the first frame is rendered.
    final stateManager = WorkoutStateManager();
    await stateManager.init();

    runApp(
      ProviderScope(
        overrides: [
          workoutStateManagerProvider.overrideWithValue(stateManager),
        ],
        child: const _AppWithStateRestore(),
      ),
    );
  }, (error, stack) {
    // Catch errors that occur outside of Flutter's error handling
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

/// Restores any persisted active workout state before rendering the main UI.
class _AppWithStateRestore extends ConsumerStatefulWidget {
  const _AppWithStateRestore();

  @override
  ConsumerState<_AppWithStateRestore> createState() =>
      _AppWithStateRestoreState();
}

class _AppWithStateRestoreState extends ConsumerState<_AppWithStateRestore>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Attempt to restore a previously active workout session.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutNotifierProvider.notifier).restoreState();
      
      // Initialize Global AI Provider
      ref.read(globalAIProvider.notifier).init().catchError((e) {
        if (kDebugMode) {
          print('⚠️ Failed to initialize Global AI Provider: $e');
        }
        // Don't block app startup if AI initialization fails
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      // Invalidate workout history so it re-fetches when the app comes back
      // to the foreground (e.g. after syncing data in another app).
      ref.read(workoutRefreshCounterProvider.notifier).state++;
    }
  }

  @override
  Widget build(BuildContext context) => const MainApp();
}

/// Root application widget that wires up MaterialApp.router with the
/// go_router provider and the app theme.
class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'IronFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Scaffold that wraps each top-level route with a shared [BottomNavigationBar].
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.child});

  final Widget child;

  static const List<String> _tabRoutes = [
    AppRoutes.home,
    AppRoutes.workout,
    AppRoutes.progress,
    AppRoutes.nutrition,
    AppRoutes.profile,
  ];

  int _currentIndex(String location) {
    for (int i = _tabRoutes.length - 1; i >= 0; i--) {
      if (location.startsWith(_tabRoutes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _currentIndex(location);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111111) : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            if (index != currentIndex) {
              context.go(_tabRoutes[index]);
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Workout',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined),
              activeIcon: Icon(Icons.show_chart),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Nutrition',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

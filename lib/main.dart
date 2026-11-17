import 'package:progression_tracker/core/utils/app_logger.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/config/flavor_config.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/observability_provider.dart';
import 'core/services/app_check_service.dart';
import 'core/services/telemetry_preferences.dart';
import 'core/providers/language_provider.dart';
import 'core/providers/theme_provider.dart';
import 'l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/utils/data_migration.dart';
import 'core/utils/hive_manager.dart';
import 'features/auth/data/datasources/auth_session_storage.dart';
import 'features/workout/presentation/managers/workout_state_manager.dart';
import 'features/workout/presentation/providers/workout_providers.dart';
import 'features/workout/presentation/providers/rest_timer_provider.dart';
import 'features/notifications/domain/services/notification_service.dart';
import 'features/settings/domain/usecases/delete_account_use_case.dart';
import 'package:progression_tracker/features/settings/presentation/screens/telemetry_consent_screen.dart';
import 'features/ai/presentation/providers/global_ai_provider.dart';
import 'shared/presentation/services/app_haptics.dart';

void main() async {
  final observability = createRuntimeObservabilityService();
  final featureFlags = createRuntimeFeatureFlagsService();

  // Run app in error zone to catch all errors
  runZonedGuarded<Future<void>>(() async {
    final bootSpan = observability.startSpan('cold_boot');
    WidgetsFlutterBinding.ensureInitialized();

    // Configure transparent edge-to-edge system bars (Android 14+ / iOS)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Register bundled OFL font licenses (Inter & Space Grotesk) for LicensePage
    LicenseRegistry.addLicense(() async* {
      final licenseText = await rootBundle.loadString('assets/fonts/OFL.txt');
      yield LicenseEntryWithLineBreaks(
        const ['inter', 'space_grotesk'],
        licenseText,
      );
    });

    // Environment configuration comes from --dart-define / --dart-define-from-file.
    // Avoid blocking startup loading an unbundled .env asset (Wave 3.2).

    // Initialize Firebase (best-effort so 100% offline cold boot never blocks UI)
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ Firebase initialization skipped/offline: $e');
      }
    }

    // Initialize Firebase App Check (staged monitor mode in Wave 1 Step 7)
    await AppCheckService.initialize();

    // Apply the user's stored Analytics/Crashlytics opt-outs before any
    // telemetry can be emitted. Debug builds never collect.
    await TelemetryPreferences.applyStoredPreferences();

    // Load cached/remote feature flags and kill switches (ADR-005).
    await featureFlags.initialize(refreshRemote: Firebase.apps.isNotEmpty);

    // Initialize consent-gated & PII-scrubbed error handlers.
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(
        observability.recordError(
          details.exception,
          details.stack ?? StackTrace.current,
          context: details.context?.toDescription() ?? 'flutter_error',
          fatal: true,
        ),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        observability.recordError(
          error,
          stack,
          context: 'platform_dispatcher',
          fatal: true,
        ),
      );
      return true;
    };

    if (!kIsWeb && kDebugMode) {
      AppLogger.debug('✓ Firebase Crashlytics handlers wired via ObservabilityService');
    } else if (kIsWeb && kDebugMode) {
      AppLogger.debug('ℹ️ Firebase Crashlytics skipped (not supported on web)');
    }

    if (kDebugMode) {
      AppLogger.debug('✓ Telemetry preferences applied (collection disabled in debug)');
    }

    // Initialize Hive
    await HiveManager.initialize();

    // Finish any interrupted account deletion wipe before UI renders
    await DeleteAccountUseCase.checkAndExecutePendingWipe();

    // One-time local schema migrations (Phase 1: backfill userId /
    // updatedAt / exerciseDefinitionId on pre-v2 records). Never throws
    // and never blocks startup on failure.
    await DataMigration.runIfNeeded(
      currentUserId: AuthSessionStorage().getUserId(),
    );

    // Initialize Notification Service without requesting OS permissions on cold boot.
    // Notification permissions are requested contextually when the user enables
    // a reminder or starts a rest timer (Wave 1 Step 5).
    final notificationService = NotificationService();
    await notificationService.initialize(
      onNotificationTap: (payload) {
        // Handle notification tap
        if (kDebugMode) {
          AppLogger.debug('Notification tapped with payload: $payload');
        }
        // TODO: Navigate to appropriate screen based on payload
      },
    );

    // Skip food database initialization on web for faster startup
    // Food data will be loaded from local Hive database instead
    if (kDebugMode) {
      AppLogger.debug('✓ Skipping Firestore food upload for faster startup');
      AppLogger.debug('✓ Food data will be loaded from local Hive database');
    }

    // Pre-initialise the WorkoutStateManager so the Hive box is open before
    // the first frame is rendered.
    final stateManager = WorkoutStateManager();
    await stateManager.init();
    bootSpan.stop(succeeded: true);

    runApp(
      ProviderScope(
        overrides: [
          workoutStateManagerProvider.overrideWithValue(stateManager),
          observabilityServiceProvider.overrideWithValue(observability),
          featureFlagsServiceProvider.overrideWithValue(featureFlags),
        ],
        child: const _AppWithStateRestore(),
      ),
    );
  }, (error, stack) {
    unawaited(
      observability.recordError(
        error,
        stack,
        context: 'run_zoned_guarded',
        fatal: true,
      ),
    );
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
    // Attempt to restore a previously active workout session and rest timer.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(workoutNotifierProvider.notifier).restoreState();
      ref.read(restTimerProvider.notifier).sync();

      NotificationService().setOnNotificationTap((payload) {
        if (payload == 'rest_timer') {
          ref.read(routerProvider).go(AppRoutes.workoutActive);
        }
      });

      NotificationService().getLaunchNotificationPayload().then((payload) {
        if (payload == 'rest_timer') {
          ref.read(routerProvider).go(AppRoutes.workoutActive);
        }
      });
      
      // Initialize Global AI Provider
      ref.read(globalAIProvider.notifier).init().catchError((e) {
        if (kDebugMode) {
          AppLogger.debug('⚠️ Failed to initialize Global AI Provider: $e');
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
      // Workout history no longer needs a manual refresh bump here
      // (Phase 3, F-12): providers derive from the Hive box-watch
      // stream, so any data written while backgrounded (e.g. a sync
      // pull) already re-emitted on write.
      // Sync rest timer from absolute timestamp (TRN-02)
      ref.read(restTimerProvider.notifier).sync();
    }
  }

  @override
  Widget build(BuildContext context) => const MainApp();
}

/// Root application widget that wires up MaterialApp.router with the
/// go_router provider and the app theme.
class MainApp extends ConsumerWidget {
  const MainApp({
    super.key,
    this.flavorConfig,
  });

  final FlavorConfig? flavorConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(languageProvider);
    final config = flavorConfig ?? FlavorConfig.current;

    return MaterialApp.router(
      title: config.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();
        if (!config.showFlavorBanner) {
          return content;
        }
        return Banner(
          message: config.flavor.name.toUpperCase(),
          location: BannerLocation.topEnd,
          color: config.isDev
              ? const Color(0xFFD97706)
              : const Color(0xFF0284C7),
          child: content,
        );
      },
    );
  }
}

/// Scaffold that wraps the 4 primary tabs with Direction 4 responsive navigation.
class MainScaffold extends StatefulWidget {
  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  static const List<String> tabRoutes = [
    AppRoutes.home,
    AppRoutes.workout,
    AppRoutes.nutrition,
    AppRoutes.progress,
  ];

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        TelemetryConsentScreen.showIfNeeded(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final navigationShell = widget.navigationShell;
    final currentIndex = navigationShell.currentIndex;
    final tokens = context.tokens;

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        navigationShell.goBranch(0);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          if (isWide) {
            return Scaffold(
              body: Row(
                children: [
                  NavigationRail(
                    backgroundColor: tokens.panel,
                    selectedIndex: currentIndex,
                    onDestinationSelected: (index) {
                      if (index != currentIndex) {
                        AppHaptics.shared.selectionChanged();
                        navigationShell.goBranch(
                          index,
                          initialLocation: index == navigationShell.currentIndex,
                        );
                      }
                    },
                    selectedIconTheme: IconThemeData(color: tokens.kineticAccent),
                    unselectedIconTheme: IconThemeData(color: tokens.textSecondary),
                    selectedLabelTextStyle: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tokens.kineticAccent,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: tokens.textSecondary,
                    ),
                    labelType: NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: Text('TODAY'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.fitness_center_outlined),
                        selectedIcon: Icon(Icons.fitness_center),
                        label: Text('TRAIN'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.restaurant_outlined),
                        selectedIcon: Icon(Icons.restaurant),
                        label: Text('FUEL'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.show_chart_outlined),
                        selectedIcon: Icon(Icons.show_chart),
                        label: Text('PROGRESS'),
                      ),
                    ],

                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: navigationShell,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: tokens.panel,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacings.radiusXl),
                ),
                border: Border(
                  top: BorderSide(
                    color: tokens.borderSubtle,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: tokens.isDark ? 0.35 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacings.radiusXl),
                ),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: (index) {
                    if (index != currentIndex) {
                      AppHaptics.shared.selectionChanged();
                      navigationShell.goBranch(
                        index,
                        initialLocation: index == navigationShell.currentIndex,
                      );
                    }
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: tokens.kineticAccent,
                  unselectedItemColor: tokens.textSecondary,
                  selectedLabelStyle: const TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home),
                      label: 'TODAY',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.fitness_center_outlined),
                      activeIcon: Icon(Icons.fitness_center),
                      label: 'TRAIN',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.restaurant_outlined),
                      activeIcon: Icon(Icons.restaurant),
                      label: 'FUEL',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.show_chart_outlined),
                      activeIcon: Icon(Icons.show_chart),
                      label: 'PROGRESS',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/onboarding/data/user_profile_storage.dart';

/// Monolithic Sci-Fi Splash screen that verifies authentication and onboarding telemetry
/// before routing the operator to the appropriate interface.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;

    // Small delay to allow the Monolithic branding and state check to initialize cleanly
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final currentUri = GoRouter.of(context).routerDelegate.currentConfiguration.uri;
    if (currentUri.path != AppRoutes.splash) {
      return;
    }

    final authState = ref.read(authNotifierProvider);
    final userId = authState.user?.id;
    final isOnboarded = UserProfileStorage().isOnboardedSync(userId: userId);

    if (!authState.isAuthenticated) {
      context.go(AppRoutes.login);
    } else if (!isOnboarded) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Brand Logo Icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final glow = _pulseAnimation.value;
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.radiusLg),
                        border: Border.all(
                          color: tokens.kineticAccent.withValues(
                            alpha: 0.3 + (glow * 0.3),
                          ),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.kineticAccent.withValues(
                              alpha: 0.10 * glow,
                            ),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.fitness_center_rounded,
                        size: 48,
                        color: tokens.kineticAccent,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 28),

                // Brand Name
                Text(
                  'IRONFLOW',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: tokens.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'STRENGTH & WORKOUT TRACKER',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: tokens.textMuted,
                  ),
                ),

                const Spacer(),

                // Loading Bar
                SizedBox(
                  width: 160,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
                        child: LinearProgressIndicator(
                          minHeight: 3,
                          backgroundColor: tokens.panel,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            tokens.kineticAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading...',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: tokens.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

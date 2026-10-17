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

    final authState = ref.read(authNotifierProvider);
    final isOnboarded = UserProfileStorage().isOnboardedSync();

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

                // Monolithic Sci-Fi Logo Icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final glow = _pulseAnimation.value;
                    return Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.radiusLg),
                        border: Border.all(
                          color: tokens.kineticAccent.withValues(
                            alpha: 0.3 + (glow * 0.4),
                          ),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.kineticAccent.withValues(
                              alpha: 0.12 * glow,
                            ),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Corner bracket accents
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: tokens.kineticAccent, width: 1.5),
                                  left: BorderSide(color: tokens.kineticAccent, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: tokens.kineticAccent, width: 1.5),
                                  right: BorderSide(color: tokens.kineticAccent, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 52,
                            color: tokens.kineticAccent,
                          ),
                        ],
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
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                    color: tokens.textPrimary,
                  ),
                ),

                const SizedBox(height: 8),

                // Protocol subtitle
                Text(
                  'BIOMETRIC TELEMETRY & TRAINING SYSTEM',
                  style: TextStyle(
                    fontFamily: AppTypography.displayFontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: tokens.textMuted,
                  ),
                ),

                const Spacer(),

                // Futuristic Loading Bar
                SizedBox(
                  width: 180,
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
                        '// INITIALIZING TERMINAL',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
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

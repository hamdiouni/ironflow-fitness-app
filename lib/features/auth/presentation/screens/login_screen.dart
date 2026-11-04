import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/shared/presentation/components/components.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

/// Stripe Design System Authentication Screen.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isProcessingGoogleSignIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDemoCredentials() {
    AppHaptics.shared.buttonPress();
    setState(() {
      _emailController.text = 'demo@ironflow.com';
      _passwordController.text = 'password123';
    });
  }

  String _resolvePostLoginRoute() {
    try {
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      return AppRoutes.resolvePostAuthRedirect(from);
    } catch (_) {
      return AppRoutes.home;
    }
  }

  String _withFromQuery(String baseRoute) {
    try {
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      if (from != null && from.isNotEmpty) {
        return Uri(path: baseRoute, queryParameters: {'from': from}).toString();
      }
    } catch (_) {}
    return baseRoute;
  }

  Future<void> _handleEmailSignIn() async {
    if (_isProcessingGoogleSignIn) return;
    if (!_formKey.currentState!.validate()) return;

    AppHaptics.shared.buttonPress();

    try {
      await ref.read(authNotifierProvider.notifier).signInWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;
      final isOnboarded = await ref.read(isOnboardedProvider.future);
      if (!mounted) return;
      if (isOnboarded) {
        context.go(_resolvePostLoginRoute());
      } else {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Login] Email sign-in failed: $e');
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    _isProcessingGoogleSignIn = true;
    AppHaptics.shared.selectionChanged();

    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();

      if (!mounted) return;
      final isOnboarded = await ref.read(isOnboardedProvider.future);
      if (!mounted) return;
      if (isOnboarded) {
        context.go(_resolvePostLoginRoute());
      } else {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Login] Google Sign-In failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingGoogleSignIn = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final tokens = AppThemeTokens.of(context);

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // Top Telemetry Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: tokens.kineticAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Sign In',
                                style: TextStyle(
                                  fontFamily: AppTypography.displayFontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: tokens.kineticAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(tokens.radiusPill),
                            ),
                            child: Text(
                              'Secure',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: tokens.kineticAccent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Stripe Signature Mesh Hero Badge
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(tokens.radiusLg),
                          child: StripeMeshBackdrop(
                            height: 88,
                            child: Center(
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: tokens.panel,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: tokens.kineticAccent.withValues(alpha: 0.5),
                                    width: 1.5,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x1F003770),
                                      blurRadius: 16,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.shield_rounded,
                                  size: 30,
                                  color: tokens.kineticAccent,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: tokens.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Sign in to access your workout plan, nutrition, and progress.',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 13,
                          color: tokens.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 28),

                      // Error Banner
                      if (authState.error != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: tokens.error.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(tokens.radiusPill),
                            border: Border.all(
                              color: tokens.error.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: tokens.error, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  authState.error!,
                                  style: TextStyle(
                                    fontFamily: AppTypography.bodyFontFamily,
                                    fontSize: 12,
                                    color: tokens.error,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // Form Soft Layered Card
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: tokens.panel,
                          borderRadius: BorderRadius.circular(tokens.radiusLg),
                          border: Border.all(color: tokens.borderSubtle, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: tokens.isDark ? 0.25 : 0.06),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email Field
                            Text(
                              'Email Address',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                color: tokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.email],
                              enabled: !authState.isLoading,
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 14,
                                color: tokens.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: 'you@example.com',
                                hintStyle: TextStyle(
                                  fontFamily: AppTypography.bodyFontFamily,
                                  fontSize: 13,
                                  color: tokens.textMuted.withValues(alpha: 0.6),
                                ),
                                prefixIcon: Icon(
                                  Icons.alternate_email_rounded,
                                  size: 18,
                                  color: tokens.kineticAccent,
                                ),
                                filled: true,
                                fillColor: tokens.elevated,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  borderSide: BorderSide(color: tokens.error, width: 1),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  borderSide: BorderSide(color: tokens.error, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!value.contains('@') || !value.contains('.')) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // Password Field
                            Text(
                              'Password',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                                color: tokens.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [AutofillHints.password],
                              onFieldSubmitted: (_) => _handleEmailSignIn(),
                              enabled: !authState.isLoading,
                              style: TextStyle(
                                fontFamily: AppTypography.bodyFontFamily,
                                fontSize: 14,
                                color: tokens.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                hintStyle: TextStyle(
                                  fontFamily: AppTypography.bodyFontFamily,
                                  fontSize: 13,
                                  color: tokens.textMuted.withValues(alpha: 0.6),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  size: 18,
                                  color: tokens.kineticAccent,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 18,
                                    color: tokens.textMuted,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: tokens.elevated,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  borderSide: BorderSide(color: tokens.error, width: 1),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  borderSide: BorderSide(color: tokens.error, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 14),

                            // Demo Credentials Auto-Fill Pill
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: _fillDemoCredentials,
                                borderRadius: BorderRadius.circular(tokens.radiusPill),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: tokens.kineticAccent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(tokens.radiusPill),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.auto_fix_high_rounded,
                                        size: 14,
                                        color: tokens.kineticAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Fill Demo Account',
                                        style: TextStyle(
                                          fontFamily: AppTypography.displayFontFamily,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: tokens.kineticAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Action Button
                      AppButton(
                        label: 'Log In',
                        variant: AppButtonVariant.primary,
                        isLoading: authState.isLoading,
                        isFullWidth: true,
                        onPressed: authState.isLoading ? null : _handleEmailSignIn,
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: tokens.borderSubtle, height: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'OR CONTINUE WITH',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: tokens.textMuted,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: tokens.borderSubtle, height: 1)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Google Sign-In Button
                      AppButton(
                        label: 'Continue with Google',
                        variant: AppButtonVariant.secondary,
                        isLoading: _isProcessingGoogleSignIn,
                        isFullWidth: true,
                        icon: Icon(
                          Icons.g_mobiledata_rounded,
                          size: 24,
                          color: tokens.kineticAccent,
                        ),
                        onPressed: (_isProcessingGoogleSignIn || authState.isLoading)
                            ? null
                            : _handleGoogleSignIn,
                      ),

                      const SizedBox(height: 12),

                      AppButton(
                        label: 'Explore Demo Account',
                        variant: AppButtonVariant.ghost,
                        isFullWidth: true,
                        icon: Icon(
                          Icons.auto_awesome_rounded,
                          size: 18,
                          color: tokens.kineticAccent,
                        ),
                        onPressed: authState.isLoading
                            ? null
                            : () async {
                                _fillDemoCredentials();
                                await _handleEmailSignIn();
                              },
                      ),

                      const SizedBox(height: 28),

                      // Sign-up Link
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 13,
                              color: tokens.textSecondary,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              AppHaptics.shared.selectionChanged();
                              context.go(_withFromQuery(AppRoutes.signup));
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontFamily: AppTypography.displayFontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: tokens.kineticAccent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

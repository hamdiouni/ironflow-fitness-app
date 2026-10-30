import 'package:progression_tracker/core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

/// Monolithic Sci-Fi Operator Authentication Screen.
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
                      const SizedBox(height: 24),

                      // Brand Icon Badge
                      Center(
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: tokens.panel,
                            borderRadius: BorderRadius.circular(tokens.radiusMd),
                            border: Border.all(
                              color: tokens.kineticAccent.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.fitness_center_rounded,
                            size: 34,
                            color: tokens.kineticAccent,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          color: tokens.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Sign in to access your workout plan, nutrition, and progress',
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
                        color: tokens.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(tokens.radiusSm),
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

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: tokens.panel,
                      borderRadius: BorderRadius.circular(tokens.radiusMd),
                      border: Border.all(color: tokens.borderSubtle, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Field
                        Text(
                          'EMAIL ADDRESS',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: tokens.textMuted,
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
                              color: tokens.textMuted.withValues(alpha: 0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.alternate_email_rounded,
                              size: 18,
                              color: tokens.kineticAccent,
                            ),
                            filled: true,
                            fillColor: tokens.card,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                              borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                              borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                              borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                              borderSide: BorderSide(color: tokens.error, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
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
                          'PASSWORD',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                            color: tokens.textMuted,
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
                              color: tokens.textMuted.withValues(alpha: 0.5),
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
                            fillColor: tokens.card,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                              borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                              borderSide: BorderSide(color: tokens.borderSubtle, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                              borderSide: BorderSide(color: tokens.kineticAccent, width: 1.5),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
                              borderSide: BorderSide(color: tokens.error, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens.radiusSm),
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

                        // Demo Credentials Auto-Fill Chip
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: _fillDemoCredentials,
                            borderRadius: BorderRadius.circular(tokens.radiusSm),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_fix_high_rounded,
                                    size: 13,
                                    color: tokens.kineticAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'AUTOFILL DEMO ACCOUNT',
                                    style: TextStyle(
                                      fontFamily: AppTypography.displayFontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
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
                    label: 'Sign In',
                    variant: AppButtonVariant.primary,
                    size: AppButtonSize.large,
                    isLoading: authState.isLoading,
                    isFullWidth: true,
                    onPressed: authState.isLoading ? null : _handleEmailSignIn,
                  ),

                  const SizedBox(height: 18),

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
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: tokens.textMuted,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: tokens.borderSubtle, height: 1)),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Google Sign-In Button
                  AppButton(
                    label: 'Continue with Google',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.large,
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

                  const SizedBox(height: 28),

                  // Sign-up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
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

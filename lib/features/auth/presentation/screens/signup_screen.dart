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

/// Monolithic Sci-Fi Operator Registration Screen.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isProcessingGoogleSignIn = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _resolvePostSignUpRoute() {
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

  Future<void> _handleSignUp() async {
    if (_isProcessingGoogleSignIn) return;
    if (!_formKey.currentState!.validate()) return;

    AppHaptics.shared.buttonPress();

    try {
      await ref.read(authNotifierProvider.notifier).signUpWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );

      if (!mounted) return;
      final isOnboarded = await ref.read(isOnboardedProvider.future);
      if (!mounted) return;
      if (isOnboarded) {
        context.go(_resolvePostSignUpRoute());
      } else {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Signup] Sign up error: $e');
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
        context.go(_resolvePostSignUpRoute());
      } else {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('❌ [Signup] Google sign in error: $e');
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
      appBar: AppBar(
        backgroundColor: tokens.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back to Authentication',
          onPressed: () {
            AppHaptics.shared.selectionChanged();
            context.go(_withFromQuery(AppRoutes.login));
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CREATE ACCOUNT',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              'START YOUR FITNESS JOURNEY',
              style: TextStyle(
                fontFamily: AppTypography.displayFontFamily,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: tokens.textMuted,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Monolithic Header & Icon Badge
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: tokens.panel,
                        borderRadius: BorderRadius.circular(tokens.radiusMd),
                        border: Border.all(
                          color: tokens.kineticAccent.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.kineticAccent.withValues(alpha: 0.08),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: tokens.kineticAccent, width: 1.2),
                                  left: BorderSide(color: tokens.kineticAccent, width: 1.2),
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.person_add_alt_1_outlined,
                            size: 36,
                            color: tokens.kineticAccent,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'INITIALIZE IDENTITY',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: tokens.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Establish new biometric telemetry profile and training data records',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
                      color: tokens.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

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
                        // Full Name
                        Text(
                          'YOUR FULL NAME',
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
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.name],
                          enabled: !authState.isLoading,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 14,
                            color: tokens.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Alex Morgan',
                            hintStyle: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 13,
                              color: tokens.textMuted.withValues(alpha: 0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
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
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

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

                        const SizedBox(height: 16),

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
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.newPassword],
                          enabled: !authState.isLoading,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 14,
                            color: tokens.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'At least 6 characters',
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

                        const SizedBox(height: 16),

                        // Confirm Password
                        Text(
                          'CONFIRM PASSWORD',
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
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignUp(),
                          enabled: !authState.isLoading,
                          style: TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 14,
                            color: tokens.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Re-enter password',
                            hintStyle: TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 13,
                              color: tokens.textMuted.withValues(alpha: 0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.lock_reset_rounded,
                              size: 18,
                              color: tokens.kineticAccent,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 18,
                                color: tokens.textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
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
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  AppButton(
                    label: 'CREATE ACCOUNT',
                    variant: AppButtonVariant.primary,
                    isLoading: authState.isLoading,
                    isFullWidth: true,
                    onPressed: authState.isLoading ? null : _handleSignUp,
                  ),

                  const SizedBox(height: 18),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: tokens.borderSubtle, height: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'OR SIGN UP WITH',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
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
                    label: 'CONTINUE WITH GOOGLE',
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

                  const SizedBox(height: 28),

                  // Back to Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ALREADY HAVE AN ACCOUNT? ',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12,
                          color: tokens.textSecondary,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          AppHaptics.shared.selectionChanged();
                          context.go(_withFromQuery(AppRoutes.login));
                        },
                        child: Text(
                          'LOG IN',
                          style: TextStyle(
                            fontFamily: AppTypography.displayFontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
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
    );
  }
}

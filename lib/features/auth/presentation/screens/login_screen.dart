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
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Login] Email sign-in failed: $e');
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
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.onboarding);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Login] Google Sign-In failed: $e');
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
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: tokens.kineticAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'OPERATOR AUTHENTICATION',
                            style: TextStyle(
                              fontFamily: AppTypography.displayFontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                              color: tokens.textMuted,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'NODE // 01',
                        style: TextStyle(
                          fontFamily: AppTypography.displayFontFamily,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: tokens.kineticAccent.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Monolithic Header & Icon Badge
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
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
                            Icons.shield_outlined,
                            size: 38,
                            color: tokens.kineticAccent,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'TERMINAL ACCESS',
                    style: TextStyle(
                      fontFamily: AppTypography.displayFontFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: tokens.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Authenticate operator credentials to decrypt telemetry records',
                    style: TextStyle(
                      fontFamily: AppTypography.bodyFontFamily,
                      fontSize: 12,
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
                          'OPERATOR IDENTIFIER',
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
                            hintText: 'operator@ironflow.com',
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
                              return 'Operator identifier is required';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Enter a valid communication address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Password Field
                        Text(
                          'SECURITY CIPHER',
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
                              return 'Security cipher is required';
                            }
                            if (value.length < 6) {
                              return 'Cipher must be at least 6 characters';
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
                                    'AUTOFILL DEMO CREDENTIALS',
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
                    label: 'AUTHENTICATE OPERATOR',
                    variant: AppButtonVariant.primary,
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
                          'OR EXTERNAL FEDERATION',
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

                  // Sign-up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'NEW OPERATOR? ',
                        style: TextStyle(
                          fontFamily: AppTypography.bodyFontFamily,
                          fontSize: 12,
                          color: tokens.textSecondary,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          AppHaptics.shared.selectionChanged();
                          context.go(AppRoutes.signup);
                        },
                        child: Text(
                          'INITIALIZE PROTOCOL',
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

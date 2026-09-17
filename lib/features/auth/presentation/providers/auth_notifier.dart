import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:progression_tracker/core/providers/analytics_provider.dart';

/// Auth state
class AuthState {
  final bool isLoading;
  final User? user;
  final String? error;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.error,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? error,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final SignUpUseCase _signUpUseCase;
  final SignInUseCase _signInUseCase;
  final SignOutUseCase _signOutUseCase;
  final Ref _ref;

  AuthNotifier({
    required SignUpUseCase signUpUseCase,
    required SignInUseCase signInUseCase,
    required SignOutUseCase signOutUseCase,
    required Ref ref,
  })  : _signUpUseCase = signUpUseCase,
        _signInUseCase = signInUseCase,
        _signOutUseCase = signOutUseCase,
        _ref = ref,
        super(const AuthState()) {
    // Check for existing session on initialization
    _checkExistingSession();
  }

  /// Check for existing session on app start
  Future<void> _checkExistingSession() async {
    if (kDebugMode) {
      print('📊 [Auth] Checking for existing session...');
    }

    try {
      // Try to get current user from repository (which checks session storage)
      final user = await _signInUseCase.repository.getCurrentUser();

      if (user != null) {
        if (kDebugMode) {
          print('✅ [Auth] Found existing session');
          print('🔍 [Auth] User ID: ${_sanitizeUserId(user.id)}');
        }

        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          isLoading: false,
        );
      } else {
        if (kDebugMode) {
          print('📊 [Auth] No existing session found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [Auth] Error checking session: $e');
      }
      // Don't set error state, just continue as unauthenticated
    }
  }

  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('📊 [Auth] Starting sign up...');
      print('🔍 [Auth] Email domain: ${_sanitizeEmail(email)}');
    }

    state = state.copyWith(isLoading: true, error: null);
    if (kDebugMode) {
      print('📊 [Auth] State set to loading');
    }

    try {
      final user = await _signUpUseCase.call(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ [Auth] Sign up successful');
        print('🔍 [Auth] User ID: ${_sanitizeUserId(user.id)}');
      }

      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
      );
      
      // Track sign up event
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logSignUp('email');
        if (kDebugMode) {
          print('📊 [Analytics] Sign up event logged');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [Analytics] Failed to log sign up event: $e');
        }
      }
      
      if (kDebugMode) {
        print('✅ [Auth] State set to authenticated');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Auth] Sign up failed: $e');
        print('🔍 [Auth] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(
        isLoading: false,
        error: _getUserFriendlyError(e.toString()),
      );
      
      if (kDebugMode) {
        print('📊 [Auth] State set to error');
      }
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (kDebugMode) {
      print('📊 [Auth] Starting sign in...');
      print('🔍 [Auth] Email domain: ${_sanitizeEmail(email)}');
    }

    state = state.copyWith(isLoading: true, error: null);
    if (kDebugMode) {
      print('📊 [Auth] State set to loading');
    }

    try {
      final user = await _signInUseCase.call(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ [Auth] Sign in successful');
        print('🔍 [Auth] User ID: ${_sanitizeUserId(user.id)}');
      }

      state = state.copyWith(
        isLoading: false,
        user: user,
        isAuthenticated: true,
        error: null,
      );
      
      // Track login event
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logLogin('email');
        if (kDebugMode) {
          print('📊 [Analytics] Login event logged');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [Analytics] Failed to log login event: $e');
        }
      }
      
      if (kDebugMode) {
        print('✅ [Auth] State set to authenticated');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Auth] Sign in failed: $e');
        print('🔍 [Auth] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(
        isLoading: false,
        error: _getUserFriendlyError(e.toString()),
      );
      
      if (kDebugMode) {
        print('📊 [Auth] State set to error');
      }
      rethrow;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    if (kDebugMode) {
      print('📊 [Auth] Starting Google sign in...');
    }

    state = state.copyWith(isLoading: true, error: null);
    if (kDebugMode) {
      print('📊 [Auth] State set to loading');
    }

    try {
      // Use repository directly for Google sign in
      final user = await _signInUseCase.repository.signInWithGoogle();

      if (user != null) {
        if (kDebugMode) {
          print('✅ [Auth] Google sign in successful');
          print('🔍 [Auth] User ID: ${_sanitizeUserId(user.id)}');
        }

        state = state.copyWith(
          isLoading: false,
          user: user,
          isAuthenticated: true,
          error: null,
        );
        
        // Track login event
        try {
          final analytics = _ref.read(analyticsServiceProvider);
          await analytics.logLogin('google');
          if (kDebugMode) {
            print('📊 [Analytics] Google login event logged');
          }
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ [Analytics] Failed to log login event: $e');
          }
        }
        
        if (kDebugMode) {
          print('✅ [Auth] State set to authenticated');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ [Auth] Google sign in returned null user (cancelled)');
        }
        
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: null, // Don't show error if user cancelled
        );
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Auth] Google sign in failed: $e');
        print('🔍 [Auth] Stack trace: $stackTrace');
      }
      
      // Check if error is due to user cancellation
      final errorMessage = e.toString().toLowerCase();
      final isCancelled = errorMessage.contains('cancel') || 
                         errorMessage.contains('abort') ||
                         errorMessage.contains('user');
      
      state = state.copyWith(
        isLoading: false,
        error: isCancelled ? null : _getUserFriendlyError(e.toString()),
      );
      
      if (kDebugMode) {
        if (isCancelled) {
          print('📊 [Auth] User cancelled Google sign in');
        } else {
          print('📊 [Auth] State set to error');
        }
      }
      
      // Only rethrow if not cancelled
      if (!isCancelled) {
        rethrow;
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (kDebugMode) {
      print('📊 [Auth] Starting sign out...');
      if (state.user != null) {
        print('🔍 [Auth] Current user ID: ${_sanitizeUserId(state.user!.id)}');
      }
    }

    state = state.copyWith(isLoading: true, error: null);
    if (kDebugMode) {
      print('📊 [Auth] State set to loading');
    }

    try {
      await _signOutUseCase.call();

      if (kDebugMode) {
        print('✅ [Auth] Sign out successful');
      }

      state = const AuthState(
        isLoading: false,
        user: null,
        isAuthenticated: false,
        error: null,
      );
      
      // Track logout event
      try {
        final analytics = _ref.read(analyticsServiceProvider);
        await analytics.logLogout();
        if (kDebugMode) {
          print('📊 [Analytics] Logout event logged');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ [Analytics] Failed to log logout event: $e');
        }
      }
      
      if (kDebugMode) {
        print('✅ [Auth] State set to unauthenticated');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [Auth] Sign out failed: $e');
        print('🔍 [Auth] Stack trace: $stackTrace');
      }
      
      state = state.copyWith(
        isLoading: false,
        error: _getUserFriendlyError(e.toString()),
      );
      
      if (kDebugMode) {
        print('📊 [Auth] State set to error');
      }
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyError(String error) {
    if (error.contains('weak-password') || error.contains('too weak')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (error.contains('email-already-in-use') || error.contains('already exists')) {
      return 'This email is already registered. Try logging in instead.';
    } else if (error.contains('invalid-email') || error.contains('not valid')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('user-not-found') || error.contains('No user found')) {
      return 'No account found with this email. Please sign up first.';
    } else if (error.contains('wrong-password') || error.contains('Wrong password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('cancelled')) {
      return 'Sign in was cancelled.';
    } else if (error.contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (error.contains('Google Sign-In') || error.contains('not configured')) {
      return 'Google Sign-In is not available yet. Please use email/password.';
    } else if (error.contains('Apple Sign-In')) {
      return 'Apple Sign-In is not available yet. Please use email/password.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }

  /// Sanitize email address for logging (show only domain)
  String _sanitizeEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '[invalid-email]';
    return '***@${parts[1]}';
  }

  /// Sanitize user ID for logging (show only first/last chars)
  String _sanitizeUserId(String userId) {
    if (userId.length < 8) return '[id]';
    return '${userId.substring(0, 4)}...${userId.substring(userId.length - 4)}';
  }
}

/// Auth notifier provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    signInUseCase: ref.watch(signInUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    ref: ref,
  );
});

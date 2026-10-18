import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../repositories/remote_data_purger.dart';
import '../services/local_data_wiper.dart';

class DeleteAccountResult {
  final bool success;
  final String message;
  final bool requiresRecentLogin;

  const DeleteAccountResult({
    required this.success,
    required this.message,
    this.requiresRecentLogin = false,
  });

  factory DeleteAccountResult.success() => const DeleteAccountResult(
        success: true,
        message: 'Account and all associated telemetry have been permanently deleted.',
      );

  factory DeleteAccountResult.failure(String message, {bool requiresRecentLogin = false}) =>
      DeleteAccountResult(
        success: false,
        message: message,
        requiresRecentLogin: requiresRecentLogin,
      );
}

/// Use case orchestrating permanent account deletion and complete data destruction.
///
/// Complies with Apple Store Guideline 5.1.1(v) and Google Play User Data policies:
/// 1. Verifies recent authentication credentials.
/// 2. Purges all remote cloud records via [RemoteDataPurger].
/// 3. Deletes the Firebase Auth account.
/// 4. Eradicates all local storage, Hive boxes, photos, and secure storage tokens via [LocalDataWiper].
/// 5. Ensures resilient crash-recovery via pending wipe marker.
class DeleteAccountUseCase {
  static const String pendingWipeKey = 'pending_local_wipe_user_id';

  final AuthRepository _authRepository;
  final RemoteDataPurger _remoteDataPurger;
  final LocalDataWiper _localDataWiper;

  DeleteAccountUseCase({
    required AuthRepository authRepository,
    required RemoteDataPurger remoteDataPurger,
    LocalDataWiper? localDataWiper,
  })  : _authRepository = authRepository,
        _remoteDataPurger = remoteDataPurger,
        _localDataWiper = localDataWiper ?? LocalDataWiper();

  /// Executes the full permanent deletion flow.
  ///
  /// Either [password] must be provided (for email/password accounts) or
  /// [isGoogleAuth] must be true (for federated Google accounts).
  Future<DeleteAccountResult> call({
    required String userId,
    String? password,
    bool isGoogleAuth = false,
  }) async {
    if (userId.trim().isEmpty) {
      return DeleteAccountResult.failure('Cannot delete account: Missing user ID.');
    }

    // --- STEP 1: RE-AUTHENTICATION ---
    try {
      if (password != null && password.isNotEmpty) {
        await _authRepository.reauthenticateWithPassword(password);
      } else if (isGoogleAuth) {
        await _authRepository.reauthenticateWithGoogle();
      }
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      final isRecentLoginNeeded = errorStr.contains('requires-recent-login') ||
          errorStr.contains('recent-login') ||
          errorStr.contains('sensitive-operation');

      if (kDebugMode) {
        print('❌ [DeleteAccountUseCase] Re-authentication failed: $e');
      }
      return DeleteAccountResult.failure(
        'Authentication verification failed: ${e.toString().replaceAll('Exception: ', '')}',
        requiresRecentLogin: isRecentLoginNeeded,
      );
    }

    // --- STEP 2: REMOTE PURGE ---
    try {
      await _remoteDataPurger.purgeRemoteUserData(userId);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [DeleteAccountUseCase] Remote purge failed: $e');
      }
      return DeleteAccountResult.failure(
        'Failed to purge cloud records. Account deletion aborted to protect data integrity: $e',
      );
    }

    // --- STEP 3: DELETE AUTHENTICATION ACCOUNT ---
    try {
      await _authRepository.deleteAccount();
    } catch (e) {
      final errorStr = e.toString().toLowerCase();
      final isRecentLoginNeeded = errorStr.contains('requires-recent-login') ||
          errorStr.contains('recent-login');

      if (kDebugMode) {
        print('❌ [DeleteAccountUseCase] Auth account deletion failed: $e');
      }
      return DeleteAccountResult.failure(
        'Failed to delete authentication user: $e',
        requiresRecentLogin: isRecentLoginNeeded,
      );
    }

    // --- STEP 4: PERSIST PENDING WIPE MARKER FOR CRASH RESILIENCE ---
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(pendingWipeKey, userId);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [DeleteAccountUseCase] Could not persist pending wipe marker: $e');
      }
    }

    // --- STEP 5: COMPREHENSIVE LOCAL WIPE ---
    try {
      await _localDataWiper.wipeAllUserData(userId, keepAuthSession: false);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [DeleteAccountUseCase] Local wipe encountered error: $e');
      }
      // Marker remains persisted so next app launch will retry and complete the wipe.
      return DeleteAccountResult.failure(
        'Account was deleted from servers, but some local files could not be removed: $e',
      );
    }

    // --- STEP 6: CLEAR PENDING WIPE MARKER ---
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(pendingWipeKey);
    } catch (_) {}

    // --- STEP 7: SIGN OUT SESSION ---
    try {
      await _authRepository.signOut();
    } catch (_) {}

    return DeleteAccountResult.success();
  }

  /// Checks for any interrupted wipe from previous sessions and finishes it.
  /// Called at app startup before rendering UI.
  static Future<void> checkAndExecutePendingWipe({LocalDataWiper? wiper}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingUserId = prefs.getString(pendingWipeKey);
      if (pendingUserId != null && pendingUserId.isNotEmpty) {
        if (kDebugMode) {
          print('🔄 [DeleteAccountUseCase] Found pending wipe marker for: $pendingUserId. Finishing wipe...');
        }
        final actualWiper = wiper ?? LocalDataWiper();
        await actualWiper.wipeAllUserData(pendingUserId, keepAuthSession: false);
        await prefs.remove(pendingWipeKey);
        if (kDebugMode) {
          print('✅ [DeleteAccountUseCase] Pending wipe completed successfully.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [DeleteAccountUseCase] Error executing pending wipe: $e');
      }
    }
  }
}

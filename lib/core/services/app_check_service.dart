import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_logger.dart';

/// Staged rollout mode for Firebase App Check (Wave 1 Step 7 — SEC-04).
enum AppCheckStage {
  /// Attestation tokens are requested and attached on a best-effort basis;
  /// backend services log metrics without rejecting unverified requests.
  monitor,

  /// Strict enforcement mode: backend services reject requests lacking a
  /// valid App Check token.
  enforce,
}

/// Manages Firebase App Check initialization and token retrieval across
/// Android (Play Integrity / debug), iOS (App Attest + DeviceCheck fallback / debug),
/// and Web (reCAPTCHA Enterprise / v3).
class AppCheckService {
  const AppCheckService._();

  static const String _recaptchaSiteKey = String.fromEnvironment(
    'RECAPTCHA_SITE_KEY',
    defaultValue: '',
  );

  static const bool _enforceAppCheckEnv = bool.fromEnvironment(
    'ENFORCE_APP_CHECK',
    defaultValue: false,
  );

  /// Active rollout stage (defaults to `monitor` in Wave 1 until Play Integrity,
  /// App Attest, and reCAPTCHA Enterprise keys are registered in Firebase Console).
  static AppCheckStage get currentStage =>
      _enforceAppCheckEnv ? AppCheckStage.enforce : AppCheckStage.monitor;

  /// Pure policy helper returning the Android provider for the given build mode.
  static AndroidProvider resolveAndroidProvider({required bool isReleaseMode}) {
    return isReleaseMode
        ? AndroidProvider.playIntegrity
        : AndroidProvider.debug;
  }

  /// Pure policy helper returning the Apple provider for the given build mode.
  static AppleProvider resolveAppleProvider({required bool isReleaseMode}) {
    return isReleaseMode
        ? AppleProvider.appAttestWithDeviceCheckFallback
        : AppleProvider.debug;
  }

  /// Initializes Firebase App Check safely. Never throws or blocks cold boot
  /// if platform attestation is not yet enrolled in Firebase Console.
  static Future<void> initialize({
    bool isReleaseMode = kReleaseMode,
    String? webRecaptchaSiteKey,
  }) async {
    try {
      if (Firebase.apps.isEmpty) return;

      final siteKey = (webRecaptchaSiteKey ?? _recaptchaSiteKey).trim();
      if (kIsWeb && siteKey.isEmpty) {
        if (kDebugMode) {
          AppLogger.debug(
            'ℹ️ [AppCheck] Web RECAPTCHA_SITE_KEY not set; remaining in monitor mode.',
          );
        }
        return;
      }

      await FirebaseAppCheck.instance.activate(
        androidProvider: resolveAndroidProvider(isReleaseMode: isReleaseMode),
        appleProvider: resolveAppleProvider(isReleaseMode: isReleaseMode),
        webProvider: siteKey.isNotEmpty
            ? ReCaptchaEnterpriseProvider(siteKey)
            : null,
      );

      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);

      if (kDebugMode) {
        AppLogger.debug(
          '✓ [AppCheck] Activated in ${currentStage.name} mode',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.debug('⚠️ [AppCheck] Initialization note (staged monitor): $e');
      }
    }
  }

  /// Retrieves a current App Check token to attach as `X-Firebase-AppCheck`
  /// on custom HTTPS proxy requests. Returns `null` if unavailable.
  static Future<String?> getToken({bool forceRefresh = false}) async {
    try {
      if (Firebase.apps.isEmpty) return null;
      return await FirebaseAppCheck.instance.getToken(forceRefresh);
    } catch (_) {
      return null;
    }
  }
}


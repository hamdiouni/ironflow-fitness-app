import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/telemetry_preferences.dart';
import '../../../ai/data/repositories/ai_preferences_repository_impl.dart';
import '../../domain/repositories/privacy_preferences_repository.dart';

/// [SharedPreferences]-backed implementation of [PrivacyPreferencesRepository].
class PrivacyPreferencesRepositoryImpl implements PrivacyPreferencesRepository {
  static const String dataSharingEnabledKey = 'data_sharing_enabled';

  @override
  Future<PrivacySettingsSnapshot> loadSettings({
    required String userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final aiConsent = await AIPreferencesRepositoryImpl.loadStoredConsentFromPrefs(
      prefs,
      userId: userId,
    );
    return PrivacySettingsSnapshot(
      analyticsEnabled:
          prefs.getBool(TelemetryPreferences.analyticsEnabledKey) ?? false,
      crashReportingEnabled:
          prefs.getBool(TelemetryPreferences.crashReportingEnabledKey) ?? false,
      dataSharingEnabled: prefs.getBool(dataSharingEnabledKey) ?? false,
      aiPersonalizationConsent: aiConsent,
      hasRecordedTelemetryConsent:
          prefs.getBool(TelemetryPreferences.consentPromptShownKey) ?? false,
    );
  }

  @override
  Future<void> saveSettings({
    required String userId,
    required bool analyticsEnabled,
    required bool crashReportingEnabled,
    required bool dataSharingEnabled,
    required bool aiPersonalizationConsent,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
      TelemetryPreferences.analyticsEnabledKey,
      analyticsEnabled,
    );
    await prefs.setBool(
      TelemetryPreferences.crashReportingEnabledKey,
      crashReportingEnabled,
    );
    await prefs.setBool(dataSharingEnabledKey, dataSharingEnabled);
    await prefs.setBool(
      AIPreferencesRepositoryImpl.consentKeyForUser(userId),
      aiPersonalizationConsent,
    );
    await prefs.setBool(TelemetryPreferences.consentPromptShownKey, true);

    // Push Analytics and Crashlytics choices into Firebase SDKs immediately.
    await TelemetryPreferences.applyStoredPreferences(prefs: prefs);
  }
}


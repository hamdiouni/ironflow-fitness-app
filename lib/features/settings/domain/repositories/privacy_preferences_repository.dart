/// Snapshot of stored privacy & telemetry preferences for the active user.
class PrivacySettingsSnapshot {
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool dataSharingEnabled;
  final bool aiPersonalizationConsent;
  final bool hasRecordedTelemetryConsent;

  const PrivacySettingsSnapshot({
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.dataSharingEnabled,
    required this.aiPersonalizationConsent,
    required this.hasRecordedTelemetryConsent,
  });
}

/// Repository interface isolating privacy & telemetry storage from UI screens.
abstract class PrivacyPreferencesRepository {
  Future<PrivacySettingsSnapshot> loadSettings({required String userId});

  Future<void> saveSettings({
    required String userId,
    required bool analyticsEnabled,
    required bool crashReportingEnabled,
    required bool dataSharingEnabled,
    required bool aiPersonalizationConsent,
  });
}


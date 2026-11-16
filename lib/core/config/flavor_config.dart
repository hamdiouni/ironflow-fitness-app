import 'package:flutter/foundation.dart';

/// Supported application flavors (`dev`, `staging`, `production`).
enum AppFlavor {
  dev,
  staging,
  production;

  /// Parses a raw flavor string (`dev`, `staging`, `prod`, `production`).
  ///
  /// Defaults to [AppFlavor.production] when [isReleaseMode] is true and
  /// [AppFlavor.dev] in debug/test mode so unconfigured release builds always
  /// fail closed into production security rules.
  static AppFlavor parse(
    String raw, {
    bool isReleaseMode = kReleaseMode,
  }) {
    final normalized = raw.trim().toLowerCase();
    switch (normalized) {
      case 'dev':
      case 'development':
        return isReleaseMode ? AppFlavor.production : AppFlavor.dev;
      case 'staging':
      case 'stage':
        return AppFlavor.staging;
      case 'prod':
      case 'production':
        return AppFlavor.production;
      default:
        return isReleaseMode ? AppFlavor.production : AppFlavor.dev;
    }
  }
}

/// Immutable flavor configuration resolved from `--dart-define-from-file`
/// (`config/dev.json`, `config/staging.json`, `config/production.json`).
///
/// Guarantees:
/// - No production credentials or endpoints in `dev`.
/// - Release builds (`isReleaseMode == true`) never resolve to `dev` and
///   never permit direct client-side AI API keys or mock authentication.
@immutable
class FlavorConfig {
  const FlavorConfig({
    required this.flavor,
    required this.appName,
    required this.applicationId,
    required this.appIdSuffix,
    required this.iconVariant,
    required this.firebaseProjectId,
    required this.aiProxyUrl,
    required this.appCheckEnforce,
    required this.enableCloudSync,
    required this.useFirebaseAuth,
    required this.allowDirectAiKeys,
  });

  final AppFlavor flavor;
  final String appName;
  final String applicationId;
  final String appIdSuffix;
  final String iconVariant;
  final String firebaseProjectId;
  final String aiProxyUrl;
  final bool appCheckEnforce;
  final bool enableCloudSync;
  final bool useFirebaseAuth;
  final bool allowDirectAiKeys;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isStaging => flavor == AppFlavor.staging;
  bool get isProduction => flavor == AppFlavor.production;

  /// Whether a visible flavor banner (`DEV` / `STAGING`) should be shown.
  bool get showFlavorBanner => !isProduction;

  /// Resolves a [FlavorConfig] from explicit inputs or compile-time defines.
  factory FlavorConfig.resolve({
    String? rawFlavor,
    String? appName,
    String? applicationId,
    String? appIdSuffix,
    String? iconVariant,
    String? firebaseProjectId,
    String? aiProxyUrl,
    bool? appCheckEnforce,
    bool? enableCloudSync,
    bool? useFirebaseAuth,
    bool? allowDirectAiKeys,
    bool isReleaseMode = kReleaseMode,
  }) {
    final resolvedFlavor = AppFlavor.parse(
      rawFlavor ??
          const String.fromEnvironment(
            'FLAVOR',
            defaultValue: kReleaseMode ? 'production' : 'dev',
          ),
      isReleaseMode: isReleaseMode,
    );

    switch (resolvedFlavor) {
      case AppFlavor.dev:
        return FlavorConfig(
          flavor: AppFlavor.dev,
          appName: _nonEmpty(appName, const String.fromEnvironment('APP_NAME')) ??
              'IronFlow Dev',
          applicationId: _nonEmpty(
                applicationId,
                const String.fromEnvironment('APP_ID'),
              ) ??
              'com.progressiontracker.progression_tracker.dev',
          appIdSuffix: appIdSuffix ??
              const String.fromEnvironment(
                'APP_ID_SUFFIX',
                defaultValue: '.dev',
              ),
          iconVariant: _nonEmpty(
                iconVariant,
                const String.fromEnvironment('APP_ICON_VARIANT'),
              ) ??
              'dev',
          firebaseProjectId: _nonEmpty(
                firebaseProjectId,
                const String.fromEnvironment('FIREBASE_PROJECT_ID'),
              ) ??
              'ironflow-dev',
          aiProxyUrl: aiProxyUrl ??
              const String.fromEnvironment(
                'AI_PROXY_URL',
                defaultValue:
                    'http://127.0.0.1:5001/ironflow-dev/us-central1/aiGenerate',
              ),
          appCheckEnforce: appCheckEnforce ??
              const bool.fromEnvironment(
                'ENFORCE_APP_CHECK',
                defaultValue: false,
              ),
          enableCloudSync: enableCloudSync ??
              const bool.fromEnvironment(
                'ENABLE_CLOUD_SYNC',
                defaultValue: false,
              ),
          useFirebaseAuth: useFirebaseAuth ??
              const bool.fromEnvironment(
                'USE_FIREBASE_AUTH',
                defaultValue: false,
              ),
          allowDirectAiKeys: !isReleaseMode &&
              (allowDirectAiKeys ??
                  const bool.fromEnvironment(
                    'ALLOW_DIRECT_AI_KEYS',
                    defaultValue: true,
                  )),
        );

      case AppFlavor.staging:
        return FlavorConfig(
          flavor: AppFlavor.staging,
          appName: _nonEmpty(appName, const String.fromEnvironment('APP_NAME')) ??
              'IronFlow Staging',
          applicationId: _nonEmpty(
                applicationId,
                const String.fromEnvironment('APP_ID'),
              ) ??
              'com.progressiontracker.progression_tracker.staging',
          appIdSuffix: appIdSuffix ??
              const String.fromEnvironment(
                'APP_ID_SUFFIX',
                defaultValue: '.staging',
              ),
          iconVariant: _nonEmpty(
                iconVariant,
                const String.fromEnvironment('APP_ICON_VARIANT'),
              ) ??
              'staging',
          firebaseProjectId: _nonEmpty(
                firebaseProjectId,
                const String.fromEnvironment('FIREBASE_PROJECT_ID'),
              ) ??
              'ironflow-staging',
          aiProxyUrl: _nonEmpty(
                aiProxyUrl,
                const String.fromEnvironment('AI_PROXY_URL'),
              ) ??
              'https://us-central1-ironflow-staging.cloudfunctions.net/aiGenerate',
          appCheckEnforce: appCheckEnforce ??
              const bool.fromEnvironment(
                'ENFORCE_APP_CHECK',
                defaultValue: false,
              ),
          enableCloudSync: enableCloudSync ??
              const bool.fromEnvironment(
                'ENABLE_CLOUD_SYNC',
                defaultValue: true,
              ),
          useFirebaseAuth: true,
          allowDirectAiKeys: false,
        );

      case AppFlavor.production:
        return FlavorConfig(
          flavor: AppFlavor.production,
          appName: _nonEmpty(appName, const String.fromEnvironment('APP_NAME')) ??
              'IronFlow',
          applicationId: _nonEmpty(
                applicationId,
                const String.fromEnvironment('APP_ID'),
              ) ??
              'com.progressiontracker.progression_tracker',
          appIdSuffix: '',
          iconVariant: _nonEmpty(
                iconVariant,
                const String.fromEnvironment('APP_ICON_VARIANT'),
              ) ??
              'production',
          firebaseProjectId: _nonEmpty(
                firebaseProjectId,
                const String.fromEnvironment('FIREBASE_PROJECT_ID'),
              ) ??
              'ironflow-5b79d',
          aiProxyUrl: _nonEmpty(
                aiProxyUrl,
                const String.fromEnvironment('AI_PROXY_URL'),
              ) ??
              'https://us-central1-ironflow-5b79d.cloudfunctions.net/aiGenerate',
          appCheckEnforce: appCheckEnforce ??
              const bool.fromEnvironment(
                'ENFORCE_APP_CHECK',
                defaultValue: false,
              ),
          enableCloudSync: enableCloudSync ??
              const bool.fromEnvironment(
                'ENABLE_CLOUD_SYNC',
                defaultValue: true,
              ),
          useFirebaseAuth: true,
          allowDirectAiKeys: false,
        );
    }
  }

  /// Active compile-time flavor configuration.
  static final FlavorConfig current = FlavorConfig.resolve();

  static String? _nonEmpty(String? primary, String fallback) {
    if (primary != null && primary.trim().isNotEmpty) {
      return primary.trim();
    }
    if (fallback.trim().isNotEmpty) {
      return fallback.trim();
    }
    return null;
  }
}


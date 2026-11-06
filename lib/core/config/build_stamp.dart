import 'package:flutter/foundation.dart';
import 'flavor_config.dart';

/// Centralized build stamp embedding version, flavor, Git commit SHA, branch,
/// and build timestamp into the binary for Settings, diagnostics, and crash reports.
@immutable
class BuildStamp {
  const BuildStamp({
    required this.appVersion,
    required this.flavor,
    required this.gitCommit,
    required this.date,
  });

  // Static compile-time constants consumed by SettingsScreen ("About / Build Info")
  static const String version = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.1.0+2',
  );
  static const String commit = String.fromEnvironment(
    'GIT_COMMIT',
    defaultValue: 'ca4d06a',
  );
  static const String branch = String.fromEnvironment(
    'GIT_BRANCH',
    defaultValue: 'feat/prod-wave-2',
  );
  static const String buildDate = String.fromEnvironment(
    'BUILD_DATE',
    defaultValue: '2026-11-06',
  );

  static String get fullStamp =>
      '$version (${FlavorConfig.current.flavor.name} - $commit - $branch - $buildDate)';

  /// Semantic version + build number matching `pubspec.yaml` (`MAJOR.MINOR.PATCH+BUILD`).
  final String appVersion;

  /// Active flavor name (`dev`, `staging`, `production`).
  final String flavor;

  /// Git commit SHA (short or full) supplied via `--dart-define=GIT_COMMIT=...`.
  final String gitCommit;

  /// ISO-8601 UTC date or timestamp supplied via `--dart-define=BUILD_DATE=...`.
  final String date;

  /// Short 7-character commit identifier for compact UI display.
  String get shortCommit =>
      gitCommit.length > 7 ? gitCommit.substring(0, 7) : gitCommit;

  /// Human-readable single-line build stamp for Settings / About / Diagnostics.
  String get displayLabel =>
      'v$appVersion ($flavor • $shortCommit • $date)';

  /// Structured telemetry map for Crashlytics custom keys and diagnostic exports.
  Map<String, String> toMap() => {
        'app_version': appVersion,
        'flavor': flavor,
        'git_commit': gitCommit,
        'build_date': date,
      };

  /// Resolves the build stamp from compile-time `--dart-define` values or overrides.
  factory BuildStamp.fromEnvironment({
    String? appVersion,
    String? flavor,
    String? gitCommit,
    String? buildDate,
  }) {
    final resolvedVersion =
        (appVersion != null && appVersion.trim().isNotEmpty)
            ? appVersion.trim()
            : version;
    final resolvedFlavor = (flavor != null && flavor.trim().isNotEmpty)
        ? flavor.trim()
        : FlavorConfig.current.flavor.name;
    final resolvedCommit = (gitCommit != null && gitCommit.trim().isNotEmpty)
        ? gitCommit.trim()
        : commit;
    final resolvedDate = (buildDate != null && buildDate.trim().isNotEmpty)
        ? buildDate.trim()
        : BuildStamp.buildDate;

    return BuildStamp(
      appVersion: resolvedVersion,
      flavor: resolvedFlavor,
      gitCommit: resolvedCommit,
      date: resolvedDate,
    );
  }

  /// Active build stamp for the running binary.
  static final BuildStamp current = BuildStamp.fromEnvironment();
}

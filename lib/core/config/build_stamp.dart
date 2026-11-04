/// Centralized build stamp for runtime identification and verification.
class BuildStamp {
  const BuildStamp._();

  static const String version = String.fromEnvironment('APP_VERSION', defaultValue: '1.1.0+2');
  static const String commit = String.fromEnvironment('GIT_COMMIT', defaultValue: 'a0d01f7');
  static const String branch = String.fromEnvironment('GIT_BRANCH', defaultValue: 'feat/design-reset');
  static const String buildDate = String.fromEnvironment('BUILD_DATE', defaultValue: '2026-11-04');

  static String get fullStamp => '$version ($commit - $branch - $buildDate)';
}


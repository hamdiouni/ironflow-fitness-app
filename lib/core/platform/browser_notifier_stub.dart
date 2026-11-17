/// Thin bridge to the browser Notification API (Wave 8.1, ADR-004).
///
/// Non-web stub: every call is a safe no-op.
class BrowserNotifier {
  const BrowserNotifier();

  /// Whether the platform exposes the Notification API.
  bool get isSupported => false;

  /// `granted`, `denied`, `default`, or `unsupported`.
  String get permission => 'unsupported';

  /// Whether the page is currently hidden (background tab / minimized).
  bool get isPageHidden => false;

  /// Asks for permission. Must be called synchronously from a user gesture.
  Future<bool> requestPermission() async => false;

  /// Shows a notification replacing any earlier one with the same [tag].
  void show({
    required String title,
    required String body,
    required String tag,
  }) {}
}

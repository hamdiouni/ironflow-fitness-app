import 'dart:js_interop';
import 'dart:js_interop_unsafe';

/// Thin bridge to the browser Notification API (Wave 8.1, ADR-004).
///
/// Uses only the Dart SDK (`dart:js_interop`), no extra package. Every call
/// is guarded so a missing or blocked API never throws into the app.
class BrowserNotifier {
  const BrowserNotifier();

  JSObject? get _notificationClass {
    if (!globalContext.has('Notification')) return null;
    final value = globalContext['Notification'];
    return value.isA<JSObject>() ? value as JSObject : null;
  }

  bool get isSupported => _notificationClass != null;

  String get permission {
    final cls = _notificationClass;
    if (cls == null) return 'unsupported';
    final value = cls['permission'];
    return value.isA<JSString>() ? (value as JSString).toDart : 'default';
  }

  bool get isPageHidden {
    try {
      final document = globalContext['document'];
      if (!document.isA<JSObject>()) return false;
      final hidden = (document as JSObject)['hidden'];
      return hidden.isA<JSBoolean>() && (hidden as JSBoolean).toDart;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestPermission() async {
    final cls = _notificationClass;
    if (cls == null) return false;
    try {
      final promise = cls.callMethod<JSPromise<JSString>>(
        'requestPermission'.toJS,
      );
      final result = await promise.toDart;
      return result.toDart == 'granted';
    } catch (_) {
      return false;
    }
  }

  void show({
    required String title,
    required String body,
    required String tag,
  }) {
    final cls = _notificationClass;
    if (cls == null || permission != 'granted') return;
    try {
      final options = <String, Object?>{'body': body, 'tag': tag}.jsify();
      (cls as JSFunction).callAsConstructor<JSObject>(title.toJS, options);
    } catch (_) {
      // Notification blocked or unavailable; the in-app timer still works.
    }
  }
}

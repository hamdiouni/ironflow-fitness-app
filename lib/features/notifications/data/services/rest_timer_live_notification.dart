import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../../core/platform/browser_notifier.dart';
import '../../../workout/domain/services/rest_timer_live_surface.dart';

/// Platform that the rest timer live surface renders on.
enum RestTimerSurfacePlatform { android, web, other }

/// Minimal seam over `flutter_local_notifications` so the live surface can be
/// unit-tested without a platform channel.
abstract class LocalNotificationGateway {
  Future<void> show(
    int id,
    String title,
    String body,
    NotificationDetails details, {
    String? payload,
  });

  Future<void> cancel(int id);
}

/// Production gateway backed by the shared plugin instance that
/// `NotificationService.initialize` already set up (taps route to the same
/// handler).
class PluginLocalNotificationGateway implements LocalNotificationGateway {
  PluginLocalNotificationGateway([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> show(
    int id,
    String title,
    String body,
    NotificationDetails details, {
    String? payload,
  }) {
    return _plugin.show(id, title, body, details, payload: payload);
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id);
}

/// Lock-screen / browser mirror of the rest timer (Wave 8.1, ADR-004).
///
/// * **Android:** one silent ongoing notification with a system chronometer
///   counting down to the end time (`usesChronometer` +
///   `chronometerCountDown`), visible on the lock screen, removed by
///   `timeoutAfter` at the end time even if the app is killed. When the rest
///   ends while the app is in the background, an immediate heads-up
///   "Rest Complete!" alert is posted so the inexact scheduled alert cannot be
///   lost.
/// * **Web:** asks for Notification permission on the first rest start (a
///   user gesture) and shows a "Rest complete" notification only when the
///   tab is hidden. Works while the tab is open; browsers may delay timers
///   in background tabs.
/// * **iOS:** no live surface. A Live Activity needs a native widget
///   extension and Xcode on a Mac — NOT VERIFIED in this environment. The
///   existing scheduled completion alert still fires.
class RestTimerLiveNotification implements RestTimerLiveSurface {
  RestTimerLiveNotification({
    LocalNotificationGateway? gateway,
    BrowserNotifier browser = const BrowserNotifier(),
    RestTimerSurfacePlatform? platform,
    bool Function()? isAppInForeground,
    DateTime Function()? clock,
  })  : _gateway = gateway ?? PluginLocalNotificationGateway(),
        _browser = browser,
        _platform = platform ?? _detectPlatform(),
        _isAppInForeground = isAppInForeground ?? _defaultIsForeground,
        _clock = clock ?? DateTime.now;

  static const int liveNotificationId = 98;
  static const int completionNotificationId = 99;
  static const String liveChannelId = 'rest_timer_live';
  static const String liveChannelName = 'Rest Timer (Live)';
  static const String completionChannelId = 'rest_timer';
  static const String browserTag = 'ironflow-rest-timer';
  static const String payload = 'rest_timer';

  final LocalNotificationGateway _gateway;
  final BrowserNotifier _browser;
  final RestTimerSurfacePlatform _platform;
  final bool Function() _isAppInForeground;
  final DateTime Function() _clock;

  RestTimerSurfacePlatform get platform => _platform;

  static RestTimerSurfacePlatform _detectPlatform() {
    if (kIsWeb) return RestTimerSurfacePlatform.web;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return RestTimerSurfacePlatform.android;
    }
    return RestTimerSurfacePlatform.other;
  }

  static bool _defaultIsForeground() {
    final state = WidgetsBinding.instance.lifecycleState;
    return state == null || state == AppLifecycleState.resumed;
  }

  /// Formats [seconds] as `M:SS`.
  static String formatClock(int seconds) {
    final safe = math.max(0, seconds);
    final minutes = safe ~/ 60;
    final secs = safe % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  /// Android details for the running countdown.
  static AndroidNotificationDetails buildRunningAndroidDetails({
    required DateTime endTime,
    required DateTime now,
  }) {
    final remainingMs = endTime.difference(now).inMilliseconds;
    return AndroidNotificationDetails(
      liveChannelId,
      liveChannelName,
      channelDescription: 'Live rest countdown on the lock screen',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      playSound: false,
      enableVibration: false,
      showWhen: true,
      when: endTime.millisecondsSinceEpoch,
      usesChronometer: true,
      chronometerCountDown: true,
      timeoutAfter: math.max(1, remainingMs),
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.stopwatch,
    );
  }

  /// Android details for the paused state (static text, no chronometer).
  static AndroidNotificationDetails buildPausedAndroidDetails() {
    return const AndroidNotificationDetails(
      liveChannelId,
      liveChannelName,
      channelDescription: 'Live rest countdown on the lock screen',
      importance: Importance.low,
      priority: Priority.low,
      icon: '@mipmap/ic_launcher',
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      playSound: false,
      enableVibration: false,
      showWhen: false,
      usesChronometer: false,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.stopwatch,
    );
  }

  /// Android details for the background "Rest Complete!" heads-up alert,
  /// matching the existing scheduled alert channel.
  static AndroidNotificationDetails buildCompletionAndroidDetails() {
    return const AndroidNotificationDetails(
      completionChannelId,
      'Rest Timer',
      channelDescription: 'Alerts when rest interval between sets completes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );
  }

  void _guard(Future<void> Function() action) {
    try {
      action().catchError((Object _) {});
    } catch (_) {
      // Never let a notification failure reach the timer.
    }
  }

  @override
  void showRunning({required DateTime endTime, required int totalSeconds}) {
    switch (_platform) {
      case RestTimerSurfacePlatform.android:
        final details = buildRunningAndroidDetails(
          endTime: endTime,
          now: _clock(),
        );
        _guard(
          () => _gateway.show(
            liveNotificationId,
            'Resting',
            '${formatClock(totalSeconds)} rest · tap to return to your workout',
            NotificationDetails(android: details),
            payload: payload,
          ),
        );
      case RestTimerSurfacePlatform.web:
        if (_browser.isSupported && _browser.permission == 'default') {
          _guard(() async {
            await _browser.requestPermission();
          });
        }
      case RestTimerSurfacePlatform.other:
        break;
    }
  }

  @override
  void showPaused({required int remainingSeconds}) {
    if (_platform != RestTimerSurfacePlatform.android) return;
    _guard(
      () => _gateway.show(
        liveNotificationId,
        'Rest paused',
        '${formatClock(remainingSeconds)} left · tap to resume',
        NotificationDetails(android: buildPausedAndroidDetails()),
        payload: payload,
      ),
    );
  }

  @override
  void showCompleted() {
    switch (_platform) {
      case RestTimerSurfacePlatform.android:
        _guard(() => _gateway.cancel(liveNotificationId));
        if (!_isAppInForeground()) {
          _guard(
            () => _gateway.show(
              completionNotificationId,
              '⏱️ Rest Complete!',
              'Time to crush your next set!',
              NotificationDetails(android: buildCompletionAndroidDetails()),
              payload: payload,
            ),
          );
        }
      case RestTimerSurfacePlatform.web:
        if (_browser.isPageHidden) {
          _browser.show(
            title: 'Rest complete',
            body: 'Time for your next set.',
            tag: browserTag,
          );
        }
      case RestTimerSurfacePlatform.other:
        break;
    }
  }

  @override
  void clear() {
    if (_platform != RestTimerSurfacePlatform.android) return;
    _guard(() => _gateway.cancel(liveNotificationId));
  }
}

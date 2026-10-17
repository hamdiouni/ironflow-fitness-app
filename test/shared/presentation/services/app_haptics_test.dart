import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppHaptics Service Unit Tests', () {
    final List<MethodCall> hapticCalls = [];
    late AppHaptics haptics;

    setUp(() {
      hapticCalls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (MethodCall call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          hapticCalls.add(call);
        }
        return null;
      });
      haptics = AppHaptics(isEnabled: true);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('setLogged triggers lightImpact', () async {
      await haptics.setLogged();
      expect(hapticCalls.length, 1);
      expect(hapticCalls.first.arguments, 'HapticFeedbackType.lightImpact');
    });

    test('restTimerComplete triggers mediumImpact', () async {
      await haptics.restTimerComplete();
      expect(hapticCalls.length, 1);
      expect(hapticCalls.first.arguments, 'HapticFeedbackType.mediumImpact');
    });

    test('selectionChanged triggers selectionClick', () async {
      await haptics.selectionChanged();
      expect(hapticCalls.length, 1);
      expect(hapticCalls.first.arguments, 'HapticFeedbackType.selectionClick');
    });

    test('buttonPress triggers lightImpact', () async {
      await haptics.buttonPress();
      expect(hapticCalls.length, 1);
      expect(hapticCalls.first.arguments, 'HapticFeedbackType.lightImpact');
    });

    test('error triggers heavyImpact', () async {
      await haptics.error();
      expect(hapticCalls.length, 1);
      expect(hapticCalls.first.arguments, 'HapticFeedbackType.heavyImpact');
    });

    test('milestoneReached fires once per milestone per day', () async {
      final testDate = DateTime(2026, 10, 17);

      // First trigger for protein on testDate -> should fire
      await haptics.milestoneReached(milestoneId: 'protein', date: testDate);
      expect(hapticCalls.length, 1);
      expect(hapticCalls.first.arguments, 'HapticFeedbackType.mediumImpact');

      // Second trigger for protein on SAME testDate -> must NOT fire again
      await haptics.milestoneReached(milestoneId: 'protein', date: testDate);
      expect(hapticCalls.length, 1);

      // Different milestone (calories) on SAME date -> should fire
      await haptics.milestoneReached(milestoneId: 'calories', date: testDate);
      expect(hapticCalls.length, 2);

      // Same milestone (protein) on NEXT day -> should fire
      final nextDay = DateTime(2026, 10, 18);
      await haptics.milestoneReached(milestoneId: 'protein', date: nextDay);
      expect(hapticCalls.length, 3);
    });

    test('toggle disabled prevents all haptic feedback from firing', () async {
      final disabledHaptics = AppHaptics(isEnabled: false);

      await disabledHaptics.setLogged();
      await disabledHaptics.restTimerComplete();
      await disabledHaptics.selectionChanged();
      await disabledHaptics.buttonPress();
      await disabledHaptics.error();
      await disabledHaptics.milestoneReached(milestoneId: 'protein');

      expect(hapticCalls, isEmpty);
    });

    test('HapticsNotifier toggles enabled state', () async {
      final notifier = HapticsNotifier();
      expect(notifier.state, isTrue);

      await notifier.toggle(false);
      expect(notifier.state, isFalse);
      expect(AppHaptics.shared.isEnabled, isFalse);

      await notifier.toggle(true);
      expect(notifier.state, isTrue);
      expect(AppHaptics.shared.isEnabled, isTrue);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/shared/presentation/components/app_button.dart';
import 'package:progression_tracker/shared/presentation/components/app_card.dart';
import 'package:progression_tracker/shared/presentation/components/app_dialog.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('iOS Platform & Haptics Verification Tests (TargetPlatform.iOS)', () {
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

    testWidgets('Direction 4 theme tokens and components render seamlessly on iOS', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme.copyWith(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                final tokens = AppThemeTokens.of(context);
                expect(tokens.canvas, equals(AppColors.canvasDark));
                expect(tokens.kineticAccent, equals(AppColors.kineticAccentDark));
                expect(tokens.onAccent, equals(AppColors.onAccentDark));

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      AppCard(
                        child: Text('iOS Soft Card', style: TextStyle(color: tokens.textPrimary)),
                      ),
                      AppButton(
                        label: 'iOS Primary CTA',
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('iOS Soft Card'), findsOneWidget);
      expect(find.text('iOS Primary CTA'), findsOneWidget);
      expect(find.byType(AppCard), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('iOS modal dialogs adapt with Direction 4 tokens', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme.copyWith(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      AppDialog.show(
                        context: context,
                        title: 'iOS Dialog',
                        content: const Text('Direction 4 Soft Dialog on iOS'),
                        confirmLabel: 'Confirm',
                      );
                    },
                    child: const Text('Open Dialog'),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('iOS Dialog'), findsOneWidget);
      expect(find.text('Direction 4 Soft Dialog on iOS'), findsOneWidget);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.text('iOS Dialog'), findsNothing);
    });

    test('All hardware haptic trigger patterns execute cleanly via system channels', () async {
      await haptics.setLogged();
      expect(hapticCalls.last.arguments, equals('HapticFeedbackType.lightImpact'));

      await haptics.restTimerComplete();
      expect(hapticCalls.last.arguments, equals('HapticFeedbackType.mediumImpact'));

      await haptics.selectionChanged();
      expect(hapticCalls.last.arguments, equals('HapticFeedbackType.selectionClick'));

      await haptics.buttonPress();
      expect(hapticCalls.last.arguments, equals('HapticFeedbackType.lightImpact'));

      await haptics.error();
      expect(hapticCalls.last.arguments, equals('HapticFeedbackType.heavyImpact'));

      expect(hapticCalls.length, equals(5));
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/notifications/domain/entities/reminder_settings.dart';
import 'package:progression_tracker/features/notifications/presentation/notifiers/reminder_settings_notifier.dart';
import 'package:progression_tracker/features/notifications/presentation/providers/notification_providers.dart';
import 'package:progression_tracker/features/notifications/presentation/screens/reminder_settings_screen.dart';

class FakeReminderSettingsNotifier
    extends StateNotifier<AsyncValue<ReminderSettings>>
    implements ReminderSettingsNotifier {
  FakeReminderSettingsNotifier(ReminderSettings settings)
      : super(AsyncValue.data(settings));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const testSettings = ReminderSettings(
    workoutRemindersEnabled: true,
    workoutReminderTime: TimeOfDayModel(hour: 17, minute: 30),
    mealRemindersEnabled: true,
    breakfastTime: TimeOfDayModel(hour: 8, minute: 0),
    lunchTime: TimeOfDayModel(hour: 12, minute: 30),
    dinnerTime: TimeOfDayModel(hour: 19, minute: 0),
    streakRemindersEnabled: true,
    streakReminderTime: TimeOfDayModel(hour: 20, minute: 0),
    soundEnabled: true,
    vibrationEnabled: true,
  );

  Widget createWidgetUnderTest({
    ReminderSettings settings = testSettings,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return ProviderScope(
      overrides: [
        reminderSettingsProvider.overrideWith(
          (ref) => FakeReminderSettingsNotifier(settings),
        ),
      ],
      child: MaterialApp(
        themeMode: themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          extensions: [AppThemeTokens.light],
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          extensions: [AppThemeTokens.dark],
        ),
        home: const ReminderSettingsScreen(),
      ),
    );
  }

  group('ReminderSettingsScreen Widget Tests (Monolithic Sci-Fi)', () {
    testWidgets('renders REMINDER SETTINGS header and directives',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('REMINDER SETTINGS'), findsOneWidget);
      expect(find.text('NOTIFICATION MATRIX'), findsOneWidget);
      expect(find.text('WORKOUT DIRECTIVES'), findsOneWidget);
      expect(find.text('NUTRITION DIRECTIVES'), findsOneWidget);
      expect(find.text('STREAK CONTINUITY'), findsOneWidget);
      expect(find.text('HAPTIC & AUDIO PROTOCOL'), findsOneWidget);
      expect(find.text('Daily Workout Time'), findsOneWidget);
      expect(find.text('5:30 PM'), findsOneWidget);
    });
  });
}

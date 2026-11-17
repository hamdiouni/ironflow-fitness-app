import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/shared/presentation/components/motion_widgets.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(extensions: [AppThemeTokens.dark]),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AnimatedScaleButton Accessibility & Keyboard Activation', () {
    testWidgets('exposes button Semantics with enabled, label, and hint',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          wrap(
            AnimatedScaleButton(
              onPressed: () {},
              semanticLabel: 'Start Session',
              semanticHint: 'Starts your active workout',
              child: const Text('START'),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AnimatedScaleButton));
        expect(
          semantics,
          matchesSemantics(
            isButton: true,
            isEnabled: true,
            isFocusable: true,
            hasEnabledState: true,
            hasTapAction: true,
            hasFocusAction: true,
            label: 'Start Session\nSTART',
            hint: 'Starts your active workout',
          ),
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('triggers onPressed via Enter and Space keyboard activation',
        (tester) async {
      int presses = 0;

      await tester.pumpWidget(
        wrap(
          AnimatedScaleButton(
            onPressed: () => presses++,
            child: const Text('ACTIVATE'),
          ),
        ),
      );

      // Focus the button via Tab, then press Enter and Space.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();

      expect(presses, greaterThanOrEqualTo(2));
    });

    testWidgets('marks disabled Semantics when onPressed is null',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          wrap(
            const AnimatedScaleButton(
              onPressed: null,
              semanticLabel: 'Disabled Button',
              child: Text('LOCKED'),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AnimatedScaleButton));
        expect(
          semantics,
          matchesSemantics(
            isButton: true,
            isEnabled: false,
            hasEnabledState: true,
            label: 'Disabled Button\nLOCKED',
          ),
        );
      } finally {
        handle.dispose();
      }
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/shared/presentation/components/medical_disclaimer_banner.dart';

void main() {
  Widget wrapWithTheme(Widget child, {bool isDark = true}) {
    return MaterialApp(
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('Wave 6.2 MedicalDisclaimerBanner (LEG-03)', () {
    testWidgets('renders standard non-medical disclaimer card', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(const MedicalDisclaimerBanner()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medical & Fitness Notice'), findsOneWidget);
      expect(
        find.textContaining('IronFlow provides workout tracking and educational fitness estimates'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.health_and_safety_outlined), findsOneWidget);
    });

    testWidgets('renders compact disclaimer banner with custom message', (tester) async {
      bool dismissed = false;
      await tester.pumpWidget(
        wrapWithTheme(
          MedicalDisclaimerBanner(
            compact: true,
            customText: 'Custom test disclaimer text',
            onDismiss: () => dismissed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom test disclaimer text'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      expect(dismissed, isTrue);
    });

    testWidgets('renders cleanly in light mode without overflow', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const Padding(
            padding: EdgeInsets.all(16),
            child: MedicalDisclaimerBanner(),
          ),
          isDark: false,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(MedicalDisclaimerBanner), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/design_system/presentation/screens/design_gallery_screen.dart';

void main() {
  testWidgets('DesignGalleryScreen renders components and toggles theme without overflow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const DesignGalleryScreen(),
        ),
      ),
    );
    // Pump past the 500ms initialization timer in ThemeNotifier
    await tester.pump(const Duration(milliseconds: 600));

    // Verify header title and top gallery section
    expect(find.text('Design System Gallery'), findsOneWidget);
    expect(find.text('MONOLITHIC SCI-FI'), findsOneWidget);
    expect(find.text('Color Tokens'), findsOneWidget);

    // Scroll to see buttons section
    await tester.scrollUntilVisible(
      find.text('Buttons (48dp Touch Targets)'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Buttons (48dp Touch Targets)'), findsOneWidget);

    // Tap theme toggle icon in app bar
    final toggleButton = find.byTooltip('Toggle Light/Dark Theme');
    expect(toggleButton, findsOneWidget);
    await tester.tap(toggleButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify no exceptions or overflow occurred
    expect(tester.takeException(), isNull);
  });
}

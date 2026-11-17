import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/core/theme/app_theme_tokens.dart';
import 'package:progression_tracker/features/settings/domain/usecases/restore_data_use_case.dart';
import 'package:progression_tracker/features/settings/presentation/providers/settings_providers.dart';
import 'package:progression_tracker/features/settings/presentation/screens/export_settings_screen.dart';

class _FakeRestoreDataUseCase implements RestoreDataUseCase {
  @override
  Future<bool> hasUndoSnapshot() async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('ExportSettingsScreen renders header and backup/restore sections',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          restoreDataUseCaseProvider.overrideWithValue(_FakeRestoreDataUseCase()),
        ],
        child: MaterialApp(
          theme: ThemeData.dark().copyWith(
            extensions: [AppThemeTokens.dark],
          ),
          home: const ExportSettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EXPORT & BACKUP'), findsOneWidget);
    expect(find.text('LOCAL DATA SOVEREIGNTY'), findsOneWidget);
    expect(find.text('RESTORE ARCHIVE'), findsOneWidget);
  });
}


import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';

void main() {
  group('Wave 3.5 & 3.6 Architecture Hygiene Guards', () {
    final libDir = Directory('lib');

    List<File> allDartFilesInLib() {
      return libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))
          .toList();
    }

    String normalizePath(String rawPath) =>
        rawPath.replaceAll(r'\', '/');

    String resolveImport(String fromFilePath, String importTarget) {
      if (importTarget.startsWith('package:progression_tracker/')) {
        return 'lib/${importTarget.substring('package:progression_tracker/'.length)}';
      }
      if (importTarget.startsWith('dart:') || importTarget.startsWith('package:')) {
        return importTarget;
      }
      final fromParts = normalizePath(fromFilePath).split('/')..removeLast();
      for (final seg in importTarget.split('/')) {
        if (seg == '.' || seg.isEmpty) continue;
        if (seg == '..') {
          if (fromParts.isNotEmpty) fromParts.removeLast();
        } else {
          fromParts.add(seg);
        }
      }
      return fromParts.join('/');
    }

    test('domain layer never imports data or presentation layers', () {
      final importPattern = RegExp(
        r"""^\s*(?:import|export)\s+['"]([^'"]+)['"]""",
        multiLine: true,
      );
      final violations = <String>[];

      for (final file in allDartFilesInLib()) {
        final norm = normalizePath(file.path);
        if (!norm.contains('/domain/')) continue;

        final content = file.readAsStringSync();
        for (final match in importPattern.allMatches(content)) {
          final target = match.group(1)!;
          final resolved = resolveImport(norm, target);
          if (resolved.startsWith('lib/') &&
              (resolved.contains('/data/') ||
                  resolved.contains('/presentation/') ||
                  resolved.startsWith('lib/dev/'))) {
            violations.add('$norm -> $target ($resolved)');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Domain layer must remain pure and never import data/presentation:\n'
            '${violations.join('\n')}',
      );
    });

    test('zero legacy StateNotifier or StateNotifierProvider remain in lib/', () {
      final hits = <String>[];
      final pattern = RegExp(r'\bStateNotifier(?:Provider)?\b');
      for (final file in allDartFilesInLib()) {
        final norm = normalizePath(file.path);
        final lines = file.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          final trimmed = lines[i].trimLeft();
          if (trimmed.startsWith('//')) continue;
          if (pattern.hasMatch(lines[i])) {
            hits.add('$norm:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
      expect(
        hits,
        isEmpty,
        reason: 'All Riverpod state holders must use Notifier/AsyncNotifier (ADR-007):\n'
            '${hits.join('\n')}',
      );
    });

    test('zero deprecated .withOpacity( calls remain in lib/', () {
      final hits = <String>[];
      for (final file in allDartFilesInLib()) {
        final norm = normalizePath(file.path);
        final lines = file.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (lines[i].contains('.withOpacity(')) {
            hits.add('$norm:${i + 1}: ${lines[i].trim()}');
          }
        }
      }
      expect(
        hits,
        isEmpty,
        reason: 'Use .withValues(alpha: ...) instead of deprecated .withOpacity:\n'
            '${hits.join('\n')}',
      );
    });

    test('mock data sources and developer screens are isolated from production paths', () {
      final importPattern = RegExp(
        r"""^\s*(?:import|export)\s+['"]([^'"]+)['"]""",
        multiLine: true,
      );
      const allowedMockImporters = <String>{
        'lib/features/auth/presentation/providers/auth_provider.dart',
        'lib/features/auth/data/datasources/mock_auth_datasource.dart',
        'lib/features/auth/data/datasources/mock_user_datasource.dart',
      };
      final violations = <String>[];

      for (final file in allDartFilesInLib()) {
        final norm = normalizePath(file.path);
        if (norm.startsWith('lib/dev/')) continue;

        final content = file.readAsStringSync();
        for (final match in importPattern.allMatches(content)) {
          final target = match.group(1)!;
          final resolved = resolveImport(norm, target);

          final isDevScreen = resolved.startsWith('lib/dev/design_lab/') ||
              resolved.endsWith('/design_gallery_screen.dart') ||
              resolved.endsWith('/design_preview_screen.dart');
          if (isDevScreen) {
            violations.add('Prod file imports dev screen: $norm -> $resolved');
          }

          final isMockDs = resolved.endsWith('/mock_auth_datasource.dart') ||
              resolved.endsWith('/mock_user_datasource.dart');
          if (isMockDs && !allowedMockImporters.contains(norm)) {
            violations.add('Prod file imports mock datasource: $norm -> $resolved');
          }
        }
      }

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('release route table excludes debug/preview routes and forces Firebase Auth', () {
      final prodRoutes = buildAppRoutes(includeDebugRoutes: false);
      final topPaths = prodRoutes
          .whereType<GoRoute>()
          .map((r) => r.path)
          .toSet();

      expect(topPaths, isNot(contains(AppRoutes.designPreview)));
      expect(topPaths, isNot(contains(AppRoutes.designGallery)));

      expect(
        shouldUseFirebaseAuth(
          isReleaseMode: true,
          flavor: 'dev',
          useFirebaseAuthFlag: false,
        ),
        isTrue,
      );
      expect(
        shouldUseFirebaseAuth(
          isReleaseMode: false,
          flavor: 'prod',
          useFirebaseAuthFlag: false,
        ),
        isTrue,
      );
    });

    test('zero non-generated Dart files in lib/ exceed 800 lines (Wave 3.3)', () {
      final oversized = <String>[];

      for (final file in allDartFilesInLib()) {
        final norm = normalizePath(file.path);
        if (norm.endsWith('.g.dart') ||
            norm.endsWith('.freezed.dart') ||
            norm.startsWith('lib/l10n/')) {
          continue;
        }
        final lineCount = file.readAsLinesSync().length;
        if (lineCount > 800) {
          oversized.add('$norm ($lineCount lines)');
        }
      }

      expect(
        oversized,
        isEmpty,
        reason: 'Every non-generated Dart file in lib/ must stay <= 800 lines:\n'
            '${oversized.join('\n')}',
      );
    });

    test('presentation screens never access Hive or SharedPreferences directly (Wave 3.7)', () {
      final directStoragePattern = RegExp(
        r'\b(?:Hive\.box|Hive\.openBox|SharedPreferences\.getInstance)\b',
      );
      final violations = <String>[];

      for (final file in allDartFilesInLib()) {
        final norm = normalizePath(file.path);
        if (!norm.contains('/presentation/screens/')) continue;

        final lines = file.readAsLinesSync();
        for (var i = 0; i < lines.length; i++) {
          final trimmed = lines[i].trimLeft();
          if (trimmed.startsWith('//')) continue;
          if (directStoragePattern.hasMatch(lines[i])) {
            violations.add('$norm:${i + 1}: ${lines[i].trim()}');
          }
        }
      }

      expect(
        violations,
        isEmpty,
        reason: 'Screens must use domain repository/provider abstractions instead of direct storage calls:\n'
            '${violations.join('\n')}',
      );
    });
  });
}

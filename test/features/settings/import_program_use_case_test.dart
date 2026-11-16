import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/settings/domain/usecases/import_program_use_case.dart';
import 'package:progression_tracker/features/workout/domain/entities/active_program.dart';
import 'package:progression_tracker/features/workout/domain/repositories/active_program_repository.dart';

class _InMemoryActiveProgramRepo extends Fake
    implements ActiveProgramRepository {
  ActiveProgram? saved;

  @override
  Future<void> saveActiveProgram(ActiveProgram program) async {
    saved = program;
  }

  @override
  Future<ActiveProgram?> loadActiveProgram() async => saved;

  @override
  Future<void> clearActiveProgram() async {
    saved = null;
  }
}

void main() {
  late Directory tempDir;
  late ImportProgramUseCase useCase;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('import_program_test_');
    useCase = ImportProgramUseCase(_InMemoryActiveProgramRepo());
  });

  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Wave 2.2 — ImportProgramUseCase Characterization', () {
    test('returns failure when file paths do not exist', () async {
      final missingJson =
          await useCase.importFromJsonFile('${tempDir.path}/missing.json');
      expect(missingJson.success, isFalse);
      expect(missingJson.message, contains('File not found'));

      final missingCsv = await useCase.importFromCsvFile(
        '${tempDir.path}/missing.csv',
        'Strong',
      );
      expect(missingCsv.success, isFalse);
      expect(missingCsv.message, contains('File not found'));

      final validateMissing =
          await useCase.validateProgramFile('${tempDir.path}/nope.json');
      expect(validateMissing.success, isFalse);
    });

    test('validates IronFlow, Jefit, and Generic JSON formats and rejects incomplete IronFlow specs',
        () async {
      final validIronFlowFile = File('${tempDir.path}/ironflow.json')
        ..writeAsStringSync(jsonEncode({
          'ironflow_version': '1.0',
          'name': 'Upper Lower',
          'days': {
            '1': {
              'exercises': [
                {'name': 'Bench Press'},
                {'name': 'Row'},
              ],
            },
          },
        }));

      final ok = await useCase.validateProgramFile(validIronFlowFile.path);
      expect(ok.success, isTrue);

      final preview = await useCase.getImportPreview(validIronFlowFile.path);
      expect(preview['name'], 'Upper Lower');
      expect(preview['day_count'], 1);
      expect(preview['exercise_count'], 2);

      final badIronFlowFile = File('${tempDir.path}/bad_ironflow.json')
        ..writeAsStringSync(jsonEncode({
          'export_info': {'app': 'ironflow'},
          'days': {'1': {}},
        }));
      final bad = await useCase.validateProgramFile(badIronFlowFile.path);
      expect(bad.success, isFalse);
      expect(bad.errors, contains('Missing program name'));
      expect(bad.errors, contains('Day 1 missing exercises'));

      final jefitFile = File('${tempDir.path}/jefit.json')
        ..writeAsStringSync(jsonEncode({
          'jefit_program': true,
          'title': 'Jefit Split',
        }));
      final jefitRes = await useCase.validateProgramFile(jefitFile.path);
      expect(jefitRes.success, isTrue);
      expect(jefitRes.warnings, isNotEmpty);

      final genericFile = File('${tempDir.path}/generic.json')
        ..writeAsStringSync(jsonEncode({'custom': 1}));
      final genericRes = await useCase.validateProgramFile(genericFile.path);
      expect(genericRes.success, isTrue);
      expect(genericRes.warnings.length, 2);
    });

    test('validates CSV files and rejects empty/single-line CSVs', () async {
      final shortCsv = File('${tempDir.path}/short.csv')
        ..writeAsStringSync('Exercise,Sets\n');
      final shortRes = await useCase.validateProgramFile(shortCsv.path);
      expect(shortRes.success, isFalse);
      expect(shortRes.errors,
          contains('CSV file must have at least a header and one data row'));

      final validCsv = File('${tempDir.path}/valid.csv')
        ..writeAsStringSync('Exercise Name,Sets,Reps\nSquat,3,5\n');
      final validRes = await useCase.validateProgramFile(validCsv.path);
      expect(validRes.success, isTrue);

      final preview = await useCase.getImportPreview(validCsv.path);
      expect(preview['row_count'], 1);
      expect(preview['format'], 'CSV');
    });

    test('characterization: conversion methods currently fail safely with UnimplementedError message',
        () async {
      final jsonImport = await useCase.importFromJsonString(jsonEncode({
        'ironflow_version': '1.0',
        'name': 'PPL',
        'days': {
          '1': {'exercises': []},
        },
      }));
      expect(jsonImport.success, isFalse);
      expect(jsonImport.message, contains('Failed to import program'));

      final csvImport = await useCase.importFromCsvString(
        'Exercise,Sets\nBench,3\n',
        'My CSV',
      );
      expect(csvImport.success, isFalse);
      expect(csvImport.message, contains('Failed to import CSV program'));
    });
  });
}

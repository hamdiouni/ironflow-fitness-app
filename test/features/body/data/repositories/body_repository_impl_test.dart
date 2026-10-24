import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/body/data/datasources/hive_body_data_source.dart';
import 'package:progression_tracker/features/body/data/repositories/body_repository_impl.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/entities/measurement_type.dart';

void main() {
  late Directory tempDir;
  late Box<Map> bodyEntriesBox;
  late HiveBodyDataSource dataSource;
  late BodyRepositoryImpl repository;
  late List<BodyEntry> savedCallbacks;
  late List<String> deletedCallbacks;

  BodyEntry entry({
    required String id,
    required DateTime date,
    double weight = 80,
    String? userId,
  }) {
    return BodyEntry(
      id: id,
      date: date,
      weight: weight,
      measurements: const <MeasurementType, double>{
        MeasurementType.waist: 82,
      },
      userId: userId,
    );
  }

  Future<void> saveAll(List<BodyEntry> entries) async {
    for (final item in entries) {
      await repository.saveBodyEntry(item);
    }
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('body_repository_');
    Hive.init(tempDir.path);
    bodyEntriesBox = await Hive.openBox<Map>('body_entries');
  });

  setUp(() async {
    await bodyEntriesBox.clear();
    savedCallbacks = <BodyEntry>[];
    deletedCallbacks = <String>[];
    dataSource = HiveBodyDataSource();
    repository = BodyRepositoryImpl(
      dataSource,
      userId: 'Alice',
      onEntrySaved: (item) async {
        savedCallbacks.add(item);
      },
      onEntryDeleted: (id) async {
        deletedCallbacks.add(id);
      },
    );
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('save stamps the repository owner and updatedAt before callbacks',
      () async {
    final before = DateTime.now().subtract(const Duration(seconds: 1));
    await repository.saveBodyEntry(
      entry(id: 'entry-1', date: DateTime(2026, 1, 2, 8)),
    );
    final after = DateTime.now().add(const Duration(seconds: 1));

    final entries = await repository.getAllBodyEntries();

    expect(entries, hasLength(1));
    expect(entries.single.userId, 'Alice');
    expect(entries.single.updatedAt, isNotNull);
    expect(entries.single.updatedAt!.isBefore(before), isFalse);
    expect(entries.single.updatedAt!.isAfter(after), isFalse);
    expect(entries.single.measurements[MeasurementType.waist], 82.0);

    expect(savedCallbacks, hasLength(1));
    expect(savedCallbacks.single.id, 'entry-1');
    expect(savedCallbacks.single.userId, 'Alice');
    expect(savedCallbacks.single.updatedAt, entries.single.updatedAt);
  });

  test('entries are newest first and the date range includes boundaries',
      () async {
    final start = DateTime(2026, 1, 1, 8);
    final end = DateTime(2026, 1, 3, 8);
    await saveAll(<BodyEntry>[
      entry(id: 'middle', date: DateTime(2026, 1, 2, 8)),
      entry(id: 'at-end', date: end),
      entry(id: 'at-start', date: start),
      entry(id: 'after-end', date: DateTime(2026, 1, 4, 8)),
    ]);

    final allEntries = await repository.getAllBodyEntries();
    final rangedEntries =
        await repository.getBodyEntriesByDateRange(start, end);

    expect(
      allEntries.map((item) => item.id),
      <String>['after-end', 'at-end', 'middle', 'at-start'],
    );
    expect(
      rangedEntries.map((item) => item.id),
      <String>['at-end', 'middle', 'at-start'],
    );
  });

  test('delete removes the entry and then calls the delete callback',
      () async {
    await saveAll(<BodyEntry>[
      entry(id: 'keep', date: DateTime(2026, 1, 1, 8)),
      entry(id: 'delete', date: DateTime(2026, 1, 2, 8)),
    ]);
    savedCallbacks.clear();

    await repository.deleteBodyEntry('delete');

    final entries = await repository.getAllBodyEntries();
    expect(entries.map((item) => item.id), <String>['keep']);
    expect(deletedCallbacks, <String>['delete']);
  });

  test('callback failures do not fail a completed local save or delete',
      () async {
    final failingCallbackRepository = BodyRepositoryImpl(
      dataSource,
      userId: 'Alice',
      onEntrySaved: (_) async {
        throw StateError('save callback failed');
      },
      onEntryDeleted: (_) async {
        throw StateError('delete callback failed');
      },
    );

    await failingCallbackRepository.saveBodyEntry(
      entry(id: 'local-only', date: DateTime(2026, 1, 2, 8)),
    );
    expect(await failingCallbackRepository.getAllBodyEntries(), hasLength(1));

    await failingCallbackRepository.deleteBodyEntry('local-only');
    expect(await failingCallbackRepository.getAllBodyEntries(), isEmpty);
  });
}

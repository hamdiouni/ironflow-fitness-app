import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/body/data/datasources/hive_body_data_source.dart';
import 'package:progression_tracker/features/body/data/models/body_entry_model.dart';

void main() {
  late Directory tempDir;
  late Box<Map> bodyEntriesBox;
  late HiveBodyDataSource dataSource;

  BodyEntryModel entry({
    required String id,
    required DateTime date,
    required double weight,
  }) {
    return BodyEntryModel(
      id: id,
      date: date.toIso8601String(),
      weight: weight,
      measurements: const <String, double>{},
      userId: 'Alice',
      updatedAt: '2026-01-01T00:00:00.000',
    );
  }

  Future<void> letStreamSubscribe() {
    return Future<void>.delayed(const Duration(milliseconds: 10));
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_body_stream_');
    Hive.init(tempDir.path);
    bodyEntriesBox = await Hive.openBox<Map>('body_entries');
  });

  setUp(() async {
    await bodyEntriesBox.clear();
    dataSource = HiveBodyDataSource();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('watchAllBodyEntries starts with the current sorted snapshot',
      () async {
    await dataSource.saveBodyEntry(
      entry(id: 'day-1', date: DateTime(2026, 1, 1, 8), weight: 80),
    );
    await dataSource.saveBodyEntry(
      entry(id: 'day-3', date: DateTime(2026, 1, 3, 8), weight: 79),
    );

    final snapshot = await dataSource.watchAllBodyEntries().first;

    expect(snapshot.map((item) => item.id), <String>['day-3', 'day-1']);
  });

  test('watchAllBodyEntries emits a fresh sorted snapshot after writes',
      () async {
    final snapshotsFuture =
        dataSource.watchAllBodyEntries().take(4).toList();
    await letStreamSubscribe();

    await dataSource.saveBodyEntry(
      entry(id: 'day-1', date: DateTime(2026, 1, 1, 8), weight: 80),
    );
    await letStreamSubscribe();
    await dataSource.saveBodyEntry(
      entry(id: 'day-3', date: DateTime(2026, 1, 3, 8), weight: 79),
    );
    await letStreamSubscribe();
    await dataSource.deleteBodyEntry('day-1');

    final snapshots = await snapshotsFuture.timeout(
      const Duration(seconds: 5),
    );

    expect(
      snapshots.map(
        (snapshot) => snapshot.map((item) => item.id).toList(growable: false),
      ),
      <List<String>>[
        <String>[],
        <String>['day-1'],
        <String>['day-3', 'day-1'],
        <String>['day-3'],
      ],
    );
  });
}

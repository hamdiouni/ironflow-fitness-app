import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/workout/data/datasources/hive_active_program_datasource.dart';
import 'package:progression_tracker/features/workout/data/models/active_program_model.dart';
import 'package:progression_tracker/features/workout/data/models/workout_program_model.dart';

void main() {
  late Directory tempDir;
  late Box<dynamic> authSessionBox;
  late Box<Map> activeProgramBox;
  late HiveActiveProgramDataSource dataSource;

  ActiveProgramModel programModel(String id, {String? userId}) {
    return ActiveProgramModel(
      id: id,
      program: WorkoutProgramModel(
        id: 'program-$id',
        name: 'Program $id',
        description: 'Scoped test program',
        durationWeeks: 4,
        difficulty: 'intermediate',
        days: const [],
        userId: userId,
      ),
      currentDayIndex: 0,
      isActive: true,
      userId: userId,
    );
  }

  Future<void> signInAs(String userId) async {
    await authSessionBox.put('is_logged_in', true);
    await authSessionBox.put('user_id', userId);
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('active_program_scope_');
    Hive.init(tempDir.path);
    authSessionBox = await Hive.openBox<dynamic>('auth_session');
    activeProgramBox = await Hive.openBox<Map>('active_program');
  });

  setUp(() async {
    await authSessionBox.clear();
    await activeProgramBox.clear();
    dataSource = HiveActiveProgramDataSource();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('active programs are stored and loaded per signed-in account',
      () async {
    await signInAs('Alice');
    await dataSource.saveActiveProgram(programModel('Alice', userId: 'Alice'));
    expect((await dataSource.loadActiveProgram())?.id, 'Alice');

    await signInAs('bob');
    expect(await dataSource.loadActiveProgram(), isNull);

    await dataSource.saveActiveProgram(programModel('bob', userId: 'bob'));
    expect((await dataSource.loadActiveProgram())?.id, 'bob');

    await signInAs('Alice');
    expect((await dataSource.loadActiveProgram())?.id, 'Alice');
  });

  test('archived program restore is scoped to the same account', () async {
    await signInAs('Alice');
    await dataSource.saveActiveProgram(programModel('Alice', userId: 'Alice'));
    await dataSource.archiveCurrentProgram();
    await dataSource.clearActiveProgram();

    await signInAs('bob');
    expect(await dataSource.hasArchivedProgram(), isFalse);
    expect(await dataSource.restoreArchivedProgram(), isNull);

    await signInAs('Alice');
    expect(await dataSource.hasArchivedProgram(), isTrue);
    expect((await dataSource.restoreArchivedProgram())?.id, 'Alice');
    expect((await dataSource.loadActiveProgram())?.id, 'Alice');
  });

  test('legacy singleton is adopted once by the first scoped account',
      () async {
    // No signed-in session and no model owner => legacy singleton key.
    await dataSource.saveActiveProgram(programModel('legacy'));

    await signInAs('Alice');
    expect((await dataSource.loadActiveProgram())?.id, 'legacy');

    await signInAs('bob');
    expect(await dataSource.loadActiveProgram(), isNull);
  });
}

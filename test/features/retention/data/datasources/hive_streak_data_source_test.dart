import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/features/retention/data/datasources/hive_streak_data_source.dart';
import 'package:progression_tracker/features/retention/domain/entities/streak.dart';

void main() {
  late Directory tempDir;
  late Box<Map> streakBox;

  Streak streak(int current) {
    return Streak(
      currentStreak: current,
      longestStreak: current + 2,
      lastWorkoutDate: DateTime(2026, 1, 10),
      streakStartDate: DateTime(2026, 1, 1),
    );
  }

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_streak_scope_');
    Hive.init(tempDir.path);
    streakBox = await Hive.openBox<Map>('streak');
  });

  setUp(() async {
    await streakBox.clear();
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  test('streaks are stored separately for each user', () async {
    final aliceSource = HiveStreakDataSource(userId: 'Alice');
    final bobSource = HiveStreakDataSource(userId: 'bob');

    await aliceSource.saveStreak(streak(4));
    await bobSource.saveStreak(streak(9));

    expect((await aliceSource.getStreak()).currentStreak, 4);
    expect((await bobSource.getStreak()).currentStreak, 9);
    expect(streakBox.containsKey('current_streak_alice'), isTrue);
    expect(streakBox.containsKey('current_streak_bob'), isTrue);
    expect(streakBox.containsKey('current_streak'), isFalse);
  });

  test('legacy streak is adopted only by the first scoped user', () async {
    await streakBox.put('current_streak', streak(6).toJson());
    final aliceSource = HiveStreakDataSource(userId: 'Alice');
    final bobSource = HiveStreakDataSource(userId: 'bob');

    expect((await aliceSource.getStreak()).currentStreak, 6);
    expect((await bobSource.getStreak()).currentStreak, 0);
    expect(streakBox.containsKey('current_streak_alice'), isTrue);
    expect(streakBox.containsKey('current_streak'), isFalse);
  });

  test('clearStreak removes only the scoped user streak', () async {
    final aliceSource = HiveStreakDataSource(userId: 'Alice');
    final bobSource = HiveStreakDataSource(userId: 'bob');
    await aliceSource.saveStreak(streak(3));
    await bobSource.saveStreak(streak(7));

    await aliceSource.clearStreak();

    expect((await aliceSource.getStreak()).currentStreak, 0);
    expect((await bobSource.getStreak()).currentStreak, 7);
  });
}

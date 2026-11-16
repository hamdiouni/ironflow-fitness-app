import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:progression_tracker/features/sync/data/datasources/firestore_sync_datasource.dart';
import 'package:progression_tracker/features/sync/data/datasources/hive_sync_queue_datasource.dart';
import 'package:progression_tracker/features/sync/data/services/sync_service.dart';
import 'package:progression_tracker/features/sync/domain/entities/sync_action.dart';
import 'package:progression_tracker/features/sync/domain/entities/sync_status.dart';
import 'package:progression_tracker/features/sync/presentation/providers/sync_provider.dart';
import 'package:progression_tracker/features/sync/presentation/widgets/sync_indicator.dart';

// ignore: subtype_of_sealed_class
class _FakeDocSnapshot extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _FakeDocSnapshot(this._id, this._data);
  final String _id;
  final Map<String, dynamic> _data;

  @override
  String get id => _id;

  @override
  bool get exists => true;

  @override
  Map<String, dynamic> data() => _data;
}

// ignore: subtype_of_sealed_class
class _FakeDocGetSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  _FakeDocGetSnapshot(this._id, this._exists, this._data);
  final String _id;
  final bool _exists;
  final Map<String, dynamic>? _data;

  @override
  String get id => _id;

  @override
  bool get exists => _exists;

  @override
  Map<String, dynamic>? data() => _data;
}

class _FakeQuerySnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  _FakeQuerySnapshot(this._docs);
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs;

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;
}

// ignore: subtype_of_sealed_class
class _FakeQuery extends Fake implements Query<Map<String, dynamic>> {
  _FakeQuery(this.docs, this.recordedClauses);

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;
  final List<String> recordedClauses;

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    if (isEqualTo != null) {
      recordedClauses.add('where:$field==$isEqualTo');
    } else if (isGreaterThan != null) {
      recordedClauses.add('where:$field>$isGreaterThan');
    }
    return this;
  }

  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) {
    recordedClauses.add('orderBy:$field:desc=$descending');
    return this;
  }

  @override
  Query<Map<String, dynamic>> limit(int limit) {
    recordedClauses.add('limit:$limit');
    return this;
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return _FakeQuerySnapshot(docs);
  }
}

// ignore: subtype_of_sealed_class
class _FakeDocumentRef extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _FakeDocumentRef(this.docPath, this.store);
  final String docPath;
  final Map<String, Map<String, dynamic>> store;

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async {
    store[docPath] = data;
  }

  @override
  Future<void> delete() async {
    store.remove(docPath);
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get(
      [GetOptions? options]) async {
    final val = store[docPath];
    return _FakeDocGetSnapshot(docPath.split('/').last, val != null, val);
  }
}

// ignore: subtype_of_sealed_class
class _FakeCollectionRef extends _FakeQuery
    implements CollectionReference<Map<String, dynamic>> {
  _FakeCollectionRef(
    this.name,
    super.docs,
    super.recordedClauses,
    this.store,
  );
  final String name;
  final Map<String, Map<String, dynamic>> store;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return _FakeDocumentRef('$name/$path', store);
  }
}

class _FakeFirestore extends Fake implements FirebaseFirestore {
  final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      collectionDocs = {};
  final Map<String, Map<String, dynamic>> docStore = {};
  final List<String> recordedClauses = [];

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    return _FakeCollectionRef(
      collectionPath,
      collectionDocs[collectionPath] ?? const [],
      recordedClauses,
      docStore,
    );
  }
}

class _SpySyncService extends Fake implements SyncService {
  int syncAllCalls = 0;
  int retryCalls = 0;
  String? lastUserId;
  final _controller = StreamController<SyncStatusEntity>.broadcast();

  @override
  Stream<SyncStatusEntity> get syncStatus => _controller.stream;

  @override
  Future<SyncStatusEntity> getCurrentStatus() async => SyncStatusEntity.initial();

  @override
  Future<void> syncAll({String? userId}) async {
    syncAllCalls++;
    lastUserId = userId;
  }

  @override
  Future<void> retryFailedActions(String userId) async {
    retryCalls++;
  }

  @override
  void dispose() {
    _controller.close();
  }
}

class _FakeAuthRepo implements AuthRepository {
  _FakeAuthRepo(this.user);
  final User? user;

  @override
  Future<User?> getCurrentUser() async => user;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('sync_char_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('Wave 2.2 — Sync Providers, Queue & Indicator Characterization', () {
    test('HiveSyncQueueDataSourceImpl tracks counts, deletions, and completed cleanup',
        () async {
      final queue = HiveSyncQueueDataSourceImpl();
      await Hive.openBox<Map>('sync_queue');
      await Hive.box<Map>('sync_queue').clear();

      await queue.addAction(SyncAction(
        id: 'a-pending',
        type: SyncActionType.create,
        dataType: SyncDataType.workout,
        dataId: 'w-1',
        data: const {},
        timestamp: DateTime(2026, 1, 1, 10),
        status: SyncStatus.pending,
      ));
      await queue.addAction(SyncAction(
        id: 'a-failed',
        type: SyncActionType.update,
        dataType: SyncDataType.nutrition,
        dataId: 'm-1',
        data: const {},
        timestamp: DateTime(2026, 1, 1, 11),
        status: SyncStatus.failed,
      ));
      await queue.addAction(SyncAction(
        id: 'a-done',
        type: SyncActionType.delete,
        dataType: SyncDataType.bodyProgress,
        dataId: 'b-1',
        data: const {},
        timestamp: DateTime(2026, 1, 1, 9),
        status: SyncStatus.completed,
      ));

      expect(await queue.getPendingCount(), 1);
      expect(await queue.getFailedCount(), 1);
      await queue.clearCompleted();
      expect(Hive.box<Map>('sync_queue').containsKey('a-done'), isFalse);

      await queue.deleteAction('a-failed');
      expect(await queue.getFailedCount(), 0);
    });

    test('FirestoreSyncDataSourceImpl records max server syncedAt and skips invalid tombstone docs',
        () async {
      final firestore = _FakeFirestore();
      final t1 = Timestamp.fromDate(DateTime.utc(2026, 2, 1, 10));
      final t2 = Timestamp.fromDate(DateTime.utc(2026, 2, 1, 12));
      firestore.collectionDocs['workouts'] = [
        _FakeDocSnapshot('w-1', {
          'id': 'w-1',
          'userId': 'u-1',
          'date': '2026-02-01T10:00:00.000Z',
          'durationSeconds': 1800,
          'totalVolume': 1200.0,
          'exercises': const <Map<String, dynamic>>[],
          'syncedAt': t1,
        }),
        // Tombstone stub missing full workout payload -> skipped safely without throwing.
        _FakeDocSnapshot('w-tombstone', {
          'userId': 'u-1',
          'deletedAt': '2026-02-01T12:00:00.000Z',
          'syncedAt': t2,
        }),
      ];

      final ds = FirestoreSyncDataSourceImpl(firestore: firestore);
      final workouts = await ds.getWorkouts(
        'u-1',
        since: DateTime.utc(2026, 2, 1, 8),
      );

      expect(workouts.map((w) => w.id), ['w-1']);
      expect(
        ds.getLastServerTimestamp('workouts'),
        t2.toDate(),
      );
      expect(firestore.recordedClauses, contains('limit:100'));
      expect(firestore.recordedClauses, contains('orderBy:syncedAt:desc=false'));

      // Singleton nutrition targets returns null cleanly when absent.
      expect(await ds.getNutritionTargets('u-1'), isNull);

      // Tombstone writes deletion markers with serverTimestamp sentinel.
      await ds.deleteWorkout('u-1', 'w-1');
      expect(firestore.docStore['workouts/w-1']?['userId'], 'u-1');
      expect(firestore.docStore['workouts/w-1']?['deletedAt'], isNotNull);
    });

    test('syncTriggerProvider skips local-only users and dispatches cloud sync for signed-in users',
        () async {
      final spy = _SpySyncService();
      addTearDown(spy.dispose);

      final guestContainer = ProviderContainer(
        overrides: [
          syncServiceProvider.overrideWithValue(spy),
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepo(User(
              id: kLocalGuestUserId,
              email: 'local@device.offline',
              displayName: 'Local Athlete',
              photoUrl: null,
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            )),
          ),
        ],
      );
      addTearDown(guestContainer.dispose);

      await guestContainer.read(syncTriggerProvider)();
      expect(spy.syncAllCalls, 0);

      final cloudContainer = ProviderContainer(
        overrides: [
          syncServiceProvider.overrideWithValue(spy),
          authRepositoryProvider.overrideWithValue(
            _FakeAuthRepo(User(
              id: 'cloud-user-1',
              email: 'cloud@ironflow.test',
              displayName: 'Cloud User',
              photoUrl: null,
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            )),
          ),
        ],
      );
      addTearDown(cloudContainer.dispose);

      await cloudContainer.read(syncTriggerProvider)();
      expect(spy.syncAllCalls, 1);
      expect(spy.lastUserId, 'cloud-user-1');

      await cloudContainer.read(retryFailedActionsProvider)();
      expect(spy.retryCalls, 1);
    });

    testWidgets(
        'SyncIndicator and CompactSyncIndicator render states and dispatch Retry / Sync Now actions',
        (tester) async {
      var syncTapped = false;
      var retryTapped = false;

      Widget buildIndicatorHost(
        Key scopeKey,
        SyncStatusEntity status,
        bool online,
      ) {
        return ProviderScope(
          key: scopeKey,
          overrides: [
            syncStatusStreamProvider.overrideWith((ref) => Stream.value(status)),
            isOnlineProvider.overrideWith((ref) => Stream.value(online)),
            syncTriggerProvider.overrideWithValue(() async {
              syncTapped = true;
            }),
            retryFailedActionsProvider.overrideWithValue(() async {
              retryTapped = true;
            }),
          ],
          child: MaterialApp(
            theme: ThemeData.dark().copyWith(extensions: [AppThemeTokens.dark]),
            home: const Scaffold(
              body: Column(
                children: [
                  SyncIndicator(showDetails: true),
                  CompactSyncIndicator(),
                ],
              ),
            ),
          ),
        );
      }

      // Offline state
      await tester.pumpWidget(
        buildIndicatorHost(
          const ValueKey('offline'),
          SyncStatusEntity.initial(),
          false,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Offline'), findsOneWidget);

      // Failed actions + CompactSyncIndicator dialog interactions
      await tester.pumpWidget(
        buildIndicatorHost(
          const ValueKey('failed'),
          SyncStatusEntity(
            isSyncing: false,
            lastSyncTime: DateTime.now(),
            pendingActions: 2,
            failedActions: 1,
          ),
          true,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 failed'), findsOneWidget);

      await tester.tap(find.byType(CompactSyncIndicator));
      await tester.pumpAndSettle();
      expect(find.text('Sync Status'), findsOneWidget);

      await tester.tap(find.text('Retry Failed'));
      await tester.pumpAndSettle();
      expect(retryTapped, isTrue);

      await tester.tap(find.byType(CompactSyncIndicator));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sync Now'));
      await tester.pumpAndSettle();
      expect(syncTapped, isTrue);
    });
  });
}

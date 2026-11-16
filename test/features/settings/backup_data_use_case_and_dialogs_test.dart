import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/core/router/app_router.dart';
import 'package:progression_tracker/core/utils/record_ownership.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/entities/user_profile.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/body/domain/entities/body_entry.dart';
import 'package:progression_tracker/features/body/domain/repositories/body_repository.dart';
import 'package:progression_tracker/features/nutrition/domain/entities/daily_nutrition_summary.dart';
import 'package:progression_tracker/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:progression_tracker/features/settings/domain/usecases/backup_data_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_all_data_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_nutrition_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/export_workouts_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/restore_data_use_case.dart';
import 'package:progression_tracker/features/settings/presentation/widgets/export/export_restore_modal.dart';
import 'package:progression_tracker/features/settings/presentation/widgets/settings_dialogs.dart';
import 'package:progression_tracker/features/workout/domain/entities/workout.dart';
import 'package:progression_tracker/features/workout/domain/repositories/workout_repository.dart';

class _FakeAuthRepo implements AuthRepository {
  _FakeAuthRepo(this.user);
  User? user;
  bool signedOut = false;

  @override
  Future<User?> getCurrentUser() async => user;

  @override
  Future<bool> isAuthenticated() async => user != null;

  @override
  Future<UserProfile?> getUserProfile(String userId) async => null;

  @override
  Future<void> saveUserProfile(UserProfile profile) async {}

  @override
  Future<void> signOut() async {
    signedOut = true;
    user = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _EmptyWorkoutRepo extends Fake implements WorkoutRepository {
  @override
  Future<List<Workout>> getAllWorkouts() async => [];
}

class _EmptyNutritionRepo extends Fake implements NutritionRepository {
  @override
  Future<List<DailyNutritionSummary>> getNutritionHistory(
    DateTime startDate,
    DateTime endDate,
  ) async =>
      [];
}

class _EmptyBodyRepo extends Fake implements BodyRepository {
  @override
  Future<List<BodyEntry>> getAllBodyEntries() async => [];
}

// ignore: subtype_of_sealed_class
class _FakeDocSnap extends Fake
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _FakeDocSnap(this._id, this._data);
  final String _id;
  final Map<String, dynamic> _data;

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data() => _data;
}

class _FakeQuerySnap extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  _FakeQuerySnap(this._docs);
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> _docs;

  @override
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _docs;
}

// ignore: subtype_of_sealed_class
class _FakeBackupCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _FakeBackupCollection(this.docs);
  final List<_FakeDocSnap> docs;

  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) =>
      this;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async =>
      _FakeQuerySnap(docs);
}

// ignore: subtype_of_sealed_class
class _FakeUserDoc extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _FakeUserDoc(this.backupDocs);
  final List<_FakeDocSnap> backupDocs;

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _FakeBackupCollection(backupDocs);
}

// ignore: subtype_of_sealed_class
class _FakeUsersCol extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  _FakeUsersCol(this.backupDocs);
  final List<_FakeDocSnap> backupDocs;

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) =>
      _FakeUserDoc(backupDocs);
}

class _FakeFirestore extends Fake implements FirebaseFirestore {
  final List<_FakeDocSnap> backupDocs = [];

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      _FakeUsersCol(backupDocs);
}

class _FakeStorage extends Fake implements FirebaseStorage {}

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(this.repo)
      : super(
          signUpUseCase: SignUpUseCase(repo),
          signInUseCase: SignInUseCase(repo),
          signOutUseCase: SignOutUseCase(repo),
        );

  final _FakeAuthRepo repo;

  @override
  AuthState build() => AuthState(
        isAuthenticated: repo.user != null,
        user: repo.user,
      );

  @override
  Future<void> signOut() async {
    await repo.signOut();
    state = const AuthState(isAuthenticated: false, user: null);
  }
}

void main() {
  group('Wave 2.2 — BackupDataUseCase & Settings UI Dialogs Characterization',
      () {
    test('BackupRecord roundtrips cleanly through JSON serialization', () {
      final created = DateTime.utc(2026, 3, 1, 9, 30);
      final record = BackupRecord(
        id: 'manual_1',
        createdAt: created,
        fileName: 'backup_20260301_0930.json',
        fileSize: 2048,
        cloudPath: 'users/u-1/backups/backup_20260301_0930.json',
        type: BackupType.manual,
        statistics: const {'workouts': 5, 'meals': 12},
      );

      final roundtripped = BackupRecord.fromJson(record.toJson());
      expect(roundtripped.id, 'manual_1');
      expect(roundtripped.fileSize, 2048);
      expect(roundtripped.type, BackupType.manual);
      expect(roundtripped.statistics['workouts'], 5);
    });

    test('BackupDataUseCase enforces auth/local-only guards and computes backup statistics',
        () async {
      final firestore = _FakeFirestore();
      final storage = _FakeStorage();
      final authRepo = _FakeAuthRepo(null);
      final wRepo = _EmptyWorkoutRepo();
      final nRepo = _EmptyNutritionRepo();
      final bRepo = _EmptyBodyRepo();
      final exportAll = ExportAllDataUseCase(
        wRepo,
        nRepo,
        bRepo,
        authRepo,
        ExportWorkoutsUseCase(wRepo),
        ExportNutritionUseCase(nRepo),
      );

      final useCase = BackupDataUseCase(exportAll, authRepo, firestore, storage);

      // Unauthenticated cannot list or create backups.
      await expectLater(() => useCase.getAllBackups(), throwsException);
      await expectLater(() => useCase.createManualBackup(), throwsException);

      // Local-only guest user returns empty backup list and throws UnsupportedError on upload.
      authRepo.user = User(
        id: kLocalGuestUserId,
        email: 'local@device.offline',
        displayName: 'Local Athlete',
        photoUrl: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      expect(await useCase.getAllBackups(), isEmpty);
      expect(await useCase.isBackupNeeded(), isTrue);
      await expectLater(
        () => useCase.createManualBackup(),
        throwsUnsupportedError,
      );

      // Cloud user computes statistics across stored backup docs.
      authRepo.user = User(
        id: 'cloud-1',
        email: 'athlete@ironflow.test',
        displayName: 'Cloud Athlete',
        photoUrl: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      firestore.backupDocs.addAll([
        _FakeDocSnap('b-auto', {
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'file_name': 'auto.json',
          'file_size': 1024,
          'cloud_path': 'users/cloud-1/backups/auto.json',
          'type': BackupType.automatic.toString(),
          'statistics': {'workouts': 1},
        }),
        _FakeDocSnap('b-man', {
          'created_at': DateTime.utc(2026, 1, 1).toIso8601String(),
          'file_name': 'man.json',
          'file_size': 2048,
          'cloud_path': 'users/cloud-1/backups/man.json',
          'type': BackupType.manual.toString(),
          'statistics': {'workouts': 2},
        }),
      ]);

      final stats = await useCase.getBackupStatistics();
      expect(stats['total_backups'], 2);
      expect(stats['automatic_backups'], 1);
      expect(stats['manual_backups'], 1);
      expect(stats['total_size_bytes'], 3072);
      expect(await useCase.isBackupNeeded(), isFalse);
    });

    testWidgets(
        'showExportRestoreModal validates backup JSON and dispatches restore callback',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(520, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final wRepo = _EmptyWorkoutRepo();
      final nRepo = _EmptyNutritionRepo();
      final bRepo = _EmptyBodyRepo();
      final authRepo = _FakeAuthRepo(null);
      final restoreUseCase = RestoreDataUseCase(wRepo, nRepo, bRepo, authRepo);

      String? restoredJson;
      bool? restoredOverwrite;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(extensions: [AppThemeTokens.dark]),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showExportRestoreModal(
                  context: context,
                  restoreUseCase: restoreUseCase,
                  onExecuteRestore: (json, overwrite) async {
                    restoredJson = json;
                    restoredOverwrite = overwrite;
                  },
                ),
                child: const Text('OPEN RESTORE'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('OPEN RESTORE'));
      await tester.pumpAndSettle();
      expect(find.text('SYSTEM RESTORATION PROTOCOL'), findsOneWidget);

      // Invalid JSON renders validation error.
      await tester.enterText(find.byType(TextField), '{bad json');
      await tester.pumpAndSettle();
      expect(find.textContaining('INVALID BACKUP ARCHIVE'), findsOneWidget);

      // Valid archive renders preview and MERGE DATA triggers callback.
      final validArchive = jsonEncode({
        'export_info': {
          'export_version': '2.0',
          'export_date': '2026-03-01T00:00:00.000Z',
        },
        'workouts': [],
        'nutrition_logs': [],
        'body_measurements': [],
      });
      await tester.enterText(find.byType(TextField), validArchive);
      await tester.pumpAndSettle();
      expect(find.text('VALIDATED TELEMETRY ARCHIVE'), findsOneWidget);

      await tester.ensureVisible(find.text('MERGE DATA'));
      await tester.tap(find.text('MERGE DATA'));
      await tester.pumpAndSettle();

      expect(restoredJson, validArchive);
      expect(restoredOverwrite, isFalse);
    });

    testWidgets(
        'settings dialogs render document viewer, logout flow, and state inspector',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(600, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final authRepo = _FakeAuthRepo(User(
        id: 'user-dialogs-1',
        email: 'athlete@ironflow.test',
        displayName: 'Dialog Athlete',
        photoUrl: null,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ));

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Consumer(
              builder: (ctx, ref, _) {
                final tokens = AppThemeTokens.of(ctx);
                return Scaffold(
                  body: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => showSettingsDocumentDialog(
                          ctx,
                          title: 'TERMS OF SERVICE',
                          content: kIronFlowTermsOfService,
                          tokens: tokens,
                        ),
                        child: const Text('OPEN DOCS'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            showSettingsStateInspector(ctx, ref, tokens),
                        child: const Text('OPEN INSPECTOR'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            showSettingsLogoutDialog(ctx, ref, tokens),
                        child: const Text('OPEN LOGOUT'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.login,
            builder: (context, state) => const Scaffold(body: Text('LOGIN')),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith(() => _FakeAuthNotifier(authRepo)),
          ],
          child: MaterialApp.router(
            theme: ThemeData.dark().copyWith(extensions: [AppThemeTokens.dark]),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Document dialog opens and closes cleanly.
      await tester.tap(find.text('OPEN DOCS'));
      await tester.pumpAndSettle();
      expect(find.text('TERMS OF SERVICE'), findsOneWidget);
      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();

      // State inspector opens cleanly.
      await tester.tap(find.text('OPEN INSPECTOR'));
      await tester.pumpAndSettle();
      expect(find.text('APP STATE TELEMETRY'), findsOneWidget);
      expect(find.text('AUTHENTICATED'), findsOneWidget);
      await tester.tap(find.text('DISMISS'));
      await tester.pumpAndSettle();

      // Logout dialog signs out and redirects to /login.
      await tester.tap(find.text('OPEN LOGOUT'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('LOGOUT'));
      await tester.pumpAndSettle();
      expect(authRepo.signedOut, isTrue);
      expect(find.text('LOGIN'), findsOneWidget);
    });
  });
}

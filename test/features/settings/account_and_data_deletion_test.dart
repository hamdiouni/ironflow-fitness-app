import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:progression_tracker/core/utils/secure_storage_manager.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/notifications/domain/services/notification_service.dart';
import 'package:progression_tracker/features/settings/domain/repositories/remote_data_purger.dart';
import 'package:progression_tracker/features/settings/domain/services/local_data_wiper.dart';
import 'package:progression_tracker/features/settings/domain/usecases/delete_account_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/delete_user_data_use_case.dart';

// --- FAKES & TEST DOUBLES ---

class FakeAuthRepository implements AuthRepository {
  User? currentUser;
  bool shouldThrowOnReauth = false;
  bool shouldThrowRecentLoginOnReauth = false;
  bool shouldThrowOnDeleteAccount = false;
  final List<String> callOrder = [];

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    callOrder.add('reauthenticateWithPassword');
    if (shouldThrowRecentLoginOnReauth) {
      throw Exception('requires-recent-login: Security token expired');
    }
    if (shouldThrowOnReauth || password != 'validPassword123') {
      throw Exception('Wrong password provided for that user.');
    }
  }

  @override
  Future<void> reauthenticateWithGoogle() async {
    callOrder.add('reauthenticateWithGoogle');
    if (shouldThrowRecentLoginOnReauth) {
      throw Exception('requires-recent-login: Google token expired');
    }
    if (shouldThrowOnReauth) {
      throw Exception('Google re-authentication failed');
    }
  }

  @override
  Future<void> deleteAccount() async {
    callOrder.add('deleteAccount');
    if (shouldThrowOnDeleteAccount) {
      throw Exception('Failed to delete auth user from server');
    }
    currentUser = null;
  }

  @override
  Future<void> signOut() async {
    callOrder.add('signOut');
    currentUser = null;
  }

  @override
  Future<User?> getCurrentUser() async => currentUser;

  @override
  Future<bool> isAuthenticated() async => currentUser != null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRemoteDataPurger implements RemoteDataPurger {
  final List<String> purgedUserIds = [];
  bool shouldThrow = false;
  final List<String> callOrder = [];

  @override
  Future<void> purgeRemoteUserData(String userId) async {
    callOrder.add('purgeRemoteUserData');
    if (shouldThrow) {
      throw Exception('Network offline: Unable to reach cloud database');
    }
    purgedUserIds.add(userId);
  }
}

class FakeSecureStorageManager extends SecureStorageManager {
  final Map<String, String> data = {};
  bool clearAllCalled = false;

  @override
  Future<void> saveAuthToken(String token) async => data['auth_token'] = token;

  @override
  Future<String?> getAuthToken() async => data['auth_token'];

  @override
  Future<void> saveRefreshToken(String token) async => data['refresh_token'] = token;

  @override
  Future<String?> getRefreshToken() async => data['refresh_token'];

  @override
  Future<void> saveUserId(String userId) async => data['user_id'] = userId;

  @override
  Future<String?> getUserId() async => data['user_id'];

  @override
  Future<void> clearAll() async {
    clearAllCalled = true;
    data.clear();
  }
}

class FakeNotificationService implements NotificationService {
  bool cancelAllCalled = false;

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllCalled = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempHiveDir;
  late Directory tempDocsDir;
  late FakeAuthRepository authRepo;
  late FakeRemoteDataPurger remotePurger;
  late FakeSecureStorageManager secureStorage;
  late FakeNotificationService notificationService;
  late LocalDataWiper localDataWiper;
  late DeleteAccountUseCase deleteAccountUseCase;
  late DeleteUserDataUseCase deleteUserDataUseCase;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    tempHiveDir = await Directory.systemTemp.createTemp('hive_deletion_test_');
    tempDocsDir = await Directory.systemTemp.createTemp('docs_deletion_test_');
    Hive.init(tempHiveDir.path);

    authRepo = FakeAuthRepository()
      ..currentUser = User(
        id: 'user_target_42',
        email: 'athlete@ironflow.com',
        displayName: 'Athlete',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

    remotePurger = FakeRemoteDataPurger();
    secureStorage = FakeSecureStorageManager()
      ..saveAuthToken('jwt_secret_token')
      ..saveRefreshToken('jwt_refresh_token')
      ..saveUserId('user_target_42');

    notificationService = FakeNotificationService();

    localDataWiper = LocalDataWiper(
      secureStorage: secureStorage,
      notificationService: notificationService,
      privateDocumentsDir: tempDocsDir,
    );

    deleteAccountUseCase = DeleteAccountUseCase(
      authRepository: authRepo,
      remoteDataPurger: remotePurger,
      localDataWiper: localDataWiper,
    );

    deleteUserDataUseCase = DeleteUserDataUseCase(
      localDataWiper: localDataWiper,
    );
  });

  tearDown(() async {
    await Hive.close();
    if (await tempHiveDir.exists()) {
      await tempHiveDir.delete(recursive: true);
    }
    if (await tempDocsDir.exists()) {
      await tempDocsDir.delete(recursive: true);
    }
  });

  group('REL-01 Account & Data Deletion Tests', () {
    test('1. DeleteAccountUseCase step execution order is strictly preserved', () async {
      authRepo.callOrder.clear();
      remotePurger.callOrder.clear();

      final result = await deleteAccountUseCase.call(
        userId: 'user_target_42',
        password: 'validPassword123',
      );

      expect(result.success, isTrue);

      // Verify that reauth occurred BEFORE remote purge
      expect(authRepo.callOrder.first, 'reauthenticateWithPassword');
      // Verify remote purge occurred
      expect(remotePurger.purgedUserIds, contains('user_target_42'));
      // Verify auth delete occurred after remote purge
      expect(authRepo.callOrder, contains('deleteAccount'));
      // Verify sign out occurred at the end
      expect(authRepo.callOrder.last, 'signOut');
    });

    test('2. Re-authentication failure aborts immediately and destroys ZERO data', () async {
      authRepo.shouldThrowOnReauth = true;

      // Seed a test box
      final box = await Hive.openBox('workouts');
      await box.put('w1', {'name': 'Squat Session'});

      final result = await deleteAccountUseCase.call(
        userId: 'user_target_42',
        password: 'incorrectPassword',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Wrong password'));

      // Assert zero remote purge
      expect(remotePurger.purgedUserIds, isEmpty);
      // Assert zero auth deletion
      expect(authRepo.currentUser, isNotNull);
      // Assert local data remains completely untouched
      expect(box.get('w1'), isNotNull);
      expect(secureStorage.clearAllCalled, isFalse);
    });

    test('3. requires-recent-login is caught and surfaced with flag for UI prompt', () async {
      authRepo.shouldThrowRecentLoginOnReauth = true;

      final result = await deleteAccountUseCase.call(
        userId: 'user_target_42',
        password: 'validPassword123',
      );

      expect(result.success, isFalse);
      expect(result.requiresRecentLogin, isTrue);
      expect(remotePurger.purgedUserIds, isEmpty);
    });

    test('4. Remote purge failure (e.g. offline) aborts before deleting auth or local data', () async {
      remotePurger.shouldThrow = true;

      final workoutBox = await Hive.openBox('workouts');
      await workoutBox.put('w1', {'name': 'Deadlift PR'});

      final result = await deleteAccountUseCase.call(
        userId: 'user_target_42',
        password: 'validPassword123',
      );

      expect(result.success, isFalse);
      expect(result.message, contains('Failed to purge cloud records'));

      // Auth account must NOT be deleted
      expect(authRepo.currentUser, isNotNull);
      // Local workout must NOT be wiped
      expect(workoutBox.get('w1'), isNotNull);
    });

    test('5. Local wipe completeness: clears user boxes, photos, snapshots, notifications & tokens', () async {
      // 1. Seed user-scoped boxes
      final workoutBox = await Hive.openBox('workouts');
      await workoutBox.put('w1', {'exercise': 'Bench Press'});

      final mealsBox = await Hive.openBox('meals');
      await mealsBox.put('m1', {'name': 'Oatmeal'});

      final userProfileBox = await Hive.openBox('user_profile_box_user_target_42');
      await userProfileBox.put('profile', {'age': 28});

      // 2. Seed files: snapshot, photo, export
      final snapshotsDir = Directory('${tempDocsDir.path}/safety_snapshots');
      await snapshotsDir.create(recursive: true);
      final snapshotFile = File('${snapshotsDir.path}/safety_snapshot_123.json');
      await snapshotFile.writeAsString('{"test": "snapshot"}');

      final photosDir = Directory('${tempDocsDir.path}/progress_photos');
      await photosDir.create(recursive: true);
      final photoFile = File('${photosDir.path}/photo_123.jpg');
      await photoFile.writeAsString('binary_data');

      final exportFile = File('${tempDocsDir.path}/workout_export_2026.csv');
      await exportFile.writeAsString('Date,Exercise,Weight');

      // Execute full wipe
      await localDataWiper.wipeAllUserData('user_target_42', keepAuthSession: false);

      // Assert boxes are wiped
      expect(workoutBox.isEmpty, isTrue);
      expect(mealsBox.isEmpty, isTrue);
      expect(userProfileBox.isEmpty, isTrue);

      // Assert files are deleted
      expect(await snapshotFile.exists(), isFalse);
      expect(await photoFile.exists(), isFalse);
      expect(await exportFile.exists(), isFalse);

      // Assert notifications and tokens wiped
      expect(notificationService.cancelAllCalled, isTrue);
      expect(secureStorage.clearAllCalled, isTrue);
    });

    test('6. Other-account and bundled dataset isolation: protected boxes remain intact', () async {
      // Seed target user box
      final targetUserBox = await Hive.openBox('user_profile_box_user_target_42');
      await targetUserBox.put('theme', 'dark');

      // Seed another user's box on the same device
      final otherUserBox = await Hive.openBox('user_profile_box_user_other_99');
      await otherUserBox.put('theme', 'neon');

      // Seed bundled dataset box (foods)
      final foodsBox = await Hive.openBox('foods');
      await foodsBox.put('item_chicken_breast', {'protein': 31});

      final exercisesBox = await Hive.openBox('exercises');
      await exercisesBox.put('ex_barbell_squat', {'name': 'Barbell Squat'});

      // Wipe only user_target_42
      await localDataWiper.wipeAllUserData('user_target_42', keepAuthSession: false);

      // Assert target user box wiped
      expect(targetUserBox.isEmpty, isTrue);

      // Assert other user's box is 100% UNTOUCHED
      expect(otherUserBox.get('theme'), 'neon');

      // Assert protected bundled datasets are 100% UNTOUCHED
      expect(foodsBox.get('item_chicken_breast'), isNotNull);
      expect(exercisesBox.get('ex_barbell_squat'), isNotNull);
    });

    test('7. Partial failure recovery at relaunch: pending wipe marker triggers cleanup', () async {
      final prefs = await SharedPreferences.getInstance();

      // Simulate a previous session that crashed mid-deletion, leaving a pending marker
      await prefs.setString(DeleteAccountUseCase.pendingWipeKey, 'user_crashed_77');

      final crashedUserBox = await Hive.openBox('user_profile_box_user_crashed_77');
      await crashedUserBox.put('unwiped_data', 'critical');

      // Execute startup recovery
      await DeleteAccountUseCase.checkAndExecutePendingWipe(wiper: localDataWiper);

      // Assert that recovery finished the wipe
      expect(crashedUserBox.isEmpty, isTrue);
      // Assert that marker was cleared
      expect(prefs.containsKey(DeleteAccountUseCase.pendingWipeKey), isFalse);
    });

    test('8. DeleteUserDataUseCase purges local training logs while keeping auth session', () async {
      final workoutBox = await Hive.openBox('workouts');
      await workoutBox.put('w1', {'reps': 10});

      final result = await deleteUserDataUseCase.call('user_target_42');

      expect(result.success, isTrue);
      expect(workoutBox.isEmpty, isTrue);

      // Secure storage tokens must be preserved
      expect(secureStorage.clearAllCalled, isFalse);
      expect(await secureStorage.getAuthToken(), 'jwt_secret_token');
    });
  });
}

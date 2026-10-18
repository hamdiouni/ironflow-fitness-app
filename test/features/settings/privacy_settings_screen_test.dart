import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:progression_tracker/core/constants/app_theme.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:progression_tracker/features/settings/domain/repositories/remote_data_purger.dart';
import 'package:progression_tracker/features/settings/domain/services/local_data_wiper.dart';
import 'package:progression_tracker/features/settings/domain/usecases/delete_account_use_case.dart';
import 'package:progression_tracker/features/settings/domain/usecases/delete_user_data_use_case.dart';
import 'package:progression_tracker/features/settings/presentation/providers/settings_providers.dart';
import 'package:progression_tracker/features/settings/presentation/screens/privacy_settings_screen.dart';
import 'package:progression_tracker/shared/presentation/services/app_haptics.dart';

class MockAuthRepository implements AuthRepository {
  User? user;
  bool reauthCalled = false;
  bool deleteAccountCalled = false;
  bool signOutCalled = false;

  @override
  Future<User?> getCurrentUser() async => user;

  @override
  Future<void> reauthenticateWithPassword(String password) async {
    reauthCalled = true;
    if (password != 'secret123') {
      throw Exception('Wrong password provided for that user.');
    }
  }

  @override
  Future<void> reauthenticateWithGoogle() async {}

  @override
  Future<void> deleteAccount() async {
    deleteAccountCalled = true;
    user = null;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    user = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockRemoteDataPurger implements RemoteDataPurger {
  bool purgeCalled = false;

  @override
  Future<void> purgeRemoteUserData(String userId) async {
    purgeCalled = true;
  }
}

class MockLocalDataWiper extends LocalDataWiper {
  bool wipeCalled = false;
  bool lastKeepAuthSession = false;

  @override
  Future<void> wipeAllUserData(String userId, {bool keepAuthSession = false}) async {
    wipeCalled = true;
    lastKeepAuthSession = keepAuthSession;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository mockAuthRepo;
  late MockRemoteDataPurger mockRemotePurger;
  late MockLocalDataWiper mockLocalWiper;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'analytics_enabled': true,
      'crash_reporting_enabled': true,
      'data_sharing_enabled': false,
      'ai_personalization_consent': false,
    });

    mockAuthRepo = MockAuthRepository()
      ..user = User(
        id: 'u-123',
        email: 'test@ironflow.com',
        displayName: 'Test Athlete',
        photoUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    mockRemotePurger = MockRemoteDataPurger();
    mockLocalWiper = MockLocalDataWiper();
    AppHaptics.shared = AppHaptics(isEnabled: false);
  });

  Widget createSubject() {
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepo),
        remoteDataPurgerProvider.overrideWithValue(mockRemotePurger),
        localDataWiperProvider.overrideWithValue(mockLocalWiper),
        deleteUserDataUseCaseProvider.overrideWithValue(
          DeleteUserDataUseCase(localDataWiper: mockLocalWiper),
        ),
        deleteAccountUseCaseProvider.overrideWithValue(
          DeleteAccountUseCase(
            authRepository: mockAuthRepo,
            remoteDataPurger: mockRemotePurger,
            localDataWiper: mockLocalWiper,
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.darkTheme,
        routes: {
          '/login': (context) => const Scaffold(body: Text('LOGIN SCREEN')),
        },
        home: const PrivacySettingsScreen(),
      ),
    );
  }

  group('PrivacySettingsScreen Widget & Deletion Flow Tests', () {
    testWidgets('1. Renders telemetry toggles and two danger zone deletion actions', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      expect(find.text('PRIVACY & TELEMETRY'), findsWidgets);
      expect(find.text('Diagnostics & Crash Telemetry'), findsOneWidget);
      expect(find.text('Usage Analytics'), findsOneWidget);
      expect(find.text('AI Personalization Consent'), findsOneWidget);

      expect(find.text('Purge Local Device Data'), findsOneWidget);
      expect(find.text('Delete Account & All Data'), findsOneWidget);
    });

    testWidgets('2. Purge Local Data requires typing DELETE before activating button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Purge Local Device Data'));
      await tester.pumpAndSettle();

      expect(find.text('PURGE LOCAL DEVICE DATA'), findsOneWidget);
      final confirmBtnFinder = find.widgetWithText(ElevatedButton, 'PURGE LOCAL DATA');
      expect(confirmBtnFinder, findsOneWidget);

      // Initially disabled (onPressed is null)
      final initialBtn = tester.widget<ElevatedButton>(confirmBtnFinder);
      expect(initialBtn.onPressed, isNull);

      // Type partial or lowercase "delete"
      await tester.enterText(find.byType(TextField), 'delete');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(confirmBtnFinder).onPressed, isNull);

      // Type exact "DELETE"
      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      expect(tester.widget<ElevatedButton>(confirmBtnFinder).onPressed, isNotNull);

      // Tap confirm
      await tester.tap(confirmBtnFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify Local wipe was called with keepAuthSession: true
      expect(mockLocalWiper.wipeCalled, isTrue);
      expect(mockLocalWiper.lastKeepAuthSession, isTrue);
    });

    testWidgets('3. Full Account Deletion requires DELETE and re-authentication with password', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete Account & All Data'));
      await tester.pumpAndSettle();

      expect(find.text('DELETE ACCOUNT & ALL DATA'), findsOneWidget);

      // Type DELETE in first step
      await tester.enterText(find.byType(TextField), 'DELETE');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'CONTINUE TO RE-AUTH'));
      await tester.pumpAndSettle();

      // Step 2: Re-authentication dialog appears
      expect(find.text('SECURITY RE-AUTHENTICATION'), findsOneWidget);
      expect(find.text('Confirm ownership of account test@ironflow.com before permanent deletion.'), findsOneWidget);

      // Enter correct password and confirm
      await tester.enterText(find.byType(TextField), 'secret123');
      await tester.pump();
      await tester.tap(find.widgetWithText(ElevatedButton, 'CONFIRM & DESTROY'));
      // Pump until useCase and navigation transition to /login completes
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('LOGIN SCREEN').evaluate().isNotEmpty) {
          break;
        }
      }

      // Assert re-auth, remote purge, auth delete, and local wipe occurred
      expect(mockAuthRepo.reauthCalled, isTrue);
      expect(mockRemotePurger.purgeCalled, isTrue);
      expect(mockAuthRepo.deleteAccountCalled, isTrue);
      expect(mockLocalWiper.wipeCalled, isTrue);
      expect(mockLocalWiper.lastKeepAuthSession, isFalse);
      expect(mockAuthRepo.signOutCalled, isTrue);

      // Assert navigated to login
      expect(find.text('LOGIN SCREEN'), findsOneWidget);
    });

    testWidgets('4. Opens Privacy Policy modal with valid policy URL and copy button', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Privacy Policy & Charter'));
      await tester.pumpAndSettle();

      expect(find.text('PRIVACY POLICY & TELEMETRY CHARTER'), findsOneWidget);
      expect(find.text('COPY POLICY URL'), findsOneWidget);
      expect(find.text('CLOSE'), findsOneWidget);

      await tester.tap(find.text('CLOSE'));
      await tester.pumpAndSettle();
      expect(find.text('PRIVACY POLICY & TELEMETRY CHARTER'), findsNothing);
    });

    testWidgets('5. Layout resilience: 360dp width and 1.5x text scale does not overflow', (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 740 * 2);
      tester.view.devicePixelRatio = 2.0;

      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            textScaler: TextScaler.linear(1.5),
            size: Size(360, 740),
          ),
          child: createSubject(),
        ),
      );
      await tester.pumpAndSettle();

      // No overflow exception thrown
      expect(tester.takeException(), isNull);

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    });
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_provider.dart';
import 'package:progression_tracker/features/notifications/domain/services/notification_service.dart';
import 'package:progression_tracker/features/notifications/presentation/providers/notification_providers.dart';

class _FakeAuthRepository implements AuthRepository {
  bool failSignOut = false;

  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<void> signOut() async {
    if (failSignOut) throw Exception('sign out failed');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _RecordingNotificationService implements NotificationService {
  _RecordingNotificationService(this.events);

  final List<String> events;
  int cancelAllCalls = 0;

  @override
  Future<void> cancelAllNotifications() async {
    cancelAllCalls++;
    events.add('cancelAll');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late List<String> events;
  late _FakeAuthRepository repository;
  late _RecordingNotificationService notifications;
  late ProviderContainer container;

  setUp(() {
    events = <String>[];
    repository = _FakeAuthRepository();
    notifications = _RecordingNotificationService(events);
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<void> startListening() async {
    container.read(authNotifierProvider);
    // Let the initial session check settle before recording.
    await Future<void>.delayed(Duration.zero);
    events.clear();
    final subscription = container.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        if (next.isLoading) {
          events.add('state:loading');
        } else if (next.user == null) {
          events.add('state:signedOut');
        }
      },
    );
    addTearDown(subscription.close);
  }

  test('sign-out cancels scheduled reminders before the user state clears',
      () async {
    await startListening();

    await container.read(authNotifierProvider.notifier).signOut();

    expect(notifications.cancelAllCalls, 1);
    // Cancel must finish before the signed-out state is published, so the
    // next scope (guest/other account) reschedules from its own settings
    // afterwards instead of being wiped by a late cancel.
    expect(
      events,
      <String>['state:loading', 'cancelAll', 'state:signedOut'],
    );
  });

  test('failed sign-out leaves reminders scheduled', () async {
    await startListening();
    repository.failSignOut = true;

    await expectLater(
      container.read(authNotifierProvider.notifier).signOut(),
      throwsException,
    );

    expect(notifications.cancelAllCalls, 0);
  });
}

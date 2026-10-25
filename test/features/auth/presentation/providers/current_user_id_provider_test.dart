import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:progression_tracker/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:progression_tracker/features/auth/presentation/providers/auth_notifier.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<User?> getCurrentUser() async => null;

  @override
  Future<bool> isAuthenticated() async => false;

  @override
  Future<void> signOut() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAuthNotifier extends AuthNotifier {
  _TestAuthNotifier({
    required Ref ref,
    required AuthRepository repository,
  }) : super(
          signUpUseCase: SignUpUseCase(repository),
          signInUseCase: SignInUseCase(repository),
          signOutUseCase: SignOutUseCase(repository),
          ref: ref,
        );

  void setUser(User? user) {
    state = AuthState(
      user: user,
      isAuthenticated: user != null,
    );
  }
}

void main() {
  late ProviderContainer container;
  late _TestAuthNotifier authNotifier;

  User user(String id) {
    return User(
      id: id,
      email: '$id@example.com',
      displayName: id,
      photoUrl: null,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
  }

  setUp(() {
    container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWith((ref) {
          authNotifier = _TestAuthNotifier(
            ref: ref,
            repository: _FakeAuthRepository(),
          );
          return authNotifier;
        }),
      ],
    );
    container.read(authNotifierProvider);
  });

  tearDown(() {
    container.dispose();
  });

  test('currentUserIdProvider is null while signed out', () {
    expect(container.read(currentUserIdProvider), isNull);

    authNotifier.setUser(user('Alice'));

    expect(container.read(currentUserIdProvider), 'Alice');
  });

  test('currentUserIdProvider follows account switch and sign out', () async {
    final seen = <String?>[];
    final subscription = container.listen<String?>(
      currentUserIdProvider,
      (previous, next) => seen.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    authNotifier.setUser(user('Alice'));
    await Future<void>.delayed(Duration.zero);
    authNotifier.setUser(user('bob'));
    await Future<void>.delayed(Duration.zero);
    authNotifier.setUser(null);
    await Future<void>.delayed(Duration.zero);

    expect(seen, <String?>[null, 'Alice', 'bob', null]);
    expect(container.read(currentUserIdProvider), isNull);
  });
}

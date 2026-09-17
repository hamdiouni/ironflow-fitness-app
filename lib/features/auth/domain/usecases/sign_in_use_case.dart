import 'package:progression_tracker/features/auth/domain/entities/user.dart';
import 'package:progression_tracker/features/auth/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<User> call({
    required String email,
    required String password,
  }) async {
    return repository.signInWithEmail(
      email: email,
      password: password,
    );
  }
}

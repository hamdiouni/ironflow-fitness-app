import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in with Apple
class SignInWithAppleUseCase {
  final AuthRepository _repository;

  SignInWithAppleUseCase(this._repository);

  Future<User> call() async {
    return await _repository.signInWithApple();
  }
}
